#include "process.h"
#include "lib.h"
#include "malloc.h"


#define ALLOC_SLOWDOWN 100
#define MAX_ALLOC 100
extern uint8_t end[];

uint8_t *heap_top;
uint8_t *heap_bottom;
uint8_t *stack_bottom;



void process_main(void) {
    pid_t p = getpid();
    srand(p);
    heap_bottom = heap_top = ROUNDUP((uint8_t*) end, PAGESIZE);
    stack_bottom = ROUNDDOWN((uint8_t*) read_rsp() - 1, PAGESIZE);

    // set breakpoint to one page less than stack
    uint8_t* new_brk = ROUNDDOWN(stack_bottom -1, PAGESIZE);
    brk(new_brk);

    void * ptr = malloc(PAGESIZE);
    if(ptr != NULL)
	    for(int i = 0 ; i < PAGESIZE ; i++){
		((char *)ptr)[i] = 'X';
	    }

    TEST_PASS();
}
