// malloc.rs (ported from uspace/malloc.c + uspace/malloc.h)
//
//    A dynamic memory allocator for WeensyOS user processes, built on
//    top of brk/sbrk (see uspace/process's `brk`/`sbrk` and
//    kernel::sbrk).
//
//    This assignment's free list is *implicit*: every block already
//    stores its own size in a header at its start, so "the next block"
//    is always just `offset + size` -- there is no linked list of raw
//    pointers to build or maintain anywhere. That means the entire
//    allocator can be written as a `&mut [u8]` view of the heap
//    addressed by plain `usize`/`u64` offsets, with `unsafe` confined
//    to a handful of small, single-purpose primitives at the bottom of
//    this file (turning a raw address into that byte slice, and
//    reading/writing a header or a result array through it) -- `malloc`,
//    `calloc`, `defrag`, and `heap_info` are all fully safe functions
//    built on top of those. `free`/`realloc` are `unsafe fn` only
//    because their contract genuinely requires trusting the caller's
//    pointer, exactly as in C.
#![no_std]

use core::mem::size_of;
use core::ptr::NonNull;
use core::sync::atomic::{AtomicU64, Ordering};
use weensyos_process::sbrk;
use weensyos_shared::round_up;

// This crate doesn't have kernel.rs's PAGESIZE in scope (different
// crate entirely), so it gets its own copy of the constant -- same
// pattern already used by the p-allocator/p-malloc uspace programs.
const PAGESIZE: u64 = 4096;

// ---------------------------------------------------------------------
// Block header
// ---------------------------------------------------------------------

/// A block is either free, in active use by the caller, or `Internal`
/// -- this library's own bookkeeping allocations (`heap_info`'s result
/// arrays, and its own sorting scratch space). `Internal` blocks are
/// excluded from `num_allocs`/`free_space`/`largest_free_chunk`, same
/// as the reference C allocator's `INTERNAL` sentinel -- but as a real
/// enum variant here instead of a magic value sharing one field with a
/// byte count (the reference's `is_available` is simultaneously a
/// free/internal flag *and*, for used blocks, a slop-byte count,
/// depending which range it falls in).
#[repr(u8)]
#[derive(Clone, Copy, PartialEq, Eq)]
enum BlockState {
    Free,
    Used,
    Internal,
}

/// A block's metadata, stored at its own start. `size` is the size of
/// the *entire* block, header included, so the next block is always
/// `offset + size` -- this is what makes the free list implicit.
/// `#[repr(C)]` naturally lays this out as 1 byte of `state`, 7 bytes
/// of padding, then an 8-byte-aligned `size` -- 16 bytes total, so any
/// payload placed immediately after a header is automatically 8-byte
/// aligned as long as the heap's own base address is (it is: `sbrk`
/// only ever hands back page-aligned addresses here).
#[repr(C)]
#[derive(Clone, Copy)]
struct Header {
    state: BlockState,
    size: u64,
}

const HEADER_SIZE: u64 = size_of::<Header>() as u64;
// Below this remainder, splitting a block would leave a free fragment
// too small to even hold its own header -- fold it into the allocation
// instead (over-allocating by at most one header's worth of bytes),
// same rule and threshold as the reference C allocator.
const MIN_SPLIT: u64 = HEADER_SIZE;

// ---------------------------------------------------------------------
// Heap state
// ---------------------------------------------------------------------

// Where this process's heap begins, and the highest address `sbrk` has
// handed back so far. `AtomicU64` (not `static mut`) so reading or
// writing either needs no `unsafe` block -- there's only one thread per
// process here, so `Relaxed` ordering is all that's needed.
//
// `HEAP_TOP` is a local cache of the break, updated only when *we* call
// `sbrk` to grow it -- re-querying the real break via an actual
// `sbrk(0)` *syscall* on every single malloc/calloc/free/realloc would
// mean paying a full kernel trap (register save, `exception()`'s own
// `check_virtual_memory()` and VGA-memviewer redraw, a keyboard check)
// just to ask a question this library already knows the answer to.
static HEAP_BASE: AtomicU64 = AtomicU64::new(0);
static HEAP_TOP: AtomicU64 = AtomicU64::new(0);

