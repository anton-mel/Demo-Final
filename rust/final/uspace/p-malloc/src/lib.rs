#![no_std]
#![no_main]

use weensyos_process::{getpid, r#yield};
use weensyos_shared::{rand, srand};

const ALLOC_SLOWDOWN: u32 = 100;
const PAGESIZE: u64 = 4096;

#[no_mangle]
pub extern "C" fn process_main() -> ! {
    let p = getpid();
    srand(p as u32);

    // Allocate heap pages until (1) hit the stack (out of address space)
    // or (2) allocation fails (out of physical memory).
    loop {
        if (rand() % ALLOC_SLOWDOWN) < p as u32 {
            match weensyos_malloc::malloc(PAGESIZE) {
                None => break,
                Some(ptr) => unsafe { *(ptr.as_ptr() as *mut i32) = p }, // check we have write access
            }
        }
        r#yield();
    }

    // After running out of memory, do nothing forever.
    loop {
        r#yield();
    }
}
