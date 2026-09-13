#![no_std]

use core::mem::size_of;
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

const HEADER_SIZE: u64 = size_of::<Header>() as u64;
const MIN_SPLIT: u64 = HEADER_SIZE;

static mut HEAP_BASE: u64 = 0;
static mut HEAP_TOP: u64 = 0;

fn heap_mut() -> &'static mut [u8] {
    unsafe {
        if HEAP_BASE == 0 {
            HEAP_BASE = sbrk(0);
            HEAP_TOP = HEAP_BASE;
        }
        core::slice::from_raw_parts_mut(HEAP_BASE as *mut u8, (HEAP_TOP - HEAP_BASE) as usize)
    }
}

fn grow_heap(min_extra: u64) -> Option<u64> {
    let old_len = heap_mut().len() as u64;
    let grow_by = round_up(min_extra, PAGESIZE);
    let old_break = sbrk(grow_by as i64);
    if old_break == u64::MAX {
        return None;
    }
    unsafe { HEAP_TOP = old_break + grow_by };
    write_header(heap_mut(), old_len, Header { state: BlockState::Free, size: grow_by });
    Some(old_len)
}

fn read_header(heap: &[u8], offset: u64) -> Header {
    unsafe { *(heap.as_ptr().add(offset as usize) as *const Header) }
}

fn write_header(heap: &mut [u8], offset: u64, header: Header) {
    unsafe { *(heap.as_mut_ptr().add(offset as usize) as *mut Header) = header };
}

fn payload_ptr(heap: &mut [u8], offset: u64) -> NonNull<u8> {
    unsafe { NonNull::new_unchecked(heap.as_mut_ptr().add((offset + HEADER_SIZE) as usize)) }
}

fn offset_of(ptr: NonNull<u8>) -> u64 {
    // Safety: single-threaded, see HEAP_BASE above.
    unsafe { ptr.as_ptr() as u64 - HEAP_BASE - HEADER_SIZE }
}

fn mark_internal(heap: &mut [u8], ptr: NonNull<u8>) {
    let offset = offset_of(ptr);
    let mut header = read_header(heap, offset);
    header.state = BlockState::Internal;
    write_header(heap, offset, header);
}

fn split_or_use(heap: &mut [u8], offset: u64, header: Header, need: u64, state: BlockState) -> NonNull<u8> {
    let remainder = header.size - need;
    if remainder >= MIN_SPLIT {
        write_header(heap, offset, Header { state, size: need });
        write_header(heap, offset + need, Header { state: BlockState::Free, size: remainder });
    } else {
        write_header(heap, offset, Header { state, size: header.size });
    }
    payload_ptr(heap, offset)
}

unsafe fn as_slice_mut<'a, T>(ptr: NonNull<u8>, len: usize) -> &'a mut [T] {
    core::slice::from_raw_parts_mut(ptr.as_ptr() as *mut T, len)
}

// ---------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------

pub fn malloc(sz: u64) -> Option<NonNull<u8>> {
    if sz == 0 {
        return None;
    }
    let need = round_up(sz, 8) + HEADER_SIZE;

    // First-fit search over the implicit free list.
    let heap = heap_mut();
    let mut offset = 0u64;
    while offset < heap.len() as u64 {
        let header = read_header(heap, offset);
        if header.state == BlockState::Free && header.size >= need {
            return Some(split_or_use(heap, offset, header, need, BlockState::Used));
        }
        offset += header.size;
    }

    // No block fit: grow the heap and use the new space.
    let new_offset = grow_heap(need)?;
    let heap = heap_mut();
    let header = read_header(heap, new_offset);
    Some(split_or_use(heap, new_offset, header, need, BlockState::Used))
}

pub fn calloc(num: u64, sz: u64) -> Option<NonNull<u8>> {
    if num == 0 || sz == 0 {
        return None;
    }
    let ptr = malloc(num.checked_mul(sz)?)?;
    unsafe { core::ptr::write_bytes(ptr.as_ptr(), 0, (num * sz) as usize) };
    Some(ptr)
}

pub unsafe fn free(ptr: Option<NonNull<u8>>) {
    let Some(ptr) = ptr else { return };
    let offset = offset_of(ptr);
    let mut header = read_header(heap_mut(), offset);
    header.state = BlockState::Free;
    write_header(heap_mut(), offset, header);
}

pub unsafe fn realloc(ptr: Option<NonNull<u8>>, sz: u64) -> Option<NonNull<u8>> {
    let Some(old_ptr) = ptr else { return malloc(sz) };
    if sz == 0 {
        free(Some(old_ptr));
        return None;
    }
    let old_size = read_header(heap_mut(), offset_of(old_ptr)).size - HEADER_SIZE;
    let new_ptr = malloc(sz)?;
    core::ptr::copy_nonoverlapping(old_ptr.as_ptr(), new_ptr.as_ptr(), old_size.min(sz) as usize);
    free(Some(old_ptr));
    Some(new_ptr)
}

pub fn defrag() {
    let heap = heap_mut();
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
    let heap = heap_mut();
    let (mut num_allocs, mut free_space, mut largest_free_chunk) = (0u64, 0i64, 0i64);
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

    if num_allocs == 0 {
        *info = HeapInfoStruct { num_allocs: 0, size_array: core::ptr::null_mut(), ptr_array: core::ptr::null_mut(), free_space: free_space as i32, largest_free_chunk: largest_free_chunk as i32 };
        return 0;
    }

    let Some(size_buf) = malloc(num_allocs * 8) else { return fail_heap_info(info) };
    let Some(ptr_buf) = malloc(num_allocs * 8) else {
        unsafe { free(Some(size_buf)) };
        return fail_heap_info(info);
    };
    mark_internal(heap_mut(), size_buf);
    mark_internal(heap_mut(), ptr_buf);

    let size_array: &mut [i64] = unsafe { as_slice_mut(size_buf, num_allocs as usize) };
    let ptr_array: &mut [*mut u8] = unsafe { as_slice_mut(ptr_buf, num_allocs as usize) };

    let heap = heap_mut();
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
