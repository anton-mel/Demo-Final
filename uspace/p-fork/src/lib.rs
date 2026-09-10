// p-fork.rs (ported from uspace/p-fork.c)
//
//    Program that forks thrice to produce a total of 4 processes. Each
//    process keeps allocating memory till stack bottom is reached OR the
//    system is out of memory; after that, each process loops forever.
#![no_std]
#![no_main]

// Pulling in `weensyos_process` links its `#[panic_handler]` into this
// program's final binary -- every uspace program needs exactly one.
use weensyos_process::{sys_fork, sys_getpid, sys_page_alloc, sys_yield};
use weensyos_shared::{rand, round_down, round_up, srand};

const ALLOC_SLOWDOWN: u32 = 100;
const PAGESIZE: u64 = 4096;

extern "C" {
    static end: u8;
}

fn read_rsp() -> u64 {
    let rsp: u64;
    unsafe { core::arch::asm!("mov {}, rsp", out(reg) rsp, options(nostack)) };
    rsp
}

#[no_mangle]
pub extern "C" fn process_main() -> ! {
    // Fork a total of three new copies.
    let p1 = sys_fork();
    assert!(p1 >= 0);
    let p2 = sys_fork();
    assert!(p2 >= 0);

    // Check fork return values: fork should return 0 to the child.
    if sys_getpid() == 1 {
        assert!(p1 != 0 && p2 != 0 && p1 != p2);
    } else {
        assert!(p1 == 0 || p2 == 0);
    }

    // The rest of this code is like p-allocator.

    let p = sys_getpid();
    srand(p as u32);

    let mut heap_top = round_up(unsafe { &end as *const u8 as u64 }, PAGESIZE);
    let stack_bottom = round_down(read_rsp() - 1, PAGESIZE);

    loop {
        if (rand() % ALLOC_SLOWDOWN) < p as u32 {
            if heap_top == stack_bottom || sys_page_alloc(heap_top) < 0 {
                break;
            }
            unsafe { *(heap_top as *mut u8) = p as u8 }; // check we have write access to new page
            heap_top += PAGESIZE;
        }
        sys_yield();
    }

    // After running out of memory, do nothing forever
    loop {
        sys_yield();
    }
}