fn ensure_init() -> (u64, u64) {
    let base = HEAP_BASE.load(Ordering::Relaxed);
    if base != 0 {
        return (base, HEAP_TOP.load(Ordering::Relaxed));
    }
    let base = sbrk(0);
    HEAP_BASE.store(base, Ordering::Relaxed);
    HEAP_TOP.store(base, Ordering::Relaxed);
    (base, base)
}

/// Grows the heap by at least `min_extra` bytes (rounded up to a page,
/// since that's what a real `sbrk` call costs a kernel trap for
/// regardless of how small the request is) and formats the new space
/// as one free block. Returns that new block's offset, or `None` on OOM.
fn grow_heap(min_extra: u64) -> Option<u64> {
    let (base, top) = ensure_init();
    let old_len = top - base;
    let grow_by = round_up(min_extra, PAGESIZE);
    let old_break = sbrk(grow_by as i64);
    if old_break == u64::MAX {
        return None;
    }
    let new_top = old_break + grow_by;
    HEAP_TOP.store(new_top, Ordering::Relaxed);
    let heap = unsafe { heap_slice(base, new_top) };
    write_header(heap, old_len, Header { state: BlockState::Free, size: grow_by });
    Some(old_len)
}

/// Runs `f` against the current heap. The one place besides `free`
/// and `realloc` that a raw address becomes a Rust slice.
fn with_heap<R>(f: impl FnOnce(&mut [u8]) -> R) -> R {
    let (base, top) = ensure_init();
    // Safety: `base`/`top` are always values `sbrk` itself returned
    // (either just now, or cached from an earlier call), so
    // `[base, top)` is exactly the range the kernel has promised is
    // this process's heap.
    f(unsafe { heap_slice(base, top) })
}

/// Safety: see `with_heap` above -- callers must pass a `(base, top)`
/// pair that genuinely came from `sbrk`.
unsafe fn heap_slice(base: u64, top: u64) -> &'static mut [u8] {
    core::slice::from_raw_parts_mut(base as *mut u8, (top - base) as usize)
}

fn read_header(heap: &[u8], offset: u64) -> Header {
    // Safety: every offset this module passes here is either 0 (the
    // heap's first block) or `prev_offset + prev_header.size` for a
    // header previously written by `write_header`/`grow_heap`, so it's
    // always the start of a real, initialized header within `heap`.
    unsafe { *(heap.as_ptr().add(offset as usize) as *const Header) }
}

fn write_header(heap: &mut [u8], offset: u64, header: Header) {
    // Safety: same as `read_header`.
    unsafe { *(heap.as_mut_ptr().add(offset as usize) as *mut Header) = header };
}

fn payload_ptr(heap: &mut [u8], offset: u64) -> NonNull<u8> {
    // Safety: `offset + HEADER_SIZE` is within `heap` by the same
    // invariant `read_header`/`write_header` rely on; the pointer is
    // never null since it's derived from a real slice.
    unsafe { NonNull::new_unchecked(heap.as_mut_ptr().add((offset + HEADER_SIZE) as usize)) }
}

fn offset_of_payload(base: u64, ptr: NonNull<u8>) -> u64 {
    ptr.as_ptr() as u64 - base - HEADER_SIZE
}

/// Reinterprets an allocation this library just handed out (or is about
/// to) as a `[T]` of `len` elements -- used for `heap_info`'s two result
/// arrays and its own sorting scratch buffer.
///
/// Safety: `ptr` must point to a live allocation from this library of
/// at least `len * size_of::<T>()` bytes with `T`'s alignment (true for
/// every call site below: `T` is `i64`/`*mut u8`/`Entry`, all at most
/// 8-byte aligned, and payloads from this allocator are always
/// 8-byte aligned).
unsafe fn as_slice_mut<'a, T>(ptr: NonNull<u8>, len: usize) -> &'a mut [T] {
    core::slice::from_raw_parts_mut(ptr.as_ptr() as *mut T, len)
}

