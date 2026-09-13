// p-allocator.rs (ported from uspace/p-allocator.c)
//
//    Program that starts allocating page by page from its heap till it
//    reaches the stack OR runs out of memory.
#![no_std]
#![no_main]

// Pulling in `weensyos_process` (even though this file only calls a few of
// its functions) is what links its `#[panic_handler]` into this program's
// final binary -- every uspace program needs exactly one.
use weensyos_process::{sys_page_alloc, sys_yield};
use weensyos_shared::{rand, round_down, round_up, srand};

const ALLOC_SLOWDOWN: u32 = 100;
const PAGESIZE: u64 = 4096;

extern "C" {
    // The first address not allocated to process code or data (provided by
    // link/process.ld -- see PROVIDE(end = .)).
    static end: u8;
}

fn read_rsp() -> u64 {
    let rsp: u64;
    unsafe { core::arch::asm!("mov {}, rsp", out(reg) rsp, options(nostack)) };
    rsp
}

#[no_mangle]
pub extern "C" fn process_main() -> ! {
    let p = weensyos_process::sys_getpid();
    srand(p as u32);

    // The heap starts on the page right after the `end` symbol.
    let mut heap_top = round_up(unsafe { &end as *const u8 as u64 }, PAGESIZE);
    // The bottom of the stack is the first address on the current stack
    // page (this process never needs more than one stack page).
    let stack_bottom = round_down(read_rsp() - 1, PAGESIZE);

    // Allocate heap pages until (1) hit the stack (out of address space)
    // or (2) allocation fails (out of physical memory).
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
