#include "process.h"
#include "lib.h"
#include "malloc.h"


extern uint8_t end[];

uint8_t *heap_top;
uint8_t *heap_bottom;
uint8_t *stack_bottom;

void process_main(void) {
    pid_t p = getpid();
    srand(p);
    heap_bottom = heap_top = ROUNDUP((uint8_t*) end, PAGESIZE);
    stack_bottom = ROUNDDOWN((uint8_t*) read_rsp() - 1, PAGESIZE);

    malloc(10);
    malloc(10);


    heap_info_struct h1, h2;
    heap_info(&h1);
    heap_info(&h2);

    assert(h1.size_array != h2.size_array);
    assert(h1.size_array != NULL);
    assert(h2.size_array != NULL);
    assert(h1.ptr_array != h2.ptr_array);
    assert(h1.ptr_array != NULL);
    assert(h2.ptr_array != NULL);

    free(h1.size_array);
    free(h2.size_array);

    free(h1.ptr_array);
    free(h2.ptr_array);

    app_printf(0, "HEAP CORRECT PASS\n");
    TEST_PASS();

    // After running out of memory, do nothing forever
    while (1) {
        yield();
    }
}
