// kernel.rs (ported from kernel/kernel.c + kernel/kernel.h)
//
//    This is the kernel.
//
//    This is the CS3230 *final project* starter (brk/sbrk + user-space
//    malloc, layered on top of a complete WeensyOS Project 5), not
//    Project 5 itself -- see uspace/malloc for the actual pset TODOs.
//    Process creation/fork/exit/page-alloc are themselves given here,
//    provided in compiled form as kernel/k-vm.o (no source available),
//    exactly like the C starter: this file calls them through a small
//    `extern "C"` boundary instead of reimplementing logic nobody has
//    the spec for.

use crate::hardware::{check_keyboard, console_show_cursor, default_exception, hardware_init, process_init, timer_init};
use crate::vm::{kernel_pagetable, set_pagetable, virtual_memory_lookup};
use crate::x86_64::*;
use weensyos_shared::*;

// INITIAL PHYSICAL MEMORY LAYOUT
//
//  +-------------- Base Memory --------------+
//  v                                         v
// +-----+--------------------+----------------+--------------------+---------/
// |     | Kernel      Kernel |       :    I/O | App 1        App 1 | App 2
// |     | Code + Data  Stack |  ...  : Memory | Code + Data  Stack | Code ...
// +-----+--------------------+----------------+--------------------+---------/
// 0  0x40000              0x80000 0xA0000 0x100000             0x140000
//                                             ^
//                                             | \___ PROC_SIZE ___/
//                                      PROC_START_ADDR

#[allow(dead_code)]
const PROC_SIZE: u64 = 0x40000; // initial state only

// Process state type
pub type Procstate = u32;
pub const P_FREE: Procstate = 0; // free slot
pub const P_RUNNABLE: Procstate = 1; // runnable process
#[allow(dead_code)]
pub const P_BLOCKED: Procstate = 2; // blocked process
pub const P_BROKEN: Procstate = 3; // faulted process

// Process descriptor type
#[repr(C)]
#[derive(Clone, Copy)]
pub struct Proc {
    pub p_pid: i32,                        // process ID
    pub p_gpid: i32,                       // process group (unused by anything in this pset,
                                            // but must stay for layout parity with kernel/k-vm.o)
    pub program_break: u64,                // process's program breakpoint
    pub original_break: u64,               // process's heap start / initial breakpoint
    pub p_registers: X86_64Registers,      // process's current registers
    pub p_state: Procstate,                // process state (see above)
    pub p_pagetable: *mut X86_64Pagetable, // process's page table
    pub display_status: u8,                // process's display status for memviewer
}

pub const NPROC: usize = 16; // maximum number of processes

// Kernel start address
pub const KERNEL_START_ADDR: u64 = 0x40000;
// Top of the kernel stack
pub const KERNEL_STACK_TOP: u64 = 0x80000;

// First application-accessible address
pub const PROC_START_ADDR: u64 = 0x100000;

// Physical memory size
pub const MEMSIZE_PHYSICAL: u64 = 0x200000;
// Number of physical pages
pub const NPAGES: usize = (MEMSIZE_PHYSICAL / PAGESIZE) as usize;

// Virtual memory size
pub const MEMSIZE_VIRTUAL: u64 = 0x300000;

// Hardware interrupt numbers
pub const INT_HARDWARE: u64 = 32;
pub const INT_TIMER: u64 = INT_HARDWARE;

pub const PROCINIT_ALLOW_PROGRAMMED_IO: u32 = 0x01;
#[allow(dead_code)]
pub const PROCINIT_DISABLE_INTERRUPTS: u32 = 0x02;

// `#[no_mangle]`/lowercase name: kernel/k-vm.o (precompiled, no source
// available -- see the "k-vm functions" section below) reads and writes
// this array directly by its plain C symbol name.
#[allow(non_upper_case_globals)]
#[no_mangle]
pub static mut processes: [Proc; NPROC] = [Proc {
    p_pid: 0,
    p_gpid: 0,
    program_break: 0,
    original_break: 0,
    p_registers: X86_64Registers::zeroed(),
    p_state: P_FREE,
    p_pagetable: core::ptr::null_mut(),
    display_status: 0,
}; NPROC]; // array of process descriptors
           // Note that processes[0] is never used.
