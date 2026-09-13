// clib.rs (ported from shared/lib.h + shared/lib.c: "C library subset")

// struct vamapping
//    Used to store mapping information returned by virtual_memory_lookup
//    and other kernel functions.
#[repr(C)]
#[derive(Clone, Copy)]
pub struct VaMapping {
    pub pn: i32,   // physical page number; -1 if unmapped
    pub pa: u64,   // physical address; u64::MAX if unmapped
    pub perm: i32, // permissions; 0 if unmapped
}

impl VaMapping {
    pub const UNMAPPED: VaMapping = VaMapping { pn: -1, pa: u64::MAX, perm: 0 };
}

// Round down to the nearest multiple of n
pub const fn round_down(a: u64, n: u64) -> u64 {
    a - a % n
}
// Round up to the nearest multiple of n
pub const fn round_up(a: u64, n: u64) -> u64 {
    round_down(a + n - 1, n)
}

// rand, srand
//    A simple linear congruential generator, matching the reference C
//    library's (so the demo workloads see the same distribution of
//    allocation/fork/exit decisions).

pub const RAND_MAX: u32 = 0x7FFFFFFF;

static mut RAND_SEED_SET: bool = false;
static mut RAND_SEED: u32 = 0;

pub fn rand() -> u32 {
    unsafe {
        if !RAND_SEED_SET {
            srand(819234718);
        }
        RAND_SEED = RAND_SEED.wrapping_mul(1664525).wrapping_add(1013904223);
        RAND_SEED & RAND_MAX
    }
}

pub fn srand(seed: u32) {
    unsafe {
        RAND_SEED = seed;
        RAND_SEED_SET = true;
    }
}
