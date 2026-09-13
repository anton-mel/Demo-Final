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

    /* Many things allocated at the same time */
    static char *ptrs[512];

    for(size_t i = 0; i < sizeof(ptrs)/sizeof(ptrs[0]); ++i) {
        ptrs[i] = (char *) malloc(i+1);
        assert(ptrs[i] != NULL);

        /* Check that we can write */
        memset(ptrs[i], i % 16 , i+1);
    }

    assert(sbrk(0) > (void *)heap_bottom);

    for(size_t i = 0; i < sizeof(ptrs)/sizeof(ptrs[0]); ++i) {
        /* check for corruption */
        for(size_t j = 0; j < i+1; j++) {
            assert(ptrs[i][j] == (char)(i % 16));
        }

        free((void *)ptrs[i]);
    }

    TEST_PASS();
}
