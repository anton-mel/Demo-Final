// kernel.rs (ported from kernel/kernel.h + kernel/kernel.c)
//
//    This is the kernel.

use crate::hardware::{check_keyboard, console_show_cursor, default_exception, hardware_init, process_init, timer_init};
use crate::kloader::program_load;
use crate::vm::{kernel_pagetable, set_pagetable, virtual_memory_lookup, virtual_memory_map};
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
    pub p_registers: X86_64Registers,      // process's current registers
    pub p_state: Procstate,                // process state (see above)
    pub p_pagetable: *mut X86_64Pagetable, // process's page table
    pub display_status: u8,                // process's display status for memviewer
    pub program_break: u64,                // current end of the heap (brk/sbrk)
    pub original_break: u64,               // heap's starting break, set once by the loader
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

static mut PROCESSES: [Proc; NPROC] = [Proc {
    p_pid: 0,
    p_registers: X86_64Registers::zeroed(),
    p_state: P_FREE,
    p_pagetable: core::ptr::null_mut(),
    display_status: 0,
    program_break: 0,
    original_break: 0,
}; NPROC]; // array of process descriptors
           // Note that processes[0] is never used.
static mut CURRENT: *mut Proc = core::ptr::null_mut(); // pointer to currently executing proc

const HZ: i32 = 100; // timer interrupt frequency (interrupts/sec)
static mut TICKS: u32 = 0; // # timer interrupts so far

static mut DISP_GLOBAL: u8 = 1; // global flag to display memviewer

// PAGEINFO
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

pub static mut PAGEINFO: [PhysicalPageInfo; NPAGES] = [PhysicalPageInfo { owner: PO_FREE, refcount: 0 }; NPAGES];

// kernel(command)
//    Initialize the hardware and processes and start running. The `command`
//    string is an optional string passed from the boot loader.