static mut CURRENT: *mut Proc = core::ptr::null_mut(); // pointer to currently executing proc

const HZ: i32 = 100; // timer interrupt frequency (interrupts/sec)
static mut TICKS: u32 = 0; // # timer interrupts so far

static mut DISP_GLOBAL: u8 = 1; // global flag to display memviewer

// pageinfo
//
//    The pageinfo[] array keeps track of information about each physical page.
//    There is one entry per physical page.
//    `pageinfo[pn]` holds the information for physical page number `pn`.
//    You can get a physical page number from a physical address `pa` using
//    `page_number(pa)`. (This also works for page table entries.)
//    To change a physical page number `pn` into a physical address, use
//    `page_address(pn)`.
//
//    pageinfo[pn].refcount is the number of times physical page `pn` is
//      currently referenced. 0 means it's free.
//    pageinfo[pn].owner is a constant indicating who owns the page.
//      PO_KERNEL means the kernel, PO_RESERVED means reserved memory (such
//      as the console), and a number >= 0 means that process ID.
//
//    pageinfo_init() sets up the initial pageinfo[] state.

#[repr(C)]
#[derive(Clone, Copy)]
pub struct PhysicalPageInfo {
    pub owner: i8,
    pub refcount: i8,
}

pub const PO_FREE: i8 = 0; // this page is free
pub const PO_RESERVED: i8 = -1; // this page is reserved memory
pub const PO_KERNEL: i8 = -2; // this page is used by the kernel

// `#[no_mangle]`/lowercase name: kernel/k-vm.o reads and writes this
// array directly by its plain C symbol name (see the "k-vm functions"
// section below).
#[allow(non_upper_case_globals)]
#[no_mangle]
pub static mut pageinfo: [PhysicalPageInfo; NPAGES] = [PhysicalPageInfo { owner: PO_FREE, refcount: 0 }; NPAGES];

// k-vm functions
//
//    Provided in compiled form only (kernel/k-vm.o) -- there is no
//    source to port, so these are called through a plain `extern "C"`
//    boundary, exactly like linking against any other precompiled C
//    object file. `process_load` here is k-vm.o's own whole-process
//    setup helper; it's a different function from kloader.rs's
//    `program_load` (which it presumably calls internally).
extern "C" {
    #[allow(dead_code)] // not called until Part 1's INT_PAGEFAULT arm is filled in
    fn palloc(pid: i32) -> *mut u8;
    fn process_free(pid: i32);
    fn process_config_tables(pid: i32) -> i32;
    fn process_load(p: *mut Proc, program_number: i32) -> i32;
    fn process_setup_stack(p: *mut Proc);
    fn process_fork(p: *mut Proc) -> i32;
    fn process_page_alloc(p: *mut Proc, addr: u64) -> i32;
}

// kernel(command)
//    Initialize the hardware and processes and start running. The `command`
//    string is an optional string passed from the boot loader.

#[no_mangle]
pub unsafe extern "C" fn kernel(command: *const u8) {
    hardware_init();
    pageinfo_init();
    console_clear();
    timer_init(HZ);

    // Set up process descriptors
    for i in 0..NPROC {
        processes[i] = Proc {
            p_pid: i as i32,
            p_gpid: 0,
            program_break: 0,
            original_break: 0,
            p_registers: X86_64Registers::zeroed(),
            p_state: P_FREE,
            p_pagetable: core::ptr::null_mut(),
            display_status: 0,
        };
    }

    if cstr_eq(command, b"malloc") {
        process_setup(1, 1);
    } else if cstr_eq(command, b"alloctests") {
        process_setup(1, 2);
    } else if cstr_eq(command, b"test") {
        process_setup(1, 3);
    } else if cstr_eq(command, b"test2") {
        for i in 1..=2 {
            process_setup(i, 3);
        }
    } else {
        process_setup(1, 0);
    }

    // Switch to the first process using run()
    run(&mut processes[1]);
}

