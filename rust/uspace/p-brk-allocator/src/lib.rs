// p-brk-allocator.rs (ported from uspace/p-allocator.c, final-project
// version -- sbrk-based, not the base pset's sys_page_alloc-based one)
//
//    Grows its heap one page at a time via sbrk until it either hits the
//    stack or sbrk fails, writing to each new page to confirm it's
//    actually accessible. Run via boot command "allocator".
#![no_std]
#![no_main]

// Pulling in `weensyos_process` (even though this file only calls a few of
// its functions) is what links its `#[panic_handler]` into this program's
// final binary -- every uspace program needs exactly one.
use weensyos_process::{sys_getpid, sys_sbrk};
use weensyos_shared::round_down;

const PAGESIZE: u64 = 4096;

fn read_rsp() -> u64 {
    let rsp: u64;
    unsafe { core::arch::asm!("mov {}, rsp", out(reg) rsp, options(nostack)) };
    rsp
}

#[no_mangle]
pub extern "C" fn process_main() -> ! {
    let p = sys_getpid();

    let mut heap_top = sys_sbrk(0);
    // The bottom of the stack is the first address on the current stack
    // page (this process never needs more than one stack page).
    let stack_bottom = round_down(read_rsp() - 1, PAGESIZE);

    while heap_top + PAGESIZE < stack_bottom {
        let ret = sys_sbrk(PAGESIZE as i64);
        if ret == u64::MAX {
            break;
        }
        unsafe { *(heap_top as *mut u8) = p as u8 }; // check we have write access to new page
        heap_top = ret + PAGESIZE;
    }

    loop {
        weensyos_process::sys_yield();
    }
}