fn mark_internal(heap: &mut [u8], base: u64, ptr: NonNull<u8>) {
    let offset = offset_of_payload(base, ptr);
    let mut header = read_header(heap, offset);
    header.state = BlockState::Internal;
    write_header(heap, offset, header);
}

/// Uses `need` bytes of the free block at `offset` (whose full size is
/// `header.size`) for a block of `new_state`. Splits off the leftover
/// as a new free block when it's big enough to hold its own header;
/// otherwise folds the whole block into this allocation.
fn split_or_use(heap: &mut [u8], offset: u64, header: Header, need: u64, new_state: BlockState) -> NonNull<u8> {
    let remainder = header.size - need;
    if remainder >= MIN_SPLIT {
        write_header(heap, offset, Header { state: new_state, size: need });
        write_header(heap, offset + need, Header { state: BlockState::Free, size: remainder });
    } else {
        write_header(heap, offset, Header { state: new_state, size: header.size });
    }
    payload_ptr(heap, offset)
}

// ---------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------

// malloc(sz)
//    Allocates `sz` bytes of uninitialized memory and returns a pointer
//    to it. If `sz == 0`, returns `None` (a value that can safely be
//    passed to `free`, which is a no-op on `None`). The pointer is
//    always 8-byte aligned.
pub fn malloc(sz: u64) -> Option<NonNull<u8>> {
    if sz == 0 {
        return None;
    }
    let need = round_up(sz, 8) + HEADER_SIZE;

    // First-fit search over the implicit free list.
    let found = with_heap(|heap| {
        let mut offset = 0u64;
        while offset < heap.len() as u64 {
            let header = read_header(heap, offset);
            if header.state == BlockState::Free && header.size >= need {
                return Some(split_or_use(heap, offset, header, need, BlockState::Used));
            }
            offset += header.size;
        }
        None
    });
    if found.is_some() {
        return found;
    }

    // No block fit: grow the heap and use the new space.
    let new_offset = grow_heap(need)?;
    Some(with_heap(|heap| {
        let header = read_header(heap, new_offset);
        split_or_use(heap, new_offset, header, need, BlockState::Used)
    }))
}

// calloc(num, sz)
//    Allocates zeroed memory for an array of `num` elements of `sz`
//    bytes each. Returns `None` if `num`, `sz`, or `num * sz` overflows,
//    or on OOM.
pub fn calloc(num: u64, sz: u64) -> Option<NonNull<u8>> {
    if num == 0 || sz == 0 {
        return None;
    }
    let total = num.checked_mul(sz)?;
    let ptr = malloc(total)?;
    // Safety: `malloc` just returned this pointer backed by at least
    // `total` bytes of freshly-allocated (uninitialized, but ours to
    // write) memory.
    unsafe { core::ptr::write_bytes(ptr.as_ptr(), 0, total as usize) };
    Some(ptr)
}

// free(ptr)
//    Frees the memory at `ptr`. Does nothing if `ptr` is `None`.
//
// # Safety
// `ptr`, when `Some`, must be a still-live allocation from this
// library, not already freed.
pub unsafe fn free(ptr: Option<NonNull<u8>>) {
    let Some(ptr) = ptr else { return };
    let (base, top) = ensure_init();
    let heap = heap_slice(base, top);
    let offset = offset_of_payload(base, ptr);
    let mut header = read_header(heap, offset);
    header.state = BlockState::Free;
    write_header(heap, offset, header);
}

