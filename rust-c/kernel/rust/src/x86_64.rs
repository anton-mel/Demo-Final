// x86_64.rs
//
//    Rust code to interface with x86 hardware and CPU.
//
//    Contents:
//    - Memory and interrupt constants.
//    - X86_64Registers: Used in process descriptors to store x86 registers.
//    - x86 functions: wrappers for useful x86 instructions.
//    - Hardware structures: structures and constants for initializing
//      x86 hardware, including the interrupt descriptor table.

use core::arch::asm;

// Paged memory constants
pub const PAGEOFFBITS: u32 = 12;            // # bits in page offset
pub const PAGESIZE: u64 = 1 << PAGEOFFBITS; // Size of page in bytes
pub const PAGEINDEXBITS: u32 = 9;           // # bits in a page index level
pub const NPAGETABLEENTRIES: usize = 1 << PAGEINDEXBITS; // # entries in page table page

pub const fn page_number(ptr: u64) -> i32 {
    (ptr >> PAGEOFFBITS) as i32
}
pub const fn page_address(pn: i32) -> u64 {
    (pn as u64) << PAGEOFFBITS
}

// Page table entry type and page table type
pub type X86_64PageentryT = u64;

#[repr(C, align(4096))]
#[derive(Clone, Copy)]
pub struct X86_64Pagetable {
    pub entry: [X86_64PageentryT; NPAGETABLEENTRIES],
}

// Parts of a paged address: page index, page offset
pub fn pageindex(addr: u64, level: u32) -> usize {
    debug_assert!(level <= 3);
    ((addr >> (PAGEOFFBITS + (3 - level) * PAGEINDEXBITS)) & 0x1FF) as usize
}
pub fn l1pageindex(addr: u64) -> usize {
    pageindex(addr, 3)
}
pub fn l2pageindex(addr: u64) -> usize {
    pageindex(addr, 2)
}
pub fn l3pageindex(addr: u64) -> usize {
    pageindex(addr, 1)
}
pub fn l4pageindex(addr: u64) -> usize {
    pageindex(addr, 0)
}
pub const PAGEOFFMASK: u64 = PAGESIZE - 1;
pub const fn page_offset(addr: u64) -> u64 {
    addr & PAGEOFFMASK
}

// The physical address contained in a page table entry
pub const fn pte_addr(pageentry: X86_64PageentryT) -> u64 {
    pageentry & !0xFFF
}

// Page table entry flags
pub const fn pte_flags(pageentry: X86_64PageentryT) -> u64 { pageentry & 0xFFF }
// - Permission flags: define whether page is accessible
pub const PTE_P: X86_64PageentryT = 1; // entry is Present
pub const PTE_W: X86_64PageentryT = 2; // entry is Writeable
pub const PTE_U: X86_64PageentryT = 4; // entry is User-accessible
// - Accessed flags: automatically turned on by processor
pub const PTE_A: X86_64PageentryT = 32; // entry was Accessed (read/written)
pub const PTE_D: X86_64PageentryT = 64; // entry was Dirtied (written)
pub const PTE_PS: X86_64PageentryT = 128; // entry has a large Page Size
// - There are other flags too!

// Page fault error flags
// These bits are stored in X86_64Registers::reg_err after a page fault trap.
pub const PFERR_PRESENT: u64 = 0x1; // protection violation (rather than missing page)
pub const PFERR_WRITE: u64 = 0x2; // fault happened on a write
pub const PFERR_USER: u64 = 0x4; // fault happened in an application (user mode)

// struct X86_64Registers
//     A complete set of x86-64 general-purpose registers, plus some
//     special-purpose registers. The order and contents are defined to make
//     it more convenient to use important x86-64 instructions (see
//     k-exception.S, which pushes/pops exactly this layout).
#[repr(C)]
#[derive(Clone, Copy)]
pub struct X86_64Registers {
    pub reg_rax: u64,
    pub reg_rcx: u64,
    pub reg_rdx: u64,
    pub reg_rbx: u64,
    pub reg_rbp: u64,
    pub reg_rsi: u64,
    pub reg_rdi: u64,
    pub reg_r8: u64,
    pub reg_r9: u64,
    pub reg_r10: u64,
    pub reg_r11: u64,
    pub reg_r12: u64,
    pub reg_r13: u64,
    pub reg_r14: u64,
    pub reg_r15: u64,
    pub reg_fs: u64,
    pub reg_gs: u64,

