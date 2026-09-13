// kloader.rs (ported from kernel/k-loader.c)
//
//    Load a weensy application into memory from the boot image.

use crate::elf::*;
use crate::kernel::Proc;
use crate::vm::{kernel_pagetable, set_pagetable, virtual_memory_lookup, virtual_memory_map};
use crate::x86_64::{PAGESIZE, PTE_P, PTE_U, PTE_W};
use weensyos_shared::{cpos, console_printf, round_up};

// palloc(pid)
//    Given (kernel/k-vm.o, no source available): allocates a page from
//    pageinfo and returns its physical address, or null on failure. This
//    is Project 5's own physical-page allocator -- this final project
//    builds on a *complete* Project 5, so program_load_segment below
//    calls it directly instead of identity-mapping `addr` the way an
//    unsolved Project-5 starter would.
extern "C" {
    fn palloc(pid: i32) -> *mut u8;
}

// The build embeds each compiled test program's binary directly into the
// kernel image (see the GNUmakefile's `-b binary` link step). `objcopy`
// does this by turning the program's binary file into an object file the
// linker can attach to the kernel, and it automatically names the start
// of that data `_binary_obj_p_*_start`. Each symbol below is just
// "the address where one program's raw ELF bytes begin in memory."
//
// `objcopy` also emits a matching `_binary_obj_p_*_end` symbol, but
// nothing uses it: `program_load` figures out each program's size
// from the ELF header's own fields, not from `_end`.
extern "C" {
    static _binary_obj_p_allocator_start: u8;
    static _binary_obj_p_malloc_start: u8;
    static _binary_obj_p_alloctests_start: u8;
    static _binary_obj_p_test_start: u8;
}

struct RamImage {
    begin: *const u8,
}

unsafe fn ramimages() -> [RamImage; 4] {
    [
        RamImage { begin: &_binary_obj_p_allocator_start },
        RamImage { begin: &_binary_obj_p_malloc_start },
        RamImage { begin: &_binary_obj_p_alloctests_start },
        RamImage { begin: &_binary_obj_p_test_start },
    ]
}

// program_load(p, programnumber)
//    Load the code corresponding to program `programnumber` into the process
//    `p` and set `p->p_registers.reg_rip` to its entry point. Calls
//    `palloc` as required. Returns 0 on success and -1 on failure (e.g.
//    out-of-memory).
//
//    (The reference k-loader.c also threads an `allocator` callback through
//    this function and program_load_segment below, for a page-allocation
//    strategy no step of this pset ever actually supplies -- it's always
//    NULL. It's dropped here rather than carried around unused -- safe
//    even though kernel/k-vm.o's process_load still calls this as if it
//    took a 3rd argument, since on x86-64 SysV a callee simply ignores
//    whatever's in the register/stack slot for a parameter it doesn't
//    declare.)
//
//    `#[no_mangle] extern "C"`: kernel/k-vm.o (precompiled, no source
// available -- see kernel.rs) calls this by its plain C symbol name.
#[no_mangle]
pub unsafe extern "C" fn program_load(p: &mut Proc, programnumber: i32) -> i32 {
    // is this a valid program?
    let ramimages = ramimages();
    assert!(programnumber >= 0 && (programnumber as usize) < ramimages.len());
    let eh = ramimages[programnumber as usize].begin as *const ElfHeader;
    assert!((*eh).e_magic == ELF_MAGIC);

    // load each loadable program segment into memory, tracking the
    // highest address any of them reaches -- the heap starts right
    // after that, per the assignment spec's Part 1.
    let ph = (eh as *const u8).add((*eh).e_phoff as usize) as *const ElfProgram;
    let mut max_end_mem: u64 = 0;
    for i in 0..(*eh).e_phnum as isize {
        let ph_i = &*ph.offset(i);
        if ph_i.p_type == ELF_PTYPE_LOAD {
            let pdata = (eh as *const u8).add(ph_i.p_offset as usize);
            if program_load_segment(p, ph_i, pdata) < 0 {
                return -1;
            }
            max_end_mem = max_end_mem.max(ph_i.p_va + ph_i.p_memsz);
        }
    }

    // set the entry point from the ELF header
    p.p_registers.reg_rip = (*eh).e_entry;

    // The heap (and the break) start on the page right after the last
    // loaded segment; a zero-sized heap to begin with.
    p.program_break = round_up(max_end_mem, PAGESIZE);
    p.original_break = p.program_break;
    0
}

// program_load_segment(p, ph, src)
//    Load an ELF segment at virtual address `ph->p_va` in process `p`. Copies
//    `[src, src + ph->p_filesz)` to `dst`, then clears
//    `[ph->p_va + ph->p_filesz, ph->p_va + ph->p_memsz)` to 0.
//    Calls `palloc` to allocate pages and `virtual_memory_map`
//    to map them in `p->p_pagetable`. Returns 0 on success and -1 on failure.

unsafe fn program_load_segment(p: &mut Proc, ph: &ElfProgram, src: *const u8) -> i32 {
    let mut va = ph.p_va;
    let end_file = va + ph.p_filesz;
    let end_mem = va + ph.p_memsz;
    va &= !(PAGESIZE - 1); // round to page boundary

    let writable = (ph.p_flags & ELF_PFLAG_WRITE) != 0;

    // allocate memory
    let mut addr = va;
    while addr < end_mem {
        let pa = palloc(p.p_pid);
        if pa.is_null() || virtual_memory_map(p.p_pagetable, addr, pa as u64, PAGESIZE, (PTE_P | PTE_W | PTE_U) as i32) < 0 {
            console_printf(cpos(22, 0), 0xC000, format_args!("program_load_segment(pid {}): can't assign address {:#x}\n", p.p_pid, addr));
            return -1;
        }
        addr += PAGESIZE;
    }

    // ensure new memory mappings are active
    set_pagetable(p.p_pagetable);

    // copy data from executable image into process memory
    core::ptr::copy_nonoverlapping(src, va as *mut u8, (end_file - va) as usize);
    core::ptr::write_bytes(end_file as *mut u8, 0, (end_mem - end_file) as usize);

    // restore kernel pagetable
    set_pagetable(kernel_pagetable);

    // A segment the process may never write to (like .text) can be
    // shared between processes by fork(), instead of copied, once it's
    // mapped read-only -- drop PTE_W now that the segment's data has
    // been copied in.
    if !writable {
        let mut addr = va;
        while addr < end_mem {
            let vam = virtual_memory_lookup(p.p_pagetable, addr);
            virtual_memory_map(p.p_pagetable, addr, vam.pa, PAGESIZE, (PTE_P | PTE_U) as i32);
            addr += PAGESIZE;
        }
    }
    // (Heap-start/break setup lives in program_load, once, after every
    // segment of the program has been loaded -- not here per-segment.)
    0
}
