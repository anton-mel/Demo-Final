// p-alloctests.rs (ported from uspace/p-alloctests.c)
//
//    Simple correctness checks on the malloc library -- realloc
//    preserves contents, calloc zeroes memory, heap_info reports
//    allocations in descending size order -- followed by a
//    page-at-a-time allocation loop that reports timing. Run via boot
//    command "alloctests".
#![no_std]
#![no_main]

use weensyos_malloc::{calloc, free, heap_info, malloc, realloc, HeapInfoStruct};
use weensyos_process::{app_printf, sys_getpid, sys_yield};

const PAGESIZE: u64 = 4096;

fn rdtsc() -> u64 {
    let (lo, hi): (u32, u32);
    unsafe { core::arch::asm!("rdtsc", out("eax") lo, out("edx") hi, options(nostack)) };
    ((hi as u64) << 32) | (lo as u64)
}

#[no_mangle]
pub extern "C" fn process_main() -> ! {
    let p = sys_getpid();

    // Alloc an int array of 10 elements, fill it in.
    let array_ptr = malloc(4 * 10).expect("malloc(40) failed").as_ptr() as *mut i32;
    let array = unsafe { core::slice::from_raw_parts_mut(array_ptr, 10) };
    for (i, slot) in array.iter_mut().enumerate() {
        *slot = i as i32;
    }

    // Realloc to 20 elements; contents up to the old size must survive.
    let array_ptr = unsafe {
        core::ptr::NonNull::new(array_ptr as *mut u8)
            .and_then(|p| realloc(Some(p), 4 * 20))
            .expect("realloc failed")
            .as_ptr() as *mut i32
    };
    let array = unsafe { core::slice::from_raw_parts(array_ptr, 20) };
    for (i, &v) in array.iter().enumerate().take(10) {
        assert_eq!(v, i as i32);
    }

    // Alloc a 30-element int array via calloc; must be zeroed.
    let array2_ptr = calloc(30, 4).expect("calloc(30, 4) failed").as_ptr() as *mut i32;
    let array2 = unsafe { core::slice::from_raw_parts(array2_ptr, 30) };
    for &v in array2 {
        assert_eq!(v, 0);
    }

    let mut info = HeapInfoStruct { num_allocs: 0, size_array: core::ptr::null_mut(), ptr_array: core::ptr::null_mut(), free_space: 0, largest_free_chunk: 0 };
    if heap_info(&mut info) == 0 {
        // Allocations must come back in strictly descending size order.
        let sizes = unsafe { core::slice::from_raw_parts(info.size_array, info.num_allocs as usize) };
        for i in 1..sizes.len() {
            assert!(sizes[i] < sizes[i - 1]);
        }
        unsafe {
            free(core::ptr::NonNull::new(info.size_array as *mut u8));
            free(core::ptr::NonNull::new(info.ptr_array as *mut u8));
        }
    } else {
        app_printf!(0, "heap_info failed\n");
    }

    unsafe {
        free(core::ptr::NonNull::new(array_ptr as *mut u8));
        free(core::ptr::NonNull::new(array2_ptr as *mut u8));
    }

    let mut total_time: u64 = 0;
    let mut total_pages: u64 = 0;

    // Allocate pages until out of memory, timing each allocation.
    loop {
        let start = rdtsc();
        let ptr = malloc(PAGESIZE);
        total_time += rdtsc() - start;
        match ptr {
            None => break,
            Some(ptr) => {
                total_pages += 1;
                unsafe { *(ptr.as_ptr() as *mut i32) = p }; // check write access
            }
        }
    }

    app_printf!(p, "Total_time taken to alloc: {} Average time: {}\n", total_time, total_time / total_pages.max(1));

    loop {
        sys_yield();
    }
}
