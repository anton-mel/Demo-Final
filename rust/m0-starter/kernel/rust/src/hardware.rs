// hardware.rs
//
//    Grody functions for interacting with x86 hardware.

use crate::kernel::{
    Proc, INT_HARDWARE, INT_TIMER, KERNEL_STACK_TOP, PROCINIT_ALLOW_PROGRAMMED_IO,
    PROCINIT_DISABLE_INTERRUPTS,
};
use crate::vm::virtual_memory_init;
use crate::x86_64::*;
use core::arch::asm;
use weensyos_shared::{console_printf, cpos, INT_SYS};

// hardware_init
//    Initialize hardware. Calls the functions below.

pub fn hardware_init() {
    segments_init();
    interrupt_init();
    unsafe { virtual_memory_init() };
}

// segments_init
//    Set up segment registers and interrupt descriptor table.
//
//    The segment registers distinguish the kernel from applications:
//    the kernel runs with segments SEGSEL_KERN_CODE and SEGSEL_KERN_DATA,
//    and applications with SEGSEL_APP_CODE and SEGSEL_APP_DATA.
//    The kernel segment runs with full privilege (level 0), but application
//    segments run with less privilege (level 3).
//
//    The interrupt descriptor table tells the processor where to jump
//    when an interrupt or exception happens. See k-exception.S.
//
//    The taskstate_t, segmentdescriptor_t, and pseduodescriptor_t types
//    are defined by the x86 hardware.

// Segment selectors
const SEGSEL_KERN_CODE: u64 = 0x8;  // kernel code segment
const SEGSEL_APP_CODE: u64  = 0x10; // application code segment
#[allow(unused)]                    // SEGSEL_KERN_DATA is not used
const SEGSEL_KERN_DATA: u64 = 0x18; // kernel data segment
const SEGSEL_APP_DATA: u64  = 0x20; // application data segment
const SEGSEL_TASKSTATE: u64 = 0x28; // task state segment

// Segments
static mut SEGMENTS: [u64; 7] = [0; 7];

fn set_app_segment(segment: &mut u64, ty: u64, dpl: u64) {
    *segment = ty | X86SEG_S | (dpl << 45) | X86SEG_P;
}

fn set_sys_segment(segment: &mut [u64], ty: u64, dpl: u64, addr: u64, size: u64) {
    segment[0] = ((addr & 0x0000000000FFFFFF) << 16)
        | ((addr & 0x00000000FF000000) << 32)
        | ((size - 1) & 0x0FFFF)
        | (((size - 1) & 0xF0000) << 48)
        | ty
        | (dpl << 45)
        | X86SEG_P;                 // segment present
    segment[1] = addr >> 32;
}

// Interrupt descriptors
static mut INTERRUPT_DESCRIPTORS: [X86_64Gatedescriptor; 256] =
    [X86_64Gatedescriptor { gd_low: 0, gd_high: 0 }; 256];

// Processor state for taking an interrupt
static mut KERNEL_TASK_DESCRIPTOR: X86_64Taskstate = X86_64Taskstate {
    ts_reserved0: 0,
    ts_rsp: [0; 3],
    ts_ist: [0; 7],
    ts_reserved1: 0,
    ts_reserved2: 0,
    ts_iomap_base: 0,
};

fn set_gate(gate: &mut X86_64Gatedescriptor, ty: u64, dpl: u64, function: u64) {
    gate.gd_low = (function & 0x000000000000FFFF)
        | (SEGSEL_KERN_CODE << 16)
        | ty
        | (dpl << 45)
        | X86SEG_P
        | ((function & 0x00000000FFFF0000) << 32);
    gate.gd_high = function >> 32;
}

// Particular interrupt handler routines, defined in k-exception.S
extern "C" {
    fn default_int_handler();
    fn gpf_int_handler();
    fn pagefault_int_handler();
    fn timer_int_handler();
    static sys_int_handlers: [unsafe extern "C" fn(); 16];
}

