#include "process.h"
#include "lib.h"
#include "malloc.h"

extern uint8_t end[];

uint8_t* heap_top;
uint8_t* stack_bottom;


void process_main(void) {
    pid_t p = getpid();
    srand(p);
    // The heap starts on the page right after the 'end' symbol,
    // whose address is the first address not allocated to process code
    // or data.
    heap_top = ROUNDUP((uint8_t*) end, PAGESIZE);

    // sbrk(0) should return current program break without changing it.
    void * ptr = sbrk(0);
    if(ptr == (void *)-1){
    kernel_panic("SBRK unimplemented!");
    }
    assert(ptr == heap_top);

    // The bottom of the stack is the first address on the current
    // stack page (this process never needs more than one stack page).
    stack_bottom = ROUNDDOWN((uint8_t*) read_rsp() - 1, PAGESIZE);


    // allocate a lot of pages (1MB)
    int num_pages = (1 << 8);
    sbrk(PAGESIZE * num_pages);

    int num = 0;
    for(int i = 0 ; i < num_pages ; i++){
        if(i % 2){
            // write to page
            *((heap_top + PAGESIZE*i)) = (char)p;
            assert(heap_top[PAGESIZE*i] == (char)p);
            num++;
        }
    }

    // confirm checkered pattern
    for(int i = 0 ; i < num_pages ; i++){
        if(!(i % 2)){
            vamapping map;
            mapping((uintptr_t)heap_top + PAGESIZE*i, &map);
            assert(!(map.perm & PTE_P));
        }
    }

    // now de-alloc half of them one by one
    ptr = sbrk(0);
    app_printf(0, "num:%d\n", num);
    num--;
    sbrk(-PAGESIZE);
    while(num){
        void * prev = sbrk(-PAGESIZE);
        assert(prev + PAGESIZE == ptr);
        ptr = prev;
        num--;

        vamapping map;
        mapping((uintptr_t)prev, &map);
        assert(!(map.perm & PTE_P));
    }
    ptr = sbrk(0);


    assert(ptr == (heap_top + (num_pages >> 1) * PAGESIZE));

    TEST_PASS();
}