    pub reg_intno: u64,         // (3) Interrupt number and error
    pub reg_err: u64,           // code (optional; supplied by x86 interrupt mechanism)

    pub reg_rip: u64,           // (4) Task status: instruction pointer,
    pub reg_cs: u16,            // code segment, flags, stack
    pub reg_padding2: [u16; 3], // in the order required by `iretq`
    pub reg_rflags: u64,
    pub reg_rsp: u64,
    pub reg_ss: u16,
    pub reg_padding3: [u16; 3],
}

impl X86_64Registers {
    pub const fn zeroed() -> Self {
        X86_64Registers {
            reg_rax: 0, reg_rcx: 0, reg_rdx: 0, reg_rbx: 0, reg_rbp: 0,
            reg_rsi: 0, reg_rdi: 0, reg_r8: 0, reg_r9: 0, reg_r10: 0,
            reg_r11: 0, reg_r12: 0, reg_r13: 0, reg_r14: 0, reg_r15: 0,
            reg_fs: 0, reg_gs: 0, reg_intno: 0, reg_err: 0, reg_rip: 0,
            reg_cs: 0, reg_padding2: [0; 3], reg_rflags: 0, reg_rsp: 0,
            reg_ss: 0, reg_padding3: [0; 3],
        }
    }
}

// Interrupt numbers
pub const INT_DIVIDE: u64 = 0x0; // Divide error
pub const INT_DEBUG: u64 = 0x1; // Debug exception
pub const INT_BREAKPOINT: u64 = 0x3; // Breakpoint
pub const INT_OVERFLOW: u64 = 0x4; // Overflow
pub const INT_BOUNDS: u64 = 0x5; // Bounds check
pub const INT_INVALIDOP: u64 = 0x6; // Invalid opcode
pub const INT_DOUBLEFAULT: u64 = 0x8; // Double fault
pub const INT_INVALIDTSS: u64 = 0xa; // Invalid TSS
pub const INT_SEGMENT: u64 = 0xb; // Segment not present
pub const INT_STACK: u64 = 0xc; // Stack exception
pub const INT_GPF: u64 = 0xd; // General protection fault
pub const INT_PAGEFAULT: u64 = 0xe; // Page fault

// x86 functions: wrappers that execute useful x86 instructions.
//
//      Also some constants corresponding to x86 register flag bits.

#[inline(always)]
pub fn breakpoint() {
    unsafe { asm!("int3") };
}

#[inline(always)]
pub fn inb(port: u16) -> u8 {
    let data: u8;
    unsafe { asm!("in al, dx", out("al") data, in("dx") port, options(nomem, nostack, preserves_flags)) };
    data
}

#[inline(always)]
pub fn insl(port: u16, addr: *mut u32, cnt: usize) {
    unsafe {
        asm!("cld", "rep insd", inout("edi") addr => _, inout("ecx") cnt => _, in("dx") port,
             options(nostack));
    }
}

#[inline(always)]
pub fn outb(port: u16, data: u8) {
    unsafe { asm!("out dx, al", in("dx") port, in("al") data, options(nomem, nostack, preserves_flags)) };
}

#[inline(always)]
pub fn outw(port: u16, data: u16) {
    unsafe { asm!("out dx, ax", in("dx") port, in("ax") data, options(nomem, nostack, preserves_flags)) };
}

#[inline(always)]
pub fn outl(port: u16, data: u32) {
    unsafe { asm!("out dx, eax", in("dx") port, in("eax") data, options(nomem, nostack, preserves_flags)) };
}

#[inline(always)]
pub fn inl(port: u16) -> u32 {
    let data: u32;
    unsafe { asm!("in eax, dx", out("eax") data, in("dx") port, options(nomem, nostack, preserves_flags)) };
    data
}

#[inline(always)]
pub fn invlpg(addr: u64) {
    unsafe { asm!("invlpg [{}]", in(reg) addr, options(nostack)) };
}

#[inline(always)]
pub unsafe fn lgdt_ltr_lidt(gdt_ptr: &X86_64Pseudodescriptor, tss_selector: u16, idt_ptr: &X86_64Pseudodescriptor) {
    asm!(
        "lgdt [{gdt}]",
        "ltr {tss:x}",
        "lidt [{idt}]",
        gdt = in(reg) gdt_ptr,
        tss = in(reg) tss_selector,
        idt = in(reg) idt_ptr,
        options(nostack),
    );
}