// realloc(ptr, sz)
//    Changes the size of the block at `ptr` to `sz` bytes, preserving
//    contents up to the smaller of the old and new sizes. `None` for
//    `ptr` behaves like `malloc(sz)`; `sz == 0` with `Some(ptr)` behaves
//    like `free(ptr)`. Unlike the reference C implementation, `ptr` is
//    checked *before* any pointer arithmetic on it -- computing an
//    offset from a null pointer is undefined behavior in C, and this
//    can't make that mistake structurally.
//
// # Safety
// `ptr`, when `Some`, must be a still-live allocation from this
// library.
pub unsafe fn realloc(ptr: Option<NonNull<u8>>, sz: u64) -> Option<NonNull<u8>> {
    let Some(old_ptr) = ptr else {
        return malloc(sz);
    };
    if sz == 0 {
        free(Some(old_ptr));
        return None;
    }

    let (base, top) = ensure_init();
    let old_size = {
        let heap = heap_slice(base, top);
        let offset = offset_of_payload(base, old_ptr);
        read_header(heap, offset).size - HEADER_SIZE
    };

    let new_ptr = malloc(sz)?;
    let copy_len = old_size.min(sz) as usize;
    // Safety: `old_ptr` is a live allocation of at least `old_size`
    // bytes (by this function's own precondition), `new_ptr` was just
    // allocated with at least `sz >= copy_len` bytes, and the two
    // allocations can never overlap.
    core::ptr::copy_nonoverlapping(old_ptr.as_ptr(), new_ptr.as_ptr(), copy_len);
    free(Some(old_ptr));
    Some(new_ptr)
}

// defrag()
//    Coalesces every run of adjacent free blocks into one. Only runs
//    when explicitly called. A single forward pass -- O(n) -- rather
//    than the spec's tolerated O(n^2).
pub fn defrag() {
    with_heap(|heap| {
        let len = heap.len() as u64;
        let mut offset = 0u64;
        while offset < len {
            let header = read_header(heap, offset);
            if header.state != BlockState::Free {
                offset += header.size;
                continue;
            }
            let mut total = header.size;
            let mut next_offset = offset + header.size;
            while next_offset < len {
                let next = read_header(heap, next_offset);
                if next.state != BlockState::Free {
                    break;
                }
                total += next.size;
                next_offset += next.size;
            }
            if total != header.size {
                write_header(heap, offset, Header { state: BlockState::Free, size: total });
            }
            offset += total;
        }
    });
}

// HeapInfoStruct (ported from malloc.h's heap_info_struct)
//    Filled in by `heap_info` for debugging/reporting.
#[repr(C)]
pub struct HeapInfoStruct {
    /// Number of currently live (user, not this library's own internal
    /// bookkeeping) allocations.
    pub num_allocs: i32,
    /// Points to an array of `num_allocs` sizes, sorted descending,
    /// one per entry of `ptr_array`. Null when `num_allocs == 0`.
    /// Allocated by this library; freeing it is the caller's job.
    pub size_array: *mut i64,
    /// Points to an array of `num_allocs` live pointers, ordered to
    /// match `size_array`. Null when `num_allocs == 0`. Allocated by
    /// this library; freeing it is the caller's job.
    pub ptr_array: *mut *mut u8,
    /// Total bytes currently free in the heap, header bytes of those
    /// free blocks included (matching the reference: a free block's
    /// `size` already counts its own header, so summing free blocks'
    /// `size` naturally includes it).
    pub free_space: i32,
    /// Size of the single largest free chunk currently available.
    pub largest_free_chunk: i32,
}

fn fail_heap_info(info: &mut HeapInfoStruct) -> i32 {
    info.num_allocs = 0;
    info.size_array = core::ptr::null_mut();
    info.ptr_array = core::ptr::null_mut();
    info.free_space = 0;
    info.largest_free_chunk = 0;
    -1
}

