#![no_std]

use core::ptr::NonNull;
use weensyos_process::sbrk;
use weensyos_shared::round_up;

const PAGESIZE: u64 = 4096;

#[repr(u8)]
#[derive(Clone, Copy, PartialEq, Eq)]
enum BlockState {
    Free,
    Used,
    Internal,
}

#[repr(C)]
#[derive(Clone, Copy)]
struct Header {
    state: BlockState,
    size: u64,
}

const HEADER_SIZE: u64 = core::mem::size_of::<Header>() as u64;
const MIN_SPLIT: u64 = HEADER_SIZE;

static mut HEAP_START: u64 = 0;
static mut HEAP_END: u64 = 0;

unsafe fn heap_bounds() -> (*mut Header, u64) {
    if HEAP_START == 0 {
        HEAP_START = sbrk(0);
        HEAP_END = HEAP_START;
    }
    (HEAP_START as *mut Header, HEAP_END)
}

unsafe fn next_block(block: *mut Header) -> *mut Header {
    (block as *mut u8).add((*block).size as usize) as *mut Header
}

unsafe fn payload_of(block: *mut Header) -> NonNull<u8> {
    NonNull::new_unchecked((block as *mut u8).add(HEADER_SIZE as usize))
}

unsafe fn block_of(ptr: NonNull<u8>) -> *mut Header {
    ptr.as_ptr().sub(HEADER_SIZE as usize) as *mut Header
}

fn grow_heap(min_extra: u64) -> Option<*mut Header> {
    let grow_by = round_up(min_extra, PAGESIZE);
    let old_break = sbrk(grow_by as i64);
    if old_break == u64::MAX {
        return None;
    }

    unsafe {
        HEAP_END = old_break + grow_by;
        let block = old_break as *mut Header;
        *block = Header { state: BlockState::Free, size: grow_by };
        Some(block)
    }
}

unsafe fn split_or_use(block: *mut Header, need: u64, state: BlockState) -> NonNull<u8> {
    let remainder = (*block).size - need;
    if remainder >= MIN_SPLIT {
        *block = Header { state, size: need };
        *next_block(block) = Header { state: BlockState::Free, size: remainder };
    } else {
        (*block).state = state;
    }
    payload_of(block)
}

// ---------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------

pub fn malloc(sz: u64) -> Option<NonNull<u8>> {
    if sz == 0 {
        return None;
    }
    let need = round_up(sz, 8) + HEADER_SIZE;

    unsafe {
        // First-fit search over the implicit free list.
        let (mut block, end) = heap_bounds();
        while (block as u64) < end {
            if (*block).state == BlockState::Free && (*block).size >= need {
                return Some(split_or_use(block, need, BlockState::Used));
            }
            block = next_block(block);
        }

        // No block fit: grow the heap and use the new space.
        let block = grow_heap(need)?;
        Some(split_or_use(block, need, BlockState::Used))
    }
}

pub fn calloc(num: u64, sz: u64) -> Option<NonNull<u8>> {
    if num == 0 || sz == 0 {
        return None;
    }
    let ptr = malloc(num.checked_mul(sz)?)?;
    unsafe { core::ptr::write_bytes(ptr.as_ptr(), 0, (num * sz) as usize) };
    Some(ptr)
}

/// # Safety
/// `ptr`, when `Some`, must be a still-live allocation from this library.
pub unsafe fn free(ptr: Option<NonNull<u8>>) {
    let Some(ptr) = ptr else { return };
    (*block_of(ptr)).state = BlockState::Free;
}

/// # Safety
/// `ptr`, when `Some`, must be a still-live allocation from this library.
pub unsafe fn realloc(ptr: Option<NonNull<u8>>, sz: u64) -> Option<NonNull<u8>> {
    let Some(old_ptr) = ptr else { return malloc(sz) };
    if sz == 0 {
        free(Some(old_ptr));
        return None;
    }
    let old_size = (*block_of(old_ptr)).size - HEADER_SIZE;
    let new_ptr = malloc(sz)?;
    core::ptr::copy_nonoverlapping(old_ptr.as_ptr(), new_ptr.as_ptr(), old_size.min(sz) as usize);
    free(Some(old_ptr));
    Some(new_ptr)
}

