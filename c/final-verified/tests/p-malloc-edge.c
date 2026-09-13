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


    void *ptr;
    //malloc 0, can be done indefintely
    for(int i = 0; i < 10000; ++i) {
        ptr = malloc(0);
        free(ptr);
    }

    //free null can be done indefinitely
    for(int i = 0; i < 10000; ++i) {
        free(NULL);
    }

    //big malloc
    ptr = malloc(1024*1024);
    assert(ptr != NULL);

    TEST_PASS();
}
