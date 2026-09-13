// vm.rs (ported from kernel/vm.c)

// NOTE
// Read x86_64.rs for some useful functions and constants relevant here!

use crate::kernel::MEMSIZE_PHYSICAL;
use crate::log_printf;
use crate::x86_64::*;
use weensyos_shared::VaMapping;

extern "C" {
    fn default_int_handler();
}

// virtual_memory_init
//    Initialize the virtual memory system, including an initial page table
//    `kernel_pagetable`.

static mut KERNEL_PAGETABLES: [X86_64Pagetable; 5] = [X86_64Pagetable { entry: [0; NPAGETABLEENTRIES] }; 5];
#[allow(non_upper_case_globals)]
pub static mut kernel_pagetable: *mut X86_64Pagetable = core::ptr::null_mut();

pub unsafe fn virtual_memory_init() {
    kernel_pagetable = &mut KERNEL_PAGETABLES[0];

    // connect the pagetable pages
    KERNEL_PAGETABLES[0].entry[0] = (&KERNEL_PAGETABLES[1] as *const X86_64Pagetable as u64) | PTE_P | PTE_W | PTE_U;
    KERNEL_PAGETABLES[1].entry[0] = (&KERNEL_PAGETABLES[2] as *const X86_64Pagetable as u64) | PTE_P | PTE_W | PTE_U;
    KERNEL_PAGETABLES[2].entry[0] = (&KERNEL_PAGETABLES[3] as *const X86_64Pagetable as u64) | PTE_P | PTE_W | PTE_U;
    KERNEL_PAGETABLES[2].entry[1] = (&KERNEL_PAGETABLES[4] as *const X86_64Pagetable as u64) | PTE_P | PTE_W | PTE_U;

    // identity map the page table
    virtual_memory_map(kernel_pagetable, 0, 0, MEMSIZE_PHYSICAL, (PTE_P | PTE_W | PTE_U) as i32);

    // check if kernel is identity mapped
    let mut addr = 0;
    while addr < MEMSIZE_PHYSICAL {
        let vmap = virtual_memory_lookup(kernel_pagetable, addr);
        // this assert will probably fail initially!
        // have you implemented virtual_memory_map and lookup_l1pagetable?
        assert!(vmap.pa == addr);
        assert!((vmap.perm as u64 & (PTE_P | PTE_W)) == (PTE_P | PTE_W));
        addr += PAGESIZE;
    }

    // set pointer to this pagetable in the CR3 register
    // set_pagetable also does several checks for a valid pagetable
    set_pagetable(kernel_pagetable);
}

// set_pagetable
//    Change page directory. lcr3() is the hardware instruction;
//    set_pagetable() additionally checks that important kernel procedures are
//    mappable in `pagetable`, and panics if they aren't.

pub unsafe fn set_pagetable(pagetable: *mut X86_64Pagetable) {
    assert!(page_offset(pagetable as u64) == 0); // must be page aligned
    // check for kernel space being mapped in pagetable
    assert!(virtual_memory_lookup(pagetable, default_int_handler as u64).pa == default_int_handler as u64);
    assert!(virtual_memory_lookup(kernel_pagetable, pagetable as u64).pa == pagetable as u64);
    assert!(virtual_memory_lookup(pagetable, kernel_pagetable as u64).pa == kernel_pagetable as u64);
    assert!(virtual_memory_lookup(pagetable, virtual_memory_map as u64).pa == virtual_memory_map as u64);
    lcr3(pagetable as u64);
}

// virtual_memory_map(pagetable, va, pa, sz, perm)
//    Map virtual address range `[va, va+sz)` in `pagetable`.
//    When `X >= 0 && X < sz`, the new pagetable will map virtual address
//    `va+X` to physical address `pa+X` with permissions `perm`.
//
//    Precondition: `va`, `pa`, and `sz` must be multiples of PAGESIZE
//    (4096).
//
//    Typically `perm` is a combination of `PTE_P` (the memory is Present),
//    `PTE_W` (the memory is Writable), and `PTE_U` (the memory may be
//    accessed by User applications). If `!(perm & PTE_P)`, `pa` is ignored.
//
//    Returns 0 if the map succeeds, -1 if it fails (because a required
//    page table was not allocated).