#[no_mangle]
pub unsafe extern "C" fn kernel(command: *const u8) {
    hardware_init();
    pageinfo_init();
    console_clear();
    timer_init(HZ);

    // Step 1: isolate the kernel -- applications may not access kernel
    // memory, except for the single page holding the CGA console.
    virtual_memory_map(kernel_pagetable, 0, 0, PROC_START_ADDR, (PTE_P | PTE_W) as i32);
    virtual_memory_map(kernel_pagetable, CONSOLE_ADDR, CONSOLE_ADDR, PAGESIZE, (PTE_P | PTE_W | PTE_U) as i32);

    for i in 0..NPROC {
        PROCESSES[i] = Proc {
            p_pid: i as i32,
            p_registers: X86_64Registers::zeroed(),
            p_state: P_FREE,
            p_pagetable: core::ptr::null_mut(),
            display_status: 0,
            program_break: 0,
            original_break: 0,
        };
    }

    if cstr_eq(command, b"fork") {
        process_setup(1, 4);
    } else if cstr_eq(command, b"forkexit") {
        process_setup(1, 5);
    } else if cstr_eq(command, b"test") {
        process_setup(1, 6);
    } else if cstr_eq(command, b"test2") {
        for i in 1..=2 {
            process_setup(i, 6);
        }
    // Final-project additions: brk/sbrk (program_number 7), user malloc
    // (8), and malloc correctness/timing tests (9) -- see kloader.rs's
    // `ramimages`. Reached by pressing 'a', 'm', or 'c' respectively once
    // WeensyOS is running (hardware.rs's `check_keyboard` soft-reboots
    // with these command strings, the same mechanism "fork"/"test"/etc
    // already use), not by anything passed at boot/build time.
    } else if cstr_eq(command, b"allocator") {
        process_setup(1, 7);
    } else if cstr_eq(command, b"malloc") {
        process_setup(1, 8);
    } else if cstr_eq(command, b"alloctests") {
        process_setup(1, 9);
    } else {
        for i in 1..=4 {
            process_setup(i, i - 1);
        }
    }

    run(&mut PROCESSES[1]);
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
//    This loads the application's code and data into memory, sets its
//    %rip and %rsp, gives it a stack page, and marks it as runnable.

unsafe fn process_setup(pid: i32, program_number: i32) {
    process_init(&mut PROCESSES[pid as usize], 0);
    PROCESSES[pid as usize].p_pagetable = new_pagetable(pid);

    let r = program_load(&mut PROCESSES[pid as usize], program_number);
    assert!(r >= 0);

    // Step 4: every process's stack starts at the same virtual address, at
    // the top of virtual memory; address spaces may now overlap freely
    // since each process has its own page table and physical pages.
    PROCESSES[pid as usize].p_registers.reg_rsp = MEMSIZE_VIRTUAL;
    let stack_page = PROCESSES[pid as usize].p_registers.reg_rsp - PAGESIZE;
    let stack_pa = find_free_page();
    assign_physical_page(stack_pa, pid as i8);
    virtual_memory_map(PROCESSES[pid as usize].p_pagetable, stack_page, stack_pa, PAGESIZE, (PTE_P | PTE_W | PTE_U) as i32);
    PROCESSES[pid as usize].p_state = P_RUNNABLE;
}

// assign_physical_page(addr, owner)
//    Allocates the page with physical address `addr` to the given owner.
//    Fails if physical page `addr` was already allocated. Returns 0 on
//    success and -1 on failure. Used by the program loader.

pub unsafe fn assign_physical_page(addr: u64, owner: i8) -> i32 {
    if (addr & 0xFFF) != 0 || addr >= MEMSIZE_PHYSICAL || PAGEINFO[page_number(addr) as usize].refcount != 0 {
        -1
    } else {
        PAGEINFO[page_number(addr) as usize].refcount = 1;
        PAGEINFO[page_number(addr) as usize].owner = owner;
        0
    }
}

// find_free_page
//    Returns the physical address of a free page, or (u64::MAX) if none
//    exists. Does not mark the page as used.

pub unsafe fn find_free_page() -> u64 {
    for pn in 0..NPAGES {
        if PAGEINFO[pn].refcount == 0 {
            return page_address(pn as i32);
        }
    }
    u64::MAX
}

// sbrk(p, difference)
//    Adjusts `p`'s program break by `difference` bytes (not required to
//    be a multiple of PAGESIZE). Returns 0 on success or -1 on error --
//    moving the break below the heap's start (`p.original_break`), or
//    at/past the top of the stack (fixed at MEMSIZE_VIRTUAL - PAGESIZE
//    for this pset).
//
//    Growing the heap does not map any pages here -- that's the
//    "optimistic"/lazy allocation the assignment asks for: `sbrk` just
//    moves the break, and the first time the process actually touches
//    a new page it takes a page fault, handled by `exception`'s
//    INT_PAGEFAULT arm below. Shrinking the heap, by contrast, unmaps
//    and frees affected pages immediately -- there's no reason to defer
//    that. A page in the shrunk range may never have been faulted in at
//    all (if the process grew then shrank without touching it), so only
//    ever touch a page that `virtual_memory_lookup` confirms is mapped
//    (`vam.pn >= 0`); doing otherwise, as the reference C solution does,
//    is exactly the kind of bug Rust's bounds-checked indexing would
//    catch as a panic instead of silently corrupting `PAGEINFO`.

unsafe fn sbrk(p: &mut Proc, difference: i64) -> i32 {
    let old_break = p.program_break;
    let new_break = (old_break as i64 + difference) as u64;

    if new_break < p.original_break || new_break >= MEMSIZE_VIRTUAL - PAGESIZE {
        return -1;
    }
    p.program_break = new_break;

    if difference < 0 {
        let mut addr = round_up(new_break, PAGESIZE);
        let old_top = round_up(old_break, PAGESIZE);
        while addr < old_top {
            let vam = virtual_memory_lookup(p.p_pagetable, addr);
            if vam.pn >= 0 {
                PAGEINFO[vam.pn as usize].owner = PO_FREE;
                PAGEINFO[vam.pn as usize].refcount = 0;
                virtual_memory_map(p.p_pagetable, addr, 0, PAGESIZE, 0);
            }
            addr += PAGESIZE;
        }
    }
    0
}

// new_pagetable(pid)
//    Allocates a fresh 4-level page table for process `pid` (1 L4 + 1 L3 +
//    1 L2 + 2 L1, enough to cover MEMSIZE_VIRTUAL) with the kernel's
//    mappings below PROC_START_ADDR (including the console) copied in.
//    Returns null, freeing any pages it managed to reserve, on OOM.

unsafe fn new_pagetable(pid: i32) -> *mut X86_64Pagetable {
    let mut tables: [*mut X86_64Pagetable; 5] = [core::ptr::null_mut(); 5];
    for t in tables.iter_mut() {
        // reserve the page immediately -- find_free_page() only looks at
        // free pages, so it must be claimed before the next call or the
        // same page could be handed out twice
        let pa = find_free_page();
        if pa == u64::MAX || assign_physical_page(pa, pid as i8) < 0 {
            free_owned_pages(pid);
            return core::ptr::null_mut();
        }
        *t = pa as *mut X86_64Pagetable;
        core::ptr::write_bytes(*t, 0, 1);
    }
    let pagetable = tables[0];
    let l3 = tables[1];
    let l2 = tables[2];
    let l1a = tables[3];
    let l1b = tables[4];
    (*pagetable).entry[0] = (l3 as u64) | PTE_P | PTE_W | PTE_U;
    (*l3).entry[0] = (l2 as u64) | PTE_P | PTE_W | PTE_U;
    (*l2).entry[0] = (l1a as u64) | PTE_P | PTE_W | PTE_U;
    (*l2).entry[1] = (l1b as u64) | PTE_P | PTE_W | PTE_U;

    let mut addr = 0;
    while addr < PROC_START_ADDR {
        let vam = virtual_memory_lookup(kernel_pagetable, addr);
        if vam.pn >= 0 {
            virtual_memory_map(pagetable, addr, vam.pa, PAGESIZE, vam.perm);
        }
        addr += PAGESIZE;
    }
    pagetable
}

// free_owned_pages(pid)
//    Frees every physical page exclusively owned by process `pid`. Used
//    for a process's page-table pages, which are never shared.

unsafe fn free_owned_pages(pid: i32) {
    for pn in 0..NPAGES {
        if PAGEINFO[pn].owner as i32 == pid {
            PAGEINFO[pn].refcount = 0;
            PAGEINFO[pn].owner = PO_FREE;
        }
    }
}

// free_process(pid, pt)
//    Frees all of process `pid`'s memory, found by walking its page
//    table `pt` (may be null if `pt` was never built): pages `pid` owns
//    outright are freed, pages it merely shares (e.g. read-only code
//    pages from fork()) have their reference count decremented, and
//    finally the page-table pages themselves (always owned by `pid`)
//    are freed.

unsafe fn free_process(pid: i32, pt: *mut X86_64Pagetable) {
    if !pt.is_null() {
        let mut va = PROC_START_ADDR;
        while va < MEMSIZE_VIRTUAL {
            let vam = virtual_memory_lookup(pt, va);
            if vam.pn >= 0 {
                if PAGEINFO[vam.pn as usize].owner as i32 == pid {
                    PAGEINFO[vam.pn as usize].refcount = 0;
                    PAGEINFO[vam.pn as usize].owner = PO_FREE;
                } else if PAGEINFO[vam.pn as usize].refcount > 0 {
                    PAGEINFO[vam.pn as usize].refcount -= 1;
                }
            }
            va += PAGESIZE;
        }
    }
    free_owned_pages(pid);
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
    // check for write access for end address
    let end_map = virtual_memory_lookup(p.p_pagetable, endaddr);
    if (end_map.perm & ((PTE_W | PTE_P) as i32)) != (PTE_W | PTE_P) as i32 {
        return;
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
                // Matches the reference's `panic(NULL)`: print exactly
                // "PANIC" (no file/line/message) and hang, rather than
                // going through the normal panic!() machinery, which
                // would always attach its own file:line and a message.
                crate::hardware::error_fmt(weensyos_shared::cpos(23, 0), 0xC000, format_args!("PANIC"));
                crate::hardware::fail();
            }
            let map = virtual_memory_lookup((*CURRENT).p_pagetable, addr);
            let msg = core::slice::from_raw_parts(map.pa as *const u8, 160);
            let len = msg.iter().position(|&b| b == 0).unwrap_or(msg.len());
            panic!("{}", core::str::from_utf8_unchecked(&msg[..len]));
        }

        INT_SYS_GETPID => {
            (*CURRENT).p_registers.reg_rax = (*CURRENT).p_pid as u64;
        }

        INT_SYS_YIELD => {
            schedule(); /* will not be reached */
        }

        INT_SYS_PAGE_ALLOC => {
            // Step 3: `addr` is now just a virtual address -- satisfy the
            // request with any free physical page, not necessarily addr itself.
            let addr = (*CURRENT).p_registers.reg_rdi;
            let mut r = -1;
            if addr % PAGESIZE == 0 && addr >= PROC_START_ADDR && addr < MEMSIZE_VIRTUAL {
                let pa = find_free_page();
                if pa != u64::MAX {
                    r = assign_physical_page(pa, (*CURRENT).p_pid as i8);
                    if r >= 0 {
                        virtual_memory_map((*CURRENT).p_pagetable, addr, pa, PAGESIZE, (PTE_P | PTE_W | PTE_U) as i32);
                    }
                }
            }
            (*CURRENT).p_registers.reg_rax = r as u64;
        }

        INT_SYS_FORK => {
            // Step 5: find a free process slot (never slot 0).
            let mut child_pid: i32 = 0;
            for i in 1..NPROC as i32 {
                if PROCESSES[i as usize].p_state == P_FREE {
                    child_pid = i;
                    break;
                }
            }

            let child_pt = if child_pid != 0 { new_pagetable(child_pid) } else { core::ptr::null_mut() };
            let mut failed = child_pt.is_null();
            // copy every application page (below PROC_START_ADDR is already
            // shared with the kernel, console included, via new_pagetable)
            let mut va = PROC_START_ADDR;
            while !failed && va < MEMSIZE_VIRTUAL {
                let vam = virtual_memory_lookup((*CURRENT).p_pagetable, va);
                if vam.pn >= 0 {
                    if vam.perm & PTE_W as i32 == 0 {
                        // Step 6: read-only pages (e.g. program text) can't be
                        // written by either process, so share them instead of
                        // copying them -- just track the extra reference.
                        virtual_memory_map(child_pt, va, vam.pa, PAGESIZE, vam.perm);
                        PAGEINFO[vam.pn as usize].refcount += 1;
                    } else {
                        let pa = find_free_page();
                        if pa == u64::MAX || assign_physical_page(pa, child_pid as i8) < 0 {
                            failed = true;
                            break;
                        }
                        core::ptr::copy_nonoverlapping(vam.pa as *const u8, pa as *mut u8, PAGESIZE as usize);
                        virtual_memory_map(child_pt, va, pa, PAGESIZE, vam.perm);
                    }
                }
                va += PAGESIZE;
            }

            if failed {
                if child_pid != 0 {
                    free_process(child_pid, child_pt);
                }
                (*CURRENT).p_registers.reg_rax = (-1i64) as u64;
            } else {
                PROCESSES[child_pid as usize].p_registers = (*CURRENT).p_registers;
                PROCESSES[child_pid as usize].p_registers.reg_rax = 0;
                PROCESSES[child_pid as usize].p_pagetable = child_pt;
                PROCESSES[child_pid as usize].display_status = 1;
                PROCESSES[child_pid as usize].program_break = (*CURRENT).program_break;
                PROCESSES[child_pid as usize].original_break = (*CURRENT).original_break;
                PROCESSES[child_pid as usize].p_state = P_RUNNABLE;
                (*CURRENT).p_registers.reg_rax = child_pid as u64;
            }
        }

        INT_SYS_EXIT => {
            // Step 7: free all of this process's memory (its page-table
            // pages, its owned code/data/heap/stack pages, and its
            // references to any pages it shares with others) and mark
            // its slot free. `run`'s caller sees `p_state != P_RUNNABLE`
            // below and calls schedule().
            free_process((*CURRENT).p_pid, (*CURRENT).p_pagetable);
            (*CURRENT).p_state = P_FREE;
        }

        INT_SYS_MAPPING => {
            syscall_mapping(&mut *CURRENT);
        }

        INT_SYS_MEM_TOG => {
            syscall_mem_tog(&mut *CURRENT);
        }

        INT_SYS_BRK => {
            let addr = (*CURRENT).p_registers.reg_rdi;
            let difference = addr as i64 - (*CURRENT).program_break as i64;
            let r = sbrk(&mut *CURRENT, difference);
            (*CURRENT).p_registers.reg_rax = r as i64 as u64;
        }

        INT_SYS_SBRK => {
            let difference = (*CURRENT).p_registers.reg_rdi as i64;
            let old_break = (*CURRENT).program_break;
            // sbrk returns the *previous* break on success, or (void*)-1
            // (all bits set) on error, matching libc's sbrk(2) semantics.
            (*CURRENT).p_registers.reg_rax = if sbrk(&mut *CURRENT, difference) == 0 { old_break } else { u64::MAX };
        }

        INT_TIMER => {
            TICKS += 1;
            schedule(); /* will not be reached */
        }

        INT_PAGEFAULT => {
            // Analyze faulting address and access type.
            let addr = rcr2();
            let missing = (*reg).reg_err & PFERR_PRESENT == 0;
            let in_heap = addr >= (*CURRENT).original_break && addr < (*CURRENT).program_break;

            if (*reg).reg_err & PFERR_USER != 0 && missing && in_heap {
                // Optimistic/lazy allocation: `sbrk`/`brk` already moved
                // the break to include this address, but never mapped a
                // page for it (growth never eagerly maps memory) -- this
                // is the expected first-touch fault. Map one page and
                // resume; if no physical page is available, the process
                // is killed instead (per the assignment spec).
                let page_addr = round_down(addr, PAGESIZE);
                let pa = find_free_page();
                if pa != u64::MAX
                    && assign_physical_page(pa, (*CURRENT).p_pid as i8) >= 0
                    && virtual_memory_map((*CURRENT).p_pagetable, page_addr, pa, PAGESIZE, (PTE_P | PTE_W | PTE_U) as i32) >= 0
                {
                    // Stays P_RUNNABLE; falls through to `run` below.
                } else {
                    free_process((*CURRENT).p_pid, (*CURRENT).p_pagetable);
                    (*CURRENT).p_state = P_FREE;
                }
            } else {
                let operation = if (*reg).reg_err & PFERR_WRITE != 0 { "write" } else { "read" };
                let problem = if missing { "missing page" } else { "protection problem" };

                if (*reg).reg_err & PFERR_USER == 0 {
                    panic!("Kernel page fault for {:#x} ({} {}, rip={:#x})!", addr, operation, problem, (*reg).reg_rip);
                }
                console_printf(
                    cpos(24, 0),
                    0x0C00,
                    format_args!("Process {} page fault for {:#x} ({} {}, rip={:#x})!\n", (*CURRENT).p_pid, addr, operation, problem, (*reg).reg_rip),
                );
                (*CURRENT).p_state = P_BROKEN;
            }
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
        if PROCESSES[pid as usize].p_state == P_RUNNABLE {
            run(&mut PROCESSES[pid as usize]);
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
        PAGEINFO[page_number(addr) as usize].owner = owner;
        PAGEINFO[page_number(addr) as usize].refcount = (owner != PO_FREE) as i8;
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
            if PROCESSES[xpid].p_state != P_FREE && PROCESSES[xpid].p_pagetable == kernel_pagetable {
                expected_refcount += 1;
            }
        }
    }
    check_page_table_ownership_level(pt, 0, owner, expected_refcount);
}

