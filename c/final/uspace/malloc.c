#include "malloc.h"

// malloc.c
//
//    A first-fit, implicit-free-list dynamic memory allocator, built on
//    top of sbrk. Every block in the heap -- free, allocated, or
//    internal (this library's own bookkeeping) -- starts with a
//    `block_header` immediately followed by its payload. There are no
//    separate free-list pointers stored inside free blocks (unlike a
//    typical *explicit* free list): finding a block just means walking
//    the heap sequentially, header to header, via each header's own
//    `size` field.

#define ALIGN 8

typedef enum block_state {
    BLOCK_FREE = 0,
    // Allocated by this library for its own bookkeeping (heap_info's
    // size_array/ptr_array/sort scratch space) -- excluded from
    // num_allocs, free_space, and largest_free_chunk.
    BLOCK_INTERNAL = 1,
    // Handed to a caller of malloc/calloc/realloc.
    BLOCK_USED = 2,
} block_state_t;

typedef struct block_header {
    uint8_t state;    // a block_state_t
    uint8_t slop;     // BLOCK_USED only: padding bytes between the
                       // requested size and this block's usable size
    uint16_t reserved;
    uint32_t size;    // total block size in bytes, header included
} block_header;

static int initialized = 0;
static void *managed_memory_start;
static void *last_valid_address;

static uint64_t round_up(uint64_t a, uint64_t n) {
    return (a + n - 1) / n * n;
}

static void init(void) {
    if (!initialized) {
        managed_memory_start = sbrk(0);
        last_valid_address = managed_memory_start;
        initialized = 1;
    }
}

static block_header *header_at(void *ptr) {
    return (block_header *) ptr;
}

static void *payload_of(block_header *h) {
    return (void *) ((uint8_t *) h + sizeof(block_header));
}

static block_header *header_of(void *payload) {
    return (block_header *) ((uint8_t *) payload - sizeof(block_header));
}

// malloc(sz)
//    See malloc.h. Walks the heap first-fit; if no free block is big
//    enough, grows the heap via sbrk and places the new block at the
//    old end.
void *malloc(uint64_t sz) {
    if (sz == 0) {
        return NULL;
    }
    init();

    uint64_t rounded = round_up(sz, ALIGN);
    uint8_t slop = (uint8_t) (rounded - sz);
    uint64_t block_size = rounded + sizeof(block_header);

    uint8_t *cur = (uint8_t *) managed_memory_start;
    while ((void *) cur < last_valid_address) {
        block_header *h = header_at(cur);
        if (h->state == BLOCK_FREE && h->size >= block_size) {
            uint32_t remainder = h->size - (uint32_t) block_size;
            if (remainder >= 16) {
                // Split: the tail becomes its own free block.
                block_header *next = header_at(cur + block_size);
                next->state = BLOCK_FREE;
                next->size = remainder;
                h->size = (uint32_t) block_size;
                h->state = BLOCK_USED;
                h->slop = slop;
            } else {
                // Remainder too small to be its own block -- hand the
                // whole thing over, folding the extra bytes into `slop`
                // (this is why remainder must fit in a uint8_t here: the
                // `< 16` guard above guarantees it always does).
                h->state = BLOCK_USED;
                h->slop = (uint8_t) remainder;
            }
            return payload_of(h);
        }
        cur += h->size;
    }

    if (sbrk((intptr_t) block_size) == (void *) -1) {
        return NULL;
    }
    block_header *h = header_at((uint8_t *) last_valid_address);
    last_valid_address = (uint8_t *) last_valid_address + block_size;
    h->state = BLOCK_USED;
    h->slop = slop;
    h->size = (uint32_t) block_size;
    return payload_of(h);
}

// calloc(num, sz)
//    See malloc.h.
void *calloc(uint64_t num, uint64_t sz) {
    if (num == 0 || sz == 0) {
        return NULL;
    }
    if (num > (uint64_t) -1 / sz) {
        return NULL; // would overflow num * sz
    }
    uint64_t total = num * sz;
    void *ptr = malloc(total);
    if (ptr != NULL) {
        memset(ptr, 0, total);
    }
    return ptr;
}

