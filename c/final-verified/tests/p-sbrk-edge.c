#include "process.h"
#include "lib.h"
#include "malloc.h"


#define ALLOC_SLOWDOWN 100
#define MAX_ALLOC 100
extern uint8_t end[];

uint8_t* heap_top;
uint8_t* stack_bottom;


const char large_static_data[] = "\
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam varius ex sapien, vitae ultrices lacus porttitor vitae. Aliquam massa lectus, dictum vel augue at, vestibulum mollis purus. Sed ac dapibus velit. Proin feugiat justo sit amet arcu finibus, at pharetra lacus ullamcorper. Quisque at felis dapibus, facilisis nibh eu, scelerisque arcu. Suspendisse ut bibendum sem. Duis condimentum bibendum turpis, nec ultricies ipsum bibendum non.\
\
Maecenas bibendum ac tellus id viverra. Cras pretium dignissim tincidunt. Duis dictum consequat eros a tincidunt. Quisque convallis porttitor justo. Aenean magna libero, aliquam eget leo sed, sagittis imperdiet sem. Fusce hendrerit imperdiet ex at gravida. In ultrices augue sem, at elementum velit ultricies eu. Suspendisse sodales libero a urna consectetur hendrerit. Aenean sed est et lacus porttitor lobortis eget ut orci. Duis sodales lectus in velit rutrum, nec malesuada sapien placerat. Nam lacinia nunc eget turpis bibendum semper. Mauris malesuada luctus sem, at aliquam est porttitor eu. Cras tincidunt egestas scelerisque.\
\
Mauris mi quam, rhoncus a hendrerit at, porta ut libero. Aliquam tortor nisl, finibus faucibus tincidunt a, mattis fermentum magna. Donec ut ex lacinia, ultricies enim eget, lobortis sapien. Sed erat est, laoreet semper vehicula eget, auctor a mi. Morbi eu nunc diam. Quisque placerat ex velit, a suscipit metus bibendum sed. Cras non vestibulum ligula, sed condimentum mauris. Nullam nec interdum enim, id tincidunt sem. Curabitur ac diam vitae neque ultricies varius. Maecenas felis metus, varius posuere purus placerat, finibus luctus neque. Integer et tristique dolor. Praesent ultrices ex eros, ac rhoncus eros accumsan a. Nunc condimentum nec dui sit amet dapibus. Nullam eget ex tellus. Vivamus at sagittis nibh.\
\
Cras malesuada convallis odio, et tempus mi euismod vitae. Ut porttitor tincidunt velit quis faucibus. Integer rhoncus leo in nisi sollicitudin venenatis. Donec porttitor porttitor enim. Curabitur gravida, turpis at tempor sollicitudin, mi orci efficitur urna, sit amet malesuada eros magna eget nulla. Cras pharetra placerat nibh, et gravida lorem fringilla ut. Etiam volutpat dictum augue sed ultricies. Sed et sagittis massa. Vivamus eu nunc semper, auctor dui vel, auctor elit. Donec at auctor velit, id pharetra est. In ac tincidunt sapien. Fusce vehicula in dolor eu porttitor. Nam ultrices est quis pulvinar bibendum. Cras sit amet nisl eleifend, porttitor velit eu, lacinia eros. Integer justo ligula, mollis et dui sed, accumsan rhoncus purus. Maecenas pellentesque odio dolor, id convallis tortor tincidunt at.\
\
Nam eu ante nisl. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Cras vehicula tristique justo, sit amet bibendum urna faucibus ut. Sed porttitor massa velit, et mollis velit fringilla a. Etiam gravida non quam at finibus. Vivamus nec tortor sollicitudin, interdum sem non, tincidunt mi. Donec eu neque eu arcu consequat gravida. Praesent pharetra maximus purus, at finibus nisi iaculis nec. Nullam sit amet laoreet augue. Nam consectetur vel enim eu iaculis. Ut consequat orci eget varius varius. Suspendisse ac enim quis purus iaculis ullamcorper.\
\
Aliquam erat volutpat. Proin vehicula mi justo, et pellentesque massa maximus sodales. Curabitur diam felis, aliquam eu volutpat eget, hendrerit in libero. Donec viverra orci erat, nec tincidunt felis efficitur ut. Vivamus tellus erat, consectetur nec ex ut, sagittis molestie ligula. Duis nec accumsan felis. Interdum et malesuada fames ac ante ipsum primis in faucibus. Fusce ac gravida dui. Etiam congue suscipit lorem, quis molestie felis lobortis posuere. Phasellus auctor, nibh in pretium vestibulum, nibh ipsum imperdiet libero, ut euismod lorem nisl eget erat. Maecenas vestibulum vehicula ante, convallis vestibulum risus. Vestibulum condimentum quis nibh ac hendrerit. Donec suscipit nulla ac ligula blandit dignissim. Phasellus mi nunc, iaculis at cursus nec, lobortis eget diam.\
\
Suspendisse mattis nisl non tincidunt dictum. Sed vestibulum ultricies sapien. Vivamus posuere imperdiet lorem vel interdum. Morbi arcu dolor, commodo ac fringilla at, auctor at ligula. Nunc et felis enim. Donec tincidunt eget eros id tristique. Nulla tincidunt pulvinar lacus, et tincidunt eros fermentum ac. Phasellus ac volutpat eros, quis ultricies velit. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin tristique nisl non orci dapibus, at imperdiet mi porttitor. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Praesent pellentesque imperdiet velit, dignissim ullamcorper est eleifend non. Suspendisse placerat, mauris vel aliquet blandit, erat nibh commodo nisi, a consectetur nunc neque et velit. Maecenas mattis ultricies mauris, sed porttitor mi commodo quis. Quisque eu molestie lectus. Suspendisse potenti. Praesent a facilisis sem libero.\n";


void process_main(void) {
    pid_t p = getpid();
    srand(p);
    heap_top = ROUNDUP((uint8_t*) end, PAGESIZE);
    stack_bottom = ROUNDDOWN((uint8_t*) read_rsp() - 1, PAGESIZE);

    uint8_t * heap = heap_top;

    intptr_t break1, break2;

    //Sanity
    break1 = (intptr_t)sbrk(0);
    assert(break1 == (intptr_t)heap_top);
    break2 = break1;

    //Move before end, returns error
    break1 = (intptr_t)sbrk(-50);
    assert(break1 = -1);

    //Break unchanged after error
    break1 = (intptr_t)sbrk(0);
    assert(break1 == break2);
    break2 = break1;

    //Move past stack
    break1 = (intptr_t)sbrk(1024*1024*1024);
    assert(break1 = -1);

    //Break unchanged after error
    break1 = (intptr_t)sbrk(0);
    assert(break1 == break2);

    app_printf(0, large_static_data);

    TEST_PASS();
}
