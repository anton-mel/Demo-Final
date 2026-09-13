// kloader.rs (ported from kernel/k-loader.c)
//
//    Load a weensy application into memory from the boot image.

use crate::elf::*;
use crate::kernel::{assign_physical_page, find_free_page, Proc};
use crate::vm::{kernel_pagetable, set_pagetable, virtual_memory_lookup, virtual_memory_map};
use crate::x86_64::{PAGESIZE, PTE_P, PTE_U, PTE_W};
use weensyos_shared::{cpos, console_printf, round_up};

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
    static _binary_obj_p_allocator2_start: u8;
    static _binary_obj_p_allocator3_start: u8;
    static _binary_obj_p_allocator4_start: u8;
    static _binary_obj_p_fork_start: u8;
    static _binary_obj_p_forkexit_start: u8;
    static _binary_obj_p_test_start: u8;
    // Final-project additions (brk/sbrk + user malloc).
    static _binary_obj_p_brk_allocator_start: u8;
    static _binary_obj_p_malloc_start: u8;
    static _binary_obj_p_alloctests_start: u8;
}

struct RamImage {
    begin: *const u8,
}

unsafe fn ramimages() -> [RamImage; 10] {
    [
        RamImage { begin: &_binary_obj_p_allocator_start },
        RamImage { begin: &_binary_obj_p_allocator2_start },
        RamImage { begin: &_binary_obj_p_allocator3_start },
        RamImage { begin: &_binary_obj_p_allocator4_start },
        RamImage { begin: &_binary_obj_p_fork_start },
        RamImage { begin: &_binary_obj_p_forkexit_start },
        RamImage { begin: &_binary_obj_p_test_start },
        RamImage { begin: &_binary_obj_p_brk_allocator_start }, // 7
        RamImage { begin: &_binary_obj_p_malloc_start },        // 8
        RamImage { begin: &_binary_obj_p_alloctests_start },    // 9
    ]
}

// program_load(p, programnumber)
//    Load the code corresponding to program `programnumber` into the process
//    `p` and set `p->p_registers.reg_rip` to its entry point. Calls
//    `assign_physical_page` as required. Returns 0 on success and
//    -1 on failure (e.g. out-of-memory).
//
//    (The reference k-loader.c also threads an `allocator` callback through
//    this function and program_load_segment below, for a page-allocation
//    strategy no step of this pset ever actually supplies -- it's always
//    NULL. It's dropped here rather than carried around unused.)

pub unsafe fn program_load(p: &mut Proc, programnumber: i32) -> i32 {
    // is this a valid program?
    let ramimages = ramimages();
    assert!(programnumber >= 0 && (programnumber as usize) < ramimages.len());
    let eh = ramimages[programnumber as usize].begin as *const ElfHeader;
    assert!((*eh).e_magic == ELF_MAGIC);

    // load each loadable program segment into memory
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

    // The heap starts on the page right after the last loaded segment
    // (text/data/bss); the break starts there too, i.e. a zero-sized
    // heap. brk/sbrk (kernel::sbrk) move `program_break` from here.
    p.program_break = round_up(max_end_mem, PAGESIZE);
    p.original_break = p.program_break;
    0
}

// program_load_segment(p, ph, src)
//    Load an ELF segment at virtual address `ph->p_va` in process `p`. Copies
//    `[src, src + ph->p_filesz)` to `dst`, then clears
//    `[ph->p_va + ph->p_filesz, ph->p_va + ph->p_memsz)` to 0.
//    Calls `assign_physical_page` to allocate pages and `virtual_memory_map`
//    to map them in `p->p_pagetable`. Returns 0 on success and -1 on failure.

unsafe fn program_load_segment(p: &mut Proc, ph: &ElfProgram, src: *const u8) -> i32 {
    let mut va = ph.p_va;
    let end_file = va + ph.p_filesz;
    let end_mem = va + ph.p_memsz;
    va &= !(PAGESIZE - 1); // round to page boundary

    // Step 6: a segment the process may never write to (like .text) can
    // be shared between processes by fork(), instead of copied, once it
    // is mapped read-only.
    let writable = (ph.p_flags & ELF_PFLAG_WRITE) != 0;

    // allocate memory (Step 6: any free physical page, not identity-mapped)
    let mut addr = va;
    while addr < end_mem {
        let pa = find_free_page();
        if pa == u64::MAX
            || assign_physical_page(pa, p.p_pid as i8) < 0
            || virtual_memory_map(p.p_pagetable, addr, pa, PAGESIZE, (PTE_P | PTE_W | PTE_U) as i32) < 0
        {
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

    // now that the segment's data is copied, drop PTE_W on read-only
    // segments so applications can't write them (and fork() can share them)
    if !writable {
        let mut addr = va;
        while addr < end_mem {
            let vam = virtual_memory_lookup(p.p_pagetable, addr);
            virtual_memory_map(p.p_pagetable, addr, vam.pa, PAGESIZE, (PTE_P | PTE_U) as i32);
            addr += PAGESIZE;
        }
    }
    0
}