// free(ptr)
//    See malloc.h.
void free(void *ptr) {
    if (ptr == NULL) {
        return;
    }
    header_of(ptr)->state = BLOCK_FREE;
}

// realloc(ptr, sz)
//    See malloc.h. Unlike a naive port, this branches on `ptr == NULL`
//    before ever computing a header offset from it, so there's no
//    equivalent of the classic bug where `ptr - sizeof(header)` gets
//    computed even when `ptr` is NULL.
void *realloc(void *ptr, uint64_t sz) {
    if (ptr == NULL) {
        return malloc(sz);
    }
    if (sz == 0) {
        free(ptr);
        return NULL;
    }

    block_header *old_h = header_of(ptr);
    uint64_t old_usable = old_h->size - sizeof(block_header) - old_h->slop;
    void *new_ptr = malloc(sz);
    if (new_ptr == NULL) {
        return NULL;
    }
    memcpy(new_ptr, ptr, old_usable < sz ? old_usable : sz);
    free(ptr);
    return new_ptr;
}

// defrag()
//    See malloc.h. Coalesces every run of adjacent free blocks into
//    one, in a single forward pass. Only runs when explicitly called --
//    malloc/free never coalesce on their own.
void defrag(void) {
    uint8_t *cur = (uint8_t *) managed_memory_start;
    while ((void *) cur < last_valid_address) {
        block_header *h = header_at(cur);
        if (h->state == BLOCK_FREE) {
            uint8_t *next = cur + h->size;
            while ((void *) next < last_valid_address) {
                block_header *nh = header_at(next);
                if (nh->state != BLOCK_FREE) {
                    break;
                }
                next += nh->size;
            }
            if (next != cur + h->size) {
                h->size = (uint32_t) (next - cur);
            }
        }
        cur += h->size;
    }
}

// merge_sort_descending / merge (helpers for heap_info)
//    Sorts `sizes` into descending order, applying the same swaps to
//    `ptrs` so `ptrs[i]` still names the allocation `sizes[i]`
//    describes. O(n log n) worst case, better than the O(n^2) the
//    assignment explicitly allows -- scratch space for the merge is
//    itself heap_info's problem to arrange (see below), not this
//    function's.

static void merge(long *sizes, void **ptrs, long *tmp_sizes, void **tmp_ptrs, int lo, int mid, int hi) {
    int i = lo, j = mid, k = lo;
    while (i < mid && j < hi) {
        if (sizes[i] >= sizes[j]) {
            tmp_sizes[k] = sizes[i];
            tmp_ptrs[k] = ptrs[i];
            i++;
        } else {
            tmp_sizes[k] = sizes[j];
            tmp_ptrs[k] = ptrs[j];
            j++;
        }
        k++;
    }
    while (i < mid) {
        tmp_sizes[k] = sizes[i];
        tmp_ptrs[k] = ptrs[i];
        i++;
        k++;
    }
    while (j < hi) {
        tmp_sizes[k] = sizes[j];
        tmp_ptrs[k] = ptrs[j];
        j++;
        k++;
    }
    for (int x = lo; x < hi; x++) {
        sizes[x] = tmp_sizes[x];
        ptrs[x] = tmp_ptrs[x];
    }
}

static void merge_sort_descending(long *sizes, void **ptrs, long *tmp_sizes, void **tmp_ptrs, int lo, int hi) {
    if (hi - lo <= 1) {
        return;
    }
    int mid = lo + (hi - lo) / 2;
    merge_sort_descending(sizes, ptrs, tmp_sizes, tmp_ptrs, lo, mid);
    merge_sort_descending(sizes, ptrs, tmp_sizes, tmp_ptrs, mid, hi);
    merge(sizes, ptrs, tmp_sizes, tmp_ptrs, lo, mid, hi);
}

