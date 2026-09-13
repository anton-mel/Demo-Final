#![no_std]
#![no_main]

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
    let stack_bottom = round_down(read_rsp() - 1, PAGESIZE);

    while heap_top + PAGESIZE < stack_bottom {
        let ret = sbrk(PAGESIZE as i64);
        if ret == u64::MAX {
            break;
        }
        unsafe { *(heap_top as *mut u8) = p as u8 }; /* check we have write access to new page */
        heap_top = ret + PAGESIZE;
    }

    panic!("TEST PASS");
}

