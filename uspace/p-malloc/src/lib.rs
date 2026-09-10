// p-malloc.rs (ported from uspace/p-malloc.c)
//
//    Allocates one page at a time via `malloc` until it fails, writing
//    to each new page to confirm it's actually accessible. Run via boot
//    command "malloc".
#![no_std]
#![no_main]

use weensyos_process::{sys_getpid, sys_yield};
use weensyos_shared::{rand, srand};

const ALLOC_SLOWDOWN: u32 = 100;
const PAGESIZE: u64 = 4096;

#[no_mangle]
pub extern "C" fn process_main() -> ! {
    let p = sys_getpid();
    srand(p as u32);

    loop {
        if (rand() % ALLOC_SLOWDOWN) < p as u32 {
            match weensyos_malloc::malloc(PAGESIZE) {
                None => break,
                Some(ptr) => unsafe { *(ptr.as_ptr() as *mut i32) = p }, // check write access
            }
        }
        sys_yield();
    }

    // After running out of memory, do nothing forever.
    loop {
        sys_yield();
    }
}
