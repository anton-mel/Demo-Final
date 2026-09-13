// malloc.rs (ported from uspace/malloc.c + uspace/malloc.h)
//
//    A dynamic memory allocator for WeensyOS user processes, built on
//    top of brk/sbrk (see weensyos_process::{brk, sbrk} and
//    kernel::sbrk).
//
//    Design note: this is deliberately NOT a pointer-linked free list.
//    The heap is an *implicit* free list (per the assignment spec) --
//    each block's own header says how big it is, so walking the list
//    just means "jump forward by header + size," with no next/prev
//    pointers to maintain at all. That plus one more idea -- treating
//    "the heap" as a plain `&mut [u8]` (byte offsets in, byte offsets
//    out) rather than as raw pointers you chase and cast -- means
//    almost this entire file is ordinary safe slice/arithmetic code.
//    The only genuinely unsafe operations are (1) turning the
//    kernel-given heap base address into a `&mut [u8]` view in the
//    first place, and (2) handing back/reinterpreting the couple of
//    `'static` slices `heap_info` returns -- both isolated in small,
//    clearly-commented spots below. `malloc`/`calloc`/`defrag` are
//    fully safe functions; only `free`/`realloc` are `unsafe fn`,
//    matching the real safety contract (a bad pointer there is
//    genuinely undefined behavior, same as in C).
#![no_std]

use core::ptr::NonNull;
use core::sync::atomic::{AtomicU64, Ordering};
use weensyos_process::sbrk;

// Block header layout (8 bytes, matching this allocator's 8-byte
// alignment): byte 0 is the block's state tag; bytes 4..8 are its
// payload size (not including this header) as a little-endian u32.
const HEADER: usize = 8;
const ALIGN: u64 = 8;
const MIN_PAYLOAD: u32 = 8; // don't bother splitting off slivers smaller than this

const FREE: u8 = 0;
const USED: u8 = 1;
const INTERNAL: u8 = 2; // this library's own bookkeeping (heap_info's arrays)

// The address `sbrk(0)` first returned, i.e. where this process's heap
// begins. An `AtomicU64` (instead of a `static mut`) so reading/writing
// it never needs an `unsafe` block -- there's only one thread per
// process here, so `Relaxed` ordering is all that's needed.
static HEAP_BASE: AtomicU64 = AtomicU64::new(0);

fn ensure_base() -> u64 {
    let base = HEAP_BASE.load(Ordering::Relaxed);
    if base != 0 {
        return base;
    }
    let base = sbrk(0);
    HEAP_BASE.store(base, Ordering::Relaxed);
    base
}

fn align_up(sz: u64) -> Option<u32> {
    let aligned = (sz.max(1) + ALIGN - 1) & !(ALIGN - 1);
    u32::try_from(aligned).ok()
}

fn read_header(heap: &[u8], off: usize) -> (u8, u32) {
    (heap[off], u32::from_le_bytes(heap[off + 4..off + 8].try_into().unwrap()))
}

fn write_header(heap: &mut [u8], off: usize, state: u8, size: u32) {
    heap[off] = state;
    heap[off + 4..off + 8].copy_from_slice(&size.to_le_bytes());
}

// with_heap(f)
//    Runs `f` against a byte-level view of the heap raised so far
//    (from the first break to the current one). This is the only place
//    that constructs a slice from a raw address -- everywhere else,
//    "the heap" is just `&mut [u8]`, and every block header/free-list
//    walk below is ordinary safe indexing into it.
fn with_heap<R>(f: impl FnOnce(&mut [u8]) -> R) -> R {
    let base = ensure_base();
    let len = (sbrk(0) - base) as usize;
    // SAFETY: [base, base + len) is exactly the range this process's
    // own `sbrk` calls have carved out as heap; nothing else in this
    // process touches it, and only one `&mut [u8]` view of it is ever
    // alive at a time (this function doesn't call back into itself).
    let heap = unsafe { core::slice::from_raw_parts_mut(base as *mut u8, len) };
    f(heap)
}

// grow(extra)
//    Extends the heap by at least `extra` bytes via `sbrk`, returning
//    the offset (into the view `with_heap` exposes) where the new
//    space begins, or `None` if `sbrk` failed (out of address space).
fn grow(extra: u32) -> Option<usize> {
    let base = ensure_base();
    let old_top = sbrk(extra as i64);
    if old_top == u64::MAX {
        return None;
    }
    Some((old_top - base) as usize)
}

fn make_ptr(off: usize) -> Option<NonNull<u8>> {
    let addr = HEAP_BASE.load(Ordering::Relaxed) + off as u64 + HEADER as u64;
    NonNull::new(addr as *mut u8)
}

fn offset_of(ptr: NonNull<u8>) -> usize {
    (ptr.as_ptr() as u64 - HEAP_BASE.load(Ordering::Relaxed)) as usize - HEADER
}

fn find_fit(heap: &[u8], want: u32) -> Option<usize> {
    let mut off = 0;
    while off + HEADER <= heap.len() {
        let (state, size) = read_header(heap, off);
        if state == FREE && size >= want {
            return Some(off);
        }
        off += HEADER + size as usize;
    }
    None
}