fn segments_init() {
    unsafe {
        // Segments for kernel & user code & data
        // The privilege level, which can be 0 or 3, differentiates between
        // kernel and user code. (Data segments are unused in WeensyOS.)
        SEGMENTS[0] = 0;
        set_app_segment(&mut SEGMENTS[(SEGSEL_KERN_CODE >> 3) as usize], X86SEG_X | X86SEG_L, 0);
        set_app_segment(&mut SEGMENTS[(SEGSEL_APP_CODE >> 3) as usize], X86SEG_X | X86SEG_L, 3);
        set_app_segment(&mut SEGMENTS[(SEGSEL_APP_DATA >> 3) as usize], X86SEG_W, 3);
        let ts_addr = (&KERNEL_TASK_DESCRIPTOR as *const X86_64Taskstate) as u64;
        let ts_size = core::mem::size_of::<X86_64Taskstate>() as u64;
        let tss_idx = (SEGSEL_TASKSTATE >> 3) as usize;
        set_sys_segment(&mut SEGMENTS[tss_idx..tss_idx + 2], X86SEG_TSS, 0, ts_addr, ts_size);

        let gdt = X86_64Pseudodescriptor {
            pseudod_limit: (core::mem::size_of_val(&SEGMENTS) - 1) as u16,
            pseudod_base: SEGMENTS.as_ptr() as u64,
        };

        // Kernel task descriptor lets us receive interrupts
        KERNEL_TASK_DESCRIPTOR.ts_rsp[0] = KERNEL_STACK_TOP;

        // Interrupt handler; most interrupts are effectively ignored
        for i in 16..INTERRUPT_DESCRIPTORS.len() {
            set_gate(&mut INTERRUPT_DESCRIPTORS[i], X86GATE_INTERRUPT, 0, default_int_handler as u64);
        }

        // Timer interrupt
        set_gate(&mut INTERRUPT_DESCRIPTORS[INT_TIMER as usize], X86GATE_INTERRUPT, 0, timer_int_handler as u64);

        // GPF and page fault
        set_gate(&mut INTERRUPT_DESCRIPTORS[INT_GPF as usize], X86GATE_INTERRUPT, 0, gpf_int_handler as u64);
        set_gate(&mut INTERRUPT_DESCRIPTORS[INT_PAGEFAULT as usize], X86GATE_INTERRUPT, 0, pagefault_int_handler as u64);

        // System calls get special handling.
        // Note that the last argument is '3'. This means that unprivileged
        // (level-3) applications may generate these interrupts.
        for i in 0..16 {
            set_gate(
                &mut INTERRUPT_DESCRIPTORS[INT_SYS as usize + i],
                X86GATE_INTERRUPT,
                3,
                sys_int_handlers[i] as u64,
            );
        }

        let idt = X86_64Pseudodescriptor {
            pseudod_limit: (core::mem::size_of_val(&INTERRUPT_DESCRIPTORS) - 1) as u16,
            pseudod_base: INTERRUPT_DESCRIPTORS.as_ptr() as u64,
        };

        // Reload segment pointers
        lgdt_ltr_lidt(&gdt, SEGSEL_TASKSTATE as u16, &idt);

        // Set up control registers: check alignment
        let cr0 = rcr0() | CR0_PE | CR0_PG | CR0_WP | CR0_AM | CR0_MP | CR0_NE;
        lcr0(cr0);
    }
}

// interrupt_init
//    Set up the interrupt controller (Intel part number 8259A).
//
//    Each interrupt controller supports up to 8 different kinds of interrupt.
//    The first x86s supported only one controller; this was too few, so modern
//    x86 machines can have more than one controller, a master and some slaves.
//    Much hoop-jumping is required to get the controllers to communicate!
//
//    Note: "IRQ" stands for "Interrupt ReQuest line", and stands for an
//    interrupt number.

