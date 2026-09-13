// kloader.rs
//
//    Load a weensy application into memory from the boot image.

use crate::elf::*;
use crate::kernel::Proc;
use crate::vm::{kernel_pagetable, set_pagetable, virtual_memory_lookup, virtual_memory_map};
use crate::x86_64::{PAGESIZE, PTE_P, PTE_U, PTE_W};
use weensyos_shared::{cpos, console_printf};

extern "C" {
    fn palloc(pid: i32) -> *mut u8;
}

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
//    `assign_physical_page` to as required. Returns 0 on success and
//    -1 on failure (e.g. out-of-memory). `allocator` is passed to
//    `virtual_memory_map`.

#[no_mangle]
pub unsafe extern "C" fn program_load(p: &mut Proc, programnumber: i32) -> i32 {
    // is this a valid program?
    let ramimages = ramimages();
    assert!(programnumber >= 0 && (programnumber as usize) < ramimages.len());
    let eh = ramimages[programnumber as usize].begin as *const ElfHeader;
    assert!((*eh).e_magic == ELF_MAGIC);

    // load each loadable program segment into memory
    let ph = (eh as *const u8).add((*eh).e_phoff as usize) as *const ElfProgram;
    for i in 0..(*eh).e_phnum as isize {
        let ph_i = &*ph.offset(i);
        if ph_i.p_type == ELF_PTYPE_LOAD {
            let pdata = (eh as *const u8).add(ph_i.p_offset as usize);
            if program_load_segment(p, ph_i, pdata) < 0 {
                return -1;
            }
        }
    }

    // set the entry point from the ELF header
    p.p_registers.reg_rip = (*eh).e_entry;
    
    // TODO
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