// cstr_eq(ptr, s)
//    Rust memory-safety helper: compares a possibly-null C string (as
//    passed in from k-exception.S's entry_from_boot) against a Rust
//    byte-string literal.
fn cstr_eq(ptr: *const u8, s: &[u8]) -> bool {
    if ptr.is_null() {
        return false;
    }
    unsafe {
        for (i, &want) in s.iter().enumerate() {
            if *ptr.add(i) != want {
                return false;
            }
        }
        *ptr.add(s.len()) == 0
    }
}

// process_setup(pid, program_number)
//    Load application program `program_number` as process number `pid`.
//    Given (k-vm.o) functions do essentially all of the work here:
//    `process_config_tables` builds the process's page table,
//    `process_load` (k-vm.o's own, not kloader::program_load) loads the
//    program image and sets up registers, and `process_setup_stack`
//    gives it a stack page.

unsafe fn process_setup(pid: i32, program_number: i32) {
    process_init(&mut processes[pid as usize], 0);
    assert!(process_config_tables(pid) == 0);

    // Calls program_load in kloader.rs.
    assert!(process_load(&mut processes[pid as usize], program_number) >= 0);

    process_setup_stack(&mut processes[pid as usize]);

    processes[pid as usize].p_state = P_RUNNABLE;
}

// sbrk(p, difference)
//    Adjusts `p`'s program break by `difference` bytes. Returns 0 on
//    success and -1 on error.

#[allow(unused_variables, dead_code)]
unsafe fn sbrk(p: &mut Proc, difference: i64) -> i32 {
    0
}

// assign_physical_page(addr, owner)
//    Allocates the page with physical address `addr` to the given owner.
//    Fails if physical page `addr` was already allocated. Returns 0 on
//    success and -1 on failure. Used by the program loader.

pub unsafe fn assign_physical_page(addr: u64, owner: i8) -> i32 {
    if (addr & 0xFFF) != 0 || addr >= MEMSIZE_PHYSICAL || pageinfo[page_number(addr) as usize].refcount != 0 {
        -1
    } else {
        pageinfo[page_number(addr) as usize].refcount = 1;
        pageinfo[page_number(addr) as usize].owner = owner;
        0
    }
}

// find_free_page
//    Returns the physical address of a free page, or (u64::MAX) if none
//    exists. Does not mark the page as used.

pub unsafe fn find_free_page() -> u64 {
    for pn in 0..NPAGES {
        if pageinfo[pn].refcount == 0 {
            return page_address(pn as i32);
        }
    }
    u64::MAX
}

pub unsafe fn syscall_fork(p: &mut Proc) -> i32 {
    process_fork(p)
}

pub unsafe fn syscall_exit(p: &mut Proc) {
    process_free(p.p_pid);
}

pub unsafe fn syscall_page_alloc(p: &mut Proc, addr: u64) -> i32 {
    process_page_alloc(p, addr)
}

pub unsafe fn syscall_mapping(p: &mut Proc) {
    let mapping_ptr = p.p_registers.reg_rdi;
    let ptr = p.p_registers.reg_rsi;

    // convert to physical address so kernel can write to it
    let map = virtual_memory_lookup(p.p_pagetable, mapping_ptr);

    // check for write access
    if (map.perm & ((PTE_W | PTE_U) as i32)) != (PTE_W | PTE_U) as i32 {
        return;
    }
    let endaddr = mapping_ptr + core::mem::size_of::<VaMapping>() as u64 - 1;
    if page_number(endaddr) != page_number(ptr) {
        // check for write access for end address
        let end_map = virtual_memory_lookup(p.p_pagetable, endaddr);
        if (end_map.perm & ((PTE_W | PTE_P) as i32)) != (PTE_W | PTE_P) as i32 {
            return;
        }
    }
    // find the actual mapping now
    let ptr_lookup = virtual_memory_lookup(p.p_pagetable, ptr);
    *(map.pa as *mut VaMapping) = ptr_lookup;
}