// Coalesces every run of adjacent free blocks into one.
pub fn defrag() {
    unsafe {
        let (mut block, end) = heap_bounds();
        while (block as u64) < end {
            if (*block).state != BlockState::Free {
                block = next_block(block);
                continue;
            }
            let mut total = (*block).size;
            let mut next = next_block(block);
            while (next as u64) < end && (*next).state == BlockState::Free {
                total += (*next).size;
                next = next_block(next);
            }
            (*block).size = total;
            block = next_block(block);
        }
    }
}

#[repr(C)]
pub struct HeapInfoStruct {
    pub num_allocs: i32,
    pub size_array: *mut i64,
    pub ptr_array: *mut *mut u8,
    pub free_space: i32,
    pub largest_free_chunk: i32,
}

fn fail_heap_info(info: &mut HeapInfoStruct) -> i32 {
    *info = HeapInfoStruct { num_allocs: 0, size_array: core::ptr::null_mut(), ptr_array: core::ptr::null_mut(), free_space: 0, largest_free_chunk: 0 };
    -1
}

pub fn heap_info(info: &mut HeapInfoStruct) -> i32 {
    let (mut num_allocs, mut free_space, mut largest_free_chunk) = (0u64, 0i64, 0i64);
    unsafe {
        let (mut block, end) = heap_bounds();
        while (block as u64) < end {
            match (*block).state {
                BlockState::Used => num_allocs += 1,
                BlockState::Free => {
                    free_space += (*block).size as i64;
                    largest_free_chunk = largest_free_chunk.max((*block).size as i64);
                }
                BlockState::Internal => {}
            }
            block = next_block(block);
        }
    }

    if num_allocs == 0 {
        *info = HeapInfoStruct { num_allocs: 0, size_array: core::ptr::null_mut(), ptr_array: core::ptr::null_mut(), free_space: free_space as i32, largest_free_chunk: largest_free_chunk as i32 };
        return 0;
    }

    let Some(size_buf) = malloc(num_allocs * 8) else { return fail_heap_info(info) };
    let Some(ptr_buf) = malloc(num_allocs * 8) else {
        unsafe { free(Some(size_buf)) };
        return fail_heap_info(info);
    };

    // Safety: `size_array`/`ptr_array` below cover exactly the bytes
    // `malloc` just handed back for `size_buf`/`ptr_buf`.
    let (size_array, ptr_array) = unsafe {
        (*block_of(size_buf)).state = BlockState::Internal;
        (*block_of(ptr_buf)).state = BlockState::Internal;
        let size_array = core::slice::from_raw_parts_mut(size_buf.as_ptr() as *mut i64, num_allocs as usize);
        let ptr_array = core::slice::from_raw_parts_mut(ptr_buf.as_ptr() as *mut *mut u8, num_allocs as usize);
        (size_array, ptr_array)
    };

    unsafe {
        let (mut block, end) = heap_bounds();
        let mut i = 0usize;
        while (block as u64) < end && i < size_array.len() {
            if (*block).state == BlockState::Used {
                size_array[i] = ((*block).size - HEADER_SIZE) as i64;
                ptr_array[i] = payload_of(block).as_ptr();
                i += 1;
            }
            block = next_block(block);
        }
    }

    sort_descending(size_array, ptr_array);

    info.num_allocs = num_allocs as i32;
    info.size_array = size_array.as_mut_ptr();
    info.ptr_array = ptr_array.as_mut_ptr();
    info.free_space = free_space as i32;
    info.largest_free_chunk = largest_free_chunk as i32;
    0
}

fn sort_descending(size_array: &mut [i64], ptr_array: &mut [*mut u8]) {
    let n = size_array.len();
    for i in 0..n {
        let mut largest = i;
        for j in (i + 1)..n {
            if size_array[j] > size_array[largest] {
                largest = j;
            }
        }
        size_array.swap(i, largest);
        ptr_array.swap(i, largest);
    }
}