// I/O Addresses of the two 8259A programmable interrupt controllers
const IO_PIC1: u16 = 0x20; // Master (IRQs 0-7)
const IO_PIC2: u16 = 0xA0; // Slave (IRQs 8-15)
const IRQ_SLAVE: u16 = 2; // IRQ at which slave connects to master

// Timer-related constants
const IO_TIMER1: u16 = 0x040; // 8253 Timer #1
const TIMER_MODE: u16 = IO_TIMER1 + 3; // timer mode port
const TIMER_SEL0: u8 = 0x00; // select counter 0
const TIMER_RATEGEN: u8 = 0x04; // mode 2, rate generator
const TIMER_16BIT: u8 = 0x30; // r/w counter 16 bits, LSB first

// Timer frequency: (TIMER_FREQ/freq) generates a frequency of 'freq' Hz.
const TIMER_FREQ: u32 = 1193182;
const fn timer_div(x: u32) -> u32 {
    (TIMER_FREQ + x / 2) / x
}

static mut INTERRUPTS_ENABLED: u16 = 0;

fn interrupt_mask() {
    unsafe {
        let masked = !INTERRUPTS_ENABLED;
        outb(IO_PIC1 + 1, (masked & 0xFF) as u8);
        outb(IO_PIC2 + 1, ((masked >> 8) & 0xFF) as u8);
    }
}

fn interrupt_init() {
    // mask all interrupts
    unsafe { INTERRUPTS_ENABLED = 0 };
    interrupt_mask();

    // Set up master (8259A-1)
    // ICW1:  0001g0hi
    //    g:  0 = edge triggering (1 = level triggering)
    //    h:  0 = cascaded PICs (1 = master only)
    //    i:  1 = ICW4 required (0 = no ICW4)
    outb(IO_PIC1, 0x11);
    // ICW2:  Trap offset. Interrupt 0 will cause trap INT_HARDWARE.
    outb(IO_PIC1 + 1, INT_HARDWARE as u8);
    // ICW3:  On master PIC, bit mask of IR lines connected to slave PICs;
    //        on slave PIC, IR line at which slave connects to master (0-8)
    outb(IO_PIC1 + 1, (1 << IRQ_SLAVE) as u8);
    // ICW4:  000nbmap
    //    n:  1 = special fully nested mode
    //    b:  1 = buffered mode
    //    m:  0 = slave PIC, 1 = master PIC
    //    a:  1 = Automatic EOI mode
    //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
    outb(IO_PIC1 + 1, 0x3);

    // Set up slave (8259A-2)
    outb(IO_PIC2, 0x11); // ICW1
    outb(IO_PIC2 + 1, (INT_HARDWARE + 8) as u8); // ICW2
    outb(IO_PIC2 + 1, IRQ_SLAVE as u8); // ICW3
    // NB Automatic EOI mode doesn't tend to work on the slave.
    outb(IO_PIC2 + 1, 0x01); // ICW4

    // OCW3:  0ef01prs
    //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
    //    p:  0 = no polling, 1 = polling mode
    //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
    outb(IO_PIC1, 0x68); // clear specific mask
    outb(IO_PIC1, 0x0a); // read IRR by default
    outb(IO_PIC2, 0x68); // OCW3
    outb(IO_PIC2, 0x0a); // OCW3

    // re-disable interrupts
    interrupt_mask();
}

// timer_init(rate)
//    Set the timer interrupt to fire `rate` times a second. Disables the
//    timer interrupt if `rate <= 0`.

pub fn timer_init(rate: i32) {
    unsafe {
        if rate > 0 {
            outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
            let div = timer_div(rate as u32);
            outb(IO_TIMER1, (div % 256) as u8);
            outb(IO_TIMER1, (div / 256) as u8);
            INTERRUPTS_ENABLED |= 1 << (INT_TIMER - INT_HARDWARE);
        } else {
            INTERRUPTS_ENABLED &= !(1 << (INT_TIMER - INT_HARDWARE));
        }
    }
    interrupt_mask();
}