pub unsafe fn syscall_mem_tog(process: &mut Proc) {
    let p = process.p_registers.reg_rdi as i32;
    if p == 0 {
        DISP_GLOBAL = if DISP_GLOBAL != 0 { 0 } else { 1 };
    } else {
        if p < 0 || p as usize > NPROC || p != process.p_pid {
            return;
        }
        process.display_status = if process.display_status != 0 { 0 } else { 1 };
    }
}

// exception(reg)
//    Exception handler (for interrupts, traps, and faults).
//
//    The register values from exception time are stored in `reg`.
//    The processor responds to an exception by saving application state on
//    the kernel's stack, then jumping to kernel assembly code (in
//    k-exception.S). That code saves more registers on the kernel's stack,
//    then calls exception().
//
//    Note that hardware interrupts are disabled whenever the kernel is running.

extern "C" {
    fn exception_return(reg: *const X86_64Registers) -> !;
}

#[no_mangle]
pub unsafe extern "C" fn exception(reg: *mut X86_64Registers) {
    // Copy the saved registers into the `current` process descriptor
    // and always use the kernel's page table.
    (*CURRENT).p_registers = *reg;
    set_pagetable(kernel_pagetable);

    // It can be useful to log events using the `log_printf!` macro.
    // Events logged this way are stored in the host's `log.txt` file.
    /* log_printf!("proc {}: exception {}\n", (*CURRENT).p_pid, (*reg).reg_intno); */

    // Show the current cursor location and memory state
    // (unless this is a kernel fault).
    console_show_cursor(cursorpos());
    if ((*reg).reg_intno != INT_PAGEFAULT && (*reg).reg_intno != INT_GPF)
        || ((*reg).reg_err & PFERR_USER) != 0
    {
        check_virtual_memory();
        if DISP_GLOBAL != 0 {
            memshow_physical();
            memshow_virtual_animate();
        }
    }

    // If Control-C was typed, exit the virtual machine.
    check_keyboard();

    // Actually handle the exception.
    match (*reg).reg_intno {
        INT_SYS_PANIC => {
            // rdi stores pointer for msg string
            let addr = (*CURRENT).p_registers.reg_rdi;
            if addr == 0 {
                crate::hardware::error_fmt(weensyos_shared::cpos(23, 0), 0xC000, format_args!("PANIC"));
                crate::hardware::fail();
            }
            let map = virtual_memory_lookup((*CURRENT).p_pagetable, addr);
            let msg = core::slice::from_raw_parts(map.pa as *const u8, 160);
            let len = msg.iter().position(|&b| b == 0).unwrap_or(msg.len());
            panic!("{}", core::str::from_utf8_unchecked(&msg[..len]));
            /* will not be reached */
        }

        INT_SYS_GETPID => {
            (*CURRENT).p_registers.reg_rax = (*CURRENT).p_pid as u64;
        }

        INT_SYS_FORK => {
            (*CURRENT).p_registers.reg_rax = syscall_fork(&mut *CURRENT) as u64;
        }

        INT_SYS_MAPPING => {
            syscall_mapping(&mut *CURRENT);
        }

        INT_SYS_EXIT => {
            syscall_exit(&mut *CURRENT);
            schedule(); /* will not be reached */
        }

        INT_SYS_YIELD => {
            schedule(); /* will not be reached */
        }

        INT_SYS_BRK => {
            // TODO : Your code here
        }

        INT_SYS_SBRK => {
            // TODO : Your code here
        }

        INT_SYS_PAGE_ALLOC => {
            let addr = (*CURRENT).p_registers.reg_rdi;
            syscall_page_alloc(&mut *CURRENT, addr);
        }

        INT_SYS_MEM_TOG => {
            syscall_mem_tog(&mut *CURRENT);
        }

        INT_TIMER => {
            TICKS += 1;
            schedule(); /* will not be reached */
        }

        INT_PAGEFAULT => {
            // Analyze faulting address and access type.
            let addr = rcr2();
            let operation = if (*reg).reg_err & PFERR_WRITE != 0 { "write" } else { "read" };
            let problem = if (*reg).reg_err & PFERR_PRESENT != 0 { "protection problem" } else { "missing page" };

            if (*reg).reg_err & PFERR_USER == 0 {
                panic!("Kernel page fault for {:#x} ({} {}, rip={:#x})!", addr, operation, problem, (*reg).reg_rip);
            }
            console_printf(
                cpos(24, 0),
                0x0C00,
                format_args!("Process {} page fault for {:#x} ({} {}, rip={:#x})!\n", (*CURRENT).p_pid, addr, operation, problem, (*reg).reg_rip),
            );
            (*CURRENT).p_state = P_BROKEN;
            syscall_exit(&mut *CURRENT);
        }

        _ => {
            default_exception(&mut *CURRENT); /* will not be reached */
        }
    }

    // Return to the current process (or run something else).
    if (*CURRENT).p_state == P_RUNNABLE {
        run(&mut *CURRENT);
    } else {
        schedule();
    }
}

