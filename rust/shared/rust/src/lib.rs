// lib.rs (ported from shared/lib.h + shared/lib.c)
//
//    Functions, constants, and definitions useful in both the kernel
//    and applications.
//
//    Contents: (1) C library subset, (2) system call numbers, (3) console.
//
//    Rust's `core` already provides memcpy/memset/strlen-equivalents and a
//    real formatting engine (`core::fmt`), so this module only carries what
//    `core` does not: the syscall numbers, `VaMapping`, `rand`/`srand`, the
//    `ROUNDUP`/`ROUNDDOWN` helpers, and a console writer built on
//    `core::fmt::Write`.
#![no_std]

pub mod clib;
pub mod console;
pub mod syscalls;

pub use clib::{rand, round_down, round_up, srand, VaMapping};
pub use console::{
    ccol, console_clear, console_printf, cpos, crow, cursorpos, set_cursorpos,
    CONSOLE_ADDR, CONSOLE_COLUMNS, CONSOLE_ROWS,
};
pub use syscalls::*;