// physical_memory_isreserved(pa)
//    Returns true iff `pa` is a reserved physical address.

const IOPHYSMEM: u64 = 0x000A0000;
const EXTPHYSMEM: u64 = 0x00100000;

pub fn physical_memory_isreserved(pa: u64) -> bool {
    pa == 0 || (pa >= IOPHYSMEM && pa < EXTPHYSMEM)
}

// pci_make_configaddr, pci_config_readl, pci_find_device
//    Just enough PCI config-space scanning to find the PIIX4 power
//    management controller for `poweroff`.

fn pci_make_configaddr(bus: u32, slot: u32, func: u32) -> u32 {
    (bus << 16) | (slot << 11) | (func << 8)
}

const PCI_HOST_BRIDGE_CONFIG_ADDR: u16 = 0xCF8;
const PCI_HOST_BRIDGE_CONFIG_DATA: u16 = 0xCFC;

fn pci_config_readl(configaddr: u32, offset: u32) -> u32 {
    outl(PCI_HOST_BRIDGE_CONFIG_ADDR, 0x80000000 | configaddr | offset);
    inl(PCI_HOST_BRIDGE_CONFIG_DATA)
}

fn pci_find_device(vendor: u32, device: u32) -> Option<u32> {
    for bus in 0..256 {
        for slot in 0..32 {
            for func in 0..8 {
                let configaddr = pci_make_configaddr(bus, slot, func);
                let vendor_device = pci_config_readl(configaddr, 0);
                if vendor_device == vendor | (device << 16) {
                    return Some(configaddr);
                } else if vendor_device == u32::MAX && func == 0 {
                    break;
                }
            }
        }
    }
    None
}

// poweroff
//    Turn off the virtual machine. This requires finding a PCI device
//    that speaks ACPI; QEMU emulates a PIIX4 Power Management Controller.

const PCI_VENDOR_ID_INTEL: u32 = 0x8086;
const PCI_DEVICE_ID_PIIX4: u32 = 0x7113;

pub fn poweroff() -> ! {
    if let Some(configaddr) = pci_find_device(PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_PIIX4) {
        // Read I/O base register from controller's PCI configuration space.
        let pm_io_base = pci_config_readl(configaddr, 0x40) & 0xFFC0;
        // Write `suspend enable` to the power management control register.
        outw((pm_io_base + 4) as u16, 0x2000);
    }
    // No PIIX4; spin.
    console_printf(cpos(24, 0), 0xC000, format_args!("Cannot power off!\n"));
    loop {}
}

// reboot
//    Reboot the virtual machine.

pub fn reboot() -> ! {
    outb(0x92, 3);
    loop {}
}

// process_init(p, flags)
//    Initialize special-purpose registers for process `p`.
//
//    `#[no_mangle] extern "C"`: kernel/k-vm.o (precompiled, no source
// available -- see kernel.rs) calls this by its plain C symbol name.
#[no_mangle]
pub extern "C" fn process_init(p: &mut Proc, flags: u32) {
    p.p_registers = X86_64Registers::zeroed();
    p.p_registers.reg_cs = (SEGSEL_APP_CODE | 3) as u16;
    p.p_registers.reg_fs = SEGSEL_APP_DATA | 3;
    p.p_registers.reg_gs = SEGSEL_APP_DATA | 3;
    p.p_registers.reg_ss = (SEGSEL_APP_DATA | 3) as u16;
    p.p_registers.reg_rflags = EFLAGS_IF;
    p.display_status = 1;

    if flags & PROCINIT_ALLOW_PROGRAMMED_IO != 0 {
        p.p_registers.reg_rflags |= EFLAGS_IOPL_3;
    }
    if flags & PROCINIT_DISABLE_INTERRUPTS != 0 {
        p.p_registers.reg_rflags &= !EFLAGS_IF;
    }
}

// console_show_cursor(cpos)
//    Move the console cursor to position `cpos`, which should be between 0
//    and 80 * 25.