// heap_info(info)
//    Fills in `info`. Returns 0 on success, or -1 if the library
//    couldn't allocate space for its own bookkeeping (in which case
//    `info` is zeroed and any partial allocation is freed).
pub fn heap_info(info: &mut HeapInfoStruct) -> i32 {
    // Pass 1: count live allocations and measure free space, before
    // this call's own bookkeeping allocations (below) exist to
    // perturb either number.
    let (mut num_allocs, mut free_space, mut largest_free_chunk) = (0u64, 0i64, 0i64);
    with_heap(|heap| {
        let mut offset = 0u64;
        while offset < heap.len() as u64 {
            let header = read_header(heap, offset);
            match header.state {
                BlockState::Used => num_allocs += 1,
                BlockState::Free => {
                    free_space += header.size as i64;
                    largest_free_chunk = largest_free_chunk.max(header.size as i64);
                }
                BlockState::Internal => {}
            }
            offset += header.size;
        }
    });

    if num_allocs == 0 {
        info.num_allocs = 0;
        info.size_array = core::ptr::null_mut();
        info.ptr_array = core::ptr::null_mut();
        info.free_space = free_space as i32;
        info.largest_free_chunk = largest_free_chunk as i32;
        return 0;
    }

    let Some(size_buf) = malloc(num_allocs * 8) else {
        return fail_heap_info(info);
    };
    let Some(ptr_buf) = malloc(num_allocs * 8) else {
        unsafe { free(Some(size_buf)) };
        return fail_heap_info(info);
    };
    let base = HEAP_BASE.load(Ordering::Relaxed);
    with_heap(|heap| {
        mark_internal(heap, base, size_buf);
        mark_internal(heap, base, ptr_buf);
    });

    // Safety: `size_buf`/`ptr_buf` were each just allocated above with
    // exactly `num_allocs * 8` bytes, matching `i64`'s and `*mut u8`'s
    // size, respectively.
    let size_array: &mut [i64] = unsafe { as_slice_mut(size_buf, num_allocs as usize) };
    let ptr_array: &mut [*mut u8] = unsafe { as_slice_mut(ptr_buf, num_allocs as usize) };

    // Pass 2: fill both arrays from every Used block (Internal blocks,
    // including the two just allocated for this very call, are
    // skipped -- they aren't user allocations).
    with_heap(|heap| {
        let mut offset = 0u64;
        let mut i = 0usize;
        while offset < heap.len() as u64 && i < size_array.len() {
            let header = read_header(heap, offset);
            if header.state == BlockState::Used {
                size_array[i] = (header.size - HEADER_SIZE) as i64;
                ptr_array[i] = payload_ptr(heap, offset).as_ptr();
                i += 1;
            }
            offset += header.size;
        }
    });

    sort_descending(size_array, ptr_array);

    info.num_allocs = num_allocs as i32;
    info.size_array = size_array.as_mut_ptr();
    info.ptr_array = ptr_array.as_mut_ptr();
    info.free_space = free_space as i32;
    info.largest_free_chunk = largest_free_chunk as i32;
    0
}

/// Sorts `size_array`/`ptr_array` together, descending by size, in
/// O(n log n): `core::slice::sort_unstable_by` only sorts *one* slice,
/// and there's no general-purpose allocator here to hold a temporary
/// per-element (size, ptr) pair the way a `Vec` would -- so this
/// allocates exactly one small scratch buffer through this very
/// library (marked `Internal`, freed before returning), sorts *that*
/// (a single slice of pairs, which `sort_unstable_by` can do directly),
/// then copies the result back. Falls back to leaving the input
/// unsorted (still valid, just not ordered) if even that scratch
/// allocation fails -- heap_info's own two arrays were just allocated
/// successfully, so this should never actually happen in practice.
fn sort_descending(size_array: &mut [i64], ptr_array: &mut [*mut u8]) {
    let n = size_array.len();
    if n < 2 {
        return;
    }

    #[derive(Clone, Copy)]
    struct Entry {
        size: i64,
        ptr: *mut u8,
    }

    let Some(scratch) = malloc((n * size_of::<Entry>()) as u64) else {
        return;
    };
    let base = HEAP_BASE.load(Ordering::Relaxed);
    with_heap(|heap| mark_internal(heap, base, scratch));

    // Safety: `scratch` was just allocated above with exactly
    // `n * size_of::<Entry>()` bytes.
    let entries: &mut [Entry] = unsafe { as_slice_mut(scratch, n) };
    for i in 0..n {
        entries[i] = Entry { size: size_array[i], ptr: ptr_array[i] };
    }
    entries.sort_unstable_by(|a, b| b.size.cmp(&a.size));
    for i in 0..n {
        size_array[i] = entries[i].size;
        ptr_array[i] = entries[i].ptr;
    }

    unsafe { free(Some(scratch)) };
}