// `#[no_mangle] extern "C"`: kernel/k-vm.o (precompiled, no source
// available -- see kernel.rs) calls this by its plain C symbol name, so
// it must be exposed exactly as C would see it, not Rust-mangled.
#[no_mangle]
pub unsafe extern "C" fn virtual_memory_map(pagetable: *mut X86_64Pagetable, mut va: u64, mut pa: u64, mut sz: u64, perm: i32) -> i32 {
    // sanity checks for virtual address, size, and permissions
    assert!(va % PAGESIZE == 0); // virtual address is page-aligned
    assert!(sz % PAGESIZE == 0); // size is a multiple of PAGESIZE
    assert!(va.wrapping_add(sz) >= va || va.wrapping_add(sz) == 0); // va range does not wrap
    if perm & PTE_P as i32 != 0 {
        assert!(pa % PAGESIZE == 0); // physical addr is page-aligned
        assert!(pa.wrapping_add(sz) >= pa); // physical address range does not wrap
        assert!(pa + sz <= MEMSIZE_PHYSICAL); // physical addresses exist
    }
    assert!(perm >= 0 && perm < 0x1000); // `perm` makes sense (perm can only be 12 bits)
    assert!(pagetable as u64 % PAGESIZE == 0); // `pagetable` page-aligned

    let mut last_index123: i64 = -1;
    let mut l1pagetable: *mut X86_64Pagetable = core::ptr::null_mut();

    // for each page-aligned address, set the appropriate page entry
    while sz != 0 {
        let cur_index123 = (va >> (PAGEOFFBITS + PAGEINDEXBITS)) as i64;
        if cur_index123 != last_index123 {
            l1pagetable = lookup_l1pagetable(pagetable, va, perm);
            last_index123 = cur_index123;
        }
        if (perm & PTE_P as i32 != 0) && !l1pagetable.is_null() {
            (*l1pagetable).entry[pageindex(va, 3)] = pa | perm as u64;
        } else if !l1pagetable.is_null() {
            (*l1pagetable).entry[pageindex(va, 3)] = perm as u64;
        } else if perm & PTE_P as i32 != 0 {
            // error, no allocated l1 page found for va
            log_printf!("[Kern Info] failed to find l1pagetable address at {}:{}\n", file!(), line!());
            return -1;
        }

        va += PAGESIZE;
        pa += PAGESIZE;
        sz -= PAGESIZE;
    }
    0
}

// lookup_l1pagetable(pagetable, va, perm)
//    Helper function to find the last level of `va` in `pagetable`
//
//    Returns a pointer to the last level pagetable if it exists and can be
//    accessed with the given permissions. Returns null otherwise.

unsafe fn lookup_l1pagetable(pagetable: *mut X86_64Pagetable, va: u64, perm: i32) -> *mut X86_64Pagetable {
    let mut pt = pagetable;

    // We find the l1 pagetable by doing the following three steps for each level
    // 1. Find index to the next pagetable entry using the `va`
    // 2. Check if this entry has the appropriate requested permissions
    // 3. Repeat the steps till you reach the l1 pagetable (i.e. thrice)
    // 4. return the pagetable address

    for i in 0..=2 {
        let pe: X86_64PageentryT = (*pt).entry[pageindex(va, i)];

        if pe & PTE_P == 0 {
            // address of next level should be present AND PTE_P should be set, error otherwise
            log_printf!(
                "[Kern Info] Error looking up l1pagetable: Pagetable address: {:#x} perm: {:#x}. Failed to get level {}\n",
                pte_addr(pe), pte_flags(pe), i + 2
            );
            if perm & PTE_P as i32 == 0 {
                return core::ptr::null_mut();
            }
            log_printf!("[Kern Info] failed to find pagetable address at {}:{}\n", file!(), line!());
            return core::ptr::null_mut();
        }

        // sanity-check page entry and permissions
        assert!(pte_addr(pe) < MEMSIZE_PHYSICAL); // at sensible address
        if perm & PTE_W as i32 != 0 {
            assert!(pe & PTE_W != 0); // if requester wants PTE_W, entry must allow PTE_W
        }
        if perm & PTE_U as i32 != 0 {
            assert!(pe & PTE_U != 0); // if requester wants PTE_U, entry must allow PTE_U
        }

        pt = pte_addr(pe) as *mut X86_64Pagetable;
    }
    pt
}

// virtual_memory_lookup(pagetable, va)
//    Returns information about the mapping of the virtual address `va` in
//    `pagetable`. The information is returned as a `VaMapping` object.

// `#[no_mangle] extern "C"`: see virtual_memory_map's comment above --
// kernel/k-vm.o calls this by its plain C symbol name.
#[no_mangle]
pub unsafe extern "C" fn virtual_memory_lookup(pagetable: *mut X86_64Pagetable, va: u64) -> VaMapping {
    let mut pt = pagetable;
    let mut pe: X86_64PageentryT = PTE_W | PTE_U | PTE_P;
    let mut i = 0;
    while i <= 3 && (pe & PTE_P) != 0 {
        pe = (*pt).entry[pageindex(va, i)] & !(pe & (PTE_W | PTE_U));
        pt = pte_addr(pe) as *mut X86_64Pagetable;
        i += 1;
    }
    let mut vam = VaMapping::UNMAPPED;
    if pe & PTE_P != 0 {
        vam.pn = page_number(pe);
        vam.pa = pte_addr(pe) + page_offset(va);
        vam.perm = pte_flags(pe) as i32;
    }
    vam
}
