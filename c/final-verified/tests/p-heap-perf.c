#include "process.h"
#include "lib.h"
#include "malloc.h"
#include "time.h"

#define ALLOC(ind) sizes[ind%4] * ((ind >> 2) % 4 + 1) 

typedef struct ptr_with_size{
    void * ptr;
    long size;
} ptr_with_size;
extern uint8_t end[];

uint8_t *heap_top;
uint8_t *heap_bottom;
uint8_t *stack_bottom;

void process_main(void) {
    pid_t p = getpid();
    srand(p);
    heap_bottom = heap_top = ROUNDUP((uint8_t*) end, PAGESIZE);
    stack_bottom = ROUNDDOWN((uint8_t*) read_rsp() - 1, PAGESIZE);

    heap_info_struct h1;

    mem_tog(0);

    int i;

    int sizes[] = {10, 20, 30, 1999};

    // leave about 1 MB for malloc
    sbrk(123 * PAGESIZE);
    heap_top = sbrk(0);

    ptr_with_size *ptr = (ptr_with_size *)heap_bottom;
    // shift brk so we are 1 MB before stack
    brk((void *)(intptr_t)ROUNDDOWN(0x200000-1, PAGESIZE));


    volatile int ptr_size = 0;
    mem_tog(0);

    // punish naive quicksort and bubble sort
    while((intptr_t)ROUNDUP(sbrk(0), PAGESIZE) <= 0x2C0000){
	int sz = ALLOC(ptr_size);
	void * temp_ptr = malloc(sz);
	if(temp_ptr == NULL)
	    break;
	ptr[ptr_size].ptr = temp_ptr;
	ptr[ptr_size].size = sz;
	ptr_size++;
    }

 
    register uint64_t time1 = rdtsc();
    heap_info(&h1);
    time1 = rdtsc() - time1;

    app_printf(0, "time: %lu num_allocs: %d\n", time1, h1.num_allocs);

    if(time1 > 14500000){
	assert("time too high!" && 0);
    }


    app_printf(0, "HEAP FREE SPACE PASS\n");
    TEST_PASS();
    // After running out of memory, do nothing forever
    while (1) {
        yield();
    }
}