pub fn console_show_cursor(mut cp: i32) {
    if !(0..=(weensyos_shared::CONSOLE_ROWS * weensyos_shared::CONSOLE_COLUMNS) as i32).contains(&cp) {
        cp = 0;
    }
    outb(0x3D4, 14);
    outb(0x3D5, (cp / 256) as u8);
    outb(0x3D4, 15);
    outb(0x3D5, (cp % 256) as u8);
}

// keyboard_readc
//    Read a character from the keyboard. Returns -1 if there is no character
//    to read, and 0 if no real key press was registered but you should call
//    keyboard_readc() again (e.g. the user pressed a SHIFT key). Otherwise
//    returns either an ASCII character code or one of the special characters
//    listed below.
//
//    Unfortunately mapping PC key codes to ASCII takes a lot of work.

pub const KEY_UP: i32 = 0o300;
pub const KEY_RIGHT: i32 = 0o301;
pub const KEY_DOWN: i32 = 0o302;
pub const KEY_LEFT: i32 = 0o303;
pub const KEY_HOME: i32 = 0o304;
pub const KEY_END: i32 = 0o305;
pub const KEY_PAGEUP: i32 = 0o306;
pub const KEY_PAGEDOWN: i32 = 0o307;
pub const KEY_INSERT: i32 = 0o310;
pub const KEY_DELETE: i32 = 0o311;

const MOD_SHIFT: u8 = 1 << 0;
const MOD_CONTROL: u8 = 1 << 1;
const MOD_CAPSLOCK: u8 = 1 << 3;

const KEY_SHIFT: i32 = 0o372;
const KEY_CONTROL: i32 = 0o373;
const KEY_ALT: i32 = 0o374;
const KEY_CAPSLOCK: i32 = 0o375;
const KEY_NUMLOCK: i32 = 0o376;
const KEY_SCROLLLOCK: i32 = 0o377;

const fn ckey(cn: i32) -> i32 {
    0x80 + cn
}

#[rustfmt::skip]
static KEYMAP: [i32; 256] = [
    /*0x00*/ 0, 0o33, ckey(0), ckey(1), ckey(2), ckey(3), ckey(4), ckey(5),
        ckey(6), ckey(7), ckey(8), ckey(9), ckey(10), ckey(11), 8 /* \b */, 9 /* \t */,
    /*0x10*/ 'q' as i32, 'w' as i32, 'e' as i32, 'r' as i32, 't' as i32, 'y' as i32, 'u' as i32, 'i' as i32,
        'o' as i32, 'p' as i32, ckey(12), ckey(13), ckey(14), KEY_CONTROL, 'a' as i32, 's' as i32,
    /*0x20*/ 'd' as i32, 'f' as i32, 'g' as i32, 'h' as i32, 'j' as i32, 'k' as i32, 'l' as i32, ckey(15),
        ckey(16), ckey(17), KEY_SHIFT, ckey(18), 'z' as i32, 'x' as i32, 'c' as i32, 'v' as i32,
    /*0x30*/ 'b' as i32, 'n' as i32, 'm' as i32, ckey(19), ckey(20), ckey(21), KEY_SHIFT, '*' as i32,
        KEY_ALT, ' ' as i32, KEY_CAPSLOCK, 0, 0, 0, 0, 0,
    /*0x40*/ 0, 0, 0, 0, 0, KEY_NUMLOCK, KEY_SCROLLLOCK, '7' as i32,
        '8' as i32, '9' as i32, '-' as i32, '4' as i32, '5' as i32, '6' as i32, '+' as i32, '1' as i32,
    /*0x50*/ '2' as i32, '3' as i32, '0' as i32, '.' as i32, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0,
    /*0x60*/ 0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0,
    /*0x70*/ 0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0,
    /*0x80*/ 0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0,
    /*0x90*/ 0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, ckey(14), KEY_CONTROL, 0, 0,
    /*0xA0*/ 0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0,
    /*0xB0*/ 0, 0, 0, 0, 0, '/' as i32, 0, 0,  KEY_ALT, 0, 0, 0, 0, 0, 0, 0,
    /*0xC0*/ 0, 0, 0, 0, 0, 0, 0, KEY_HOME,
        KEY_UP, KEY_PAGEUP, 0, KEY_LEFT, 0, KEY_RIGHT, 0, KEY_END,
    /*0xD0*/ KEY_DOWN, KEY_PAGEDOWN, KEY_INSERT, KEY_DELETE, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0,
    /*0xE0*/ 0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0,
    /*0xF0*/ 0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0,
];