// sort_descending(sizes, ptrs, n)
//    Sorts the two parallel arrays descending by `sizes`. Tries to get
//    O(n log n) merge-sort scratch space via malloc (marking it
//    internal so it doesn't itself show up in a later heap_info call,
//    and freeing it before returning); if the heap is too tight for
//    that, falls back to an in-place O(n^2) selection sort rather than
//    fail outright -- correctness over performance in that rare case.
static void sort_descending(long *sizes, void **ptrs, int n) {
    long *tmp_sizes = (long *) malloc(sizeof(long) * (uint64_t) n);
    void **tmp_ptrs = (void **) malloc(sizeof(void *) * (uint64_t) n);
    if (tmp_sizes != NULL && tmp_ptrs != NULL) {
        header_of(tmp_sizes)->state = BLOCK_INTERNAL;
        header_of(tmp_ptrs)->state = BLOCK_INTERNAL;
        merge_sort_descending(sizes, ptrs, tmp_sizes, tmp_ptrs, 0, n);
    } else {
        for (int i = 0; i < n; i++) {
            int max_idx = i;
            for (int j = i + 1; j < n; j++) {
                if (sizes[j] > sizes[max_idx]) {
                    max_idx = j;
                }
            }
            if (max_idx != i) {
                long ts = sizes[i];
                sizes[i] = sizes[max_idx];
                sizes[max_idx] = ts;
                void *tp = ptrs[i];
                ptrs[i] = ptrs[max_idx];
                ptrs[max_idx] = tp;
            }
        }
    }
    free(tmp_sizes);
    free(tmp_ptrs);
}

// heap_info(info)
//    See malloc.h. Two passes over the heap: the first just counts live
//    allocations (to size the output arrays); the second, run only
//    after those two arrays exist and are marked BLOCK_INTERNAL,
//    populates them and computes free_space/largest_free_chunk --
//    BLOCK_INTERNAL blocks (including the two arrays themselves)
//    contribute to neither count, which is exactly what "deduct their
//    space from free_space" means here: their bytes are simply excluded
//    from every total.
int heap_info(heap_info_struct *info) {
    if (!initialized) {
        memset(info, 0, sizeof(*info));
        return -1;
    }

    int num_allocs = 0;
    uint8_t *cur = (uint8_t *) managed_memory_start;
    while ((void *) cur < last_valid_address) {
        block_header *h = header_at(cur);
        if (h->state == BLOCK_USED) {
            num_allocs++;
        }
        cur += h->size;
    }

    long *size_array = NULL;
    void **ptr_array = NULL;
    if (num_allocs > 0) {
        size_array = (long *) malloc(sizeof(long) * (uint64_t) num_allocs);
        ptr_array = (void **) malloc(sizeof(void *) * (uint64_t) num_allocs);
        if (size_array == NULL || ptr_array == NULL) {
            free(size_array);
            free(ptr_array);
            memset(info, 0, sizeof(*info));
            return -1;
        }
        header_of(size_array)->state = BLOCK_INTERNAL;
        header_of(ptr_array)->state = BLOCK_INTERNAL;
    }

    int free_space = 0;
    int largest_free_chunk = 0;
    int index = 0;
    cur = (uint8_t *) managed_memory_start;
    while ((void *) cur < last_valid_address) {
        block_header *h = header_at(cur);
        if (h->state == BLOCK_USED) {
            size_array[index] = (long) (h->size - sizeof(block_header) - h->slop);
            ptr_array[index] = payload_of(h);
            index++;
        } else if (h->state == BLOCK_FREE) {
            free_space += (int) h->size;
            if ((int) h->size > largest_free_chunk) {
                largest_free_chunk = (int) h->size;
            }
        }
        cur += h->size;
    }
    assert(index == num_allocs);

    if (num_allocs > 0) {
        sort_descending(size_array, ptr_array, num_allocs);
    }

    info->num_allocs = num_allocs;
    info->size_array = size_array;
    info->ptr_array = ptr_array;
    info->free_space = free_space;
    info->largest_free_chunk = largest_free_chunk;
    return 0;
}