// schedule
//    Pick the next process to run and then run it.
//    If there are no runnable processes, spins forever.

pub unsafe fn schedule() -> ! {
    let mut pid = (*CURRENT).p_pid;
    loop {
        pid = (pid + 1) % NPROC as i32;
        if processes[pid as usize].p_state == P_RUNNABLE {
            run(&mut processes[pid as usize]);
        }
        // If Control-C was typed, exit the virtual machine.
        check_keyboard();
    }
}

// run(p)
//    Run process `p`. This means reloading all the registers from
//    `p->p_registers` using the `popal`, `popl`, and `iret` instructions.
//
//    As a side effect, sets `current = p`.

pub unsafe fn run(p: &mut Proc) -> ! {
    assert!(p.p_state == P_RUNNABLE);
    CURRENT = p;

    // Load the process's current pagetable.
    set_pagetable(p.p_pagetable);

    // This function is defined in k-exception.S. It restores the process's
    // registers then jumps back to user mode.
    exception_return(&p.p_registers)
    // should never get here
}

// pageinfo_init
//    Initialize the `pageinfo[]` array.

extern "C" {
    static end: u8;
}

unsafe fn pageinfo_init() {
    let end_addr = &end as *const u8 as u64;
    let mut addr = 0;
    while addr < MEMSIZE_PHYSICAL {
        let owner = if crate::hardware::physical_memory_isreserved(addr) {
            PO_RESERVED
        } else if (addr >= KERNEL_START_ADDR && addr < end_addr) || addr == KERNEL_STACK_TOP - PAGESIZE {
            PO_KERNEL
        } else {
            PO_FREE
        };
        pageinfo[page_number(addr) as usize].owner = owner;
        pageinfo[page_number(addr) as usize].refcount = (owner != PO_FREE) as i8;
        addr += PAGESIZE;
    }
}

// check_page_table_mappings
//    Check operating system invariants about kernel mappings for a page
//    table. Panic if any of the invariants are false.

extern "C" {
    static start_data: u8;
}

pub unsafe fn check_page_table_mappings(pt: *mut X86_64Pagetable) {
    assert!(pte_addr(pt as u64) == pt as u64);

    // kernel memory is identity mapped; data is writable
    let end_addr = &end as *const u8 as u64;
    let start_data_addr = &start_data as *const u8 as u64;
    let mut va = KERNEL_START_ADDR;
    while va < end_addr {
        let vam = virtual_memory_lookup(pt, va);
        if vam.pa != va {
            console_printf(cpos(22, 0), 0xC000, format_args!("{:#x} vs {:#x}\n", va, vam.pa));
        }
        assert!(vam.pa == va);
        if va >= start_data_addr {
            assert!(vam.perm & PTE_W as i32 != 0);
        }
        va += PAGESIZE;
    }

    // kernel stack is identity mapped and writable
    let kstack = KERNEL_STACK_TOP - PAGESIZE;
    let vam = virtual_memory_lookup(pt, kstack);
    assert!(vam.pa == kstack);
    assert!(vam.perm & PTE_W as i32 != 0);
}