// CKEY(0)..CKEY(21): keys whose ASCII value depends on the shift state.
#[rustfmt::skip]
static COMPLEX_KEYMAP: [[u8; 4]; 22] = [
    /*CKEY(0)*/ [b'1', b'!', 0, 0],  /*CKEY(1)*/ [b'2', b'@', 0, 0],
    /*CKEY(2)*/ [b'3', b'#', 0, 0],  /*CKEY(3)*/ [b'4', b'$', 0, 0],
    /*CKEY(4)*/ [b'5', b'%', 0, 0],  /*CKEY(5)*/ [b'6', b'^', 0, 0o36],
    /*CKEY(6)*/ [b'7', b'&', 0, 0],  /*CKEY(7)*/ [b'8', b'*', 0, 0],
    /*CKEY(8)*/ [b'9', b'(', 0, 0],  /*CKEY(9)*/ [b'0', b')', 0, 0],
    /*CKEY(10)*/ [b'-', b'_', 0, 0o37],  /*CKEY(11)*/ [b'=', b'+', 0, 0],
    /*CKEY(12)*/ [b'[', b'{', 0o33, 0],  /*CKEY(13)*/ [b']', b'}', 0o35, 0],
    /*CKEY(14)*/ [b'\n', b'\n', b'\r', b'\r'],
    /*CKEY(15)*/ [b';', b':', 0, 0],
    /*CKEY(16)*/ [b'\'', b'"', 0, 0],  /*CKEY(17)*/ [b'`', b'~', 0, 0],
    /*CKEY(18)*/ [b'\\', b'|', 0o34, 0],  /*CKEY(19)*/ [b',', b'<', 0, 0],
    /*CKEY(20)*/ [b'.', b'>', 0, 0],  /*CKEY(21)*/ [b'/', b'?', 0, 0],
];

static mut MODIFIERS: u8 = 0;
static mut LAST_ESCAPE: u8 = 0;

pub fn keyboard_readc() -> i32 {
    unsafe {
        if (inb(KEYBOARD_STATUSREG) & KEYBOARD_STATUS_READY) == 0 {
            return -1;
        }

        let data = inb(KEYBOARD_DATAREG);
        let escape = LAST_ESCAPE;
        LAST_ESCAPE = 0;

        if data == 0xE0 {
            // mode shift
            LAST_ESCAPE = 0x80;
            return 0;
        } else if data & 0x80 != 0 {
            // key release: matters only for modifier keys
            let ch = KEYMAP[((data & 0x7F) as usize) | escape as usize];
            if ch >= KEY_SHIFT && ch < KEY_CAPSLOCK {
                MODIFIERS &= !(1 << (ch - KEY_SHIFT));
            }
            return 0;
        }

        let mut ch = KEYMAP[(data as usize) | escape as usize];

        if (b'a' as i32..=b'z' as i32).contains(&ch) {
            if MODIFIERS & MOD_CONTROL != 0 {
                ch -= 0x60;
            } else if (MODIFIERS & MOD_SHIFT != 0) != (MODIFIERS & MOD_CAPSLOCK != 0) {
                ch -= 0x20;
            }
        } else if ch >= KEY_CAPSLOCK {
            MODIFIERS ^= 1 << (ch - KEY_SHIFT);
            ch = 0;
        } else if ch >= KEY_SHIFT {
            MODIFIERS |= 1 << (ch - KEY_SHIFT);
            ch = 0;
        } else if (ckey(0)..=ckey(21)).contains(&ch) {
            ch = COMPLEX_KEYMAP[(ch - ckey(0)) as usize][(MODIFIERS & 3) as usize] as i32;
        } else if ch < 0x80 && MODIFIERS & MOD_CONTROL != 0 {
            ch = 0;
        }

        ch
    }
}

