#include "malloc.h"

void free(void *firstbyte) {
    return;
}

void *malloc(uint64_t numbytes) {
    return 0 ;
}


void * calloc(uint64_t num, uint64_t sz) {
    return 0;
}

void * realloc(void * ptr, uint64_t sz) {
    return 0;
}

void defrag() {
}

int heap_info(heap_info_struct * info) {
    return 0;
}