// check_page_table_ownership
//    Check operating system invariants about ownership and reference
//    counts for page table `pt`. Panic if any of the invariants are false.

pub unsafe fn check_page_table_ownership(pt: *mut X86_64Pagetable, pid: i32) {
    // calculate expected reference count for page tables
    let mut owner = pid;
    let mut expected_refcount = 1;
    if pt == kernel_pagetable {
        owner = PO_KERNEL as i32;
        for xpid in 0..NPROC {
            if processes[xpid].p_state != P_FREE && processes[xpid].p_pagetable == kernel_pagetable {
                expected_refcount += 1;
            }
        }
    }
    check_page_table_ownership_level(pt, 0, owner, expected_refcount);
}

unsafe fn check_page_table_ownership_level(pt: *mut X86_64Pagetable, level: i32, owner: i32, refcount: i32) {
    assert!(page_number(pt as u64) < NPAGES as i32);
    assert!(pageinfo[page_number(pt as u64) as usize].owner as i32 == owner);
    assert!(pageinfo[page_number(pt as u64) as usize].refcount as i32 == refcount);
    if level < 3 {
        for index in 0..NPAGETABLEENTRIES {
            let entry = (*pt).entry[index];
            if entry != 0 {
                let nextpt = pte_addr(entry) as *mut X86_64Pagetable;
                check_page_table_ownership_level(nextpt, level + 1, owner, 1);
            }
        }
    }
}

// check_virtual_memory
//    Check operating system invariants about virtual memory. Panic if any
//    of the invariants are false.

pub unsafe fn check_virtual_memory() {
    // Process 0 must never be used.
    assert!(processes[0].p_state == P_FREE);

    // The kernel page table should be owned by the kernel;
    // its reference count should equal 1, plus the number of processes
    // that don't have their own page tables.
    // Active processes have their own page tables. A process page table
    // should be owned by that process and have reference count 1.
    // All level-2-4 page tables must have reference count 1.

    check_page_table_mappings(kernel_pagetable);
    check_page_table_ownership(kernel_pagetable, -1);

    for pid in 0..NPROC {
        if processes[pid].p_state != P_FREE && processes[pid].p_pagetable != kernel_pagetable {
            check_page_table_mappings(processes[pid].p_pagetable);
            check_page_table_ownership(processes[pid].p_pagetable, pid as i32);
        }
    }

    // Check that all referenced pages refer to active processes
    for pn in 0..(page_number(MEMSIZE_PHYSICAL) as usize) {
        if pageinfo[pn].refcount > 0 && pageinfo[pn].owner >= 0 {
            assert!(processes[pageinfo[pn].owner as usize].p_state != P_FREE);
        }
    }
}

// memshow_physical
//    Draw a picture of physical memory on the CGA console.

static MEMSTATE_COLORS: [u16; 19] = [
    b'K' as u16 | 0x0D00, b'R' as u16 | 0x0700, b'.' as u16 | 0x0700, b'1' as u16 | 0x0C00,
    b'2' as u16 | 0x0A00, b'3' as u16 | 0x0900, b'4' as u16 | 0x0E00, b'5' as u16 | 0x0F00,
    b'6' as u16 | 0x0C00, b'7' as u16 | 0x0A00, b'8' as u16 | 0x0900, b'9' as u16 | 0x0E00,
    b'A' as u16 | 0x0F00, b'B' as u16 | 0x0C00, b'C' as u16 | 0x0A00, b'D' as u16 | 0x0900,
    b'E' as u16 | 0x0E00, b'F' as u16 | 0x0F00, b'S' as u16,
];
fn shared_color() -> u16 {
    MEMSTATE_COLORS[18]
}

