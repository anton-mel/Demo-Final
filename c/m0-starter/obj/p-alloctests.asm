
obj/p-alloctests.full:     file format elf64-x86-64


Disassembly of section .text:

00000000002c0000 <process_main>:
#include "time.h"
#include "malloc.h"

extern uint8_t end[];

void process_main(void) {
  2c0000:	55                   	push   %rbp
  2c0001:	48 89 e5             	mov    %rsp,%rbp
  2c0004:	41 56                	push   %r14
  2c0006:	41 55                	push   %r13
  2c0008:	41 54                	push   %r12
  2c000a:	53                   	push   %rbx
  2c000b:	48 83 ec 20          	sub    $0x20,%rsp

// getpid
//    Return current process ID.
static inline pid_t getpid(void) {
    pid_t result;
    asm volatile ("int %1" : "=a" (result)
  2c000f:	cd 31                	int    $0x31
  2c0011:	41 89 c4             	mov    %eax,%r12d
    
    pid_t p = getpid();
    srand(p);
  2c0014:	89 c7                	mov    %eax,%edi
  2c0016:	e8 22 06 00 00       	call   2c063d <srand>

    // alloc int array of 10 elements
    int* array = (int *)malloc(sizeof(int) * 10);
  2c001b:	bf 28 00 00 00       	mov    $0x28,%edi
  2c0020:	e8 08 03 00 00       	call   2c032d <malloc>
  2c0025:	48 89 c7             	mov    %rax,%rdi
  2c0028:	ba 00 00 00 00       	mov    $0x0,%edx
  2c002d:	0f 1f 00             	nopl   (%rax)
    
    // set array elements
    for(int  i = 0 ; i < 10; i++){
	array[i] = i;
  2c0030:	89 14 97             	mov    %edx,(%rdi,%rdx,4)
    for(int  i = 0 ; i < 10; i++){
  2c0033:	48 83 c2 01          	add    $0x1,%rdx
  2c0037:	48 83 fa 0a          	cmp    $0xa,%rdx
  2c003b:	75 f3                	jne    2c0030 <process_main+0x30>
    }

    // realloc array to size 20
    array = (int*)realloc(array, sizeof(int) * 20);
  2c003d:	be 50 00 00 00       	mov    $0x50,%esi
  2c0042:	e8 f2 02 00 00       	call   2c0339 <realloc>
  2c0047:	49 89 c5             	mov    %rax,%r13
  2c004a:	b8 00 00 00 00       	mov    $0x0,%eax
  2c004f:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
  2c0055:	66 66 2e 0f 1f 84 00 	data16 cs nopw 0x0(%rax,%rax,1)
  2c005c:	00 00 00 00 

    // check if contents are same
    for(int i = 0 ; i < 10 ; i++){
	assert(array[i] == i);
  2c0060:	41 39 44 85 00       	cmp    %eax,0x0(%r13,%rax,4)
  2c0065:	75 6d                	jne    2c00d4 <process_main+0xd4>
    for(int i = 0 ; i < 10 ; i++){
  2c0067:	48 83 c0 01          	add    $0x1,%rax
  2c006b:	48 83 f8 0a          	cmp    $0xa,%rax
  2c006f:	75 ef                	jne    2c0060 <process_main+0x60>
    }

    // alloc int array of size 30 using calloc
    int * array2 = (int *)calloc(30, sizeof(int));
  2c0071:	be 04 00 00 00       	mov    $0x4,%esi
  2c0076:	bf 1e 00 00 00       	mov    $0x1e,%edi
  2c007b:	e8 b3 02 00 00       	call   2c0333 <calloc>
  2c0080:	49 89 c6             	mov    %rax,%r14

    // assert array[i] == 0
    for(int i = 0 ; i < 30; i++){
  2c0083:	48 8d 50 78          	lea    0x78(%rax),%rdx
  2c0087:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
  2c008e:	00 00 
	assert(array2[i] == 0);
  2c0090:	8b 18                	mov    (%rax),%ebx
  2c0092:	85 db                	test   %ebx,%ebx
  2c0094:	75 52                	jne    2c00e8 <process_main+0xe8>
    for(int i = 0 ; i < 30; i++){
  2c0096:	48 83 c0 04          	add    $0x4,%rax
  2c009a:	48 39 d0             	cmp    %rdx,%rax
  2c009d:	75 f1                	jne    2c0090 <process_main+0x90>
    }
    
    heap_info_struct info;
    if(heap_info(&info) == 0){
  2c009f:	48 8d 7d c0          	lea    -0x40(%rbp),%rdi
  2c00a3:	e8 98 02 00 00       	call   2c0340 <heap_info>
  2c00a8:	85 c0                	test   %eax,%eax
  2c00aa:	75 64                	jne    2c0110 <process_main+0x110>
	// check if allocations are in sorted order
	for(int  i = 1 ; i < info.num_allocs; i++){
  2c00ac:	8b 55 c0             	mov    -0x40(%rbp),%edx
  2c00af:	83 fa 01             	cmp    $0x1,%edx
  2c00b2:	7e 70                	jle    2c0124 <process_main+0x124>
  2c00b4:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  2c00b8:	8d 52 fe             	lea    -0x2(%rdx),%edx
  2c00bb:	48 8d 54 d0 08       	lea    0x8(%rax,%rdx,8),%rdx
	    assert(info.size_array[i] < info.size_array[i-1]);
  2c00c0:	48 8b 30             	mov    (%rax),%rsi
  2c00c3:	48 39 70 08          	cmp    %rsi,0x8(%rax)
  2c00c7:	7d 33                	jge    2c00fc <process_main+0xfc>
	for(int  i = 1 ; i < info.num_allocs; i++){
  2c00c9:	48 83 c0 08          	add    $0x8,%rax
  2c00cd:	48 39 d0             	cmp    %rdx,%rax
  2c00d0:	75 ee                	jne    2c00c0 <process_main+0xc0>
  2c00d2:	eb 50                	jmp    2c0124 <process_main+0x124>
	assert(array[i] == i);
  2c00d4:	ba 40 14 2c 00       	mov    $0x2c1440,%edx
  2c00d9:	be 19 00 00 00       	mov    $0x19,%esi
  2c00de:	bf 4e 14 2c 00       	mov    $0x2c144e,%edi
  2c00e3:	e8 14 02 00 00       	call   2c02fc <assert_fail>
	assert(array2[i] == 0);
  2c00e8:	ba 64 14 2c 00       	mov    $0x2c1464,%edx
  2c00ed:	be 21 00 00 00       	mov    $0x21,%esi
  2c00f2:	bf 4e 14 2c 00       	mov    $0x2c144e,%edi
  2c00f7:	e8 00 02 00 00       	call   2c02fc <assert_fail>
	    assert(info.size_array[i] < info.size_array[i-1]);
  2c00fc:	ba 90 14 2c 00       	mov    $0x2c1490,%edx
  2c0101:	be 28 00 00 00       	mov    $0x28,%esi
  2c0106:	bf 4e 14 2c 00       	mov    $0x2c144e,%edi
  2c010b:	e8 ec 01 00 00       	call   2c02fc <assert_fail>
	}
    }
    else{
	app_printf(0, "heap_info failed\n");
  2c0110:	be 73 14 2c 00       	mov    $0x2c1473,%esi
  2c0115:	bf 00 00 00 00       	mov    $0x0,%edi
  2c011a:	b8 00 00 00 00       	mov    $0x0,%eax
  2c011f:	e8 7a 00 00 00       	call   2c019e <app_printf>
    }
    
    // free array, array2
    free(array);
  2c0124:	4c 89 ef             	mov    %r13,%rdi
  2c0127:	e8 00 02 00 00       	call   2c032c <free>
    free(array2);
  2c012c:	4c 89 f7             	mov    %r14,%rdi
  2c012f:	e8 f8 01 00 00       	call   2c032c <free>

    uint64_t total_time = 0;
  2c0134:	41 bd 00 00 00 00    	mov    $0x0,%r13d
/* rdtscp */
static uint64_t rdtsc(void) {
	uint64_t var;
	uint32_t hi, lo;

	__asm volatile
  2c013a:	0f 31                	rdtsc
	    ("rdtsc" : "=a" (lo), "=d" (hi));

	var = ((uint64_t)hi << 32) | lo;
  2c013c:	48 c1 e2 20          	shl    $0x20,%rdx
  2c0140:	89 c0                	mov    %eax,%eax
  2c0142:	48 09 c2             	or     %rax,%rdx
  2c0145:	49 89 d6             	mov    %rdx,%r14
    int total_pages = 0;
    
    // allocate pages till no more memory
    while (1) {
	uint64_t time = rdtsc();
	void * ptr = malloc(PAGESIZE);
  2c0148:	bf 00 10 00 00       	mov    $0x1000,%edi
  2c014d:	e8 db 01 00 00       	call   2c032d <malloc>
  2c0152:	48 89 c1             	mov    %rax,%rcx
	__asm volatile
  2c0155:	0f 31                	rdtsc
	var = ((uint64_t)hi << 32) | lo;
  2c0157:	48 c1 e2 20          	shl    $0x20,%rdx
  2c015b:	89 c0                	mov    %eax,%eax
  2c015d:	48 09 c2             	or     %rax,%rdx
	total_time += (rdtsc() - time);
  2c0160:	4c 29 f2             	sub    %r14,%rdx
  2c0163:	49 01 d5             	add    %rdx,%r13
	if(ptr == NULL)
  2c0166:	48 85 c9             	test   %rcx,%rcx
  2c0169:	74 08                	je     2c0173 <process_main+0x173>
	    break;
	total_pages++;
  2c016b:	83 c3 01             	add    $0x1,%ebx
	*((int *)ptr) = p; // check write access
  2c016e:	44 89 21             	mov    %r12d,(%rcx)
    while (1) {
  2c0171:	eb c7                	jmp    2c013a <process_main+0x13a>
    }

    app_printf(p, "Total_time taken to alloc: %d Average time: %d\n", total_time, total_time/total_pages);
  2c0173:	48 63 db             	movslq %ebx,%rbx
  2c0176:	4c 89 e8             	mov    %r13,%rax
  2c0179:	ba 00 00 00 00       	mov    $0x0,%edx
  2c017e:	48 f7 f3             	div    %rbx
  2c0181:	48 89 c1             	mov    %rax,%rcx
  2c0184:	4c 89 ea             	mov    %r13,%rdx
  2c0187:	be c0 14 2c 00       	mov    $0x2c14c0,%esi
  2c018c:	44 89 e7             	mov    %r12d,%edi
  2c018f:	b8 00 00 00 00       	mov    $0x0,%eax
  2c0194:	e8 05 00 00 00       	call   2c019e <app_printf>

// yield
//    Yield control of the CPU to the kernel. The kernel will pick another
//    process to run, if possible.
static inline void yield(void) {
    asm volatile ("int %0" : /* no result */
  2c0199:	cd 32                	int    $0x32

    // After running out of memory
    while (1) {
  2c019b:	eb fc                	jmp    2c0199 <process_main+0x199>
  2c019d:	90                   	nop

00000000002c019e <app_printf>:
#include "process.h"

// app_printf
//     A version of console_printf that picks a sensible color by process ID.

void app_printf(int colorid, const char* format, ...) {
  2c019e:	55                   	push   %rbp
  2c019f:	48 89 e5             	mov    %rsp,%rbp
  2c01a2:	48 83 ec 50          	sub    $0x50,%rsp
  2c01a6:	49 89 f2             	mov    %rsi,%r10
  2c01a9:	48 89 55 e0          	mov    %rdx,-0x20(%rbp)
  2c01ad:	48 89 4d e8          	mov    %rcx,-0x18(%rbp)
  2c01b1:	4c 89 45 f0          	mov    %r8,-0x10(%rbp)
  2c01b5:	4c 89 4d f8          	mov    %r9,-0x8(%rbp)
    int color;
    if (colorid < 0) {
        color = 0x0700;
  2c01b9:	be 00 07 00 00       	mov    $0x700,%esi
    if (colorid < 0) {
  2c01be:	85 ff                	test   %edi,%edi
  2c01c0:	78 2e                	js     2c01f0 <app_printf+0x52>
    } else {
        static const uint8_t col[] = { 0x0E, 0x0F, 0x0C, 0x0A, 0x09 };
        color = col[colorid % sizeof(col)] << 8;
  2c01c2:	48 63 ff             	movslq %edi,%rdi
  2c01c5:	48 ba cd cc cc cc cc 	movabs $0xcccccccccccccccd,%rdx
  2c01cc:	cc cc cc 
  2c01cf:	48 89 f8             	mov    %rdi,%rax
  2c01d2:	48 f7 e2             	mul    %rdx
  2c01d5:	48 89 d0             	mov    %rdx,%rax
  2c01d8:	48 c1 e8 02          	shr    $0x2,%rax
  2c01dc:	48 83 e2 fc          	and    $0xfffffffffffffffc,%rdx
  2c01e0:	48 01 c2             	add    %rax,%rdx
  2c01e3:	48 29 d7             	sub    %rdx,%rdi
  2c01e6:	0f b6 b7 15 15 2c 00 	movzbl 0x2c1515(%rdi),%esi
  2c01ed:	c1 e6 08             	shl    $0x8,%esi
    }

    va_list val;
    va_start(val, format);
  2c01f0:	c7 45 b8 10 00 00 00 	movl   $0x10,-0x48(%rbp)
  2c01f7:	48 8d 45 10          	lea    0x10(%rbp),%rax
  2c01fb:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  2c01ff:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
  2c0203:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    cursorpos = console_vprintf(cursorpos, color, format, val);
  2c0207:	48 8d 4d b8          	lea    -0x48(%rbp),%rcx
  2c020b:	4c 89 d2             	mov    %r10,%rdx
  2c020e:	8b 3d e8 8d df ff    	mov    -0x207218(%rip),%edi        # b8ffc <cursorpos>
  2c0214:	e8 1d 10 00 00       	call   2c1236 <console_vprintf>
    va_end(val);

    if (CROW(cursorpos) >= 23) {
        cursorpos = CPOS(0, 0);
  2c0219:	3d 30 07 00 00       	cmp    $0x730,%eax
  2c021e:	ba 00 00 00 00       	mov    $0x0,%edx
  2c0223:	0f 4d c2             	cmovge %edx,%eax
  2c0226:	89 05 d0 8d df ff    	mov    %eax,-0x207230(%rip)        # b8ffc <cursorpos>
    }
}
  2c022c:	c9                   	leave
  2c022d:	c3                   	ret

00000000002c022e <kernel_panic>:


// kernel_panic, assert_fail
//     Call the INT_SYS_PANIC system call so the kernel loops until Control-C.

void kernel_panic(const char* format, ...) {
  2c022e:	55                   	push   %rbp
  2c022f:	48 89 e5             	mov    %rsp,%rbp
  2c0232:	53                   	push   %rbx
  2c0233:	48 81 ec f8 00 00 00 	sub    $0xf8,%rsp
  2c023a:	48 89 fb             	mov    %rdi,%rbx
  2c023d:	48 89 75 c8          	mov    %rsi,-0x38(%rbp)
  2c0241:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  2c0245:	48 89 4d d8          	mov    %rcx,-0x28(%rbp)
  2c0249:	4c 89 45 e0          	mov    %r8,-0x20(%rbp)
  2c024d:	4c 89 4d e8          	mov    %r9,-0x18(%rbp)
    va_list val;
    va_start(val, format);
  2c0251:	c7 45 a8 08 00 00 00 	movl   $0x8,-0x58(%rbp)
  2c0258:	48 8d 45 10          	lea    0x10(%rbp),%rax
  2c025c:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
  2c0260:	48 8d 45 c0          	lea    -0x40(%rbp),%rax
  2c0264:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
    char buf[160];
    memcpy(buf, "PANIC: ", 7);
  2c0268:	48 8d bd 08 ff ff ff 	lea    -0xf8(%rbp),%rdi
  2c026f:	ba 07 00 00 00       	mov    $0x7,%edx
  2c0274:	be 85 14 2c 00       	mov    $0x2c1485,%esi
  2c0279:	e8 c8 00 00 00       	call   2c0346 <memcpy>
    int len = vsnprintf(&buf[7], sizeof(buf) - 7, format, val) + 7;
  2c027e:	48 8d 4d a8          	lea    -0x58(%rbp),%rcx
  2c0282:	48 8d bd 0f ff ff ff 	lea    -0xf1(%rbp),%rdi
  2c0289:	48 89 da             	mov    %rbx,%rdx
  2c028c:	be 99 00 00 00       	mov    $0x99,%esi
  2c0291:	e8 ab 10 00 00       	call   2c1341 <vsnprintf>
  2c0296:	8d 50 07             	lea    0x7(%rax),%edx
    va_end(val);
    if (len > 0 && buf[len - 1] != '\n') {
  2c0299:	85 d2                	test   %edx,%edx
  2c029b:	7e 0f                	jle    2c02ac <kernel_panic+0x7e>
  2c029d:	83 c0 06             	add    $0x6,%eax
  2c02a0:	48 98                	cltq
  2c02a2:	80 bc 05 08 ff ff ff 	cmpb   $0xa,-0xf8(%rbp,%rax,1)
  2c02a9:	0a 
  2c02aa:	75 2a                	jne    2c02d6 <kernel_panic+0xa8>
        strcpy(buf + len - (len == (int) sizeof(buf) - 1), "\n");
    }
    (void) console_printf(CPOS(23, 0), 0xC000, "%s", buf);
  2c02ac:	48 8d 9d 08 ff ff ff 	lea    -0xf8(%rbp),%rbx
  2c02b3:	48 89 d9             	mov    %rbx,%rcx
  2c02b6:	ba 8d 14 2c 00       	mov    $0x2c148d,%edx
  2c02bb:	be 00 c0 00 00       	mov    $0xc000,%esi
  2c02c0:	bf 30 07 00 00       	mov    $0x730,%edi
  2c02c5:	b8 00 00 00 00       	mov    $0x0,%eax
  2c02ca:	e8 d3 0f 00 00       	call   2c12a2 <console_printf>
}

// panic(msg)
//    Panic.
static inline pid_t __attribute__((noreturn)) panic(const char* msg) {
    asm volatile ("int %0" : /* no result */
  2c02cf:	48 89 df             	mov    %rbx,%rdi
  2c02d2:	cd 30                	int    $0x30
                  : "i" (INT_SYS_PANIC), "D" (msg)
                  : "cc", "memory");
 loop: goto loop;
  2c02d4:	eb fe                	jmp    2c02d4 <kernel_panic+0xa6>
        strcpy(buf + len - (len == (int) sizeof(buf) - 1), "\n");
  2c02d6:	48 63 c2             	movslq %edx,%rax
  2c02d9:	81 fa 9f 00 00 00    	cmp    $0x9f,%edx
  2c02df:	0f 94 c2             	sete   %dl
  2c02e2:	0f b6 d2             	movzbl %dl,%edx
  2c02e5:	48 29 d0             	sub    %rdx,%rax
  2c02e8:	48 8d bc 05 08 ff ff 	lea    -0xf8(%rbp,%rax,1),%rdi
  2c02ef:	ff 
  2c02f0:	be 83 14 2c 00       	mov    $0x2c1483,%esi
  2c02f5:	e8 f9 01 00 00       	call   2c04f3 <strcpy>
  2c02fa:	eb b0                	jmp    2c02ac <kernel_panic+0x7e>

00000000002c02fc <assert_fail>:
    panic(buf);
 spinloop: goto spinloop;       // should never get here
}

void assert_fail(const char* file, int line, const char* msg) {
  2c02fc:	55                   	push   %rbp
  2c02fd:	48 89 e5             	mov    %rsp,%rbp
  2c0300:	48 89 f9             	mov    %rdi,%rcx
  2c0303:	41 89 f0             	mov    %esi,%r8d
  2c0306:	49 89 d1             	mov    %rdx,%r9
    (void) console_printf(CPOS(23, 0), 0xC000,
  2c0309:	ba f0 14 2c 00       	mov    $0x2c14f0,%edx
  2c030e:	be 00 c0 00 00       	mov    $0xc000,%esi
  2c0313:	bf 30 07 00 00       	mov    $0x730,%edi
  2c0318:	b8 00 00 00 00       	mov    $0x0,%eax
  2c031d:	e8 80 0f 00 00       	call   2c12a2 <console_printf>
    asm volatile ("int %0" : /* no result */
  2c0322:	bf 00 00 00 00       	mov    $0x0,%edi
  2c0327:	cd 30                	int    $0x30
  2c0329:	90                   	nop
 loop: goto loop;
  2c032a:	eb fe                	jmp    2c032a <assert_fail+0x2e>

00000000002c032c <free>:
#include "malloc.h"

void free(void *firstbyte) {
    return;
}
  2c032c:	c3                   	ret

00000000002c032d <malloc>:

void *malloc(uint64_t numbytes) {
    return 0 ;
}
  2c032d:	b8 00 00 00 00       	mov    $0x0,%eax
  2c0332:	c3                   	ret

00000000002c0333 <calloc>:


void * calloc(uint64_t num, uint64_t sz) {
    return 0;
}
  2c0333:	b8 00 00 00 00       	mov    $0x0,%eax
  2c0338:	c3                   	ret

00000000002c0339 <realloc>:

void * realloc(void * ptr, uint64_t sz) {
    return 0;
}
  2c0339:	b8 00 00 00 00       	mov    $0x0,%eax
  2c033e:	c3                   	ret

00000000002c033f <defrag>:

void defrag() {
}
  2c033f:	c3                   	ret

00000000002c0340 <heap_info>:

int heap_info(heap_info_struct * info) {
    return 0;
}
  2c0340:	b8 00 00 00 00       	mov    $0x0,%eax
  2c0345:	c3                   	ret

00000000002c0346 <memcpy>:


// memcpy, memmove, memset, strcmp, strlen, strnlen
//    We must provide our own implementations.

void* memcpy(void* dst, const void* src, size_t n) {
  2c0346:	55                   	push   %rbp
  2c0347:	48 89 e5             	mov    %rsp,%rbp
  2c034a:	48 83 ec 28          	sub    $0x28,%rsp
  2c034e:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  2c0352:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  2c0356:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
    const char* s = (const char*) src;
  2c035a:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  2c035e:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    for (char* d = (char*) dst; n > 0; --n, ++s, ++d) {
  2c0362:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  2c0366:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  2c036a:	eb 1c                	jmp    2c0388 <memcpy+0x42>
        *d = *s;
  2c036c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  2c0370:	0f b6 10             	movzbl (%rax),%edx
  2c0373:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  2c0377:	88 10                	mov    %dl,(%rax)
    for (char* d = (char*) dst; n > 0; --n, ++s, ++d) {
  2c0379:	48 83 6d d8 01       	subq   $0x1,-0x28(%rbp)
  2c037e:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  2c0383:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
  2c0388:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  2c038d:	75 dd                	jne    2c036c <memcpy+0x26>
    }
    return dst;
  2c038f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
  2c0393:	c9                   	leave
  2c0394:	c3                   	ret

00000000002c0395 <memmove>:

void* memmove(void* dst, const void* src, size_t n) {
  2c0395:	55                   	push   %rbp
  2c0396:	48 89 e5             	mov    %rsp,%rbp
  2c0399:	48 83 ec 28          	sub    $0x28,%rsp
  2c039d:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  2c03a1:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  2c03a5:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
    const char* s = (const char*) src;
  2c03a9:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  2c03ad:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    char* d = (char*) dst;
  2c03b1:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  2c03b5:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
    if (s < d && s + n > d) {
  2c03b9:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  2c03bd:	48 3b 45 f0          	cmp    -0x10(%rbp),%rax
  2c03c1:	73 6a                	jae    2c042d <memmove+0x98>
  2c03c3:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  2c03c7:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  2c03cb:	48 01 d0             	add    %rdx,%rax
  2c03ce:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
  2c03d2:	73 59                	jae    2c042d <memmove+0x98>
        s += n, d += n;
  2c03d4:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  2c03d8:	48 01 45 f8          	add    %rax,-0x8(%rbp)
  2c03dc:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  2c03e0:	48 01 45 f0          	add    %rax,-0x10(%rbp)
        while (n-- > 0) {
  2c03e4:	eb 17                	jmp    2c03fd <memmove+0x68>
            *--d = *--s;
  2c03e6:	48 83 6d f8 01       	subq   $0x1,-0x8(%rbp)
  2c03eb:	48 83 6d f0 01       	subq   $0x1,-0x10(%rbp)
  2c03f0:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  2c03f4:	0f b6 10             	movzbl (%rax),%edx
  2c03f7:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  2c03fb:	88 10                	mov    %dl,(%rax)
        while (n-- > 0) {
  2c03fd:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  2c0401:	48 8d 50 ff          	lea    -0x1(%rax),%rdx
  2c0405:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  2c0409:	48 85 c0             	test   %rax,%rax
  2c040c:	75 d8                	jne    2c03e6 <memmove+0x51>
    if (s < d && s + n > d) {
  2c040e:	eb 2e                	jmp    2c043e <memmove+0xa9>
        }
    } else {
        while (n-- > 0) {
            *d++ = *s++;
  2c0410:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  2c0414:	48 8d 42 01          	lea    0x1(%rdx),%rax
  2c0418:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  2c041c:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  2c0420:	48 8d 48 01          	lea    0x1(%rax),%rcx
  2c0424:	48 89 4d f0          	mov    %rcx,-0x10(%rbp)
  2c0428:	0f b6 12             	movzbl (%rdx),%edx
  2c042b:	88 10                	mov    %dl,(%rax)
        while (n-- > 0) {
  2c042d:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  2c0431:	48 8d 50 ff          	lea    -0x1(%rax),%rdx
  2c0435:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  2c0439:	48 85 c0             	test   %rax,%rax
  2c043c:	75 d2                	jne    2c0410 <memmove+0x7b>
        }
    }
    return dst;
  2c043e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
  2c0442:	c9                   	leave
  2c0443:	c3                   	ret

00000000002c0444 <memset>:

void* memset(void* v, int c, size_t n) {
  2c0444:	55                   	push   %rbp
  2c0445:	48 89 e5             	mov    %rsp,%rbp
  2c0448:	48 83 ec 28          	sub    $0x28,%rsp
  2c044c:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  2c0450:	89 75 e4             	mov    %esi,-0x1c(%rbp)
  2c0453:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
    for (char* p = (char*) v; n > 0; ++p, --n) {
  2c0457:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  2c045b:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  2c045f:	eb 15                	jmp    2c0476 <memset+0x32>
        *p = c;
  2c0461:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  2c0464:	89 c2                	mov    %eax,%edx
  2c0466:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  2c046a:	88 10                	mov    %dl,(%rax)
    for (char* p = (char*) v; n > 0; ++p, --n) {
  2c046c:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  2c0471:	48 83 6d d8 01       	subq   $0x1,-0x28(%rbp)
  2c0476:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  2c047b:	75 e4                	jne    2c0461 <memset+0x1d>
    }
    return v;
  2c047d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
  2c0481:	c9                   	leave
  2c0482:	c3                   	ret

00000000002c0483 <strlen>:

size_t strlen(const char* s) {
  2c0483:	55                   	push   %rbp
  2c0484:	48 89 e5             	mov    %rsp,%rbp
  2c0487:	48 83 ec 18          	sub    $0x18,%rsp
  2c048b:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
    size_t n;
    for (n = 0; *s != '\0'; ++s) {
  2c048f:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
  2c0496:	00 
  2c0497:	eb 0a                	jmp    2c04a3 <strlen+0x20>
        ++n;
  2c0499:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
    for (n = 0; *s != '\0'; ++s) {
  2c049e:	48 83 45 e8 01       	addq   $0x1,-0x18(%rbp)
  2c04a3:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  2c04a7:	0f b6 00             	movzbl (%rax),%eax
  2c04aa:	84 c0                	test   %al,%al
  2c04ac:	75 eb                	jne    2c0499 <strlen+0x16>
    }
    return n;
  2c04ae:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  2c04b2:	c9                   	leave
  2c04b3:	c3                   	ret

00000000002c04b4 <strnlen>:

size_t strnlen(const char* s, size_t maxlen) {
  2c04b4:	55                   	push   %rbp
  2c04b5:	48 89 e5             	mov    %rsp,%rbp
  2c04b8:	48 83 ec 20          	sub    $0x20,%rsp
  2c04bc:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  2c04c0:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
    size_t n;
    for (n = 0; n != maxlen && *s != '\0'; ++s) {
  2c04c4:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
  2c04cb:	00 
  2c04cc:	eb 0a                	jmp    2c04d8 <strnlen+0x24>
        ++n;
  2c04ce:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
    for (n = 0; n != maxlen && *s != '\0'; ++s) {
  2c04d3:	48 83 45 e8 01       	addq   $0x1,-0x18(%rbp)
  2c04d8:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  2c04dc:	48 3b 45 e0          	cmp    -0x20(%rbp),%rax
  2c04e0:	74 0b                	je     2c04ed <strnlen+0x39>
  2c04e2:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  2c04e6:	0f b6 00             	movzbl (%rax),%eax
  2c04e9:	84 c0                	test   %al,%al
  2c04eb:	75 e1                	jne    2c04ce <strnlen+0x1a>
    }
    return n;
  2c04ed:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  2c04f1:	c9                   	leave
  2c04f2:	c3                   	ret

00000000002c04f3 <strcpy>:

char* strcpy(char* dst, const char* src) {
  2c04f3:	55                   	push   %rbp
  2c04f4:	48 89 e5             	mov    %rsp,%rbp
  2c04f7:	48 83 ec 20          	sub    $0x20,%rsp
  2c04fb:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  2c04ff:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
    char* d = dst;
  2c0503:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  2c0507:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    do {
        *d++ = *src++;
  2c050b:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  2c050f:	48 8d 42 01          	lea    0x1(%rdx),%rax
  2c0513:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  2c0517:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  2c051b:	48 8d 48 01          	lea    0x1(%rax),%rcx
  2c051f:	48 89 4d f8          	mov    %rcx,-0x8(%rbp)
  2c0523:	0f b6 12             	movzbl (%rdx),%edx
  2c0526:	88 10                	mov    %dl,(%rax)
    } while (d[-1]);
  2c0528:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  2c052c:	48 83 e8 01          	sub    $0x1,%rax
  2c0530:	0f b6 00             	movzbl (%rax),%eax
  2c0533:	84 c0                	test   %al,%al
  2c0535:	75 d4                	jne    2c050b <strcpy+0x18>
    return dst;
  2c0537:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
  2c053b:	c9                   	leave
  2c053c:	c3                   	ret

00000000002c053d <strcmp>:

int strcmp(const char* a, const char* b) {
  2c053d:	55                   	push   %rbp
  2c053e:	48 89 e5             	mov    %rsp,%rbp
  2c0541:	48 83 ec 10          	sub    $0x10,%rsp
  2c0545:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  2c0549:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
    while (*a && *b && *a == *b) {
  2c054d:	eb 0a                	jmp    2c0559 <strcmp+0x1c>
        ++a, ++b;
  2c054f:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  2c0554:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
    while (*a && *b && *a == *b) {
  2c0559:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  2c055d:	0f b6 00             	movzbl (%rax),%eax
  2c0560:	84 c0                	test   %al,%al
  2c0562:	74 1d                	je     2c0581 <strcmp+0x44>
  2c0564:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  2c0568:	0f b6 00             	movzbl (%rax),%eax
  2c056b:	84 c0                	test   %al,%al
  2c056d:	74 12                	je     2c0581 <strcmp+0x44>
  2c056f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  2c0573:	0f b6 10             	movzbl (%rax),%edx
  2c0576:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  2c057a:	0f b6 00             	movzbl (%rax),%eax
  2c057d:	38 c2                	cmp    %al,%dl
  2c057f:	74 ce                	je     2c054f <strcmp+0x12>
    }
    return ((unsigned char) *a > (unsigned char) *b)
  2c0581:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  2c0585:	0f b6 00             	movzbl (%rax),%eax
  2c0588:	89 c2                	mov    %eax,%edx
  2c058a:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  2c058e:	0f b6 00             	movzbl (%rax),%eax
  2c0591:	38 d0                	cmp    %dl,%al
  2c0593:	0f 92 c0             	setb   %al
  2c0596:	0f b6 d0             	movzbl %al,%edx
        - ((unsigned char) *a < (unsigned char) *b);
  2c0599:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  2c059d:	0f b6 00             	movzbl (%rax),%eax
  2c05a0:	89 c1                	mov    %eax,%ecx
  2c05a2:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  2c05a6:	0f b6 00             	movzbl (%rax),%eax
  2c05a9:	38 c1                	cmp    %al,%cl
  2c05ab:	0f 92 c0             	setb   %al
  2c05ae:	0f b6 c0             	movzbl %al,%eax
  2c05b1:	29 c2                	sub    %eax,%edx
  2c05b3:	89 d0                	mov    %edx,%eax
}
  2c05b5:	c9                   	leave
  2c05b6:	c3                   	ret

00000000002c05b7 <strchr>:

char* strchr(const char* s, int c) {
  2c05b7:	55                   	push   %rbp
  2c05b8:	48 89 e5             	mov    %rsp,%rbp
  2c05bb:	48 83 ec 10          	sub    $0x10,%rsp
  2c05bf:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  2c05c3:	89 75 f4             	mov    %esi,-0xc(%rbp)
    while (*s && *s != (char) c) {
  2c05c6:	eb 05                	jmp    2c05cd <strchr+0x16>
        ++s;
  2c05c8:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
    while (*s && *s != (char) c) {
  2c05cd:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  2c05d1:	0f b6 00             	movzbl (%rax),%eax
  2c05d4:	84 c0                	test   %al,%al
  2c05d6:	74 0e                	je     2c05e6 <strchr+0x2f>
  2c05d8:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  2c05dc:	0f b6 00             	movzbl (%rax),%eax
  2c05df:	8b 55 f4             	mov    -0xc(%rbp),%edx
  2c05e2:	38 d0                	cmp    %dl,%al
  2c05e4:	75 e2                	jne    2c05c8 <strchr+0x11>
    }
    if (*s == (char) c) {
  2c05e6:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  2c05ea:	0f b6 00             	movzbl (%rax),%eax
  2c05ed:	8b 55 f4             	mov    -0xc(%rbp),%edx
  2c05f0:	38 d0                	cmp    %dl,%al
  2c05f2:	75 06                	jne    2c05fa <strchr+0x43>
        return (char*) s;
  2c05f4:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  2c05f8:	eb 05                	jmp    2c05ff <strchr+0x48>
    } else {
        return NULL;
  2c05fa:	b8 00 00 00 00       	mov    $0x0,%eax
    }
}
  2c05ff:	c9                   	leave
  2c0600:	c3                   	ret

00000000002c0601 <rand>:
// rand, srand

static int rand_seed_set;
static unsigned rand_seed;

int rand(void) {
  2c0601:	55                   	push   %rbp
  2c0602:	48 89 e5             	mov    %rsp,%rbp
    if (!rand_seed_set) {
  2c0605:	8b 05 f5 19 00 00    	mov    0x19f5(%rip),%eax        # 2c2000 <rand_seed_set>
  2c060b:	85 c0                	test   %eax,%eax
  2c060d:	75 0a                	jne    2c0619 <rand+0x18>
        srand(819234718U);
  2c060f:	bf 9e 87 d4 30       	mov    $0x30d4879e,%edi
  2c0614:	e8 24 00 00 00       	call   2c063d <srand>
    }
    rand_seed = rand_seed * 1664525U + 1013904223U;
  2c0619:	8b 05 e5 19 00 00    	mov    0x19e5(%rip),%eax        # 2c2004 <rand_seed>
  2c061f:	69 c0 0d 66 19 00    	imul   $0x19660d,%eax,%eax
  2c0625:	05 5f f3 6e 3c       	add    $0x3c6ef35f,%eax
  2c062a:	89 05 d4 19 00 00    	mov    %eax,0x19d4(%rip)        # 2c2004 <rand_seed>
    return rand_seed & RAND_MAX;
  2c0630:	8b 05 ce 19 00 00    	mov    0x19ce(%rip),%eax        # 2c2004 <rand_seed>
  2c0636:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
}
  2c063b:	5d                   	pop    %rbp
  2c063c:	c3                   	ret

00000000002c063d <srand>:

void srand(unsigned seed) {
  2c063d:	55                   	push   %rbp
  2c063e:	48 89 e5             	mov    %rsp,%rbp
  2c0641:	48 83 ec 08          	sub    $0x8,%rsp
  2c0645:	89 7d fc             	mov    %edi,-0x4(%rbp)
    rand_seed = seed;
  2c0648:	8b 45 fc             	mov    -0x4(%rbp),%eax
  2c064b:	89 05 b3 19 00 00    	mov    %eax,0x19b3(%rip)        # 2c2004 <rand_seed>
    rand_seed_set = 1;
  2c0651:	c7 05 a5 19 00 00 01 	movl   $0x1,0x19a5(%rip)        # 2c2000 <rand_seed_set>
  2c0658:	00 00 00 
}
  2c065b:	90                   	nop
  2c065c:	c9                   	leave
  2c065d:	c3                   	ret

00000000002c065e <fill_numbuf>:
//    Print a message onto the console, starting at the given cursor position.

// snprintf, vsnprintf
//    Format a string into a buffer.

static char* fill_numbuf(char* numbuf_end, unsigned long val, int base) {
  2c065e:	55                   	push   %rbp
  2c065f:	48 89 e5             	mov    %rsp,%rbp
  2c0662:	48 83 ec 28          	sub    $0x28,%rsp
  2c0666:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  2c066a:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  2c066e:	89 55 dc             	mov    %edx,-0x24(%rbp)
    static const char upper_digits[] = "0123456789ABCDEF";
    static const char lower_digits[] = "0123456789abcdef";

    const char* digits = upper_digits;
  2c0671:	48 c7 45 f8 40 15 2c 	movq   $0x2c1540,-0x8(%rbp)
  2c0678:	00 
    if (base < 0) {
  2c0679:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
  2c067d:	79 0b                	jns    2c068a <fill_numbuf+0x2c>
        digits = lower_digits;
  2c067f:	48 c7 45 f8 60 15 2c 	movq   $0x2c1560,-0x8(%rbp)
  2c0686:	00 
        base = -base;
  2c0687:	f7 5d dc             	negl   -0x24(%rbp)
    }

    *--numbuf_end = '\0';
  2c068a:	48 83 6d e8 01       	subq   $0x1,-0x18(%rbp)
  2c068f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  2c0693:	c6 00 00             	movb   $0x0,(%rax)
    do {
        *--numbuf_end = digits[val % base];
  2c0696:	8b 45 dc             	mov    -0x24(%rbp),%eax
  2c0699:	48 63 c8             	movslq %eax,%rcx
  2c069c:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  2c06a0:	ba 00 00 00 00       	mov    $0x0,%edx
  2c06a5:	48 f7 f1             	div    %rcx
  2c06a8:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  2c06ac:	48 01 d0             	add    %rdx,%rax
  2c06af:	48 83 6d e8 01       	subq   $0x1,-0x18(%rbp)
  2c06b4:	0f b6 10             	movzbl (%rax),%edx
  2c06b7:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  2c06bb:	88 10                	mov    %dl,(%rax)
        val /= base;
  2c06bd:	8b 45 dc             	mov    -0x24(%rbp),%eax
  2c06c0:	48 63 f0             	movslq %eax,%rsi
  2c06c3:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  2c06c7:	ba 00 00 00 00       	mov    $0x0,%edx
  2c06cc:	48 f7 f6             	div    %rsi
  2c06cf:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
    } while (val != 0);
  2c06d3:	48 83 7d e0 00       	cmpq   $0x0,-0x20(%rbp)
  2c06d8:	75 bc                	jne    2c0696 <fill_numbuf+0x38>
    return numbuf_end;
  2c06da:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
  2c06de:	c9                   	leave
  2c06df:	c3                   	ret

00000000002c06e0 <printer_vprintf>:
#define FLAG_NUMERIC            (1<<5)
#define FLAG_SIGNED             (1<<6)
#define FLAG_NEGATIVE           (1<<7)
#define FLAG_ALT2               (1<<8)

void printer_vprintf(printer* p, int color, const char* format, va_list val) {
  2c06e0:	55                   	push   %rbp
  2c06e1:	48 89 e5             	mov    %rsp,%rbp
  2c06e4:	53                   	push   %rbx
  2c06e5:	48 81 ec 98 00 00 00 	sub    $0x98,%rsp
  2c06ec:	48 89 bd 78 ff ff ff 	mov    %rdi,-0x88(%rbp)
  2c06f3:	89 b5 74 ff ff ff    	mov    %esi,-0x8c(%rbp)
  2c06f9:	48 89 95 68 ff ff ff 	mov    %rdx,-0x98(%rbp)
  2c0700:	48 89 8d 60 ff ff ff 	mov    %rcx,-0xa0(%rbp)
#define NUMBUFSIZ 24
    char numbuf[NUMBUFSIZ];

    for (; *format; ++format) {
  2c0707:	e9 32 0a 00 00       	jmp    2c113e <printer_vprintf+0xa5e>
        if (*format != '%') {
  2c070c:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  2c0713:	0f b6 00             	movzbl (%rax),%eax
  2c0716:	3c 25                	cmp    $0x25,%al
  2c0718:	74 31                	je     2c074b <printer_vprintf+0x6b>
            p->putc(p, *format, color);
  2c071a:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  2c0721:	4c 8b 00             	mov    (%rax),%r8
  2c0724:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  2c072b:	0f b6 00             	movzbl (%rax),%eax
  2c072e:	8b 95 74 ff ff ff    	mov    -0x8c(%rbp),%edx
  2c0734:	0f b6 c8             	movzbl %al,%ecx
  2c0737:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  2c073e:	89 ce                	mov    %ecx,%esi
  2c0740:	48 89 c7             	mov    %rax,%rdi
  2c0743:	41 ff d0             	call   *%r8
            continue;
  2c0746:	e9 eb 09 00 00       	jmp    2c1136 <printer_vprintf+0xa56>
        }

        // process flags
        int flags = 0;
  2c074b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%rbp)
        for (++format; *format; ++format) {
  2c0752:	48 83 85 68 ff ff ff 	addq   $0x1,-0x98(%rbp)
  2c0759:	01 
  2c075a:	eb 44                	jmp    2c07a0 <printer_vprintf+0xc0>
            const char* flagc = strchr(flag_chars, *format);
  2c075c:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  2c0763:	0f b6 00             	movzbl (%rax),%eax
  2c0766:	0f be c0             	movsbl %al,%eax
  2c0769:	89 c6                	mov    %eax,%esi
  2c076b:	bf 20 15 2c 00       	mov    $0x2c1520,%edi
  2c0770:	e8 42 fe ff ff       	call   2c05b7 <strchr>
  2c0775:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
            if (flagc) {
  2c0779:	48 83 7d a8 00       	cmpq   $0x0,-0x58(%rbp)
  2c077e:	74 30                	je     2c07b0 <printer_vprintf+0xd0>
                flags |= 1 << (flagc - flag_chars);
  2c0780:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  2c0784:	48 2d 20 15 2c 00    	sub    $0x2c1520,%rax
  2c078a:	ba 01 00 00 00       	mov    $0x1,%edx
  2c078f:	89 c1                	mov    %eax,%ecx
  2c0791:	d3 e2                	shl    %cl,%edx
  2c0793:	89 d0                	mov    %edx,%eax
  2c0795:	09 45 ec             	or     %eax,-0x14(%rbp)
        for (++format; *format; ++format) {
  2c0798:	48 83 85 68 ff ff ff 	addq   $0x1,-0x98(%rbp)
  2c079f:	01 
  2c07a0:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  2c07a7:	0f b6 00             	movzbl (%rax),%eax
  2c07aa:	84 c0                	test   %al,%al
  2c07ac:	75 ae                	jne    2c075c <printer_vprintf+0x7c>
  2c07ae:	eb 01                	jmp    2c07b1 <printer_vprintf+0xd1>
            } else {
                break;
  2c07b0:	90                   	nop
            }
        }

        // process width
        int width = -1;
  2c07b1:	c7 45 e8 ff ff ff ff 	movl   $0xffffffff,-0x18(%rbp)
        if (*format >= '1' && *format <= '9') {
  2c07b8:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  2c07bf:	0f b6 00             	movzbl (%rax),%eax
  2c07c2:	3c 30                	cmp    $0x30,%al
  2c07c4:	7e 67                	jle    2c082d <printer_vprintf+0x14d>
  2c07c6:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  2c07cd:	0f b6 00             	movzbl (%rax),%eax
  2c07d0:	3c 39                	cmp    $0x39,%al
  2c07d2:	7f 59                	jg     2c082d <printer_vprintf+0x14d>
            for (width = 0; *format >= '0' && *format <= '9'; ) {
  2c07d4:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%rbp)
  2c07db:	eb 2e                	jmp    2c080b <printer_vprintf+0x12b>
                width = 10 * width + *format++ - '0';
  2c07dd:	8b 55 e8             	mov    -0x18(%rbp),%edx
  2c07e0:	89 d0                	mov    %edx,%eax
  2c07e2:	c1 e0 02             	shl    $0x2,%eax
  2c07e5:	01 d0                	add    %edx,%eax
  2c07e7:	01 c0                	add    %eax,%eax
  2c07e9:	89 c1                	mov    %eax,%ecx
  2c07eb:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  2c07f2:	48 8d 50 01          	lea    0x1(%rax),%rdx
  2c07f6:	48 89 95 68 ff ff ff 	mov    %rdx,-0x98(%rbp)
  2c07fd:	0f b6 00             	movzbl (%rax),%eax
  2c0800:	0f be c0             	movsbl %al,%eax
  2c0803:	01 c8                	add    %ecx,%eax
  2c0805:	83 e8 30             	sub    $0x30,%eax
  2c0808:	89 45 e8             	mov    %eax,-0x18(%rbp)
            for (width = 0; *format >= '0' && *format <= '9'; ) {
  2c080b:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  2c0812:	0f b6 00             	movzbl (%rax),%eax
  2c0815:	3c 2f                	cmp    $0x2f,%al
  2c0817:	0f 8e 85 00 00 00    	jle    2c08a2 <printer_vprintf+0x1c2>
  2c081d:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  2c0824:	0f b6 00             	movzbl (%rax),%eax
  2c0827:	3c 39                	cmp    $0x39,%al
  2c0829:	7e b2                	jle    2c07dd <printer_vprintf+0xfd>
        if (*format >= '1' && *format <= '9') {
  2c082b:	eb 75                	jmp    2c08a2 <printer_vprintf+0x1c2>
            }
        } else if (*format == '*') {
  2c082d:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  2c0834:	0f b6 00             	movzbl (%rax),%eax
  2c0837:	3c 2a                	cmp    $0x2a,%al
  2c0839:	75 68                	jne    2c08a3 <printer_vprintf+0x1c3>
            width = va_arg(val, int);
  2c083b:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  2c0842:	8b 00                	mov    (%rax),%eax
  2c0844:	83 f8 2f             	cmp    $0x2f,%eax
  2c0847:	77 30                	ja     2c0879 <printer_vprintf+0x199>
  2c0849:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  2c0850:	48 8b 50 10          	mov    0x10(%rax),%rdx
  2c0854:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  2c085b:	8b 00                	mov    (%rax),%eax
  2c085d:	89 c0                	mov    %eax,%eax
  2c085f:	48 01 d0             	add    %rdx,%rax
  2c0862:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  2c0869:	8b 12                	mov    (%rdx),%edx
  2c086b:	8d 4a 08             	lea    0x8(%rdx),%ecx
  2c086e:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  2c0875:	89 0a                	mov    %ecx,(%rdx)
  2c0877:	eb 1a                	jmp    2c0893 <printer_vprintf+0x1b3>
  2c0879:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  2c0880:	48 8b 40 08          	mov    0x8(%rax),%rax
  2c0884:	48 8d 48 08          	lea    0x8(%rax),%rcx
  2c0888:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  2c088f:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  2c0893:	8b 00                	mov    (%rax),%eax
  2c0895:	89 45 e8             	mov    %eax,-0x18(%rbp)
            ++format;
  2c0898:	48 83 85 68 ff ff ff 	addq   $0x1,-0x98(%rbp)
  2c089f:	01 
  2c08a0:	eb 01                	jmp    2c08a3 <printer_vprintf+0x1c3>
        if (*format >= '1' && *format <= '9') {
  2c08a2:	90                   	nop
        }

        // process precision
        int precision = -1;
  2c08a3:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%rbp)
        if (*format == '.') {
  2c08aa:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  2c08b1:	0f b6 00             	movzbl (%rax),%eax
  2c08b4:	3c 2e                	cmp    $0x2e,%al
  2c08b6:	0f 85 00 01 00 00    	jne    2c09bc <printer_vprintf+0x2dc>
            ++format;
  2c08bc:	48 83 85 68 ff ff ff 	addq   $0x1,-0x98(%rbp)
  2c08c3:	01 
            if (*format >= '0' && *format <= '9') {
  2c08c4:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  2c08cb:	0f b6 00             	movzbl (%rax),%eax
  2c08ce:	3c 2f                	cmp    $0x2f,%al
  2c08d0:	7e 67                	jle    2c0939 <printer_vprintf+0x259>
  2c08d2:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  2c08d9:	0f b6 00             	movzbl (%rax),%eax
  2c08dc:	3c 39                	cmp    $0x39,%al
  2c08de:	7f 59                	jg     2c0939 <printer_vprintf+0x259>
                for (precision = 0; *format >= '0' && *format <= '9'; ) {
  2c08e0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%rbp)
  2c08e7:	eb 2e                	jmp    2c0917 <printer_vprintf+0x237>
                    precision = 10 * precision + *format++ - '0';
  2c08e9:	8b 55 e4             	mov    -0x1c(%rbp),%edx
  2c08ec:	89 d0                	mov    %edx,%eax
  2c08ee:	c1 e0 02             	shl    $0x2,%eax
  2c08f1:	01 d0                	add    %edx,%eax
  2c08f3:	01 c0                	add    %eax,%eax
  2c08f5:	89 c1                	mov    %eax,%ecx
  2c08f7:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  2c08fe:	48 8d 50 01          	lea    0x1(%rax),%rdx
  2c0902:	48 89 95 68 ff ff ff 	mov    %rdx,-0x98(%rbp)
  2c0909:	0f b6 00             	movzbl (%rax),%eax
  2c090c:	0f be c0             	movsbl %al,%eax
  2c090f:	01 c8                	add    %ecx,%eax
  2c0911:	83 e8 30             	sub    $0x30,%eax
  2c0914:	89 45 e4             	mov    %eax,-0x1c(%rbp)
                for (precision = 0; *format >= '0' && *format <= '9'; ) {
  2c0917:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  2c091e:	0f b6 00             	movzbl (%rax),%eax
  2c0921:	3c 2f                	cmp    $0x2f,%al
  2c0923:	0f 8e 85 00 00 00    	jle    2c09ae <printer_vprintf+0x2ce>
  2c0929:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  2c0930:	0f b6 00             	movzbl (%rax),%eax
  2c0933:	3c 39                	cmp    $0x39,%al
  2c0935:	7e b2                	jle    2c08e9 <printer_vprintf+0x209>
            if (*format >= '0' && *format <= '9') {
  2c0937:	eb 75                	jmp    2c09ae <printer_vprintf+0x2ce>
                }
            } else if (*format == '*') {
  2c0939:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  2c0940:	0f b6 00             	movzbl (%rax),%eax
  2c0943:	3c 2a                	cmp    $0x2a,%al
  2c0945:	75 68                	jne    2c09af <printer_vprintf+0x2cf>
                precision = va_arg(val, int);
  2c0947:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  2c094e:	8b 00                	mov    (%rax),%eax
  2c0950:	83 f8 2f             	cmp    $0x2f,%eax
  2c0953:	77 30                	ja     2c0985 <printer_vprintf+0x2a5>
  2c0955:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  2c095c:	48 8b 50 10          	mov    0x10(%rax),%rdx
  2c0960:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  2c0967:	8b 00                	mov    (%rax),%eax
  2c0969:	89 c0                	mov    %eax,%eax
  2c096b:	48 01 d0             	add    %rdx,%rax
  2c096e:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  2c0975:	8b 12                	mov    (%rdx),%edx
  2c0977:	8d 4a 08             	lea    0x8(%rdx),%ecx
  2c097a:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  2c0981:	89 0a                	mov    %ecx,(%rdx)
  2c0983:	eb 1a                	jmp    2c099f <printer_vprintf+0x2bf>
  2c0985:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  2c098c:	48 8b 40 08          	mov    0x8(%rax),%rax
  2c0990:	48 8d 48 08          	lea    0x8(%rax),%rcx
  2c0994:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  2c099b:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  2c099f:	8b 00                	mov    (%rax),%eax
  2c09a1:	89 45 e4             	mov    %eax,-0x1c(%rbp)
                ++format;
  2c09a4:	48 83 85 68 ff ff ff 	addq   $0x1,-0x98(%rbp)
  2c09ab:	01 
  2c09ac:	eb 01                	jmp    2c09af <printer_vprintf+0x2cf>
            if (*format >= '0' && *format <= '9') {
  2c09ae:	90                   	nop
            }
            if (precision < 0) {
  2c09af:	83 7d e4 00          	cmpl   $0x0,-0x1c(%rbp)
  2c09b3:	79 07                	jns    2c09bc <printer_vprintf+0x2dc>
                precision = 0;
  2c09b5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%rbp)
            }
        }

        // process main conversion character
        int base = 10;
  2c09bc:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%rbp)
        unsigned long num = 0;
  2c09c3:	48 c7 45 d8 00 00 00 	movq   $0x0,-0x28(%rbp)
  2c09ca:	00 
        int length = 0;
  2c09cb:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%rbp)
        char* data = "";
  2c09d2:	48 c7 45 c8 26 15 2c 	movq   $0x2c1526,-0x38(%rbp)
  2c09d9:	00 
    again:
        switch (*format) {
  2c09da:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  2c09e1:	0f b6 00             	movzbl (%rax),%eax
  2c09e4:	0f be c0             	movsbl %al,%eax
  2c09e7:	83 f8 7a             	cmp    $0x7a,%eax
  2c09ea:	0f 84 a4 00 00 00    	je     2c0a94 <printer_vprintf+0x3b4>
  2c09f0:	83 f8 7a             	cmp    $0x7a,%eax
  2c09f3:	0f 8f 3d 04 00 00    	jg     2c0e36 <printer_vprintf+0x756>
  2c09f9:	83 f8 78             	cmp    $0x78,%eax
  2c09fc:	0f 84 76 02 00 00    	je     2c0c78 <printer_vprintf+0x598>
  2c0a02:	83 f8 78             	cmp    $0x78,%eax
  2c0a05:	0f 8f 2b 04 00 00    	jg     2c0e36 <printer_vprintf+0x756>
  2c0a0b:	83 f8 75             	cmp    $0x75,%eax
  2c0a0e:	0f 84 94 01 00 00    	je     2c0ba8 <printer_vprintf+0x4c8>
  2c0a14:	83 f8 75             	cmp    $0x75,%eax
  2c0a17:	0f 8f 19 04 00 00    	jg     2c0e36 <printer_vprintf+0x756>
  2c0a1d:	83 f8 73             	cmp    $0x73,%eax
  2c0a20:	0f 84 dc 02 00 00    	je     2c0d02 <printer_vprintf+0x622>
  2c0a26:	83 f8 73             	cmp    $0x73,%eax
  2c0a29:	0f 8f 07 04 00 00    	jg     2c0e36 <printer_vprintf+0x756>
  2c0a2f:	83 f8 70             	cmp    $0x70,%eax
  2c0a32:	0f 84 58 02 00 00    	je     2c0c90 <printer_vprintf+0x5b0>
  2c0a38:	83 f8 70             	cmp    $0x70,%eax
  2c0a3b:	0f 8f f5 03 00 00    	jg     2c0e36 <printer_vprintf+0x756>
  2c0a41:	83 f8 6c             	cmp    $0x6c,%eax
  2c0a44:	74 4e                	je     2c0a94 <printer_vprintf+0x3b4>
  2c0a46:	83 f8 6c             	cmp    $0x6c,%eax
  2c0a49:	0f 8f e7 03 00 00    	jg     2c0e36 <printer_vprintf+0x756>
  2c0a4f:	83 f8 69             	cmp    $0x69,%eax
  2c0a52:	74 54                	je     2c0aa8 <printer_vprintf+0x3c8>
  2c0a54:	83 f8 69             	cmp    $0x69,%eax
  2c0a57:	0f 8f d9 03 00 00    	jg     2c0e36 <printer_vprintf+0x756>
  2c0a5d:	83 f8 64             	cmp    $0x64,%eax
  2c0a60:	74 46                	je     2c0aa8 <printer_vprintf+0x3c8>
  2c0a62:	83 f8 64             	cmp    $0x64,%eax
  2c0a65:	0f 8f cb 03 00 00    	jg     2c0e36 <printer_vprintf+0x756>
  2c0a6b:	83 f8 63             	cmp    $0x63,%eax
  2c0a6e:	0f 84 57 03 00 00    	je     2c0dcb <printer_vprintf+0x6eb>
  2c0a74:	83 f8 63             	cmp    $0x63,%eax
  2c0a77:	0f 8f b9 03 00 00    	jg     2c0e36 <printer_vprintf+0x756>
  2c0a7d:	83 f8 43             	cmp    $0x43,%eax
  2c0a80:	0f 84 e0 02 00 00    	je     2c0d66 <printer_vprintf+0x686>
  2c0a86:	83 f8 58             	cmp    $0x58,%eax
  2c0a89:	0f 84 f5 01 00 00    	je     2c0c84 <printer_vprintf+0x5a4>
  2c0a8f:	e9 a2 03 00 00       	jmp    2c0e36 <printer_vprintf+0x756>
        case 'l':
        case 'z':
            length = 1;
  2c0a94:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%rbp)
            ++format;
  2c0a9b:	48 83 85 68 ff ff ff 	addq   $0x1,-0x98(%rbp)
  2c0aa2:	01 
            goto again;
  2c0aa3:	e9 32 ff ff ff       	jmp    2c09da <printer_vprintf+0x2fa>
        case 'd':
        case 'i': {
            long x = length ? va_arg(val, long) : va_arg(val, int);
  2c0aa8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%rbp)
  2c0aac:	74 61                	je     2c0b0f <printer_vprintf+0x42f>
  2c0aae:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  2c0ab5:	8b 00                	mov    (%rax),%eax
  2c0ab7:	83 f8 2f             	cmp    $0x2f,%eax
  2c0aba:	77 30                	ja     2c0aec <printer_vprintf+0x40c>
  2c0abc:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  2c0ac3:	48 8b 50 10          	mov    0x10(%rax),%rdx
  2c0ac7:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  2c0ace:	8b 00                	mov    (%rax),%eax
  2c0ad0:	89 c0                	mov    %eax,%eax
  2c0ad2:	48 01 d0             	add    %rdx,%rax
  2c0ad5:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  2c0adc:	8b 12                	mov    (%rdx),%edx
  2c0ade:	8d 4a 08             	lea    0x8(%rdx),%ecx
  2c0ae1:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  2c0ae8:	89 0a                	mov    %ecx,(%rdx)
  2c0aea:	eb 1a                	jmp    2c0b06 <printer_vprintf+0x426>
  2c0aec:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  2c0af3:	48 8b 40 08          	mov    0x8(%rax),%rax
  2c0af7:	48 8d 48 08          	lea    0x8(%rax),%rcx
  2c0afb:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  2c0b02:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  2c0b06:	48 8b 00             	mov    (%rax),%rax
  2c0b09:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  2c0b0d:	eb 60                	jmp    2c0b6f <printer_vprintf+0x48f>
  2c0b0f:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  2c0b16:	8b 00                	mov    (%rax),%eax
  2c0b18:	83 f8 2f             	cmp    $0x2f,%eax
  2c0b1b:	77 30                	ja     2c0b4d <printer_vprintf+0x46d>
  2c0b1d:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  2c0b24:	48 8b 50 10          	mov    0x10(%rax),%rdx
  2c0b28:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  2c0b2f:	8b 00                	mov    (%rax),%eax
  2c0b31:	89 c0                	mov    %eax,%eax
  2c0b33:	48 01 d0             	add    %rdx,%rax
  2c0b36:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  2c0b3d:	8b 12                	mov    (%rdx),%edx
  2c0b3f:	8d 4a 08             	lea    0x8(%rdx),%ecx
  2c0b42:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  2c0b49:	89 0a                	mov    %ecx,(%rdx)
  2c0b4b:	eb 1a                	jmp    2c0b67 <printer_vprintf+0x487>
  2c0b4d:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  2c0b54:	48 8b 40 08          	mov    0x8(%rax),%rax
  2c0b58:	48 8d 48 08          	lea    0x8(%rax),%rcx
  2c0b5c:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  2c0b63:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  2c0b67:	8b 00                	mov    (%rax),%eax
  2c0b69:	48 98                	cltq
  2c0b6b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
            int negative = x < 0 ? FLAG_NEGATIVE : 0;
  2c0b6f:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  2c0b73:	48 c1 f8 38          	sar    $0x38,%rax
  2c0b77:	25 80 00 00 00       	and    $0x80,%eax
  2c0b7c:	89 45 a4             	mov    %eax,-0x5c(%rbp)
            num = negative ? -x : x;
  2c0b7f:	83 7d a4 00          	cmpl   $0x0,-0x5c(%rbp)
  2c0b83:	74 0d                	je     2c0b92 <printer_vprintf+0x4b2>
  2c0b85:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  2c0b89:	48 f7 d8             	neg    %rax
  2c0b8c:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
  2c0b90:	eb 08                	jmp    2c0b9a <printer_vprintf+0x4ba>
  2c0b92:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  2c0b96:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
            flags |= FLAG_NUMERIC | FLAG_SIGNED | negative;
  2c0b9a:	8b 45 a4             	mov    -0x5c(%rbp),%eax
  2c0b9d:	83 c8 60             	or     $0x60,%eax
  2c0ba0:	09 45 ec             	or     %eax,-0x14(%rbp)
            break;
  2c0ba3:	e9 d3 02 00 00       	jmp    2c0e7b <printer_vprintf+0x79b>
        }
        case 'u':
        format_unsigned:
            num = length ? va_arg(val, unsigned long) : va_arg(val, unsigned);
  2c0ba8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%rbp)
  2c0bac:	74 61                	je     2c0c0f <printer_vprintf+0x52f>
  2c0bae:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  2c0bb5:	8b 00                	mov    (%rax),%eax
  2c0bb7:	83 f8 2f             	cmp    $0x2f,%eax
  2c0bba:	77 30                	ja     2c0bec <printer_vprintf+0x50c>
  2c0bbc:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  2c0bc3:	48 8b 50 10          	mov    0x10(%rax),%rdx
  2c0bc7:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  2c0bce:	8b 00                	mov    (%rax),%eax
  2c0bd0:	89 c0                	mov    %eax,%eax
  2c0bd2:	48 01 d0             	add    %rdx,%rax
  2c0bd5:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  2c0bdc:	8b 12                	mov    (%rdx),%edx
  2c0bde:	8d 4a 08             	lea    0x8(%rdx),%ecx
  2c0be1:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  2c0be8:	89 0a                	mov    %ecx,(%rdx)
  2c0bea:	eb 1a                	jmp    2c0c06 <printer_vprintf+0x526>
  2c0bec:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  2c0bf3:	48 8b 40 08          	mov    0x8(%rax),%rax
  2c0bf7:	48 8d 48 08          	lea    0x8(%rax),%rcx
  2c0bfb:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  2c0c02:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  2c0c06:	48 8b 00             	mov    (%rax),%rax
  2c0c09:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
  2c0c0d:	eb 60                	jmp    2c0c6f <printer_vprintf+0x58f>
  2c0c0f:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  2c0c16:	8b 00                	mov    (%rax),%eax
  2c0c18:	83 f8 2f             	cmp    $0x2f,%eax
  2c0c1b:	77 30                	ja     2c0c4d <printer_vprintf+0x56d>
  2c0c1d:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  2c0c24:	48 8b 50 10          	mov    0x10(%rax),%rdx
  2c0c28:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  2c0c2f:	8b 00                	mov    (%rax),%eax
  2c0c31:	89 c0                	mov    %eax,%eax
  2c0c33:	48 01 d0             	add    %rdx,%rax
  2c0c36:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  2c0c3d:	8b 12                	mov    (%rdx),%edx
  2c0c3f:	8d 4a 08             	lea    0x8(%rdx),%ecx
  2c0c42:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  2c0c49:	89 0a                	mov    %ecx,(%rdx)
  2c0c4b:	eb 1a                	jmp    2c0c67 <printer_vprintf+0x587>
  2c0c4d:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  2c0c54:	48 8b 40 08          	mov    0x8(%rax),%rax
  2c0c58:	48 8d 48 08          	lea    0x8(%rax),%rcx
  2c0c5c:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  2c0c63:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  2c0c67:	8b 00                	mov    (%rax),%eax
  2c0c69:	89 c0                	mov    %eax,%eax
  2c0c6b:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
            flags |= FLAG_NUMERIC;
  2c0c6f:	83 4d ec 20          	orl    $0x20,-0x14(%rbp)
            break;
  2c0c73:	e9 03 02 00 00       	jmp    2c0e7b <printer_vprintf+0x79b>
        case 'x':
            base = -16;
  2c0c78:	c7 45 e0 f0 ff ff ff 	movl   $0xfffffff0,-0x20(%rbp)
            goto format_unsigned;
  2c0c7f:	e9 24 ff ff ff       	jmp    2c0ba8 <printer_vprintf+0x4c8>
        case 'X':
            base = 16;
  2c0c84:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%rbp)
            goto format_unsigned;
  2c0c8b:	e9 18 ff ff ff       	jmp    2c0ba8 <printer_vprintf+0x4c8>
        case 'p':
            num = (uintptr_t) va_arg(val, void*);
  2c0c90:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  2c0c97:	8b 00                	mov    (%rax),%eax
  2c0c99:	83 f8 2f             	cmp    $0x2f,%eax
  2c0c9c:	77 30                	ja     2c0cce <printer_vprintf+0x5ee>
  2c0c9e:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  2c0ca5:	48 8b 50 10          	mov    0x10(%rax),%rdx
  2c0ca9:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  2c0cb0:	8b 00                	mov    (%rax),%eax
  2c0cb2:	89 c0                	mov    %eax,%eax
  2c0cb4:	48 01 d0             	add    %rdx,%rax
  2c0cb7:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  2c0cbe:	8b 12                	mov    (%rdx),%edx
  2c0cc0:	8d 4a 08             	lea    0x8(%rdx),%ecx
  2c0cc3:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  2c0cca:	89 0a                	mov    %ecx,(%rdx)
  2c0ccc:	eb 1a                	jmp    2c0ce8 <printer_vprintf+0x608>
  2c0cce:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  2c0cd5:	48 8b 40 08          	mov    0x8(%rax),%rax
  2c0cd9:	48 8d 48 08          	lea    0x8(%rax),%rcx
  2c0cdd:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  2c0ce4:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  2c0ce8:	48 8b 00             	mov    (%rax),%rax
  2c0ceb:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
            base = -16;
  2c0cef:	c7 45 e0 f0 ff ff ff 	movl   $0xfffffff0,-0x20(%rbp)
            flags |= FLAG_ALT | FLAG_ALT2 | FLAG_NUMERIC;
  2c0cf6:	81 4d ec 21 01 00 00 	orl    $0x121,-0x14(%rbp)
            break;
  2c0cfd:	e9 79 01 00 00       	jmp    2c0e7b <printer_vprintf+0x79b>
        case 's':
            data = va_arg(val, char*);
  2c0d02:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  2c0d09:	8b 00                	mov    (%rax),%eax
  2c0d0b:	83 f8 2f             	cmp    $0x2f,%eax
  2c0d0e:	77 30                	ja     2c0d40 <printer_vprintf+0x660>
  2c0d10:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  2c0d17:	48 8b 50 10          	mov    0x10(%rax),%rdx
  2c0d1b:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  2c0d22:	8b 00                	mov    (%rax),%eax
  2c0d24:	89 c0                	mov    %eax,%eax
  2c0d26:	48 01 d0             	add    %rdx,%rax
  2c0d29:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  2c0d30:	8b 12                	mov    (%rdx),%edx
  2c0d32:	8d 4a 08             	lea    0x8(%rdx),%ecx
  2c0d35:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  2c0d3c:	89 0a                	mov    %ecx,(%rdx)
  2c0d3e:	eb 1a                	jmp    2c0d5a <printer_vprintf+0x67a>
  2c0d40:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  2c0d47:	48 8b 40 08          	mov    0x8(%rax),%rax
  2c0d4b:	48 8d 48 08          	lea    0x8(%rax),%rcx
  2c0d4f:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  2c0d56:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  2c0d5a:	48 8b 00             	mov    (%rax),%rax
  2c0d5d:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
            break;
  2c0d61:	e9 15 01 00 00       	jmp    2c0e7b <printer_vprintf+0x79b>
        case 'C':
            color = va_arg(val, int);
  2c0d66:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  2c0d6d:	8b 00                	mov    (%rax),%eax
  2c0d6f:	83 f8 2f             	cmp    $0x2f,%eax
  2c0d72:	77 30                	ja     2c0da4 <printer_vprintf+0x6c4>
  2c0d74:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  2c0d7b:	48 8b 50 10          	mov    0x10(%rax),%rdx
  2c0d7f:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  2c0d86:	8b 00                	mov    (%rax),%eax
  2c0d88:	89 c0                	mov    %eax,%eax
  2c0d8a:	48 01 d0             	add    %rdx,%rax
  2c0d8d:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  2c0d94:	8b 12                	mov    (%rdx),%edx
  2c0d96:	8d 4a 08             	lea    0x8(%rdx),%ecx
  2c0d99:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  2c0da0:	89 0a                	mov    %ecx,(%rdx)
  2c0da2:	eb 1a                	jmp    2c0dbe <printer_vprintf+0x6de>
  2c0da4:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  2c0dab:	48 8b 40 08          	mov    0x8(%rax),%rax
  2c0daf:	48 8d 48 08          	lea    0x8(%rax),%rcx
  2c0db3:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  2c0dba:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  2c0dbe:	8b 00                	mov    (%rax),%eax
  2c0dc0:	89 85 74 ff ff ff    	mov    %eax,-0x8c(%rbp)
            goto done;
  2c0dc6:	e9 6b 03 00 00       	jmp    2c1136 <printer_vprintf+0xa56>
        case 'c':
            data = numbuf;
  2c0dcb:	48 8d 45 8c          	lea    -0x74(%rbp),%rax
  2c0dcf:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
            numbuf[0] = va_arg(val, int);
  2c0dd3:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  2c0dda:	8b 00                	mov    (%rax),%eax
  2c0ddc:	83 f8 2f             	cmp    $0x2f,%eax
  2c0ddf:	77 30                	ja     2c0e11 <printer_vprintf+0x731>
  2c0de1:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  2c0de8:	48 8b 50 10          	mov    0x10(%rax),%rdx
  2c0dec:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  2c0df3:	8b 00                	mov    (%rax),%eax
  2c0df5:	89 c0                	mov    %eax,%eax
  2c0df7:	48 01 d0             	add    %rdx,%rax
  2c0dfa:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  2c0e01:	8b 12                	mov    (%rdx),%edx
  2c0e03:	8d 4a 08             	lea    0x8(%rdx),%ecx
  2c0e06:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  2c0e0d:	89 0a                	mov    %ecx,(%rdx)
  2c0e0f:	eb 1a                	jmp    2c0e2b <printer_vprintf+0x74b>
  2c0e11:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  2c0e18:	48 8b 40 08          	mov    0x8(%rax),%rax
  2c0e1c:	48 8d 48 08          	lea    0x8(%rax),%rcx
  2c0e20:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  2c0e27:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  2c0e2b:	8b 00                	mov    (%rax),%eax
  2c0e2d:	88 45 8c             	mov    %al,-0x74(%rbp)
            numbuf[1] = '\0';
  2c0e30:	c6 45 8d 00          	movb   $0x0,-0x73(%rbp)
            break;
  2c0e34:	eb 45                	jmp    2c0e7b <printer_vprintf+0x79b>
        default:
            data = numbuf;
  2c0e36:	48 8d 45 8c          	lea    -0x74(%rbp),%rax
  2c0e3a:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
            numbuf[0] = (*format ? *format : '%');
  2c0e3e:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  2c0e45:	0f b6 00             	movzbl (%rax),%eax
  2c0e48:	84 c0                	test   %al,%al
  2c0e4a:	74 0c                	je     2c0e58 <printer_vprintf+0x778>
  2c0e4c:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  2c0e53:	0f b6 00             	movzbl (%rax),%eax
  2c0e56:	eb 05                	jmp    2c0e5d <printer_vprintf+0x77d>
  2c0e58:	b8 25 00 00 00       	mov    $0x25,%eax
  2c0e5d:	88 45 8c             	mov    %al,-0x74(%rbp)
            numbuf[1] = '\0';
  2c0e60:	c6 45 8d 00          	movb   $0x0,-0x73(%rbp)
            if (!*format) {
  2c0e64:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  2c0e6b:	0f b6 00             	movzbl (%rax),%eax
  2c0e6e:	84 c0                	test   %al,%al
  2c0e70:	75 08                	jne    2c0e7a <printer_vprintf+0x79a>
                format--;
  2c0e72:	48 83 ad 68 ff ff ff 	subq   $0x1,-0x98(%rbp)
  2c0e79:	01 
            }
            break;
  2c0e7a:	90                   	nop
        }

        if (flags & FLAG_NUMERIC) {
  2c0e7b:	8b 45 ec             	mov    -0x14(%rbp),%eax
  2c0e7e:	83 e0 20             	and    $0x20,%eax
  2c0e81:	85 c0                	test   %eax,%eax
  2c0e83:	74 1e                	je     2c0ea3 <printer_vprintf+0x7c3>
            data = fill_numbuf(numbuf + NUMBUFSIZ, num, base);
  2c0e85:	48 8d 45 8c          	lea    -0x74(%rbp),%rax
  2c0e89:	48 83 c0 18          	add    $0x18,%rax
  2c0e8d:	8b 55 e0             	mov    -0x20(%rbp),%edx
  2c0e90:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
  2c0e94:	48 89 ce             	mov    %rcx,%rsi
  2c0e97:	48 89 c7             	mov    %rax,%rdi
  2c0e9a:	e8 bf f7 ff ff       	call   2c065e <fill_numbuf>
  2c0e9f:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
        }

        const char* prefix = "";
  2c0ea3:	48 c7 45 b8 26 15 2c 	movq   $0x2c1526,-0x48(%rbp)
  2c0eaa:	00 
        if ((flags & FLAG_NUMERIC) && (flags & FLAG_SIGNED)) {
  2c0eab:	8b 45 ec             	mov    -0x14(%rbp),%eax
  2c0eae:	83 e0 20             	and    $0x20,%eax
  2c0eb1:	85 c0                	test   %eax,%eax
  2c0eb3:	74 48                	je     2c0efd <printer_vprintf+0x81d>
  2c0eb5:	8b 45 ec             	mov    -0x14(%rbp),%eax
  2c0eb8:	83 e0 40             	and    $0x40,%eax
  2c0ebb:	85 c0                	test   %eax,%eax
  2c0ebd:	74 3e                	je     2c0efd <printer_vprintf+0x81d>
            if (flags & FLAG_NEGATIVE) {
  2c0ebf:	8b 45 ec             	mov    -0x14(%rbp),%eax
  2c0ec2:	25 80 00 00 00       	and    $0x80,%eax
  2c0ec7:	85 c0                	test   %eax,%eax
  2c0ec9:	74 0a                	je     2c0ed5 <printer_vprintf+0x7f5>
                prefix = "-";
  2c0ecb:	48 c7 45 b8 27 15 2c 	movq   $0x2c1527,-0x48(%rbp)
  2c0ed2:	00 
            if (flags & FLAG_NEGATIVE) {
  2c0ed3:	eb 75                	jmp    2c0f4a <printer_vprintf+0x86a>
            } else if (flags & FLAG_PLUSPOSITIVE) {
  2c0ed5:	8b 45 ec             	mov    -0x14(%rbp),%eax
  2c0ed8:	83 e0 10             	and    $0x10,%eax
  2c0edb:	85 c0                	test   %eax,%eax
  2c0edd:	74 0a                	je     2c0ee9 <printer_vprintf+0x809>
                prefix = "+";
  2c0edf:	48 c7 45 b8 29 15 2c 	movq   $0x2c1529,-0x48(%rbp)
  2c0ee6:	00 
            if (flags & FLAG_NEGATIVE) {
  2c0ee7:	eb 61                	jmp    2c0f4a <printer_vprintf+0x86a>
            } else if (flags & FLAG_SPACEPOSITIVE) {
  2c0ee9:	8b 45 ec             	mov    -0x14(%rbp),%eax
  2c0eec:	83 e0 08             	and    $0x8,%eax
  2c0eef:	85 c0                	test   %eax,%eax
  2c0ef1:	74 57                	je     2c0f4a <printer_vprintf+0x86a>
                prefix = " ";
  2c0ef3:	48 c7 45 b8 2b 15 2c 	movq   $0x2c152b,-0x48(%rbp)
  2c0efa:	00 
            if (flags & FLAG_NEGATIVE) {
  2c0efb:	eb 4d                	jmp    2c0f4a <printer_vprintf+0x86a>
            }
        } else if ((flags & FLAG_NUMERIC) && (flags & FLAG_ALT)
  2c0efd:	8b 45 ec             	mov    -0x14(%rbp),%eax
  2c0f00:	83 e0 20             	and    $0x20,%eax
  2c0f03:	85 c0                	test   %eax,%eax
  2c0f05:	74 44                	je     2c0f4b <printer_vprintf+0x86b>
  2c0f07:	8b 45 ec             	mov    -0x14(%rbp),%eax
  2c0f0a:	83 e0 01             	and    $0x1,%eax
  2c0f0d:	85 c0                	test   %eax,%eax
  2c0f0f:	74 3a                	je     2c0f4b <printer_vprintf+0x86b>
                   && (base == 16 || base == -16)
  2c0f11:	83 7d e0 10          	cmpl   $0x10,-0x20(%rbp)
  2c0f15:	74 06                	je     2c0f1d <printer_vprintf+0x83d>
  2c0f17:	83 7d e0 f0          	cmpl   $0xfffffff0,-0x20(%rbp)
  2c0f1b:	75 2e                	jne    2c0f4b <printer_vprintf+0x86b>
                   && (num || (flags & FLAG_ALT2))) {
  2c0f1d:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  2c0f22:	75 0c                	jne    2c0f30 <printer_vprintf+0x850>
  2c0f24:	8b 45 ec             	mov    -0x14(%rbp),%eax
  2c0f27:	25 00 01 00 00       	and    $0x100,%eax
  2c0f2c:	85 c0                	test   %eax,%eax
  2c0f2e:	74 1b                	je     2c0f4b <printer_vprintf+0x86b>
            prefix = (base == -16 ? "0x" : "0X");
  2c0f30:	83 7d e0 f0          	cmpl   $0xfffffff0,-0x20(%rbp)
  2c0f34:	75 0a                	jne    2c0f40 <printer_vprintf+0x860>
  2c0f36:	48 c7 45 b8 2d 15 2c 	movq   $0x2c152d,-0x48(%rbp)
  2c0f3d:	00 
  2c0f3e:	eb 0b                	jmp    2c0f4b <printer_vprintf+0x86b>
  2c0f40:	48 c7 45 b8 30 15 2c 	movq   $0x2c1530,-0x48(%rbp)
  2c0f47:	00 
  2c0f48:	eb 01                	jmp    2c0f4b <printer_vprintf+0x86b>
            if (flags & FLAG_NEGATIVE) {
  2c0f4a:	90                   	nop
        }

        int len;
        if (precision >= 0 && !(flags & FLAG_NUMERIC)) {
  2c0f4b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%rbp)
  2c0f4f:	78 24                	js     2c0f75 <printer_vprintf+0x895>
  2c0f51:	8b 45 ec             	mov    -0x14(%rbp),%eax
  2c0f54:	83 e0 20             	and    $0x20,%eax
  2c0f57:	85 c0                	test   %eax,%eax
  2c0f59:	75 1a                	jne    2c0f75 <printer_vprintf+0x895>
            len = strnlen(data, precision);
  2c0f5b:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  2c0f5e:	48 63 d0             	movslq %eax,%rdx
  2c0f61:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  2c0f65:	48 89 d6             	mov    %rdx,%rsi
  2c0f68:	48 89 c7             	mov    %rax,%rdi
  2c0f6b:	e8 44 f5 ff ff       	call   2c04b4 <strnlen>
  2c0f70:	89 45 b4             	mov    %eax,-0x4c(%rbp)
  2c0f73:	eb 0f                	jmp    2c0f84 <printer_vprintf+0x8a4>
        } else {
            len = strlen(data);
  2c0f75:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  2c0f79:	48 89 c7             	mov    %rax,%rdi
  2c0f7c:	e8 02 f5 ff ff       	call   2c0483 <strlen>
  2c0f81:	89 45 b4             	mov    %eax,-0x4c(%rbp)
        }
        int zeros;
        if ((flags & FLAG_NUMERIC) && precision >= 0) {
  2c0f84:	8b 45 ec             	mov    -0x14(%rbp),%eax
  2c0f87:	83 e0 20             	and    $0x20,%eax
  2c0f8a:	85 c0                	test   %eax,%eax
  2c0f8c:	74 22                	je     2c0fb0 <printer_vprintf+0x8d0>
  2c0f8e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%rbp)
  2c0f92:	78 1c                	js     2c0fb0 <printer_vprintf+0x8d0>
            zeros = precision > len ? precision - len : 0;
  2c0f94:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  2c0f97:	3b 45 b4             	cmp    -0x4c(%rbp),%eax
  2c0f9a:	7e 0b                	jle    2c0fa7 <printer_vprintf+0x8c7>
  2c0f9c:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  2c0f9f:	2b 45 b4             	sub    -0x4c(%rbp),%eax
  2c0fa2:	89 45 b0             	mov    %eax,-0x50(%rbp)
  2c0fa5:	eb 65                	jmp    2c100c <printer_vprintf+0x92c>
  2c0fa7:	c7 45 b0 00 00 00 00 	movl   $0x0,-0x50(%rbp)
  2c0fae:	eb 5c                	jmp    2c100c <printer_vprintf+0x92c>
        } else if ((flags & FLAG_NUMERIC) && (flags & FLAG_ZERO)
  2c0fb0:	8b 45 ec             	mov    -0x14(%rbp),%eax
  2c0fb3:	83 e0 20             	and    $0x20,%eax
  2c0fb6:	85 c0                	test   %eax,%eax
  2c0fb8:	74 4b                	je     2c1005 <printer_vprintf+0x925>
  2c0fba:	8b 45 ec             	mov    -0x14(%rbp),%eax
  2c0fbd:	83 e0 02             	and    $0x2,%eax
  2c0fc0:	85 c0                	test   %eax,%eax
  2c0fc2:	74 41                	je     2c1005 <printer_vprintf+0x925>
                   && !(flags & FLAG_LEFTJUSTIFY)
  2c0fc4:	8b 45 ec             	mov    -0x14(%rbp),%eax
  2c0fc7:	83 e0 04             	and    $0x4,%eax
  2c0fca:	85 c0                	test   %eax,%eax
  2c0fcc:	75 37                	jne    2c1005 <printer_vprintf+0x925>
                   && len + (int) strlen(prefix) < width) {
  2c0fce:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  2c0fd2:	48 89 c7             	mov    %rax,%rdi
  2c0fd5:	e8 a9 f4 ff ff       	call   2c0483 <strlen>
  2c0fda:	89 c2                	mov    %eax,%edx
  2c0fdc:	8b 45 b4             	mov    -0x4c(%rbp),%eax
  2c0fdf:	01 d0                	add    %edx,%eax
  2c0fe1:	39 45 e8             	cmp    %eax,-0x18(%rbp)
  2c0fe4:	7e 1f                	jle    2c1005 <printer_vprintf+0x925>
            zeros = width - len - strlen(prefix);
  2c0fe6:	8b 45 e8             	mov    -0x18(%rbp),%eax
  2c0fe9:	2b 45 b4             	sub    -0x4c(%rbp),%eax
  2c0fec:	89 c3                	mov    %eax,%ebx
  2c0fee:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  2c0ff2:	48 89 c7             	mov    %rax,%rdi
  2c0ff5:	e8 89 f4 ff ff       	call   2c0483 <strlen>
  2c0ffa:	89 c2                	mov    %eax,%edx
  2c0ffc:	89 d8                	mov    %ebx,%eax
  2c0ffe:	29 d0                	sub    %edx,%eax
  2c1000:	89 45 b0             	mov    %eax,-0x50(%rbp)
  2c1003:	eb 07                	jmp    2c100c <printer_vprintf+0x92c>
        } else {
            zeros = 0;
  2c1005:	c7 45 b0 00 00 00 00 	movl   $0x0,-0x50(%rbp)
        }
        width -= len + zeros + strlen(prefix);
  2c100c:	8b 55 b4             	mov    -0x4c(%rbp),%edx
  2c100f:	8b 45 b0             	mov    -0x50(%rbp),%eax
  2c1012:	01 d0                	add    %edx,%eax
  2c1014:	48 63 d8             	movslq %eax,%rbx
  2c1017:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  2c101b:	48 89 c7             	mov    %rax,%rdi
  2c101e:	e8 60 f4 ff ff       	call   2c0483 <strlen>
  2c1023:	48 8d 14 03          	lea    (%rbx,%rax,1),%rdx
  2c1027:	8b 45 e8             	mov    -0x18(%rbp),%eax
  2c102a:	29 d0                	sub    %edx,%eax
  2c102c:	89 45 e8             	mov    %eax,-0x18(%rbp)
        for (; !(flags & FLAG_LEFTJUSTIFY) && width > 0; --width) {
  2c102f:	eb 25                	jmp    2c1056 <printer_vprintf+0x976>
            p->putc(p, ' ', color);
  2c1031:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  2c1038:	48 8b 08             	mov    (%rax),%rcx
  2c103b:	8b 95 74 ff ff ff    	mov    -0x8c(%rbp),%edx
  2c1041:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  2c1048:	be 20 00 00 00       	mov    $0x20,%esi
  2c104d:	48 89 c7             	mov    %rax,%rdi
  2c1050:	ff d1                	call   *%rcx
        for (; !(flags & FLAG_LEFTJUSTIFY) && width > 0; --width) {
  2c1052:	83 6d e8 01          	subl   $0x1,-0x18(%rbp)
  2c1056:	8b 45 ec             	mov    -0x14(%rbp),%eax
  2c1059:	83 e0 04             	and    $0x4,%eax
  2c105c:	85 c0                	test   %eax,%eax
  2c105e:	75 36                	jne    2c1096 <printer_vprintf+0x9b6>
  2c1060:	83 7d e8 00          	cmpl   $0x0,-0x18(%rbp)
  2c1064:	7f cb                	jg     2c1031 <printer_vprintf+0x951>
        }
        for (; *prefix; ++prefix) {
  2c1066:	eb 2e                	jmp    2c1096 <printer_vprintf+0x9b6>
            p->putc(p, *prefix, color);
  2c1068:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  2c106f:	4c 8b 00             	mov    (%rax),%r8
  2c1072:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  2c1076:	0f b6 00             	movzbl (%rax),%eax
  2c1079:	8b 95 74 ff ff ff    	mov    -0x8c(%rbp),%edx
  2c107f:	0f b6 c8             	movzbl %al,%ecx
  2c1082:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  2c1089:	89 ce                	mov    %ecx,%esi
  2c108b:	48 89 c7             	mov    %rax,%rdi
  2c108e:	41 ff d0             	call   *%r8
        for (; *prefix; ++prefix) {
  2c1091:	48 83 45 b8 01       	addq   $0x1,-0x48(%rbp)
  2c1096:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  2c109a:	0f b6 00             	movzbl (%rax),%eax
  2c109d:	84 c0                	test   %al,%al
  2c109f:	75 c7                	jne    2c1068 <printer_vprintf+0x988>
        }
        for (; zeros > 0; --zeros) {
  2c10a1:	eb 25                	jmp    2c10c8 <printer_vprintf+0x9e8>
            p->putc(p, '0', color);
  2c10a3:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  2c10aa:	48 8b 08             	mov    (%rax),%rcx
  2c10ad:	8b 95 74 ff ff ff    	mov    -0x8c(%rbp),%edx
  2c10b3:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  2c10ba:	be 30 00 00 00       	mov    $0x30,%esi
  2c10bf:	48 89 c7             	mov    %rax,%rdi
  2c10c2:	ff d1                	call   *%rcx
        for (; zeros > 0; --zeros) {
  2c10c4:	83 6d b0 01          	subl   $0x1,-0x50(%rbp)
  2c10c8:	83 7d b0 00          	cmpl   $0x0,-0x50(%rbp)
  2c10cc:	7f d5                	jg     2c10a3 <printer_vprintf+0x9c3>
        }
        for (; len > 0; ++data, --len) {
  2c10ce:	eb 32                	jmp    2c1102 <printer_vprintf+0xa22>
            p->putc(p, *data, color);
  2c10d0:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  2c10d7:	4c 8b 00             	mov    (%rax),%r8
  2c10da:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  2c10de:	0f b6 00             	movzbl (%rax),%eax
  2c10e1:	8b 95 74 ff ff ff    	mov    -0x8c(%rbp),%edx
  2c10e7:	0f b6 c8             	movzbl %al,%ecx
  2c10ea:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  2c10f1:	89 ce                	mov    %ecx,%esi
  2c10f3:	48 89 c7             	mov    %rax,%rdi
  2c10f6:	41 ff d0             	call   *%r8
        for (; len > 0; ++data, --len) {
  2c10f9:	48 83 45 c8 01       	addq   $0x1,-0x38(%rbp)
  2c10fe:	83 6d b4 01          	subl   $0x1,-0x4c(%rbp)
  2c1102:	83 7d b4 00          	cmpl   $0x0,-0x4c(%rbp)
  2c1106:	7f c8                	jg     2c10d0 <printer_vprintf+0x9f0>
        }
        for (; width > 0; --width) {
  2c1108:	eb 25                	jmp    2c112f <printer_vprintf+0xa4f>
            p->putc(p, ' ', color);
  2c110a:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  2c1111:	48 8b 08             	mov    (%rax),%rcx
  2c1114:	8b 95 74 ff ff ff    	mov    -0x8c(%rbp),%edx
  2c111a:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  2c1121:	be 20 00 00 00       	mov    $0x20,%esi
  2c1126:	48 89 c7             	mov    %rax,%rdi
  2c1129:	ff d1                	call   *%rcx
        for (; width > 0; --width) {
  2c112b:	83 6d e8 01          	subl   $0x1,-0x18(%rbp)
  2c112f:	83 7d e8 00          	cmpl   $0x0,-0x18(%rbp)
  2c1133:	7f d5                	jg     2c110a <printer_vprintf+0xa2a>
        }
    done: ;
  2c1135:	90                   	nop
    for (; *format; ++format) {
  2c1136:	48 83 85 68 ff ff ff 	addq   $0x1,-0x98(%rbp)
  2c113d:	01 
  2c113e:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  2c1145:	0f b6 00             	movzbl (%rax),%eax
  2c1148:	84 c0                	test   %al,%al
  2c114a:	0f 85 bc f5 ff ff    	jne    2c070c <printer_vprintf+0x2c>
    }
}
  2c1150:	90                   	nop
  2c1151:	90                   	nop
  2c1152:	48 8b 5d f8          	mov    -0x8(%rbp),%rbx
  2c1156:	c9                   	leave
  2c1157:	c3                   	ret

00000000002c1158 <console_putc>:
typedef struct console_printer {
    printer p;
    uint16_t* cursor;
} console_printer;

static void console_putc(printer* p, unsigned char c, int color) {
  2c1158:	55                   	push   %rbp
  2c1159:	48 89 e5             	mov    %rsp,%rbp
  2c115c:	48 83 ec 20          	sub    $0x20,%rsp
  2c1160:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  2c1164:	40 88 75 e7          	mov    %sil,-0x19(%rbp)
  2c1168:	89 55 e0             	mov    %edx,-0x20(%rbp)
    console_printer* cp = (console_printer*) p;
  2c116b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  2c116f:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
    if (cp->cursor >= console + CONSOLE_ROWS * CONSOLE_COLUMNS) {
  2c1173:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  2c1177:	48 8b 40 08          	mov    0x8(%rax),%rax
  2c117b:	ba a0 8f 0b 00       	mov    $0xb8fa0,%edx
  2c1180:	48 39 d0             	cmp    %rdx,%rax
  2c1183:	72 0c                	jb     2c1191 <console_putc+0x39>
        cp->cursor = console;
  2c1185:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  2c1189:	48 c7 40 08 00 80 0b 	movq   $0xb8000,0x8(%rax)
  2c1190:	00 
    }
    if (c == '\n') {
  2c1191:	80 7d e7 0a          	cmpb   $0xa,-0x19(%rbp)
  2c1195:	75 78                	jne    2c120f <console_putc+0xb7>
        int pos = (cp->cursor - console) % 80;
  2c1197:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  2c119b:	48 8b 40 08          	mov    0x8(%rax),%rax
  2c119f:	48 2d 00 80 0b 00    	sub    $0xb8000,%rax
  2c11a5:	48 d1 f8             	sar    $1,%rax
  2c11a8:	48 89 c1             	mov    %rax,%rcx
  2c11ab:	48 ba 67 66 66 66 66 	movabs $0x6666666666666667,%rdx
  2c11b2:	66 66 66 
  2c11b5:	48 89 c8             	mov    %rcx,%rax
  2c11b8:	48 f7 ea             	imul   %rdx
  2c11bb:	48 c1 fa 05          	sar    $0x5,%rdx
  2c11bf:	48 89 c8             	mov    %rcx,%rax
  2c11c2:	48 c1 f8 3f          	sar    $0x3f,%rax
  2c11c6:	48 29 c2             	sub    %rax,%rdx
  2c11c9:	48 89 d0             	mov    %rdx,%rax
  2c11cc:	48 c1 e0 02          	shl    $0x2,%rax
  2c11d0:	48 01 d0             	add    %rdx,%rax
  2c11d3:	48 c1 e0 04          	shl    $0x4,%rax
  2c11d7:	48 29 c1             	sub    %rax,%rcx
  2c11da:	48 89 ca             	mov    %rcx,%rdx
  2c11dd:	89 55 fc             	mov    %edx,-0x4(%rbp)
        for (; pos != 80; pos++) {
  2c11e0:	eb 25                	jmp    2c1207 <console_putc+0xaf>
            *cp->cursor++ = ' ' | color;
  2c11e2:	8b 45 e0             	mov    -0x20(%rbp),%eax
  2c11e5:	83 c8 20             	or     $0x20,%eax
  2c11e8:	89 c6                	mov    %eax,%esi
  2c11ea:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  2c11ee:	48 8b 40 08          	mov    0x8(%rax),%rax
  2c11f2:	48 8d 48 02          	lea    0x2(%rax),%rcx
  2c11f6:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  2c11fa:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  2c11fe:	89 f2                	mov    %esi,%edx
  2c1200:	66 89 10             	mov    %dx,(%rax)
        for (; pos != 80; pos++) {
  2c1203:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  2c1207:	83 7d fc 50          	cmpl   $0x50,-0x4(%rbp)
  2c120b:	75 d5                	jne    2c11e2 <console_putc+0x8a>
        }
    } else {
        *cp->cursor++ = c | color;
    }
}
  2c120d:	eb 24                	jmp    2c1233 <console_putc+0xdb>
        *cp->cursor++ = c | color;
  2c120f:	0f b6 45 e7          	movzbl -0x19(%rbp),%eax
  2c1213:	8b 55 e0             	mov    -0x20(%rbp),%edx
  2c1216:	09 d0                	or     %edx,%eax
  2c1218:	89 c6                	mov    %eax,%esi
  2c121a:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  2c121e:	48 8b 40 08          	mov    0x8(%rax),%rax
  2c1222:	48 8d 48 02          	lea    0x2(%rax),%rcx
  2c1226:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  2c122a:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  2c122e:	89 f2                	mov    %esi,%edx
  2c1230:	66 89 10             	mov    %dx,(%rax)
}
  2c1233:	90                   	nop
  2c1234:	c9                   	leave
  2c1235:	c3                   	ret

00000000002c1236 <console_vprintf>:

int console_vprintf(int cpos, int color, const char* format, va_list val) {
  2c1236:	55                   	push   %rbp
  2c1237:	48 89 e5             	mov    %rsp,%rbp
  2c123a:	48 83 ec 30          	sub    $0x30,%rsp
  2c123e:	89 7d ec             	mov    %edi,-0x14(%rbp)
  2c1241:	89 75 e8             	mov    %esi,-0x18(%rbp)
  2c1244:	48 89 55 e0          	mov    %rdx,-0x20(%rbp)
  2c1248:	48 89 4d d8          	mov    %rcx,-0x28(%rbp)
    struct console_printer cp;
    cp.p.putc = console_putc;
  2c124c:	48 c7 45 f0 58 11 2c 	movq   $0x2c1158,-0x10(%rbp)
  2c1253:	00 
    if (cpos < 0 || cpos >= CONSOLE_ROWS * CONSOLE_COLUMNS) {
  2c1254:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  2c1258:	78 09                	js     2c1263 <console_vprintf+0x2d>
  2c125a:	81 7d ec cf 07 00 00 	cmpl   $0x7cf,-0x14(%rbp)
  2c1261:	7e 07                	jle    2c126a <console_vprintf+0x34>
        cpos = 0;
  2c1263:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%rbp)
    }
    cp.cursor = console + cpos;
  2c126a:	8b 45 ec             	mov    -0x14(%rbp),%eax
  2c126d:	48 98                	cltq
  2c126f:	48 01 c0             	add    %rax,%rax
  2c1272:	48 05 00 80 0b 00    	add    $0xb8000,%rax
  2c1278:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    printer_vprintf(&cp.p, color, format, val);
  2c127c:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
  2c1280:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  2c1284:	8b 75 e8             	mov    -0x18(%rbp),%esi
  2c1287:	48 8d 45 f0          	lea    -0x10(%rbp),%rax
  2c128b:	48 89 c7             	mov    %rax,%rdi
  2c128e:	e8 4d f4 ff ff       	call   2c06e0 <printer_vprintf>
    return cp.cursor - console;
  2c1293:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  2c1297:	48 2d 00 80 0b 00    	sub    $0xb8000,%rax
  2c129d:	48 d1 f8             	sar    $1,%rax
}
  2c12a0:	c9                   	leave
  2c12a1:	c3                   	ret

00000000002c12a2 <console_printf>:

int console_printf(int cpos, int color, const char* format, ...) {
  2c12a2:	55                   	push   %rbp
  2c12a3:	48 89 e5             	mov    %rsp,%rbp
  2c12a6:	48 83 ec 60          	sub    $0x60,%rsp
  2c12aa:	89 7d ac             	mov    %edi,-0x54(%rbp)
  2c12ad:	89 75 a8             	mov    %esi,-0x58(%rbp)
  2c12b0:	48 89 55 a0          	mov    %rdx,-0x60(%rbp)
  2c12b4:	48 89 4d e8          	mov    %rcx,-0x18(%rbp)
  2c12b8:	4c 89 45 f0          	mov    %r8,-0x10(%rbp)
  2c12bc:	4c 89 4d f8          	mov    %r9,-0x8(%rbp)
    va_list val;
    va_start(val, format);
  2c12c0:	c7 45 b8 18 00 00 00 	movl   $0x18,-0x48(%rbp)
  2c12c7:	48 8d 45 10          	lea    0x10(%rbp),%rax
  2c12cb:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  2c12cf:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
  2c12d3:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    cpos = console_vprintf(cpos, color, format, val);
  2c12d7:	48 8d 4d b8          	lea    -0x48(%rbp),%rcx
  2c12db:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  2c12df:	8b 75 a8             	mov    -0x58(%rbp),%esi
  2c12e2:	8b 45 ac             	mov    -0x54(%rbp),%eax
  2c12e5:	89 c7                	mov    %eax,%edi
  2c12e7:	e8 4a ff ff ff       	call   2c1236 <console_vprintf>
  2c12ec:	89 45 ac             	mov    %eax,-0x54(%rbp)
    va_end(val);
    return cpos;
  2c12ef:	8b 45 ac             	mov    -0x54(%rbp),%eax
}
  2c12f2:	c9                   	leave
  2c12f3:	c3                   	ret

00000000002c12f4 <string_putc>:
    printer p;
    char* s;
    char* end;
} string_printer;

static void string_putc(printer* p, unsigned char c, int color) {
  2c12f4:	55                   	push   %rbp
  2c12f5:	48 89 e5             	mov    %rsp,%rbp
  2c12f8:	48 83 ec 20          	sub    $0x20,%rsp
  2c12fc:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  2c1300:	40 88 75 e7          	mov    %sil,-0x19(%rbp)
  2c1304:	89 55 e0             	mov    %edx,-0x20(%rbp)
    string_printer* sp = (string_printer*) p;
  2c1307:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  2c130b:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    if (sp->s < sp->end) {
  2c130f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  2c1313:	48 8b 50 08          	mov    0x8(%rax),%rdx
  2c1317:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  2c131b:	48 8b 40 10          	mov    0x10(%rax),%rax
  2c131f:	48 39 c2             	cmp    %rax,%rdx
  2c1322:	73 1a                	jae    2c133e <string_putc+0x4a>
        *sp->s++ = c;
  2c1324:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  2c1328:	48 8b 40 08          	mov    0x8(%rax),%rax
  2c132c:	48 8d 48 01          	lea    0x1(%rax),%rcx
  2c1330:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  2c1334:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  2c1338:	0f b6 55 e7          	movzbl -0x19(%rbp),%edx
  2c133c:	88 10                	mov    %dl,(%rax)
    }
    (void) color;
}
  2c133e:	90                   	nop
  2c133f:	c9                   	leave
  2c1340:	c3                   	ret

00000000002c1341 <vsnprintf>:

int vsnprintf(char* s, size_t size, const char* format, va_list val) {
  2c1341:	55                   	push   %rbp
  2c1342:	48 89 e5             	mov    %rsp,%rbp
  2c1345:	48 83 ec 40          	sub    $0x40,%rsp
  2c1349:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  2c134d:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  2c1351:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  2c1355:	48 89 4d c0          	mov    %rcx,-0x40(%rbp)
    string_printer sp;
    sp.p.putc = string_putc;
  2c1359:	48 c7 45 e8 f4 12 2c 	movq   $0x2c12f4,-0x18(%rbp)
  2c1360:	00 
    sp.s = s;
  2c1361:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  2c1365:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
    if (size) {
  2c1369:	48 83 7d d0 00       	cmpq   $0x0,-0x30(%rbp)
  2c136e:	74 33                	je     2c13a3 <vsnprintf+0x62>
        sp.end = s + size - 1;
  2c1370:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  2c1374:	48 8d 50 ff          	lea    -0x1(%rax),%rdx
  2c1378:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  2c137c:	48 01 d0             	add    %rdx,%rax
  2c137f:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
        printer_vprintf(&sp.p, 0, format, val);
  2c1383:	48 8b 4d c0          	mov    -0x40(%rbp),%rcx
  2c1387:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  2c138b:	48 8d 45 e8          	lea    -0x18(%rbp),%rax
  2c138f:	be 00 00 00 00       	mov    $0x0,%esi
  2c1394:	48 89 c7             	mov    %rax,%rdi
  2c1397:	e8 44 f3 ff ff       	call   2c06e0 <printer_vprintf>
        *sp.s = 0;
  2c139c:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  2c13a0:	c6 00 00             	movb   $0x0,(%rax)
    }
    return sp.s - s;
  2c13a3:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  2c13a7:	48 2b 45 d8          	sub    -0x28(%rbp),%rax
}
  2c13ab:	c9                   	leave
  2c13ac:	c3                   	ret

00000000002c13ad <snprintf>:

int snprintf(char* s, size_t size, const char* format, ...) {
  2c13ad:	55                   	push   %rbp
  2c13ae:	48 89 e5             	mov    %rsp,%rbp
  2c13b1:	48 83 ec 70          	sub    $0x70,%rsp
  2c13b5:	48 89 7d a8          	mov    %rdi,-0x58(%rbp)
  2c13b9:	48 89 75 a0          	mov    %rsi,-0x60(%rbp)
  2c13bd:	48 89 55 98          	mov    %rdx,-0x68(%rbp)
  2c13c1:	48 89 4d e8          	mov    %rcx,-0x18(%rbp)
  2c13c5:	4c 89 45 f0          	mov    %r8,-0x10(%rbp)
  2c13c9:	4c 89 4d f8          	mov    %r9,-0x8(%rbp)
    va_list val;
    va_start(val, format);
  2c13cd:	c7 45 b0 18 00 00 00 	movl   $0x18,-0x50(%rbp)
  2c13d4:	48 8d 45 10          	lea    0x10(%rbp),%rax
  2c13d8:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  2c13dc:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
  2c13e0:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
    int n = vsnprintf(s, size, format, val);
  2c13e4:	48 8d 4d b0          	lea    -0x50(%rbp),%rcx
  2c13e8:	48 8b 55 98          	mov    -0x68(%rbp),%rdx
  2c13ec:	48 8b 75 a0          	mov    -0x60(%rbp),%rsi
  2c13f0:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  2c13f4:	48 89 c7             	mov    %rax,%rdi
  2c13f7:	e8 45 ff ff ff       	call   2c1341 <vsnprintf>
  2c13fc:	89 45 cc             	mov    %eax,-0x34(%rbp)
    va_end(val);
    return n;
  2c13ff:	8b 45 cc             	mov    -0x34(%rbp),%eax
}
  2c1402:	c9                   	leave
  2c1403:	c3                   	ret

00000000002c1404 <console_clear>:


// console_clear
//    Erases the console and moves the cursor to the upper left (CPOS(0, 0)).

void console_clear(void) {
  2c1404:	55                   	push   %rbp
  2c1405:	48 89 e5             	mov    %rsp,%rbp
  2c1408:	48 83 ec 10          	sub    $0x10,%rsp
    for (int i = 0; i < CONSOLE_ROWS * CONSOLE_COLUMNS; ++i) {
  2c140c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  2c1413:	eb 13                	jmp    2c1428 <console_clear+0x24>
        console[i] = ' ' | 0x0700;
  2c1415:	8b 45 fc             	mov    -0x4(%rbp),%eax
  2c1418:	48 98                	cltq
  2c141a:	66 c7 84 00 00 80 0b 	movw   $0x720,0xb8000(%rax,%rax,1)
  2c1421:	00 20 07 
    for (int i = 0; i < CONSOLE_ROWS * CONSOLE_COLUMNS; ++i) {
  2c1424:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  2c1428:	81 7d fc cf 07 00 00 	cmpl   $0x7cf,-0x4(%rbp)
  2c142f:	7e e4                	jle    2c1415 <console_clear+0x11>
    }
    cursorpos = 0;
  2c1431:	c7 05 c1 7b df ff 00 	movl   $0x0,-0x20843f(%rip)        # b8ffc <cursorpos>
  2c1438:	00 00 00 
}
  2c143b:	90                   	nop
  2c143c:	c9                   	leave
  2c143d:	c3                   	ret
