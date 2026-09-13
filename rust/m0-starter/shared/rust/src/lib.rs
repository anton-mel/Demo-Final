// lib.rs
//
//    Functions, constants, and definitions useful in both the kernel
//    and applications.

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