#[inline(always)]
pub fn lcr0(val: u32) {
    unsafe { asm!("mov cr0, {:r}", in(reg) (val as u64), options(nostack)) };
}
#[inline(always)]
pub fn rcr0() -> u32 {
    let val: u64;
    unsafe { asm!("mov {}, cr0", out(reg) val, options(nostack)) };
    val as u32
}
#[inline(always)]
pub fn rcr2() -> u64 {
    let val: u64;
    unsafe { asm!("mov {}, cr2", out(reg) val, options(nostack)) };
    val
}
#[inline(always)]
pub fn lcr3(val: u64) {
    unsafe { asm!("mov cr3, {}", in(reg) val, options(nostack)) };
}
#[inline(always)]
pub fn rcr3() -> u64 {
    let val: u64;
    unsafe { asm!("mov {}, cr3", out(reg) val, options(nostack)) };
    val
}

#[inline(always)]
pub fn cli() {
    unsafe { asm!("cli", options(nostack)) };
}
#[inline(always)]
pub fn sti() {
    unsafe { asm!("sti", options(nostack)) };
}

#[inline(always)]
pub fn read_rsp() -> u64 {
    let rsp: u64;
    unsafe { asm!("mov {}, rsp", out(reg) rsp, options(nostack)) };
    rsp
}

#[inline(always)]
pub fn read_cycle_counter() -> u64 {
    let (lo, hi): (u32, u32);
    unsafe { asm!("rdtsc", out("eax") lo, out("edx") hi, options(nostack)) };
    ((hi as u64) << 32) | (lo as u64)
}

// %cr0 flag bits (useful for lcr0() and rcr0())
pub const CR0_PE: u32 = 0x00000001; // Protection Enable
pub const CR0_WP: u32 = 0x00010000; // Write Protect
pub const CR0_AM: u32 = 0x00040000; // Alignment Mask
pub const CR0_MP: u32 = 0x00000002; // Monitor coProcessor
pub const CR0_NE: u32 = 0x00000020; // Numeric Error
pub const CR0_PG: u32 = 0x80000000; // Paging

// eflags bits (useful for process registers)
pub const EFLAGS_IF: u64 = 0x00000200; // Interrupt Flag
pub const EFLAGS_IOPL_3: u64 = 0x00003000; // IOPL == 3

// Hardware definitions: structures and constants for initializing x86
// hardware, particularly gate descriptors (loaded into the interrupt
// descriptor table) and segment descriptors.

// Pseudo-descriptors used for LGDT, LLDT, and LIDT instructions
#[repr(C, packed)]
#[derive(Clone, Copy)]
pub struct X86_64Pseudodescriptor {
    pub pseudod_limit: u16, // Limit
    pub pseudod_base: u64,  // Base address
}

// Task state structure defines kernel stack for interrupt handlers
#[repr(C, packed)]
#[derive(Clone, Copy)]
pub struct X86_64Taskstate {
    pub ts_reserved0: u32,
    pub ts_rsp: [u64; 3],
    pub ts_ist: [u64; 7],
    pub ts_reserved1: u64,
    pub ts_reserved2: u16,
    pub ts_iomap_base: u16,
}

// Gate descriptor structure defines interrupt handlers
#[repr(C)]
#[derive(Clone, Copy)]
pub struct X86_64Gatedescriptor {
    pub gd_low: u64,
    pub gd_high: u64,
}

// Segment bits
pub const X86SEG_S: u64 = 1 << 44;
pub const X86SEG_P: u64 = 1 << 47;
pub const X86SEG_L: u64 = 1 << 53;

// Application segment type bits
pub const X86SEG_W: u64 = 0x2 << 40; // Writable (data segment)
pub const X86SEG_X: u64 = 0x8 << 40; // Executable (== is code segment)

// System segment/interrupt descriptor types
pub const X86SEG_TSS: u64 = 0x9 << 40;
pub const X86GATE_INTERRUPT: u64 = 0xE << 40;

// Keyboard programmed I/O
pub const KEYBOARD_STATUSREG: u16 = 0x64;
pub const KEYBOARD_STATUS_READY: u8 = 0x01;
pub const KEYBOARD_DATAREG: u16 = 0x60;