// log_printf
//    Print debugging messages to the host's `log.txt` file. We run QEMU so
//    that messages written to the QEMU "parallel port" end up in `log.txt`.

const IO_PARALLEL1_DATA: u16 = 0x378;
const IO_PARALLEL1_STATUS: u16 = 0x379;
const IO_PARALLEL_STATUS_BUSY: u8 = 0x80;
const IO_PARALLEL1_CONTROL: u16 = 0x37A;
const IO_PARALLEL_CONTROL_SELECT: u8 = 0x08;
const IO_PARALLEL_CONTROL_INIT: u8 = 0x04;
const IO_PARALLEL_CONTROL_STROBE: u8 = 0x01;

fn delay() {
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}

fn parallel_port_putc(c: u8) {
    static mut INITIALIZED: bool = false;
    unsafe {
        if !INITIALIZED {
            outb(IO_PARALLEL1_CONTROL, 0);
            INITIALIZED = true;
        }
    }
    for _ in 0..12800 {
        if inb(IO_PARALLEL1_STATUS) & IO_PARALLEL_STATUS_BUSY != 0 {
            break;
        }
        delay();
    }
    outb(IO_PARALLEL1_DATA, c);
    outb(IO_PARALLEL1_CONTROL, IO_PARALLEL_CONTROL_SELECT | IO_PARALLEL_CONTROL_INIT | IO_PARALLEL_CONTROL_STROBE);
    outb(IO_PARALLEL1_CONTROL, IO_PARALLEL_CONTROL_SELECT | IO_PARALLEL_CONTROL_INIT);
}

struct LogWriter;

impl core::fmt::Write for LogWriter {
    fn write_str(&mut self, s: &str) -> core::fmt::Result {
        for &b in s.as_bytes() {
            parallel_port_putc(b);
        }
        Ok(())
    }
}

/// Writes to the host's `log.txt` file (via the QEMU "parallel port").
/// Use via the `log_printf!` macro.
pub fn log_fmt(args: core::fmt::Arguments) {
    use core::fmt::Write;
    let _ = LogWriter.write_fmt(args);
}

#[macro_export]
macro_rules! log_printf {
    ($($arg:tt)*) => {
        $crate::hardware::log_fmt(core::format_args!($($arg)*))
    };
}

/// Writes to both the console and `log.txt`, like the reference's
/// `error_printf` (used by `panic()`, see lib.rs's panic handler).
pub fn error_fmt(cp: i32, color: u16, args: core::fmt::Arguments) -> i32 {
    log_fmt(args);
    console_printf(cp, color, args)
}

// check_keyboard
//    Check for the user typing a control key. 'a', 'm', 'c', 't', and '2'
//    cause a soft reboot where the kernel runs the allocator programs,
//    "malloc", "alloctests", "test", or "test2", respectively. Control-C or
//    'q' exit the virtual machine. Returns key typed or -1 for no key.

