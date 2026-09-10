// process.rs
//
//    Support code for WeensyOS processes. Every uspace program crate
//    (p_allocator, p_fork, p_forkexit, p_test) depends on this one, which
//    is also where the shared `#[panic_handler]` for user processes lives
//    (exactly one is needed per final linked binary, and every program
//    links this crate in).

#![no_std]
#![feature(asm_const)]
#![feature(panic_info_message)]

use core::arch::asm;
use core::fmt;
use core::panic::PanicInfo;
use weensyos_shared::{
    console_printf, cpos, crow, cursorpos, set_cursorpos, VaMapping, INT_SYS_BRK, INT_SYS_EXIT,
    INT_SYS_FORK, INT_SYS_GETPID, INT_SYS_MAPPING, INT_SYS_MEM_TOG, INT_SYS_PAGE_ALLOC,
    INT_SYS_PANIC, INT_SYS_SBRK, INT_SYS_YIELD,
};

// SYSTEM CALLS
// Each syscall runs an interrupt instruction with the specific SYSCALL_NUMBER
// defined in shared/rust/src/syscalls.rs.
// This interrupt changes the CPU mode to kernel mode, triggers the exception
// handler, saves the registers in the cpu, and eventually reaches
// kernel::exception(). Later, the kernel selects a (potentially different)
// runnable process to continue execution.
// Below is a list of syscalls, their arguments, and error codes.

// sys_getpid
//    Return current process ID.
pub fn sys_getpid() -> i32 {
    let result: u64;
    unsafe { asm!("int {0}", const INT_SYS_GETPID, out("rax") result, options(nostack)) };
    result as i32
}

// sys_yield
//    Yield control of the CPU to the kernel. The kernel will pick another
//    process to run, if possible.
pub fn sys_yield() {
    unsafe { asm!("int {0}", const INT_SYS_YIELD, options(nostack)) };
}

// sys_page_alloc(addr)
//    Allocate a page of memory at address `addr` and allow the process to
//    write to it. `addr` must be page-aligned (a multiple of PAGESIZE ==
//    4096). Returns 0 on success and -1 on failure.
pub fn sys_page_alloc(addr: u64) -> i32 {
    let result: u64;
    unsafe { asm!("int {0}", const INT_SYS_PAGE_ALLOC, in("rdi") addr, out("rax") result, options(nostack)) };
    result as i32
}

// sys_fork()
//    Fork the current process. On success, return the child's process ID to
//    the parent, and return 0 to the child. On failure, return -1.
pub fn sys_fork() -> i32 {
    let result: u64;
    unsafe { asm!("int {0}", const INT_SYS_FORK, out("rax") result, options(nostack)) };
    result as i32
}

// sys_exit()
//    Exit this process. Does not return.
pub fn sys_exit() -> ! {
    unsafe { asm!("int {0}", const INT_SYS_EXIT, options(noreturn)) };
}

// sys_panic(msg)
//    Panic, with an optional message pointer (null for no message). The
//    kernel loops until Control-C.
pub fn sys_panic(msg: *const u8) -> ! {
    unsafe { asm!("int {0}", const INT_SYS_PANIC, in("rdi") msg, options(noreturn)) };
}

// sys_mapping(addr, map)
//    Looks up the virtual memory mapping for `addr` for the current
//    process and stores it in `map`. `[map, map + size_of::<VaMapping>())`
//    must be a writable address for the process, otherwise the syscall
//    silently does nothing.
pub fn sys_mapping(addr: u64, map: &mut VaMapping) {
    unsafe { asm!("int {0}", const INT_SYS_MAPPING, in("rdi") map as *mut VaMapping, in("rsi") addr, options(nostack)) };
}

// sys_mem_tog(pid)
//    Toggles the kernel's memory-viewer display for process `pid`. If `pid`
//    is 0, toggles the display globally (global takes precedence over
//    local). Fails silently.
pub fn sys_mem_tog(pid: i32) {
    unsafe { asm!("int {0}", const INT_SYS_MEM_TOG, in("rdi") pid, options(nostack)) };
}

// sys_brk(addr)
//    Sets the program break to `addr`. Returns 0 on success and -1 on
//    error (moving the break below the heap start, or at/past the top
//    of the stack).
pub fn sys_brk(addr: u64) -> i32 {
    let result: u64;
    unsafe { asm!("int {0}", const INT_SYS_BRK, in("rdi") addr, out("rax") result, options(nostack)) };
    result as i32
}

// sys_sbrk(increment)
//    Adjusts the program break by `increment` bytes (positive or
//    negative; not required to be a multiple of PAGESIZE) and returns
//    the *previous* break on success, or `-1i64 as u64` (checked via
//    `as isize < 0`, matching the C convention of `(void*) -1`) on
//    error. Physical pages are not mapped here for a growing heap --
//    that happens lazily, the first time the process actually touches
//    the new range and takes a page fault (see kernel::exception's
//    INT_PAGEFAULT arm).
pub fn sys_sbrk(increment: i64) -> u64 {
    let result: u64;
    unsafe { asm!("int {0}", const INT_SYS_SBRK, in("rdi") increment, out("rax") result, options(nostack)) };
    result
}

// OTHER HELPER FUNCTIONS

// app_printf(colorid, args)
//    Calls console_printf. The cursor position is read from `cursorpos`, a
//    variable shared with the kernel, and written back into it. The
//    initial color is based on the current process ID.
pub fn app_printf(colorid: i32, args: fmt::Arguments) {
    let color: u16 = if colorid < 0 {
        0x0700
    } else {
        const COL: [u8; 5] = [0x0E, 0x0F, 0x0C, 0x0A, 0x09];
        (COL[(colorid as usize) % COL.len()] as u16) << 8
    };

    let pos = console_printf(cursorpos(), color, args);
    set_cursorpos(if crow(pos) >= 23 { cpos(0, 0) } else { pos });
}

#[macro_export]
macro_rules! app_printf {
    ($colorid:expr, $($arg:tt)*) => {
        $crate::app_printf($colorid, core::format_args!($($arg)*))
    };
}

// panic, assert_fail (ported from uspace/process.c)
//    Rust's `panic!`/`assert!` replace the hand-rolled versions here too.
//    Like the reference, this prints "PANIC: <file>:<line>: <message>" to
//    the console directly (a process can, since the console page is
//    mapped user-accessible) and then calls the INT_SYS_PANIC syscall with
//    a null pointer so the kernel loops until Control-C -- see
//    kernel::exception's INT_SYS_PANIC arm.
#[panic_handler]
fn panic(info: &PanicInfo) -> ! {
    if let Some(loc) = info.location() {
        if let Some(msg) = info.message() {
            console_printf(cpos(23, 0), 0xC000, format_args!("PANIC: {}:{}: {}\n", loc.file(), loc.line(), msg));
        } else {
            console_printf(cpos(23, 0), 0xC000, format_args!("PANIC: {}:{}\n", loc.file(), loc.line()));
        }
    } else {
        console_printf(cpos(23, 0), 0xC000, format_args!("PANIC\n"));
    }
    sys_panic(core::ptr::null());
}
