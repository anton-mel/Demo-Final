#include "process.h"
#include "lib.h"
#include "malloc.h"
#include "time.h"

extern uint8_t end[];

uint8_t *heap_top;
uint8_t *heap_bottom;
uint8_t *stack_bottom;

void process_main(void) {
    pid_t p = getpid();
    srand(p);
    heap_bottom = heap_top = ROUNDUP((uint8_t*) end, PAGESIZE);
    stack_bottom = ROUNDDOWN((uint8_t*) read_rsp() - 1, PAGESIZE);

    void **ptr = (void **)sbrk(PAGESIZE << 2);

    heap_info_struct h1, h2;


    int i;
    for(i = 0 ; i < 1024 ; i++){
	ptr[i] = malloc(10 * ((i%4) + 1));
    }
 
    heap_info(&h1);
    free(h1.size_array);
    for(int j = 0 ; j < i ; j++)
	free(ptr[j]);
    register uint64_t time1 = rdtsc();
    defrag();
    time1 = rdtsc() - time1;
    free(h1.ptr_array);
    heap_info(&h2);


    assert(h2.largest_free_chunk > h1.largest_free_chunk);

    app_printf(0, "time: %lu\n", time1);

    if(time1 > 250000){
	assert("time too high!" && 0);
    }

    app_printf(0, "HEAP FREE SPACE PASS\n");
    TEST_PASS();

    // After running out of memory, do nothing forever
    while (1) {
        yield();
    }
}
