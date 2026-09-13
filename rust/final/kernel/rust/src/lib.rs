// lib.rs
//
//    To write an operating system kernel, we need code that does not depend
//    on any operating system features: no threads, files, heap memory, the
//    network, or other OS/libc abstractions. This crate is `no_std` for
//    exactly that reason.
//
//    This crate builds as a `staticlib` (see Cargo.toml); the GNUmakefile
//    links the resulting object files together with k-exception.S, boot.c,
//    and bootstart.S using the link/ scripts.

#![no_std]
#![no_main]
#![feature(panic_info_message)]
#![allow(static_mut_refs)]
#![allow(unused_variables, unused_mut)]

pub mod elf;
pub mod hardware;
pub mod kernel;
pub mod kloader;
pub mod vm;
pub mod x86_64;

use core::fmt::Write;
use core::panic::PanicInfo;

#[no_mangle]
pub extern "C" fn rust_eh_personality() {}

// panic, assert_fail
//    Use console_printf() to print a failure message and then wait for
//    control-C. Also write the failure message to the log.

#[panic_handler]
fn panic(info: &PanicInfo) -> ! {
    let mut buf = [0u8; 256];
    let mut writer = BufWriter { buf: &mut buf, pos: 0 };
    let _ = write!(writer, "PANIC: ");
    if let Some(loc) = info.location() {
        let _ = write!(writer, "{}:{}: ", loc.file(), loc.line());
    }
    if let Some(msg) = info.message() {
        let _ = write!(writer, "{}", msg);
    }
    let _ = writeln!(writer);
    let len = writer.pos;

    let msg = core::str::from_utf8(&buf[..len]).unwrap_or("PANIC");
    hardware::error_fmt(weensyos_shared::cpos(23, 0), 0xC000, format_args!("{}", msg));
    hardware::fail();
}

struct BufWriter<'a> {
    buf: &'a mut [u8],
    pos: usize,
}

impl core::fmt::Write for BufWriter<'_> {
    fn write_str(&mut self, s: &str) -> core::fmt::Result {
        for &b in s.as_bytes() {
            if self.pos >= self.buf.len() {
                break;
            }
            self.buf[self.pos] = b;
            self.pos += 1;
        }
        Ok(())
    }
}