fn console_cell(pos: i32) -> &'static mut u16 {
    unsafe { &mut *((CONSOLE_ADDR as *mut u16).offset(pos as isize)) }
}

pub unsafe fn memshow_physical() {
    console_printf(cpos(0, 32), 0x0F00, format_args!("PHYSICAL MEMORY"));
    for pn in 0..(page_number(MEMSIZE_PHYSICAL) as usize) {
        if pn % 64 == 0 {
            console_printf(cpos(1 + (pn / 64) as i32, 3), 0x0F00, format_args!("{:#08X} ", pn << 12));
        }

        let mut owner = pageinfo[pn].owner;
        if pageinfo[pn].refcount == 0 {
            owner = PO_FREE;
        }
        let mut color = MEMSTATE_COLORS[(owner - PO_KERNEL) as usize];
        // darker color for shared pages
        if pageinfo[pn].refcount > 1 && pn != page_number(CONSOLE_ADDR) as usize {
            color = shared_color() | 0x0F00;
        }

        *console_cell(cpos(1 + (pn / 64) as i32, 12 + (pn % 64) as i32)) = color;
    }
}

// memshow_virtual(pagetable, pid)
//    Draw a picture of the virtual memory map `pagetable` (owned by
//    process `pid`) on the CGA console.

pub unsafe fn memshow_virtual(pagetable: *mut X86_64Pagetable, pid: i32) {
    assert!(pagetable as u64 == pte_addr(pagetable as u64));

    console_printf(cpos(10, 26), 0x0F00, format_args!("VIRTUAL ADDRESS SPACE FOR {}", pid));
    let mut va = 0;
    while va < MEMSIZE_VIRTUAL {
        let vam = virtual_memory_lookup(pagetable, va);
        let color;
        if vam.pn < 0 {
            color = b' ' as u16;
        } else {
            assert!(vam.pa < MEMSIZE_PHYSICAL);
            let mut owner = pageinfo[vam.pn as usize].owner;
            if pageinfo[vam.pn as usize].refcount == 0 {
                owner = PO_FREE;
            }
            let mut c = MEMSTATE_COLORS[(owner - PO_KERNEL) as usize];
            // reverse video for user-accessible pages
            if vam.perm & PTE_U as i32 != 0 {
                c = ((c & 0x0F00) << 4) | ((c & 0xF000) >> 4) | (c & 0x00FF);
            }
            // darker color for shared pages
            if pageinfo[vam.pn as usize].refcount > 1 && va != CONSOLE_ADDR {
                c = shared_color() | (c & 0xF000);
                if vam.perm & PTE_U as i32 == 0 {
                    c |= 0x0F00;
                }
            }
            color = c;
        }
        let pn = page_number(va);
        if pn % 64 == 0 {
            console_printf(cpos(11 + pn / 64, 3), 0x0F00, format_args!("{:#08X} ", va));
        }
        *console_cell(cpos(11 + pn / 64, 12 + pn % 64)) = color;
        va += PAGESIZE;
    }
}

// memshow_virtual_animate
//    Draw a picture of process virtual memory maps on the CGA console.
//    Starts with process 1, then switches to a new process every 0.25 sec.

pub unsafe fn memshow_virtual_animate() {
    static mut LAST_TICKS: u32 = 0;
    static mut SHOWING: i32 = 1;

    // switch to a new process every 0.25 sec
    if LAST_TICKS == 0 || TICKS - LAST_TICKS >= (HZ / 2) as u32 {
        LAST_TICKS = TICKS;
        SHOWING += 1;
    }

    // the current process may have died -- don't display it if so
    while SHOWING <= 2 * NPROC as i32
        && (processes[(SHOWING % NPROC as i32) as usize].p_state == P_FREE
            || processes[(SHOWING % NPROC as i32) as usize].display_status == 0)
    {
        SHOWING += 1;
    }
    SHOWING %= NPROC as i32;

    if processes[SHOWING as usize].p_state != P_FREE {
        memshow_virtual(processes[SHOWING as usize].p_pagetable, SHOWING);
    }
}