// Marks the block at `off` used for `want` bytes, splitting off a new
// free block from the leftover space when that leftover is large
// enough to be worth tracking on its own.
fn take_block(heap: &mut [u8], off: usize, want: u32) {
    let (_, size) = read_header(heap, off);
    let remainder = size - want;
    if remainder >= HEADER as u32 + MIN_PAYLOAD {
        write_header(heap, off, USED, want);
        write_header(heap, off + HEADER + want as usize, FREE, remainder - HEADER as u32);
    } else {
        write_header(heap, off, USED, size);
    }
}

// malloc(sz)
//    Allocates `sz` bytes of uninitialized memory and returns a pointer
//    to it (8-byte aligned), first-fit over the implicit free list,
//    growing the heap via `sbrk` when nothing already free is big
//    enough. `sz == 0` still returns a real, unique, freeable block.
pub fn malloc(sz: u64) -> Option<NonNull<u8>> {
    let want = align_up(sz)?;
    if let Some(off) = with_heap(|heap| find_fit(heap, want)) {
        with_heap(|heap| take_block(heap, off, want));
        return make_ptr(off);
    }
    let off = grow(HEADER as u32 + want)?;
    with_heap(|heap| write_header(heap, off, USED, want));
    make_ptr(off)
}

// calloc(num, sz)
//    Like `malloc(num * sz)`, zeroed, with overflow-checked multiplication.
pub fn calloc(num: u64, sz: u64) -> Option<NonNull<u8>> {
    let total = num.checked_mul(sz)?;
    let ptr = malloc(total)?;
    with_heap(|heap| {
        let off = offset_of(ptr);
        let (_, size) = read_header(heap, off);
        heap[off + HEADER..off + HEADER + size as usize].fill(0);
    });
    Some(ptr)
}

// free(ptr)
//    Frees the memory pointed to by `ptr`. Does nothing if `ptr` is
//    `None`.
///
/// # Safety
/// `ptr`, when `Some`, must be a still-live allocation from this
/// library.
pub unsafe fn free(ptr: Option<NonNull<u8>>) {
    let Some(ptr) = ptr else { return };
    with_heap(|heap| {
        let off = offset_of(ptr);
        let (_, size) = read_header(heap, off);
        write_header(heap, off, FREE, size);
    });
}

// realloc(ptr, sz)
//    Changes the size of the block at `ptr` to `sz` bytes, preserving
//    contents up to the smaller of the old and new sizes. `None` for
//    `ptr` is equivalent to `malloc(sz)`; `sz == 0` with `Some(ptr)` is
//    equivalent to `free(ptr)`.
///
/// # Safety
/// `ptr`, when `Some`, must be a still-live allocation from this
/// library.
pub unsafe fn realloc(ptr: Option<NonNull<u8>>, sz: u64) -> Option<NonNull<u8>> {
    let Some(old) = ptr else { return malloc(sz) };
    if sz == 0 {
        free(Some(old));
        return None;
    }
    let want = align_up(sz)?;
    let off = offset_of(old);
    let old_size = with_heap(|heap| read_header(heap, off).1);
    if want <= old_size {
        with_heap(|heap| take_block(heap, off, want));
        return Some(old);
    }
    let new_ptr = malloc(sz)?;
    with_heap(|heap| {
        let new_off = offset_of(new_ptr);
        let copy_len = old_size.min(want) as usize;
        heap.copy_within(off + HEADER..off + HEADER + copy_len, new_off + HEADER);
    });
    free(Some(old));
    Some(new_ptr)
}

// defrag()
//    Coalesces every run of adjacent free blocks into one.
pub fn defrag() {
    with_heap(|heap| {
        let mut off = 0;
        while off + HEADER <= heap.len() {
            let (state, size) = read_header(heap, off);
            if state != FREE {
                off += HEADER + size as usize;
                continue;
            }
            let mut total = size;
            let mut next = off + HEADER + size as usize;
            while next + HEADER <= heap.len() {
                let (nstate, nsize) = read_header(heap, next);
                if nstate != FREE {
                    break;
                }
                total += HEADER as u32 + nsize;
                next += HEADER + nsize as usize;
            }
            write_header(heap, off, FREE, total);
            off = next;
        }
    });
}

// HeapInfo (ported from malloc.h's heap_info_struct)
//    Filled in by `heap_info` for debugging/reporting. Unlike the
//    reference struct (a raw `*mut i64`/`*mut *mut u8` pair the caller
//    has to bounds-check by hand), `sizes`/`ptrs` are plain slices --
//    their own length IS the allocation count, and `ptrs` reports
//    addresses as `u64` rather than raw pointers, since nothing here
//    ever needs to dereference them (only compare/report them). Free
//    the two backing arrays with `heap_info_free` when done with them.
pub struct HeapInfo {
    /// Sizes of currently live allocations, descending.
    pub sizes: &'static [i64],
    /// Addresses of the same allocations, in the same order as `sizes`.
    pub ptrs: &'static [u64],
    /// Total free bytes currently available in the heap (metadata bytes
    /// don't count as free space).
    pub free_space: i32,
    /// Size of the single largest free chunk currently available.
    pub largest_free_chunk: i32,
}

