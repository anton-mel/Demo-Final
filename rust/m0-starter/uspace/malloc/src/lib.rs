#![no_std]

use core::ptr::NonNull;

#[allow(unused_variables)]
pub fn malloc(sz: u64) -> Option<NonNull<u8>> {
    panic!("part1: malloc not implemented")
}

#[allow(unused_variables)]
pub fn calloc(num: u64, sz: u64) -> Option<NonNull<u8>> {
    panic!("part1: calloc not implemented")
}

#[allow(unused_variables)]
pub unsafe fn free(ptr: Option<NonNull<u8>>) {
    panic!("part1: free not implemented")
}

#[allow(unused_variables)]
pub unsafe fn realloc(ptr: Option<NonNull<u8>>, sz: u64) -> Option<NonNull<u8>> {
    panic!("part1: realloc not implemented")
}

pub fn defrag() {
    panic!("part1: defrag not implemented")
}

#[repr(C)]
pub struct HeapInfoStruct {
    // TODO
}

#[allow(unused_variables)]
pub fn heap_info(info: &mut HeapInfoStruct) -> i32 {
    panic!("part2: heap_info not implemented")
}
