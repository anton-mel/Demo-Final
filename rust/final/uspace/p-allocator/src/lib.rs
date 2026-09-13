// p-allocator.rs (ported from uspace/p-allocator.c)
//
//    Grows its heap one page at a time via sbrk until it either hits
//    the stack or sbrk fails, writing to each new page to confirm it's
//    actually accessible. Run via boot command "allocator" (the
//    default) or by pressing 'a' once WeensyOS is running.
//
//    Initially (before kernel::sbrk is implemented) this panics with an
//    assertion-shaped message almost immediately, matching the
//    reference starter's own documented behavior.
#![no_std]
#![no_main]

// Pulling in `weensyos_process` (even though this file only calls a few of
// its functions) is what links its `#[panic_handler]` into this program's
// final binary -- every uspace program needs exactly one.
use weensyos_process::{getpid, sbrk};
use weensyos_shared::round_down;

const PAGESIZE: u64 = 4096;

fn read_rsp() -> u64 {
    let rsp: u64;
    unsafe { core::arch::asm!("mov {}, rsp", out(reg) rsp, options(nostack)) };
    rsp
}

#[no_mangle]
pub extern "C" fn process_main() -> ! {
    let p = getpid();

    let mut heap_top = sbrk(0);
    // The bottom of the stack is the first address on the current stack
    // page (this process never needs more than one stack page).
    let stack_bottom = round_down(read_rsp() - 1, PAGESIZE);

    while heap_top + PAGESIZE < stack_bottom {
        let ret = sbrk(PAGESIZE as i64);
        if ret == u64::MAX {
            break;
        }
        unsafe { *(heap_top as *mut u8) = p as u8 }; // check we have write access to new page
        heap_top = ret + PAGESIZE;
    }

    panic!("TEST PASS");
}

