// syscalls.rs
//
//    An application asm calls `int NUM` to call a system call.
//    For the curious, read more here: https://os.phil-opp.com/hardware-interrupts/.
//    We handle the interrupt with ASM here: kernel/k-exception.S.

pub const INT_SYS: u64 = 48;
pub const INT_SYS_PANIC: u64 = INT_SYS;
pub const INT_SYS_GETPID: u64 = INT_SYS + 1;
pub const INT_SYS_YIELD: u64 = INT_SYS + 2;
pub const INT_SYS_PAGE_ALLOC: u64 = INT_SYS + 3;
pub const INT_SYS_FORK: u64 = INT_SYS + 4;
pub const INT_SYS_EXIT: u64 = INT_SYS + 5;

pub const INT_SYS_MAPPING: u64 = INT_SYS + 6;

pub const INT_SYS_MEM_TOG: u64 = INT_SYS + 8;
pub const INT_SYS_BRK: u64 = INT_SYS + 9;
pub const INT_SYS_SBRK: u64 = INT_SYS + 10;
