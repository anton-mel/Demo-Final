// p-test.rs (ported from uspace/p-test.c -- a stand-in for whichever
// program `make test-NAME` copies in)
//
//    Calls calloc with every (i, j) size pair from 1x1 to 63x63,
//    checking the result is zeroed and non-null, freeing it, and
//    defragmenting after each row. Run via boot command "test" or by
//    pressing 't' once WeensyOS is running.
//
//    Initially (before uspace/malloc is implemented) `calloc` always
//    returns `None`, so the first `.expect(...)` below panics
//    immediately -- matching the reference starter's own behavior of
//    failing an assertion right away.
#![no_std]
#![no_main]

use weensyos_malloc::{calloc, defrag, free};
use weensyos_process::getpid;
use weensyos_shared::srand;

#[no_mangle]
pub extern "C" fn process_main() -> ! {
    let p = getpid();
    srand(p as u32);

    // Single elements on heap of varying sizes.
    for i in 1u64..64 {
        for j in 1u64..64 {
            let ptr = calloc(i, j).expect("calloc failed");
            let bytes = unsafe { core::slice::from_raw_parts(ptr.as_ptr(), (i * j) as usize) };
            for &b in bytes {
                assert_eq!(b, 0);
            }
            unsafe { free(Some(ptr)) };
        }
        defrag();
    }

    panic!("TEST PASS");
}
