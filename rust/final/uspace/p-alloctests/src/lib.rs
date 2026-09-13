#![no_std]
#![no_main]

use weensyos_malloc::{calloc, free, heap_info, malloc, realloc, HeapInfoStruct};
use weensyos_process::{app_printf, getpid, r#yield};

const PAGESIZE: u64 = 4096;

fn rdtsc() -> u64 {
    let (lo, hi): (u32, u32);
    unsafe { core::arch::asm!("rdtsc", out("eax") lo, out("edx") hi, options(nostack)) };
    ((hi as u64) << 32) | (lo as u64)
}

fn as_raw(ptr: Option<core::ptr::NonNull<u8>>) -> *mut u8 {
    ptr.map_or(core::ptr::null_mut(), |p| p.as_ptr())
}

#[no_mangle]
pub extern "C" fn process_main() -> ! {
    let p = getpid();

    // alloc int array of 10 elements
    let array_addr = as_raw(malloc(4 * 10)) as usize;

    // set array elements
    for i in 0..10usize {
        unsafe { *((array_addr + i * 4) as *mut i32) = i as i32 };
    }

    // realloc array to size 20
    let array_addr = as_raw(unsafe { realloc(core::ptr::NonNull::new(array_addr as *mut u8), 4 * 20) }) as usize;

    // check if contents are same
    for i in 0..10usize {
        let v = unsafe { *((array_addr + i * 4) as *const i32) };
        assert_eq!(v, i as i32);
    }
    let array_ptr = array_addr as *mut i32;

    // alloc int array of size 30 using calloc
    let array2_addr = as_raw(calloc(30, 4)) as usize;

    // assert array[i] == 0
    for i in 0..30usize {
        let v = unsafe { *((array2_addr + i * 4) as *const i32) };
        assert_eq!(v, 0);
    }
    let array2_ptr = array2_addr as *mut i32;

    let mut info = HeapInfoStruct {
        num_allocs: 0,
        size_array: core::ptr::null_mut(),
        ptr_array: core::ptr::null_mut(),
        free_space: 0,
        largest_free_chunk: 0,
    };
    
    if heap_info(&mut info) == 0 {
        app_printf!(0, "heap_info: num_allocs={} free_space={} largest_free_chunk={}\n", info.num_allocs, info.free_space, info.largest_free_chunk);
        for i in 0..info.num_allocs as usize {
            let sz = unsafe { *info.size_array.add(i) };
            app_printf!(0, "  alloc[{}]: size={}\n", i, sz);
        }

        // check if allocations are in sorted order
        for i in 1..info.num_allocs as usize {
            let a = unsafe { *info.size_array.add(i) };
            let b = unsafe { *info.size_array.add(i - 1) };
            assert!(a < b);
        }
    } else {
        app_printf!(0, "heap_info failed\n");
    }

    // free array, array2
    unsafe {
        free(core::ptr::NonNull::new(array_ptr as *mut u8));
        free(core::ptr::NonNull::new(array2_ptr as *mut u8));
    }

    let mut total_time: u64 = 0;
    let mut total_pages: u64 = 0;

    // allocate pages till no more memory
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

    // after running out of memory
    loop {
        r#yield();
    }
}
