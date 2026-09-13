// console.rs (ported from shared/lib.c/lib.h: console printing)
//
//    Rust's `core::fmt` already gives us a real, safe formatting engine, so
//    unlike lib.c's hand-rolled `printer_vprintf` we build `console_printf`
//    directly on `core::fmt::Write` and the `format_args!`/`write!` macros.
//
//    `console` and `cursorpos` live at fixed addresses within the single
//    CGA console page (see link/shared.ld's PROVIDE(console = 0xB8000) in
//    the C original) so that the page mapped into every process's address
//    space, and only that page, is enough to read/write both.

use core::fmt;

pub const CONSOLE_COLUMNS: usize = 80;
pub const CONSOLE_ROWS: usize = 25;
pub const CONSOLE_ADDR: u64 = 0xB8000;
const CURSORPOS_ADDR: u64 = 0xB8FFC;

pub const fn cpos(row: i32, col: i32) -> i32 {
    row * CONSOLE_COLUMNS as i32 + col
}
pub const fn crow(cpos: i32) -> i32 {
    cpos / CONSOLE_COLUMNS as i32
}
pub const fn ccol(cpos: i32) -> i32 {
    cpos % CONSOLE_COLUMNS as i32
}

// current position of the cursor (80 * ROW + COL)
pub fn cursorpos() -> i32 {
    unsafe { *(CURSORPOS_ADDR as *const i32) }
}
pub fn set_cursorpos(pos: i32) {
    unsafe { *(CURSORPOS_ADDR as *mut i32) = pos };
}

fn console_buf() -> &'static mut [u16; CONSOLE_ROWS * CONSOLE_COLUMNS] {
    unsafe { &mut *(CONSOLE_ADDR as *mut [u16; CONSOLE_ROWS * CONSOLE_COLUMNS]) }
}

// console_clear
//    Erases the console and moves the cursor to the upper left (cpos(0, 0)).
pub fn console_clear() {
    for cell in console_buf().iter_mut() {
        *cell = b' ' as u16 | 0x0700;
    }
    set_cursorpos(0);
}

struct ConsoleWriter {
    pos: usize,
    color: u16,
}

impl fmt::Write for ConsoleWriter {
    fn write_str(&mut self, s: &str) -> fmt::Result {
        let buf = console_buf();
        for &byte in s.as_bytes() {
            if self.pos >= buf.len() {
                self.pos = 0;
            }
            if byte == b'\n' {
                while self.pos % CONSOLE_COLUMNS != 0 {
                    buf[self.pos] = b' ' as u16 | self.color;
                    self.pos += 1;
                    if self.pos >= buf.len() {
                        self.pos = 0;
                    }
                }
            } else {
                buf[self.pos] = byte as u16 | self.color;
                self.pos += 1;
            }
        }
        Ok(())
    }
}

// console_printf(cpos, color, args)
//    Format and print a message to the x86 console, starting at cursor
//    position `cpos` in color `color` (e.g. 0x0700 for grey on black).
//    Returns the final position of the cursor. Call via the `format_args!`
//    macro, e.g. `console_printf(cpos(23, 0), 0xC000, format_args!("{}", x))`.
pub fn console_printf(cpos: i32, color: u16, args: fmt::Arguments) -> i32 {
    use fmt::Write;
    let start = if cpos < 0 || cpos as usize >= CONSOLE_ROWS * CONSOLE_COLUMNS { 0 } else { cpos as usize };
    let mut writer = ConsoleWriter { pos: start, color };
    let _ = writer.write_fmt(args);
    writer.pos as i32
}

#[macro_export]
macro_rules! console_printf {
    ($cpos:expr, $color:expr, $($arg:tt)*) => {
        $crate::console::console_printf($cpos, $color, core::format_args!($($arg)*))
    };
}
