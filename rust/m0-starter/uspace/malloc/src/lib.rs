// malloc.rs (ported from uspace/malloc.c + uspace/malloc.h)
//
//    A dynamic memory allocator for WeensyOS user processes, built on
//    top of brk/sbrk (see uspace/process's `brk`/`sbrk` and
//    kernel::sbrk). This is the starter: every function below is a
//    stub, exactly like the reference malloc.c -- implementing them is
//    the assignment's Part 2 (see the assignment spec for the full
//    design: a first-fit free list, 8-byte-aligned payloads, etc).
#![no_std]

use core::ptr::NonNull;

// malloc(sz)
//    Allocates `sz` bytes of uninitialized memory and returns a pointer
//    to it. If `sz == 0`, either returns `None`, or a unique value that
//    can later be successfully passed to `free`. The pointer should be
//    8-byte aligned.
//
//    TODO: implement (see the assignment spec's Part 2).
#[allow(unused_variables)]
pub fn malloc(sz: u64) -> Option<NonNull<u8>> {
    None
}

// calloc(num, sz)
//    Allocates memory for an array of `num` elements of `sz` bytes
//    each, zeroed, and returns a pointer to it. If `num` or `sz` is 0,
//    returns `None` or a unique free-able pointer. Must check for
//    overflow in `num * sz`.
//
//    TODO: implement (see the assignment spec's Part 2).
#[allow(unused_variables)]
pub fn calloc(num: u64, sz: u64) -> Option<NonNull<u8>> {
    None
}

// free(ptr)
//    Frees the memory pointed to by `ptr`, which must have been
//    returned by a previous call to `malloc`/`calloc`/`realloc` and not
//    already freed (freeing an already-freed pointer is undefined
//    behavior). Does nothing if `ptr` is `None`.
//
//    TODO: implement (see the assignment spec's Part 2).
///
/// # Safety
/// `ptr`, when `Some`, must be a still-live allocation from this
/// library.
#[allow(unused_variables)]
pub unsafe fn free(ptr: Option<NonNull<u8>>) {}

// realloc(ptr, sz)
//    Changes the size of the block at `ptr` to `sz` bytes, preserving
//    contents up to the smaller of the old and new sizes. `None` for
//    `ptr` is equivalent to `malloc(sz)`; `sz == 0` with `Some(ptr)` is
//    equivalent to `free(ptr)`.
//
//    TODO: implement (see the assignment spec's Part 2).
///
/// # Safety
/// `ptr`, when `Some`, must be a still-live allocation from this
/// library.
#[allow(unused_variables)]
pub unsafe fn realloc(ptr: Option<NonNull<u8>>, sz: u64) -> Option<NonNull<u8>> {
    None
}

// defrag()
//    Coalesces adjacent free blocks in the heap into single, larger
//    blocks. Only runs when explicitly called.
//
//    TODO: implement (see the assignment spec's Part 2).
pub fn defrag() {}

// HeapInfoStruct (ported from malloc.h's heap_info_struct)
//    Filled in by `heap_info` for debugging/reporting.
#[repr(C)]
pub struct HeapInfoStruct {
    /// Number of currently live allocations.
    pub num_allocs: i32,
    /// Points to an array of `num_allocs` sizes, one per entry of
    /// `ptr_array`, sorted descending. Null when `num_allocs == 0`.
    /// Allocated by this library; freeing it is the caller's job.
    pub size_array: *mut i64,
    /// Points to an array of `num_allocs` live pointers, ordered to
    /// match `size_array` (also descending by size). Null when
    /// `num_allocs == 0`. Allocated by this library; freeing it is the
    /// caller's job.
    pub ptr_array: *mut *mut u8,
    /// Total free bytes currently available in the heap (metadata
    /// bytes don't count as free space).
    pub free_space: i32,
    /// Size of the single largest free chunk currently available.
    pub largest_free_chunk: i32,
}

// heap_info(info)
//    Fills in `info`. Returns 0 on success, or -1 if the library
//    couldn't allocate space for its own bookkeeping (in which case
//    `info` should be zeroed and any partial allocation freed).
//
//    TODO: implement (see the assignment spec's Part 2).
#[allow(unused_variables)]
pub fn heap_info(info: &mut HeapInfoStruct) -> i32 {
    0
}