unsafe fn check_page_table_ownership_level(pt: *mut X86_64Pagetable, level: i32, owner: i32, refcount: i32) {
    assert!(page_number(pt as u64) < NPAGES as i32);
    assert!(PAGEINFO[page_number(pt as u64) as usize].owner as i32 == owner);
    assert!(PAGEINFO[page_number(pt as u64) as usize].refcount as i32 == refcount);
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
    assert!(PROCESSES[0].p_state == P_FREE);

    // The kernel page table should be owned by the kernel;
    // its reference count should equal 1, plus the number of processes
    // that don't have their own page tables.
    // Active processes have their own page tables. A process page table
    // should be owned by that process and have reference count 1.
    // All level-2-4 page tables must have reference count 1.

    check_page_table_mappings(kernel_pagetable);
    check_page_table_ownership(kernel_pagetable, -1);

    for pid in 0..NPROC {
        if PROCESSES[pid].p_state != P_FREE && PROCESSES[pid].p_pagetable != kernel_pagetable {
            check_page_table_mappings(PROCESSES[pid].p_pagetable);
            check_page_table_ownership(PROCESSES[pid].p_pagetable, pid as i32);
        }
    }

    // Check that all referenced pages refer to active processes
    for pn in 0..(page_number(MEMSIZE_PHYSICAL) as usize) {
        if PAGEINFO[pn].refcount > 0 && PAGEINFO[pn].owner >= 0 {
            assert!(PROCESSES[PAGEINFO[pn].owner as usize].p_state != P_FREE);
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

        let mut owner = PAGEINFO[pn].owner;
        if PAGEINFO[pn].refcount == 0 {
            owner = PO_FREE;
        }
        let mut color = MEMSTATE_COLORS[(owner - PO_KERNEL) as usize];
        // darker color for shared pages
        if PAGEINFO[pn].refcount > 1 && pn != page_number(CONSOLE_ADDR) as usize {
            color = shared_color() | 0x0F00;
        }

        *console_cell(cpos(1 + (pn / 64) as i32, 12 + (pn % 64) as i32)) = color;
    }
}

// memshow_virtual(pagetable, pid)
//    Draw a picture of the virtual memory map `pagetable` (owned by
//    process `pid`) on the CGA console. (The reference kernel.c takes a
//    display name string here; since the only caller ever passes a pid,
//    we format it directly instead of routing it through an intermediate
//    C-string buffer.)

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
            let mut owner = PAGEINFO[vam.pn as usize].owner;
            if PAGEINFO[vam.pn as usize].refcount == 0 {
                owner = PO_FREE;
            }
            let mut c = MEMSTATE_COLORS[(owner - PO_KERNEL) as usize];
            // reverse video for user-accessible pages
            if vam.perm & PTE_U as i32 != 0 {
                c = ((c & 0x0F00) << 4) | ((c & 0xF000) >> 4) | (c & 0x00FF);
            }
            // darker color for shared pages
            if PAGEINFO[vam.pn as usize].refcount > 1 && va != CONSOLE_ADDR {
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
        && (PROCESSES[(SHOWING % NPROC as i32) as usize].p_state == P_FREE
            || PROCESSES[(SHOWING % NPROC as i32) as usize].display_status == 0)
    {
        SHOWING += 1;
    }
    SHOWING %= NPROC as i32;

    if PROCESSES[SHOWING as usize].p_state != P_FREE {
        memshow_virtual(PROCESSES[SHOWING as usize].p_pagetable, SHOWING);
    }
}
