// p-forkexit.rs (ported from uspace/p-forkexit.c)
//
//    Parent program: keeps forking till infinity, never exits.
//    Child program: randomly forks and allocates memory till stack bottom
//    is reached or it runs out of memory, after which it randomly exits
//    or sleeps.
#![no_std]
#![no_main]

// Pulling in `weensyos_process` links its `#[panic_handler]` into this
// program's final binary -- every uspace program needs exactly one.
use weensyos_process::{sys_exit, sys_fork, sys_getpid, sys_page_alloc, sys_yield};
use weensyos_shared::{console_printf, cpos, rand, round_down, round_up, srand, CONSOLE_ADDR};

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

fn console_cell(pos: i32) -> u16 {
    unsafe { *(CONSOLE_ADDR as *const u16).offset(pos as isize) }
}

#[no_mangle]
pub extern "C" fn process_main() -> ! {
    loop {
        if rand() % ALLOC_SLOWDOWN == 0 {
            if sys_fork() == 0 {
                break;
            }
        } else {
            sys_yield();
        }
    }

    let mut p = sys_getpid();
    srand(p as u32);

    // The heap starts on the page right after the `end` symbol.
    let mut heap_top = round_up(unsafe { &end as *const u8 as u64 }, PAGESIZE);
    // The bottom of the stack is the first address on the current stack
    // page (this process never needs more than one stack page).
    let stack_bottom = round_down(read_rsp() - 1, PAGESIZE);

    // Allocate heap pages until (1) hit the stack (out of address space)
    // or (2) allocation fails (out of physical memory).
    loop {
        let x = rand() % (8 * ALLOC_SLOWDOWN);
        if x < 8 * p as u32 {
            if heap_top == stack_bottom || sys_page_alloc(heap_top) < 0 {
                break;
            }
            unsafe { *(heap_top as *mut u8) = p as u8 }; // check we have write access to new page
            heap_top += PAGESIZE;
            if console_cell(cpos(24, 0)) != 0 {
                // clear "Out of physical memory" msg
                console_printf(cpos(24, 0), 0, format_args!("\n"));
            }
        } else if x == 8 * p as u32 {
            if sys_fork() == 0 {
                p = sys_getpid();
            }
        } else if x == 8 * p as u32 + 1 {
            sys_exit();
        } else {
            sys_yield();
        }
    }

    // After running out of memory
    loop {
        if rand() % (2 * ALLOC_SLOWDOWN) == 0 {
            sys_exit();
        } else {
            sys_yield();
        }
    }
}