pub fn check_keyboard() -> i32 {
    let c = keyboard_readc();
    if c == 'a' as i32 || c == 'm' as i32 || c == 'c' as i32 || c == 't' as i32 || c == '2' as i32 {
        // Install a temporary page table to carry us through the process of
        // reinitializing memory. This replicates work the bootloader does.
        unsafe {
            let pt = 0x8000 as *mut u8;
            core::ptr::write_bytes(pt, 0, (PAGESIZE * 3) as usize);
            *(0x8000 as *mut u64) = 0x9000 | PTE_P | PTE_W | PTE_U;
            *(0x9000 as *mut u64) = 0xA000 | PTE_P | PTE_W | PTE_U;
            *(0xA000 as *mut u64) = PTE_P | PTE_W | PTE_U | PTE_PS;
        }
        lcr3(0x8000);

        let argument: &[u8] = if c == 'a' as i32 {
            b"allocator\0"
        } else if c == 'c' as i32 {
            b"alloctests\0"
        } else if c == 't' as i32 {
            b"test\0"
        } else if c == '2' as i32 {
            b"test2\0"
        } else {
            b"malloc\0"
        };
        // The soft reboot process doesn't modify memory, so it's safe to
        // pass `multiboot_info` on the kernel stack, even though it will
        // get overwritten as the kernel runs.
        let multiboot_info: [u32; 5] = [4, 0, 0, 0, argument.as_ptr() as u32];
        unsafe {
            // rbx can't be a tracked asm! operand (LLVM reserves it), so we
            // load it from a scratch register inside the template instead.
            asm!(
                "mov ebx, {info:e}",
                "mov eax, 0x2BADB002",
                "jmp entry_from_boot",
                info = in(reg) multiboot_info.as_ptr(),
                options(noreturn),
            );
        }
    } else if c == 0x03 || c == 'q' as i32 {
        poweroff();
    }
    c
}

// fail
//    Loop until user presses Control-C, then poweroff.

pub fn fail() -> ! {
    loop {
        check_keyboard();
    }
}

// assert_fail(file, line, msg) (ported from k-hardware.c)
//    Called by C's `assert()` macro on failure. `#[no_mangle]`:
//    kernel/k-vm.o (precompiled, no source available -- see kernel.rs)
//    calls this by its plain C symbol name.
#[no_mangle]
pub unsafe extern "C" fn assert_fail(file: *const u8, line: i32, msg: *const u8) -> ! {
    panic!("{}:{}: assertion '{}' failed", cstr_to_str(file), line, cstr_to_str(msg));
}

unsafe fn cstr_to_str<'a>(ptr: *const u8) -> &'a str {
    if ptr.is_null() {
        return "";
    }
    let mut len = 0usize;
    while *ptr.add(len) != 0 {
        len += 1;
    }
    core::str::from_utf8_unchecked(core::slice::from_raw_parts(ptr, len))
}

// console_printf/log_printf (ported from shared/lib.c)
//    Real C code (`kernel/k-vm.o`, precompiled -- see kernel.rs) calls
//    these as variadic functions (`int console_printf(int, int, const
//    char*, ...)`). Implementing a genuine C-ABI-compatible printf
//    clone (parsing %d/%x/%p/%s and consuming a C va_list) is out of
//    scope for what these bridges actually need to do here: every call
//    site k-vm.o has for them is a diagnostic/error-path print, never
//    something this pset's correctness depends on. So these print the
//    format string as a literal, unsubstituted string and otherwise
//    ignore any variadic arguments -- safe at the ABI level (a callee
//    that never reads a register/stack slot for an argument it doesn't
//    declare doesn't corrupt anything), just cosmetically imprecise if
//    one of these paths is ever actually hit (e.g. a real "%d" would
//    show up literally instead of a substituted number).
//
//    `#[export_name]` rather than a same-named `#[no_mangle]` function,
//    since `console_printf` here would otherwise collide with the
//    ordinary, type-safe `weensyos_shared::console_printf` this same
//    file already imports and uses for its own formatting.
#[export_name = "console_printf"]
pub unsafe extern "C" fn c_console_printf_bridge(cp: i32, color: i32, format: *const u8) -> i32 {
    console_printf(cp, color as u16, format_args!("{}", cstr_to_str(format)))
}

#[export_name = "log_printf"]
pub unsafe extern "C" fn c_log_printf_bridge(format: *const u8) {
    log_fmt(format_args!("{}", cstr_to_str(format)));
}

pub fn default_exception(p: &mut Proc) {
    let intno = p.p_registers.reg_intno;
    panic!("Unexpected exception {}!", intno);
}