// heap_info()
//    Returns `None` if the library couldn't allocate space for its own
//    bookkeeping arrays (nothing is left partially allocated in that
//    case). Otherwise returns a `HeapInfo` describing every live
//    allocation; free it with `heap_info_free` once you're done reading it.
pub fn heap_info() -> Option<HeapInfo> {
    // Pass 1: count live allocations and free-space stats. Read-only,
    // so nothing here can disturb the counts pass 2 relies on.
    let (num_used, free_space, largest) = with_heap(|heap| {
        let mut off = 0;
        let (mut num_used, mut free_space, mut largest) = (0u32, 0i64, 0i64);
        while off + HEADER <= heap.len() {
            let (state, size) = read_header(heap, off);
            match state {
                USED => num_used += 1,
                FREE => {
                    free_space += size as i64;
                    largest = largest.max(size as i64);
                }
                _ => {}
            }
            off += HEADER + size as usize;
        }
        (num_used, free_space, largest)
    });

    if num_used == 0 {
        return Some(HeapInfo { sizes: &[], ptrs: &[], free_space: free_space as i32, largest_free_chunk: largest as i32 });
    }

    // Pass 2: allocate the two bookkeeping arrays up front, tagged
    // INTERNAL (not USED) so pass 3's scan skips over them -- they
    // describe *other* allocations, they aren't one themselves.
    let sizes_ptr = malloc((num_used as u64) * 8)?;
    let ptrs_ptr = match malloc((num_used as u64) * 8) {
        Some(p) => p,
        None => {
            unsafe { free(Some(sizes_ptr)) };
            return None;
        }
    };
    // `offset_of` gives each block's *header* offset; the arrays
    // themselves start `HEADER` bytes further in, at the payload.
    let (sizes_hdr, ptrs_hdr) = (offset_of(sizes_ptr), offset_of(ptrs_ptr));
    let (sizes_off, ptrs_off) = (sizes_hdr + HEADER, ptrs_hdr + HEADER);

    with_heap(|heap| {
        let (_, sz) = read_header(heap, sizes_hdr);
        write_header(heap, sizes_hdr, INTERNAL, sz);
        let (_, sz) = read_header(heap, ptrs_hdr);
        write_header(heap, ptrs_hdr, INTERNAL, sz);

        // Pass 3: walk again, inserting each live allocation into its
        // sorted (descending by size) slot by shifting later entries
        // up -- an insertion sort done in place as we go, needing no
        // scratch heap allocation at all (just two 8-byte stack temps).
        let mut off = 0;
        let mut count = 0usize;
        while off + HEADER <= heap.len() {
            let (state, size) = read_header(heap, off);
            if state == USED {
                let addr = HEAP_BASE.load(Ordering::Relaxed) + off as u64 + HEADER as u64;
                let mut pos = count;
                while pos > 0 {
                    let cur = i64::from_le_bytes(heap[sizes_off + (pos - 1) * 8..sizes_off + pos * 8].try_into().unwrap());
                    if cur >= size as i64 {
                        break;
                    }
                    let s: [u8; 8] = heap[sizes_off + (pos - 1) * 8..sizes_off + pos * 8].try_into().unwrap();
                    heap[sizes_off + pos * 8..sizes_off + (pos + 1) * 8].copy_from_slice(&s);
                    let p: [u8; 8] = heap[ptrs_off + (pos - 1) * 8..ptrs_off + pos * 8].try_into().unwrap();
                    heap[ptrs_off + pos * 8..ptrs_off + (pos + 1) * 8].copy_from_slice(&p);
                    pos -= 1;
                }
                heap[sizes_off + pos * 8..sizes_off + (pos + 1) * 8].copy_from_slice(&(size as i64).to_le_bytes());
                heap[ptrs_off + pos * 8..ptrs_off + (pos + 1) * 8].copy_from_slice(&addr.to_le_bytes());
                count += 1;
            }
            off += HEADER + size as usize;
        }
    });

    // SAFETY: [sizes_off, sizes_off + num_used*8) and the matching ptrs
    // range were just written above as valid i64/u64 arrays, and stay
    // live (INTERNAL, not reused) until `heap_info_free` frees them.
    let sizes = unsafe { core::slice::from_raw_parts(sizes_ptr.as_ptr() as *const i64, num_used as usize) };
    let ptrs = unsafe { core::slice::from_raw_parts(ptrs_ptr.as_ptr() as *const u64, num_used as usize) };
    Some(HeapInfo { sizes, ptrs, free_space: free_space as i32, largest_free_chunk: largest as i32 })
}

// heap_info_free(info)
//    Frees the bookkeeping arrays inside `info` (not the live
//    allocations they describe). Safe to call even on an empty
//    `HeapInfo` (e.g. from `num_allocs == 0`).
pub fn heap_info_free(info: HeapInfo) {
    if info.sizes.is_empty() {
        return;
    }
    unsafe {
        free(NonNull::new(info.sizes.as_ptr() as *mut u8));
        free(NonNull::new(info.ptrs.as_ptr() as *mut u8));
    }
}
