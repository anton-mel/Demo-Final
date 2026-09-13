
obj/p-test.full:     file format elf64-x86-64


Disassembly of section .text:

0000000000100000 <process_main>:
uint8_t *heap_bottom;
uint8_t *stack_bottom;



void process_main(void) {
  100000:	55                   	push   %rbp
  100001:	48 89 e5             	mov    %rsp,%rbp
  100004:	41 55                	push   %r13
  100006:	41 54                	push   %r12
  100008:	53                   	push   %rbx
  100009:	48 83 ec 08          	sub    $0x8,%rsp

// getpid
//    Return current process ID.
static inline pid_t getpid(void) {
    pid_t result;
    asm volatile ("int %1" : "=a" (result)
  10000d:	cd 31                	int    $0x31
  10000f:	89 c7                	mov    %eax,%edi
    pid_t p = getpid();
    srand(p);
  100011:	e8 67 05 00 00       	call   10057d <srand>
    heap_bottom = heap_top = ROUNDUP((uint8_t*) end, PAGESIZE);
  100016:	b8 1f 30 10 00       	mov    $0x10301f,%eax
  10001b:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  100021:	48 89 05 e8 1f 00 00 	mov    %rax,0x1fe8(%rip)        # 102010 <heap_top>
  100028:	48 89 05 d9 1f 00 00 	mov    %rax,0x1fd9(%rip)        # 102008 <heap_bottom>
    return rbp;
}

static inline uintptr_t read_rsp(void) {
    uintptr_t rsp;
    asm volatile("movq %%rsp,%0" : "=r" (rsp));
  10002f:	48 89 e0             	mov    %rsp,%rax
    stack_bottom = ROUNDDOWN((uint8_t*) read_rsp() - 1, PAGESIZE);
  100032:	48 83 e8 01          	sub    $0x1,%rax
  100036:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  10003c:	48 89 05 bd 1f 00 00 	mov    %rax,0x1fbd(%rip)        # 102000 <stack_bottom>
  100043:	41 bd 01 00 00 00    	mov    $0x1,%r13d
void process_main(void) {
  100049:	4c 89 eb             	mov    %r13,%rbx
  10004c:	41 bc 01 00 00 00    	mov    $0x1,%r12d

    /* Single elements on heap of varying sizes */
    for(int i = 1; i < 64; ++i) {
        for(int j = 1; j < 64; ++j) {
            void *ptr = calloc(i,j);
  100052:	4c 89 e6             	mov    %r12,%rsi
  100055:	4c 89 ef             	mov    %r13,%rdi
  100058:	e8 16 02 00 00       	call   100273 <calloc>
            assert(ptr != NULL);
  10005d:	48 85 c0             	test   %rax,%rax
  100060:	74 54                	je     1000b6 <process_main+0xb6>

            for(int k = 0; k < i*j; ++k) {
  100062:	48 89 c2             	mov    %rax,%rdx
  100065:	48 8d 0c 18          	lea    (%rax,%rbx,1),%rcx
  100069:	85 db                	test   %ebx,%ebx
  10006b:	7e 11                	jle    10007e <process_main+0x7e>
  10006d:	0f 1f 00             	nopl   (%rax)
                assert(((char *)ptr)[k] == 0);
  100070:	80 3a 00             	cmpb   $0x0,(%rdx)
  100073:	75 55                	jne    1000ca <process_main+0xca>
            for(int k = 0; k < i*j; ++k) {
  100075:	48 83 c2 01          	add    $0x1,%rdx
  100079:	48 39 ca             	cmp    %rcx,%rdx
  10007c:	75 f2                	jne    100070 <process_main+0x70>
            }

            free(ptr);
  10007e:	48 89 c7             	mov    %rax,%rdi
  100081:	e8 e6 01 00 00       	call   10026c <free>
        for(int j = 1; j < 64; ++j) {
  100086:	49 83 c4 01          	add    $0x1,%r12
  10008a:	4c 01 eb             	add    %r13,%rbx
  10008d:	49 83 fc 40          	cmp    $0x40,%r12
  100091:	75 bf                	jne    100052 <process_main+0x52>
        }
	defrag();
  100093:	b8 00 00 00 00       	mov    $0x0,%eax
  100098:	e8 e2 01 00 00       	call   10027f <defrag>
    for(int i = 1; i < 64; ++i) {
  10009d:	49 83 c5 01          	add    $0x1,%r13
  1000a1:	49 83 fd 40          	cmp    $0x40,%r13
  1000a5:	75 a2                	jne    100049 <process_main+0x49>
    }

    TEST_PASS();
  1000a7:	bf b2 13 10 00       	mov    $0x1013b2,%edi
  1000ac:	b8 00 00 00 00       	mov    $0x0,%eax
  1000b1:	e8 b8 00 00 00       	call   10016e <kernel_panic>
            assert(ptr != NULL);
  1000b6:	ba 80 13 10 00       	mov    $0x101380,%edx
  1000bb:	be 19 00 00 00       	mov    $0x19,%esi
  1000c0:	bf 8c 13 10 00       	mov    $0x10138c,%edi
  1000c5:	e8 72 01 00 00       	call   10023c <assert_fail>
                assert(((char *)ptr)[k] == 0);
  1000ca:	ba 9c 13 10 00       	mov    $0x10139c,%edx
  1000cf:	be 1c 00 00 00       	mov    $0x1c,%esi
  1000d4:	bf 8c 13 10 00       	mov    $0x10138c,%edi
  1000d9:	e8 5e 01 00 00       	call   10023c <assert_fail>

00000000001000de <app_printf>:
#include "process.h"

// app_printf
//     A version of console_printf that picks a sensible color by process ID.

void app_printf(int colorid, const char* format, ...) {
  1000de:	55                   	push   %rbp
  1000df:	48 89 e5             	mov    %rsp,%rbp
  1000e2:	48 83 ec 50          	sub    $0x50,%rsp
  1000e6:	49 89 f2             	mov    %rsi,%r10
  1000e9:	48 89 55 e0          	mov    %rdx,-0x20(%rbp)
  1000ed:	48 89 4d e8          	mov    %rcx,-0x18(%rbp)
  1000f1:	4c 89 45 f0          	mov    %r8,-0x10(%rbp)
  1000f5:	4c 89 4d f8          	mov    %r9,-0x8(%rbp)
    int color;
    if (colorid < 0) {
        color = 0x0700;
  1000f9:	be 00 07 00 00       	mov    $0x700,%esi
    if (colorid < 0) {
  1000fe:	85 ff                	test   %edi,%edi
  100100:	78 2e                	js     100130 <app_printf+0x52>
    } else {
        static const uint8_t col[] = { 0x0E, 0x0F, 0x0C, 0x0A, 0x09 };
        color = col[colorid % sizeof(col)] << 8;
  100102:	48 63 ff             	movslq %edi,%rdi
  100105:	48 ba cd cc cc cc cc 	movabs $0xcccccccccccccccd,%rdx
  10010c:	cc cc cc 
  10010f:	48 89 f8             	mov    %rdi,%rax
  100112:	48 f7 e2             	mul    %rdx
  100115:	48 89 d0             	mov    %rdx,%rax
  100118:	48 c1 e8 02          	shr    $0x2,%rax
  10011c:	48 83 e2 fc          	and    $0xfffffffffffffffc,%rdx
  100120:	48 01 c2             	add    %rax,%rdx
  100123:	48 29 d7             	sub    %rdx,%rdi
  100126:	0f b6 b7 05 14 10 00 	movzbl 0x101405(%rdi),%esi
  10012d:	c1 e6 08             	shl    $0x8,%esi
    }

    va_list val;
    va_start(val, format);
  100130:	c7 45 b8 10 00 00 00 	movl   $0x10,-0x48(%rbp)
  100137:	48 8d 45 10          	lea    0x10(%rbp),%rax
  10013b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  10013f:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
  100143:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    cursorpos = console_vprintf(cursorpos, color, format, val);
  100147:	48 8d 4d b8          	lea    -0x48(%rbp),%rcx
  10014b:	4c 89 d2             	mov    %r10,%rdx
  10014e:	8b 3d a8 8e fb ff    	mov    -0x47158(%rip),%edi        # b8ffc <cursorpos>
  100154:	e8 1d 10 00 00       	call   101176 <console_vprintf>
    va_end(val);

    if (CROW(cursorpos) >= 23) {
        cursorpos = CPOS(0, 0);
  100159:	3d 30 07 00 00       	cmp    $0x730,%eax
  10015e:	ba 00 00 00 00       	mov    $0x0,%edx
  100163:	0f 4d c2             	cmovge %edx,%eax
  100166:	89 05 90 8e fb ff    	mov    %eax,-0x47170(%rip)        # b8ffc <cursorpos>
    }
}
  10016c:	c9                   	leave
  10016d:	c3                   	ret

000000000010016e <kernel_panic>:


// kernel_panic, assert_fail
//     Call the INT_SYS_PANIC system call so the kernel loops until Control-C.

void kernel_panic(const char* format, ...) {
  10016e:	55                   	push   %rbp
  10016f:	48 89 e5             	mov    %rsp,%rbp
  100172:	53                   	push   %rbx
  100173:	48 81 ec f8 00 00 00 	sub    $0xf8,%rsp
  10017a:	48 89 fb             	mov    %rdi,%rbx
  10017d:	48 89 75 c8          	mov    %rsi,-0x38(%rbp)
  100181:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  100185:	48 89 4d d8          	mov    %rcx,-0x28(%rbp)
  100189:	4c 89 45 e0          	mov    %r8,-0x20(%rbp)
  10018d:	4c 89 4d e8          	mov    %r9,-0x18(%rbp)
    va_list val;
    va_start(val, format);
  100191:	c7 45 a8 08 00 00 00 	movl   $0x8,-0x58(%rbp)
  100198:	48 8d 45 10          	lea    0x10(%rbp),%rax
  10019c:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
  1001a0:	48 8d 45 c0          	lea    -0x40(%rbp),%rax
  1001a4:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
    char buf[160];
    memcpy(buf, "PANIC: ", 7);
  1001a8:	48 8d bd 08 ff ff ff 	lea    -0xf8(%rbp),%rdi
  1001af:	ba 07 00 00 00       	mov    $0x7,%edx
  1001b4:	be cd 13 10 00       	mov    $0x1013cd,%esi
  1001b9:	e8 c8 00 00 00       	call   100286 <memcpy>
    int len = vsnprintf(&buf[7], sizeof(buf) - 7, format, val) + 7;
  1001be:	48 8d 4d a8          	lea    -0x58(%rbp),%rcx
  1001c2:	48 8d bd 0f ff ff ff 	lea    -0xf1(%rbp),%rdi
  1001c9:	48 89 da             	mov    %rbx,%rdx
  1001cc:	be 99 00 00 00       	mov    $0x99,%esi
  1001d1:	e8 ab 10 00 00       	call   101281 <vsnprintf>
  1001d6:	8d 50 07             	lea    0x7(%rax),%edx
    va_end(val);
    if (len > 0 && buf[len - 1] != '\n') {
  1001d9:	85 d2                	test   %edx,%edx
  1001db:	7e 0f                	jle    1001ec <kernel_panic+0x7e>
  1001dd:	83 c0 06             	add    $0x6,%eax
  1001e0:	48 98                	cltq
  1001e2:	80 bc 05 08 ff ff ff 	cmpb   $0xa,-0xf8(%rbp,%rax,1)
  1001e9:	0a 
  1001ea:	75 2a                	jne    100216 <kernel_panic+0xa8>
        strcpy(buf + len - (len == (int) sizeof(buf) - 1), "\n");
    }
    (void) console_printf(CPOS(23, 0), 0xC000, "%s", buf);
  1001ec:	48 8d 9d 08 ff ff ff 	lea    -0xf8(%rbp),%rbx
  1001f3:	48 89 d9             	mov    %rbx,%rcx
  1001f6:	ba d7 13 10 00       	mov    $0x1013d7,%edx
  1001fb:	be 00 c0 00 00       	mov    $0xc000,%esi
  100200:	bf 30 07 00 00       	mov    $0x730,%edi
  100205:	b8 00 00 00 00       	mov    $0x0,%eax
  10020a:	e8 d3 0f 00 00       	call   1011e2 <console_printf>
}

// panic(msg)
//    Panic.
static inline pid_t __attribute__((noreturn)) panic(const char* msg) {
    asm volatile ("int %0" : /* no result */
  10020f:	48 89 df             	mov    %rbx,%rdi
  100212:	cd 30                	int    $0x30
                  : "i" (INT_SYS_PANIC), "D" (msg)
                  : "cc", "memory");
 loop: goto loop;
  100214:	eb fe                	jmp    100214 <kernel_panic+0xa6>
        strcpy(buf + len - (len == (int) sizeof(buf) - 1), "\n");
  100216:	48 63 c2             	movslq %edx,%rax
  100219:	81 fa 9f 00 00 00    	cmp    $0x9f,%edx
  10021f:	0f 94 c2             	sete   %dl
  100222:	0f b6 d2             	movzbl %dl,%edx
  100225:	48 29 d0             	sub    %rdx,%rax
  100228:	48 8d bc 05 08 ff ff 	lea    -0xf8(%rbp,%rax,1),%rdi
  10022f:	ff 
  100230:	be d5 13 10 00       	mov    $0x1013d5,%esi
  100235:	e8 f9 01 00 00       	call   100433 <strcpy>
  10023a:	eb b0                	jmp    1001ec <kernel_panic+0x7e>

000000000010023c <assert_fail>:
    panic(buf);
 spinloop: goto spinloop;       // should never get here
}

void assert_fail(const char* file, int line, const char* msg) {
  10023c:	55                   	push   %rbp
  10023d:	48 89 e5             	mov    %rsp,%rbp
  100240:	48 89 f9             	mov    %rdi,%rcx
  100243:	41 89 f0             	mov    %esi,%r8d
  100246:	49 89 d1             	mov    %rdx,%r9
    (void) console_printf(CPOS(23, 0), 0xC000,
  100249:	ba e0 13 10 00       	mov    $0x1013e0,%edx
  10024e:	be 00 c0 00 00       	mov    $0xc000,%esi
  100253:	bf 30 07 00 00       	mov    $0x730,%edi
  100258:	b8 00 00 00 00       	mov    $0x0,%eax
  10025d:	e8 80 0f 00 00       	call   1011e2 <console_printf>
    asm volatile ("int %0" : /* no result */
  100262:	bf 00 00 00 00       	mov    $0x0,%edi
  100267:	cd 30                	int    $0x30
  100269:	90                   	nop
 loop: goto loop;
  10026a:	eb fe                	jmp    10026a <assert_fail+0x2e>

000000000010026c <free>:
#include "malloc.h"

void free(void *firstbyte) {
    return;
}
  10026c:	c3                   	ret

000000000010026d <malloc>:

void *malloc(uint64_t numbytes) {
    return 0 ;
}
  10026d:	b8 00 00 00 00       	mov    $0x0,%eax
  100272:	c3                   	ret

0000000000100273 <calloc>:


void * calloc(uint64_t num, uint64_t sz) {
    return 0;
}
  100273:	b8 00 00 00 00       	mov    $0x0,%eax
  100278:	c3                   	ret

0000000000100279 <realloc>:

void * realloc(void * ptr, uint64_t sz) {
    return 0;
}
  100279:	b8 00 00 00 00       	mov    $0x0,%eax
  10027e:	c3                   	ret

000000000010027f <defrag>:

void defrag() {
}
  10027f:	c3                   	ret

0000000000100280 <heap_info>:

int heap_info(heap_info_struct * info) {
    return 0;
}
  100280:	b8 00 00 00 00       	mov    $0x0,%eax
  100285:	c3                   	ret

0000000000100286 <memcpy>:


// memcpy, memmove, memset, strcmp, strlen, strnlen
//    We must provide our own implementations.

void* memcpy(void* dst, const void* src, size_t n) {
  100286:	55                   	push   %rbp
  100287:	48 89 e5             	mov    %rsp,%rbp
  10028a:	48 83 ec 28          	sub    $0x28,%rsp
  10028e:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  100292:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  100296:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
    const char* s = (const char*) src;
  10029a:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  10029e:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    for (char* d = (char*) dst; n > 0; --n, ++s, ++d) {
  1002a2:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  1002a6:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  1002aa:	eb 1c                	jmp    1002c8 <memcpy+0x42>
        *d = *s;
  1002ac:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  1002b0:	0f b6 10             	movzbl (%rax),%edx
  1002b3:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  1002b7:	88 10                	mov    %dl,(%rax)
    for (char* d = (char*) dst; n > 0; --n, ++s, ++d) {
  1002b9:	48 83 6d d8 01       	subq   $0x1,-0x28(%rbp)
  1002be:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  1002c3:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
  1002c8:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  1002cd:	75 dd                	jne    1002ac <memcpy+0x26>
    }
    return dst;
  1002cf:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
  1002d3:	c9                   	leave
  1002d4:	c3                   	ret

00000000001002d5 <memmove>:

void* memmove(void* dst, const void* src, size_t n) {
  1002d5:	55                   	push   %rbp
  1002d6:	48 89 e5             	mov    %rsp,%rbp
  1002d9:	48 83 ec 28          	sub    $0x28,%rsp
  1002dd:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  1002e1:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  1002e5:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
    const char* s = (const char*) src;
  1002e9:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  1002ed:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    char* d = (char*) dst;
  1002f1:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  1002f5:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
    if (s < d && s + n > d) {
  1002f9:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  1002fd:	48 3b 45 f0          	cmp    -0x10(%rbp),%rax
  100301:	73 6a                	jae    10036d <memmove+0x98>
  100303:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  100307:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  10030b:	48 01 d0             	add    %rdx,%rax
  10030e:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
  100312:	73 59                	jae    10036d <memmove+0x98>
        s += n, d += n;
  100314:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  100318:	48 01 45 f8          	add    %rax,-0x8(%rbp)
  10031c:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  100320:	48 01 45 f0          	add    %rax,-0x10(%rbp)
        while (n-- > 0) {
  100324:	eb 17                	jmp    10033d <memmove+0x68>
            *--d = *--s;
  100326:	48 83 6d f8 01       	subq   $0x1,-0x8(%rbp)
  10032b:	48 83 6d f0 01       	subq   $0x1,-0x10(%rbp)
  100330:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  100334:	0f b6 10             	movzbl (%rax),%edx
  100337:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  10033b:	88 10                	mov    %dl,(%rax)
        while (n-- > 0) {
  10033d:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  100341:	48 8d 50 ff          	lea    -0x1(%rax),%rdx
  100345:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  100349:	48 85 c0             	test   %rax,%rax
  10034c:	75 d8                	jne    100326 <memmove+0x51>
    if (s < d && s + n > d) {
  10034e:	eb 2e                	jmp    10037e <memmove+0xa9>
        }
    } else {
        while (n-- > 0) {
            *d++ = *s++;
  100350:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  100354:	48 8d 42 01          	lea    0x1(%rdx),%rax
  100358:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  10035c:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  100360:	48 8d 48 01          	lea    0x1(%rax),%rcx
  100364:	48 89 4d f0          	mov    %rcx,-0x10(%rbp)
  100368:	0f b6 12             	movzbl (%rdx),%edx
  10036b:	88 10                	mov    %dl,(%rax)
        while (n-- > 0) {
  10036d:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  100371:	48 8d 50 ff          	lea    -0x1(%rax),%rdx
  100375:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  100379:	48 85 c0             	test   %rax,%rax
  10037c:	75 d2                	jne    100350 <memmove+0x7b>
        }
    }
    return dst;
  10037e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
  100382:	c9                   	leave
  100383:	c3                   	ret

0000000000100384 <memset>:

void* memset(void* v, int c, size_t n) {
  100384:	55                   	push   %rbp
  100385:	48 89 e5             	mov    %rsp,%rbp
  100388:	48 83 ec 28          	sub    $0x28,%rsp
  10038c:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  100390:	89 75 e4             	mov    %esi,-0x1c(%rbp)
  100393:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
    for (char* p = (char*) v; n > 0; ++p, --n) {
  100397:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  10039b:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  10039f:	eb 15                	jmp    1003b6 <memset+0x32>
        *p = c;
  1003a1:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  1003a4:	89 c2                	mov    %eax,%edx
  1003a6:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  1003aa:	88 10                	mov    %dl,(%rax)
    for (char* p = (char*) v; n > 0; ++p, --n) {
  1003ac:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  1003b1:	48 83 6d d8 01       	subq   $0x1,-0x28(%rbp)
  1003b6:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  1003bb:	75 e4                	jne    1003a1 <memset+0x1d>
    }
    return v;
  1003bd:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
  1003c1:	c9                   	leave
  1003c2:	c3                   	ret

00000000001003c3 <strlen>:

size_t strlen(const char* s) {
  1003c3:	55                   	push   %rbp
  1003c4:	48 89 e5             	mov    %rsp,%rbp
  1003c7:	48 83 ec 18          	sub    $0x18,%rsp
  1003cb:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
    size_t n;
    for (n = 0; *s != '\0'; ++s) {
  1003cf:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
  1003d6:	00 
  1003d7:	eb 0a                	jmp    1003e3 <strlen+0x20>
        ++n;
  1003d9:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
    for (n = 0; *s != '\0'; ++s) {
  1003de:	48 83 45 e8 01       	addq   $0x1,-0x18(%rbp)
  1003e3:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  1003e7:	0f b6 00             	movzbl (%rax),%eax
  1003ea:	84 c0                	test   %al,%al
  1003ec:	75 eb                	jne    1003d9 <strlen+0x16>
    }
    return n;
  1003ee:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  1003f2:	c9                   	leave
  1003f3:	c3                   	ret

00000000001003f4 <strnlen>:

size_t strnlen(const char* s, size_t maxlen) {
  1003f4:	55                   	push   %rbp
  1003f5:	48 89 e5             	mov    %rsp,%rbp
  1003f8:	48 83 ec 20          	sub    $0x20,%rsp
  1003fc:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  100400:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
    size_t n;
    for (n = 0; n != maxlen && *s != '\0'; ++s) {
  100404:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
  10040b:	00 
  10040c:	eb 0a                	jmp    100418 <strnlen+0x24>
        ++n;
  10040e:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
    for (n = 0; n != maxlen && *s != '\0'; ++s) {
  100413:	48 83 45 e8 01       	addq   $0x1,-0x18(%rbp)
  100418:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  10041c:	48 3b 45 e0          	cmp    -0x20(%rbp),%rax
  100420:	74 0b                	je     10042d <strnlen+0x39>
  100422:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  100426:	0f b6 00             	movzbl (%rax),%eax
  100429:	84 c0                	test   %al,%al
  10042b:	75 e1                	jne    10040e <strnlen+0x1a>
    }
    return n;
  10042d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  100431:	c9                   	leave
  100432:	c3                   	ret

0000000000100433 <strcpy>:

char* strcpy(char* dst, const char* src) {
  100433:	55                   	push   %rbp
  100434:	48 89 e5             	mov    %rsp,%rbp
  100437:	48 83 ec 20          	sub    $0x20,%rsp
  10043b:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  10043f:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
    char* d = dst;
  100443:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  100447:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    do {
        *d++ = *src++;
  10044b:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  10044f:	48 8d 42 01          	lea    0x1(%rdx),%rax
  100453:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  100457:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  10045b:	48 8d 48 01          	lea    0x1(%rax),%rcx
  10045f:	48 89 4d f8          	mov    %rcx,-0x8(%rbp)
  100463:	0f b6 12             	movzbl (%rdx),%edx
  100466:	88 10                	mov    %dl,(%rax)
    } while (d[-1]);
  100468:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  10046c:	48 83 e8 01          	sub    $0x1,%rax
  100470:	0f b6 00             	movzbl (%rax),%eax
  100473:	84 c0                	test   %al,%al
  100475:	75 d4                	jne    10044b <strcpy+0x18>
    return dst;
  100477:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
  10047b:	c9                   	leave
  10047c:	c3                   	ret

000000000010047d <strcmp>:

int strcmp(const char* a, const char* b) {
  10047d:	55                   	push   %rbp
  10047e:	48 89 e5             	mov    %rsp,%rbp
  100481:	48 83 ec 10          	sub    $0x10,%rsp
  100485:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  100489:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
    while (*a && *b && *a == *b) {
  10048d:	eb 0a                	jmp    100499 <strcmp+0x1c>
        ++a, ++b;
  10048f:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  100494:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
    while (*a && *b && *a == *b) {
  100499:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  10049d:	0f b6 00             	movzbl (%rax),%eax
  1004a0:	84 c0                	test   %al,%al
  1004a2:	74 1d                	je     1004c1 <strcmp+0x44>
  1004a4:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  1004a8:	0f b6 00             	movzbl (%rax),%eax
  1004ab:	84 c0                	test   %al,%al
  1004ad:	74 12                	je     1004c1 <strcmp+0x44>
  1004af:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  1004b3:	0f b6 10             	movzbl (%rax),%edx
  1004b6:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  1004ba:	0f b6 00             	movzbl (%rax),%eax
  1004bd:	38 c2                	cmp    %al,%dl
  1004bf:	74 ce                	je     10048f <strcmp+0x12>
    }
    return ((unsigned char) *a > (unsigned char) *b)
  1004c1:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  1004c5:	0f b6 00             	movzbl (%rax),%eax
  1004c8:	89 c2                	mov    %eax,%edx
  1004ca:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  1004ce:	0f b6 00             	movzbl (%rax),%eax
  1004d1:	38 d0                	cmp    %dl,%al
  1004d3:	0f 92 c0             	setb   %al
  1004d6:	0f b6 d0             	movzbl %al,%edx
        - ((unsigned char) *a < (unsigned char) *b);
  1004d9:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  1004dd:	0f b6 00             	movzbl (%rax),%eax
  1004e0:	89 c1                	mov    %eax,%ecx
  1004e2:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  1004e6:	0f b6 00             	movzbl (%rax),%eax
  1004e9:	38 c1                	cmp    %al,%cl
  1004eb:	0f 92 c0             	setb   %al
  1004ee:	0f b6 c0             	movzbl %al,%eax
  1004f1:	29 c2                	sub    %eax,%edx
  1004f3:	89 d0                	mov    %edx,%eax
}
  1004f5:	c9                   	leave
  1004f6:	c3                   	ret

00000000001004f7 <strchr>:

char* strchr(const char* s, int c) {
  1004f7:	55                   	push   %rbp
  1004f8:	48 89 e5             	mov    %rsp,%rbp
  1004fb:	48 83 ec 10          	sub    $0x10,%rsp
  1004ff:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  100503:	89 75 f4             	mov    %esi,-0xc(%rbp)
    while (*s && *s != (char) c) {
  100506:	eb 05                	jmp    10050d <strchr+0x16>
        ++s;
  100508:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
    while (*s && *s != (char) c) {
  10050d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  100511:	0f b6 00             	movzbl (%rax),%eax
  100514:	84 c0                	test   %al,%al
  100516:	74 0e                	je     100526 <strchr+0x2f>
  100518:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  10051c:	0f b6 00             	movzbl (%rax),%eax
  10051f:	8b 55 f4             	mov    -0xc(%rbp),%edx
  100522:	38 d0                	cmp    %dl,%al
  100524:	75 e2                	jne    100508 <strchr+0x11>
    }
    if (*s == (char) c) {
  100526:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  10052a:	0f b6 00             	movzbl (%rax),%eax
  10052d:	8b 55 f4             	mov    -0xc(%rbp),%edx
  100530:	38 d0                	cmp    %dl,%al
  100532:	75 06                	jne    10053a <strchr+0x43>
        return (char*) s;
  100534:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  100538:	eb 05                	jmp    10053f <strchr+0x48>
    } else {
        return NULL;
  10053a:	b8 00 00 00 00       	mov    $0x0,%eax
    }
}
  10053f:	c9                   	leave
  100540:	c3                   	ret

0000000000100541 <rand>:
// rand, srand

static int rand_seed_set;
static unsigned rand_seed;

int rand(void) {
  100541:	55                   	push   %rbp
  100542:	48 89 e5             	mov    %rsp,%rbp
    if (!rand_seed_set) {
  100545:	8b 05 cd 1a 00 00    	mov    0x1acd(%rip),%eax        # 102018 <rand_seed_set>
  10054b:	85 c0                	test   %eax,%eax
  10054d:	75 0a                	jne    100559 <rand+0x18>
        srand(819234718U);
  10054f:	bf 9e 87 d4 30       	mov    $0x30d4879e,%edi
  100554:	e8 24 00 00 00       	call   10057d <srand>
    }
    rand_seed = rand_seed * 1664525U + 1013904223U;
  100559:	8b 05 bd 1a 00 00    	mov    0x1abd(%rip),%eax        # 10201c <rand_seed>
  10055f:	69 c0 0d 66 19 00    	imul   $0x19660d,%eax,%eax
  100565:	05 5f f3 6e 3c       	add    $0x3c6ef35f,%eax
  10056a:	89 05 ac 1a 00 00    	mov    %eax,0x1aac(%rip)        # 10201c <rand_seed>
    return rand_seed & RAND_MAX;
  100570:	8b 05 a6 1a 00 00    	mov    0x1aa6(%rip),%eax        # 10201c <rand_seed>
  100576:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
}
  10057b:	5d                   	pop    %rbp
  10057c:	c3                   	ret

000000000010057d <srand>:

void srand(unsigned seed) {
  10057d:	55                   	push   %rbp
  10057e:	48 89 e5             	mov    %rsp,%rbp
  100581:	48 83 ec 08          	sub    $0x8,%rsp
  100585:	89 7d fc             	mov    %edi,-0x4(%rbp)
    rand_seed = seed;
  100588:	8b 45 fc             	mov    -0x4(%rbp),%eax
  10058b:	89 05 8b 1a 00 00    	mov    %eax,0x1a8b(%rip)        # 10201c <rand_seed>
    rand_seed_set = 1;
  100591:	c7 05 7d 1a 00 00 01 	movl   $0x1,0x1a7d(%rip)        # 102018 <rand_seed_set>
  100598:	00 00 00 
}
  10059b:	90                   	nop
  10059c:	c9                   	leave
  10059d:	c3                   	ret

000000000010059e <fill_numbuf>:
//    Print a message onto the console, starting at the given cursor position.

// snprintf, vsnprintf
//    Format a string into a buffer.

static char* fill_numbuf(char* numbuf_end, unsigned long val, int base) {
  10059e:	55                   	push   %rbp
  10059f:	48 89 e5             	mov    %rsp,%rbp
  1005a2:	48 83 ec 28          	sub    $0x28,%rsp
  1005a6:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  1005aa:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  1005ae:	89 55 dc             	mov    %edx,-0x24(%rbp)
    static const char upper_digits[] = "0123456789ABCDEF";
    static const char lower_digits[] = "0123456789abcdef";

    const char* digits = upper_digits;
  1005b1:	48 c7 45 f8 30 14 10 	movq   $0x101430,-0x8(%rbp)
  1005b8:	00 
    if (base < 0) {
  1005b9:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
  1005bd:	79 0b                	jns    1005ca <fill_numbuf+0x2c>
        digits = lower_digits;
  1005bf:	48 c7 45 f8 50 14 10 	movq   $0x101450,-0x8(%rbp)
  1005c6:	00 
        base = -base;
  1005c7:	f7 5d dc             	negl   -0x24(%rbp)
    }

    *--numbuf_end = '\0';
  1005ca:	48 83 6d e8 01       	subq   $0x1,-0x18(%rbp)
  1005cf:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  1005d3:	c6 00 00             	movb   $0x0,(%rax)
    do {
        *--numbuf_end = digits[val % base];
  1005d6:	8b 45 dc             	mov    -0x24(%rbp),%eax
  1005d9:	48 63 c8             	movslq %eax,%rcx
  1005dc:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  1005e0:	ba 00 00 00 00       	mov    $0x0,%edx
  1005e5:	48 f7 f1             	div    %rcx
  1005e8:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  1005ec:	48 01 d0             	add    %rdx,%rax
  1005ef:	48 83 6d e8 01       	subq   $0x1,-0x18(%rbp)
  1005f4:	0f b6 10             	movzbl (%rax),%edx
  1005f7:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  1005fb:	88 10                	mov    %dl,(%rax)
        val /= base;
  1005fd:	8b 45 dc             	mov    -0x24(%rbp),%eax
  100600:	48 63 f0             	movslq %eax,%rsi
  100603:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  100607:	ba 00 00 00 00       	mov    $0x0,%edx
  10060c:	48 f7 f6             	div    %rsi
  10060f:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
    } while (val != 0);
  100613:	48 83 7d e0 00       	cmpq   $0x0,-0x20(%rbp)
  100618:	75 bc                	jne    1005d6 <fill_numbuf+0x38>
    return numbuf_end;
  10061a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
  10061e:	c9                   	leave
  10061f:	c3                   	ret

0000000000100620 <printer_vprintf>:
#define FLAG_NUMERIC            (1<<5)
#define FLAG_SIGNED             (1<<6)
#define FLAG_NEGATIVE           (1<<7)
#define FLAG_ALT2               (1<<8)

void printer_vprintf(printer* p, int color, const char* format, va_list val) {
  100620:	55                   	push   %rbp
  100621:	48 89 e5             	mov    %rsp,%rbp
  100624:	53                   	push   %rbx
  100625:	48 81 ec 98 00 00 00 	sub    $0x98,%rsp
  10062c:	48 89 bd 78 ff ff ff 	mov    %rdi,-0x88(%rbp)
  100633:	89 b5 74 ff ff ff    	mov    %esi,-0x8c(%rbp)
  100639:	48 89 95 68 ff ff ff 	mov    %rdx,-0x98(%rbp)
  100640:	48 89 8d 60 ff ff ff 	mov    %rcx,-0xa0(%rbp)
#define NUMBUFSIZ 24
    char numbuf[NUMBUFSIZ];

    for (; *format; ++format) {
  100647:	e9 32 0a 00 00       	jmp    10107e <printer_vprintf+0xa5e>
        if (*format != '%') {
  10064c:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  100653:	0f b6 00             	movzbl (%rax),%eax
  100656:	3c 25                	cmp    $0x25,%al
  100658:	74 31                	je     10068b <printer_vprintf+0x6b>
            p->putc(p, *format, color);
  10065a:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  100661:	4c 8b 00             	mov    (%rax),%r8
  100664:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  10066b:	0f b6 00             	movzbl (%rax),%eax
  10066e:	8b 95 74 ff ff ff    	mov    -0x8c(%rbp),%edx
  100674:	0f b6 c8             	movzbl %al,%ecx
  100677:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  10067e:	89 ce                	mov    %ecx,%esi
  100680:	48 89 c7             	mov    %rax,%rdi
  100683:	41 ff d0             	call   *%r8
            continue;
  100686:	e9 eb 09 00 00       	jmp    101076 <printer_vprintf+0xa56>
        }

        // process flags
        int flags = 0;
  10068b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%rbp)
        for (++format; *format; ++format) {
  100692:	48 83 85 68 ff ff ff 	addq   $0x1,-0x98(%rbp)
  100699:	01 
  10069a:	eb 44                	jmp    1006e0 <printer_vprintf+0xc0>
            const char* flagc = strchr(flag_chars, *format);
  10069c:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  1006a3:	0f b6 00             	movzbl (%rax),%eax
  1006a6:	0f be c0             	movsbl %al,%eax
  1006a9:	89 c6                	mov    %eax,%esi
  1006ab:	bf 10 14 10 00       	mov    $0x101410,%edi
  1006b0:	e8 42 fe ff ff       	call   1004f7 <strchr>
  1006b5:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
            if (flagc) {
  1006b9:	48 83 7d a8 00       	cmpq   $0x0,-0x58(%rbp)
  1006be:	74 30                	je     1006f0 <printer_vprintf+0xd0>
                flags |= 1 << (flagc - flag_chars);
  1006c0:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  1006c4:	48 2d 10 14 10 00    	sub    $0x101410,%rax
  1006ca:	ba 01 00 00 00       	mov    $0x1,%edx
  1006cf:	89 c1                	mov    %eax,%ecx
  1006d1:	d3 e2                	shl    %cl,%edx
  1006d3:	89 d0                	mov    %edx,%eax
  1006d5:	09 45 ec             	or     %eax,-0x14(%rbp)
        for (++format; *format; ++format) {
  1006d8:	48 83 85 68 ff ff ff 	addq   $0x1,-0x98(%rbp)
  1006df:	01 
  1006e0:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  1006e7:	0f b6 00             	movzbl (%rax),%eax
  1006ea:	84 c0                	test   %al,%al
  1006ec:	75 ae                	jne    10069c <printer_vprintf+0x7c>
  1006ee:	eb 01                	jmp    1006f1 <printer_vprintf+0xd1>
            } else {
                break;
  1006f0:	90                   	nop
            }
        }

        // process width
        int width = -1;
  1006f1:	c7 45 e8 ff ff ff ff 	movl   $0xffffffff,-0x18(%rbp)
        if (*format >= '1' && *format <= '9') {
  1006f8:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  1006ff:	0f b6 00             	movzbl (%rax),%eax
  100702:	3c 30                	cmp    $0x30,%al
  100704:	7e 67                	jle    10076d <printer_vprintf+0x14d>
  100706:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  10070d:	0f b6 00             	movzbl (%rax),%eax
  100710:	3c 39                	cmp    $0x39,%al
  100712:	7f 59                	jg     10076d <printer_vprintf+0x14d>
            for (width = 0; *format >= '0' && *format <= '9'; ) {
  100714:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%rbp)
  10071b:	eb 2e                	jmp    10074b <printer_vprintf+0x12b>
                width = 10 * width + *format++ - '0';
  10071d:	8b 55 e8             	mov    -0x18(%rbp),%edx
  100720:	89 d0                	mov    %edx,%eax
  100722:	c1 e0 02             	shl    $0x2,%eax
  100725:	01 d0                	add    %edx,%eax
  100727:	01 c0                	add    %eax,%eax
  100729:	89 c1                	mov    %eax,%ecx
  10072b:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  100732:	48 8d 50 01          	lea    0x1(%rax),%rdx
  100736:	48 89 95 68 ff ff ff 	mov    %rdx,-0x98(%rbp)
  10073d:	0f b6 00             	movzbl (%rax),%eax
  100740:	0f be c0             	movsbl %al,%eax
  100743:	01 c8                	add    %ecx,%eax
  100745:	83 e8 30             	sub    $0x30,%eax
  100748:	89 45 e8             	mov    %eax,-0x18(%rbp)
            for (width = 0; *format >= '0' && *format <= '9'; ) {
  10074b:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  100752:	0f b6 00             	movzbl (%rax),%eax
  100755:	3c 2f                	cmp    $0x2f,%al
  100757:	0f 8e 85 00 00 00    	jle    1007e2 <printer_vprintf+0x1c2>
  10075d:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  100764:	0f b6 00             	movzbl (%rax),%eax
  100767:	3c 39                	cmp    $0x39,%al
  100769:	7e b2                	jle    10071d <printer_vprintf+0xfd>
        if (*format >= '1' && *format <= '9') {
  10076b:	eb 75                	jmp    1007e2 <printer_vprintf+0x1c2>
            }
        } else if (*format == '*') {
  10076d:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  100774:	0f b6 00             	movzbl (%rax),%eax
  100777:	3c 2a                	cmp    $0x2a,%al
  100779:	75 68                	jne    1007e3 <printer_vprintf+0x1c3>
            width = va_arg(val, int);
  10077b:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100782:	8b 00                	mov    (%rax),%eax
  100784:	83 f8 2f             	cmp    $0x2f,%eax
  100787:	77 30                	ja     1007b9 <printer_vprintf+0x199>
  100789:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100790:	48 8b 50 10          	mov    0x10(%rax),%rdx
  100794:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  10079b:	8b 00                	mov    (%rax),%eax
  10079d:	89 c0                	mov    %eax,%eax
  10079f:	48 01 d0             	add    %rdx,%rax
  1007a2:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  1007a9:	8b 12                	mov    (%rdx),%edx
  1007ab:	8d 4a 08             	lea    0x8(%rdx),%ecx
  1007ae:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  1007b5:	89 0a                	mov    %ecx,(%rdx)
  1007b7:	eb 1a                	jmp    1007d3 <printer_vprintf+0x1b3>
  1007b9:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1007c0:	48 8b 40 08          	mov    0x8(%rax),%rax
  1007c4:	48 8d 48 08          	lea    0x8(%rax),%rcx
  1007c8:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  1007cf:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  1007d3:	8b 00                	mov    (%rax),%eax
  1007d5:	89 45 e8             	mov    %eax,-0x18(%rbp)
            ++format;
  1007d8:	48 83 85 68 ff ff ff 	addq   $0x1,-0x98(%rbp)
  1007df:	01 
  1007e0:	eb 01                	jmp    1007e3 <printer_vprintf+0x1c3>
        if (*format >= '1' && *format <= '9') {
  1007e2:	90                   	nop
        }

        // process precision
        int precision = -1;
  1007e3:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%rbp)
        if (*format == '.') {
  1007ea:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  1007f1:	0f b6 00             	movzbl (%rax),%eax
  1007f4:	3c 2e                	cmp    $0x2e,%al
  1007f6:	0f 85 00 01 00 00    	jne    1008fc <printer_vprintf+0x2dc>
            ++format;
  1007fc:	48 83 85 68 ff ff ff 	addq   $0x1,-0x98(%rbp)
  100803:	01 
            if (*format >= '0' && *format <= '9') {
  100804:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  10080b:	0f b6 00             	movzbl (%rax),%eax
  10080e:	3c 2f                	cmp    $0x2f,%al
  100810:	7e 67                	jle    100879 <printer_vprintf+0x259>
  100812:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  100819:	0f b6 00             	movzbl (%rax),%eax
  10081c:	3c 39                	cmp    $0x39,%al
  10081e:	7f 59                	jg     100879 <printer_vprintf+0x259>
                for (precision = 0; *format >= '0' && *format <= '9'; ) {
  100820:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%rbp)
  100827:	eb 2e                	jmp    100857 <printer_vprintf+0x237>
                    precision = 10 * precision + *format++ - '0';
  100829:	8b 55 e4             	mov    -0x1c(%rbp),%edx
  10082c:	89 d0                	mov    %edx,%eax
  10082e:	c1 e0 02             	shl    $0x2,%eax
  100831:	01 d0                	add    %edx,%eax
  100833:	01 c0                	add    %eax,%eax
  100835:	89 c1                	mov    %eax,%ecx
  100837:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  10083e:	48 8d 50 01          	lea    0x1(%rax),%rdx
  100842:	48 89 95 68 ff ff ff 	mov    %rdx,-0x98(%rbp)
  100849:	0f b6 00             	movzbl (%rax),%eax
  10084c:	0f be c0             	movsbl %al,%eax
  10084f:	01 c8                	add    %ecx,%eax
  100851:	83 e8 30             	sub    $0x30,%eax
  100854:	89 45 e4             	mov    %eax,-0x1c(%rbp)
                for (precision = 0; *format >= '0' && *format <= '9'; ) {
  100857:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  10085e:	0f b6 00             	movzbl (%rax),%eax
  100861:	3c 2f                	cmp    $0x2f,%al
  100863:	0f 8e 85 00 00 00    	jle    1008ee <printer_vprintf+0x2ce>
  100869:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  100870:	0f b6 00             	movzbl (%rax),%eax
  100873:	3c 39                	cmp    $0x39,%al
  100875:	7e b2                	jle    100829 <printer_vprintf+0x209>
            if (*format >= '0' && *format <= '9') {
  100877:	eb 75                	jmp    1008ee <printer_vprintf+0x2ce>
                }
            } else if (*format == '*') {
  100879:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  100880:	0f b6 00             	movzbl (%rax),%eax
  100883:	3c 2a                	cmp    $0x2a,%al
  100885:	75 68                	jne    1008ef <printer_vprintf+0x2cf>
                precision = va_arg(val, int);
  100887:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  10088e:	8b 00                	mov    (%rax),%eax
  100890:	83 f8 2f             	cmp    $0x2f,%eax
  100893:	77 30                	ja     1008c5 <printer_vprintf+0x2a5>
  100895:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  10089c:	48 8b 50 10          	mov    0x10(%rax),%rdx
  1008a0:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1008a7:	8b 00                	mov    (%rax),%eax
  1008a9:	89 c0                	mov    %eax,%eax
  1008ab:	48 01 d0             	add    %rdx,%rax
  1008ae:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  1008b5:	8b 12                	mov    (%rdx),%edx
  1008b7:	8d 4a 08             	lea    0x8(%rdx),%ecx
  1008ba:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  1008c1:	89 0a                	mov    %ecx,(%rdx)
  1008c3:	eb 1a                	jmp    1008df <printer_vprintf+0x2bf>
  1008c5:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1008cc:	48 8b 40 08          	mov    0x8(%rax),%rax
  1008d0:	48 8d 48 08          	lea    0x8(%rax),%rcx
  1008d4:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  1008db:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  1008df:	8b 00                	mov    (%rax),%eax
  1008e1:	89 45 e4             	mov    %eax,-0x1c(%rbp)
                ++format;
  1008e4:	48 83 85 68 ff ff ff 	addq   $0x1,-0x98(%rbp)
  1008eb:	01 
  1008ec:	eb 01                	jmp    1008ef <printer_vprintf+0x2cf>
            if (*format >= '0' && *format <= '9') {
  1008ee:	90                   	nop
            }
            if (precision < 0) {
  1008ef:	83 7d e4 00          	cmpl   $0x0,-0x1c(%rbp)
  1008f3:	79 07                	jns    1008fc <printer_vprintf+0x2dc>
                precision = 0;
  1008f5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%rbp)
            }
        }

        // process main conversion character
        int base = 10;
  1008fc:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%rbp)
        unsigned long num = 0;
  100903:	48 c7 45 d8 00 00 00 	movq   $0x0,-0x28(%rbp)
  10090a:	00 
        int length = 0;
  10090b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%rbp)
        char* data = "";
  100912:	48 c7 45 c8 16 14 10 	movq   $0x101416,-0x38(%rbp)
  100919:	00 
    again:
        switch (*format) {
  10091a:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  100921:	0f b6 00             	movzbl (%rax),%eax
  100924:	0f be c0             	movsbl %al,%eax
  100927:	83 f8 7a             	cmp    $0x7a,%eax
  10092a:	0f 84 a4 00 00 00    	je     1009d4 <printer_vprintf+0x3b4>
  100930:	83 f8 7a             	cmp    $0x7a,%eax
  100933:	0f 8f 3d 04 00 00    	jg     100d76 <printer_vprintf+0x756>
  100939:	83 f8 78             	cmp    $0x78,%eax
  10093c:	0f 84 76 02 00 00    	je     100bb8 <printer_vprintf+0x598>
  100942:	83 f8 78             	cmp    $0x78,%eax
  100945:	0f 8f 2b 04 00 00    	jg     100d76 <printer_vprintf+0x756>
  10094b:	83 f8 75             	cmp    $0x75,%eax
  10094e:	0f 84 94 01 00 00    	je     100ae8 <printer_vprintf+0x4c8>
  100954:	83 f8 75             	cmp    $0x75,%eax
  100957:	0f 8f 19 04 00 00    	jg     100d76 <printer_vprintf+0x756>
  10095d:	83 f8 73             	cmp    $0x73,%eax
  100960:	0f 84 dc 02 00 00    	je     100c42 <printer_vprintf+0x622>
  100966:	83 f8 73             	cmp    $0x73,%eax
  100969:	0f 8f 07 04 00 00    	jg     100d76 <printer_vprintf+0x756>
  10096f:	83 f8 70             	cmp    $0x70,%eax
  100972:	0f 84 58 02 00 00    	je     100bd0 <printer_vprintf+0x5b0>
  100978:	83 f8 70             	cmp    $0x70,%eax
  10097b:	0f 8f f5 03 00 00    	jg     100d76 <printer_vprintf+0x756>
  100981:	83 f8 6c             	cmp    $0x6c,%eax
  100984:	74 4e                	je     1009d4 <printer_vprintf+0x3b4>
  100986:	83 f8 6c             	cmp    $0x6c,%eax
  100989:	0f 8f e7 03 00 00    	jg     100d76 <printer_vprintf+0x756>
  10098f:	83 f8 69             	cmp    $0x69,%eax
  100992:	74 54                	je     1009e8 <printer_vprintf+0x3c8>
  100994:	83 f8 69             	cmp    $0x69,%eax
  100997:	0f 8f d9 03 00 00    	jg     100d76 <printer_vprintf+0x756>
  10099d:	83 f8 64             	cmp    $0x64,%eax
  1009a0:	74 46                	je     1009e8 <printer_vprintf+0x3c8>
  1009a2:	83 f8 64             	cmp    $0x64,%eax
  1009a5:	0f 8f cb 03 00 00    	jg     100d76 <printer_vprintf+0x756>
  1009ab:	83 f8 63             	cmp    $0x63,%eax
  1009ae:	0f 84 57 03 00 00    	je     100d0b <printer_vprintf+0x6eb>
  1009b4:	83 f8 63             	cmp    $0x63,%eax
  1009b7:	0f 8f b9 03 00 00    	jg     100d76 <printer_vprintf+0x756>
  1009bd:	83 f8 43             	cmp    $0x43,%eax
  1009c0:	0f 84 e0 02 00 00    	je     100ca6 <printer_vprintf+0x686>
  1009c6:	83 f8 58             	cmp    $0x58,%eax
  1009c9:	0f 84 f5 01 00 00    	je     100bc4 <printer_vprintf+0x5a4>
  1009cf:	e9 a2 03 00 00       	jmp    100d76 <printer_vprintf+0x756>
        case 'l':
        case 'z':
            length = 1;
  1009d4:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%rbp)
            ++format;
  1009db:	48 83 85 68 ff ff ff 	addq   $0x1,-0x98(%rbp)
  1009e2:	01 
            goto again;
  1009e3:	e9 32 ff ff ff       	jmp    10091a <printer_vprintf+0x2fa>
        case 'd':
        case 'i': {
            long x = length ? va_arg(val, long) : va_arg(val, int);
  1009e8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%rbp)
  1009ec:	74 61                	je     100a4f <printer_vprintf+0x42f>
  1009ee:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1009f5:	8b 00                	mov    (%rax),%eax
  1009f7:	83 f8 2f             	cmp    $0x2f,%eax
  1009fa:	77 30                	ja     100a2c <printer_vprintf+0x40c>
  1009fc:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100a03:	48 8b 50 10          	mov    0x10(%rax),%rdx
  100a07:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100a0e:	8b 00                	mov    (%rax),%eax
  100a10:	89 c0                	mov    %eax,%eax
  100a12:	48 01 d0             	add    %rdx,%rax
  100a15:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  100a1c:	8b 12                	mov    (%rdx),%edx
  100a1e:	8d 4a 08             	lea    0x8(%rdx),%ecx
  100a21:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  100a28:	89 0a                	mov    %ecx,(%rdx)
  100a2a:	eb 1a                	jmp    100a46 <printer_vprintf+0x426>
  100a2c:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100a33:	48 8b 40 08          	mov    0x8(%rax),%rax
  100a37:	48 8d 48 08          	lea    0x8(%rax),%rcx
  100a3b:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  100a42:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  100a46:	48 8b 00             	mov    (%rax),%rax
  100a49:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  100a4d:	eb 60                	jmp    100aaf <printer_vprintf+0x48f>
  100a4f:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100a56:	8b 00                	mov    (%rax),%eax
  100a58:	83 f8 2f             	cmp    $0x2f,%eax
  100a5b:	77 30                	ja     100a8d <printer_vprintf+0x46d>
  100a5d:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100a64:	48 8b 50 10          	mov    0x10(%rax),%rdx
  100a68:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100a6f:	8b 00                	mov    (%rax),%eax
  100a71:	89 c0                	mov    %eax,%eax
  100a73:	48 01 d0             	add    %rdx,%rax
  100a76:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  100a7d:	8b 12                	mov    (%rdx),%edx
  100a7f:	8d 4a 08             	lea    0x8(%rdx),%ecx
  100a82:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  100a89:	89 0a                	mov    %ecx,(%rdx)
  100a8b:	eb 1a                	jmp    100aa7 <printer_vprintf+0x487>
  100a8d:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100a94:	48 8b 40 08          	mov    0x8(%rax),%rax
  100a98:	48 8d 48 08          	lea    0x8(%rax),%rcx
  100a9c:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  100aa3:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  100aa7:	8b 00                	mov    (%rax),%eax
  100aa9:	48 98                	cltq
  100aab:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
            int negative = x < 0 ? FLAG_NEGATIVE : 0;
  100aaf:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  100ab3:	48 c1 f8 38          	sar    $0x38,%rax
  100ab7:	25 80 00 00 00       	and    $0x80,%eax
  100abc:	89 45 a4             	mov    %eax,-0x5c(%rbp)
            num = negative ? -x : x;
  100abf:	83 7d a4 00          	cmpl   $0x0,-0x5c(%rbp)
  100ac3:	74 0d                	je     100ad2 <printer_vprintf+0x4b2>
  100ac5:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  100ac9:	48 f7 d8             	neg    %rax
  100acc:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
  100ad0:	eb 08                	jmp    100ada <printer_vprintf+0x4ba>
  100ad2:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  100ad6:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
            flags |= FLAG_NUMERIC | FLAG_SIGNED | negative;
  100ada:	8b 45 a4             	mov    -0x5c(%rbp),%eax
  100add:	83 c8 60             	or     $0x60,%eax
  100ae0:	09 45 ec             	or     %eax,-0x14(%rbp)
            break;
  100ae3:	e9 d3 02 00 00       	jmp    100dbb <printer_vprintf+0x79b>
        }
        case 'u':
        format_unsigned:
            num = length ? va_arg(val, unsigned long) : va_arg(val, unsigned);
  100ae8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%rbp)
  100aec:	74 61                	je     100b4f <printer_vprintf+0x52f>
  100aee:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100af5:	8b 00                	mov    (%rax),%eax
  100af7:	83 f8 2f             	cmp    $0x2f,%eax
  100afa:	77 30                	ja     100b2c <printer_vprintf+0x50c>
  100afc:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100b03:	48 8b 50 10          	mov    0x10(%rax),%rdx
  100b07:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100b0e:	8b 00                	mov    (%rax),%eax
  100b10:	89 c0                	mov    %eax,%eax
  100b12:	48 01 d0             	add    %rdx,%rax
  100b15:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  100b1c:	8b 12                	mov    (%rdx),%edx
  100b1e:	8d 4a 08             	lea    0x8(%rdx),%ecx
  100b21:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  100b28:	89 0a                	mov    %ecx,(%rdx)
  100b2a:	eb 1a                	jmp    100b46 <printer_vprintf+0x526>
  100b2c:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100b33:	48 8b 40 08          	mov    0x8(%rax),%rax
  100b37:	48 8d 48 08          	lea    0x8(%rax),%rcx
  100b3b:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  100b42:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  100b46:	48 8b 00             	mov    (%rax),%rax
  100b49:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
  100b4d:	eb 60                	jmp    100baf <printer_vprintf+0x58f>
  100b4f:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100b56:	8b 00                	mov    (%rax),%eax
  100b58:	83 f8 2f             	cmp    $0x2f,%eax
  100b5b:	77 30                	ja     100b8d <printer_vprintf+0x56d>
  100b5d:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100b64:	48 8b 50 10          	mov    0x10(%rax),%rdx
  100b68:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100b6f:	8b 00                	mov    (%rax),%eax
  100b71:	89 c0                	mov    %eax,%eax
  100b73:	48 01 d0             	add    %rdx,%rax
  100b76:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  100b7d:	8b 12                	mov    (%rdx),%edx
  100b7f:	8d 4a 08             	lea    0x8(%rdx),%ecx
  100b82:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  100b89:	89 0a                	mov    %ecx,(%rdx)
  100b8b:	eb 1a                	jmp    100ba7 <printer_vprintf+0x587>
  100b8d:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100b94:	48 8b 40 08          	mov    0x8(%rax),%rax
  100b98:	48 8d 48 08          	lea    0x8(%rax),%rcx
  100b9c:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  100ba3:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  100ba7:	8b 00                	mov    (%rax),%eax
  100ba9:	89 c0                	mov    %eax,%eax
  100bab:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
            flags |= FLAG_NUMERIC;
  100baf:	83 4d ec 20          	orl    $0x20,-0x14(%rbp)
            break;
  100bb3:	e9 03 02 00 00       	jmp    100dbb <printer_vprintf+0x79b>
        case 'x':
            base = -16;
  100bb8:	c7 45 e0 f0 ff ff ff 	movl   $0xfffffff0,-0x20(%rbp)
            goto format_unsigned;
  100bbf:	e9 24 ff ff ff       	jmp    100ae8 <printer_vprintf+0x4c8>
        case 'X':
            base = 16;
  100bc4:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%rbp)
            goto format_unsigned;
  100bcb:	e9 18 ff ff ff       	jmp    100ae8 <printer_vprintf+0x4c8>
        case 'p':
            num = (uintptr_t) va_arg(val, void*);
  100bd0:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100bd7:	8b 00                	mov    (%rax),%eax
  100bd9:	83 f8 2f             	cmp    $0x2f,%eax
  100bdc:	77 30                	ja     100c0e <printer_vprintf+0x5ee>
  100bde:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100be5:	48 8b 50 10          	mov    0x10(%rax),%rdx
  100be9:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100bf0:	8b 00                	mov    (%rax),%eax
  100bf2:	89 c0                	mov    %eax,%eax
  100bf4:	48 01 d0             	add    %rdx,%rax
  100bf7:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  100bfe:	8b 12                	mov    (%rdx),%edx
  100c00:	8d 4a 08             	lea    0x8(%rdx),%ecx
  100c03:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  100c0a:	89 0a                	mov    %ecx,(%rdx)
  100c0c:	eb 1a                	jmp    100c28 <printer_vprintf+0x608>
  100c0e:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100c15:	48 8b 40 08          	mov    0x8(%rax),%rax
  100c19:	48 8d 48 08          	lea    0x8(%rax),%rcx
  100c1d:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  100c24:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  100c28:	48 8b 00             	mov    (%rax),%rax
  100c2b:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
            base = -16;
  100c2f:	c7 45 e0 f0 ff ff ff 	movl   $0xfffffff0,-0x20(%rbp)
            flags |= FLAG_ALT | FLAG_ALT2 | FLAG_NUMERIC;
  100c36:	81 4d ec 21 01 00 00 	orl    $0x121,-0x14(%rbp)
            break;
  100c3d:	e9 79 01 00 00       	jmp    100dbb <printer_vprintf+0x79b>
        case 's':
            data = va_arg(val, char*);
  100c42:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100c49:	8b 00                	mov    (%rax),%eax
  100c4b:	83 f8 2f             	cmp    $0x2f,%eax
  100c4e:	77 30                	ja     100c80 <printer_vprintf+0x660>
  100c50:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100c57:	48 8b 50 10          	mov    0x10(%rax),%rdx
  100c5b:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100c62:	8b 00                	mov    (%rax),%eax
  100c64:	89 c0                	mov    %eax,%eax
  100c66:	48 01 d0             	add    %rdx,%rax
  100c69:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  100c70:	8b 12                	mov    (%rdx),%edx
  100c72:	8d 4a 08             	lea    0x8(%rdx),%ecx
  100c75:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  100c7c:	89 0a                	mov    %ecx,(%rdx)
  100c7e:	eb 1a                	jmp    100c9a <printer_vprintf+0x67a>
  100c80:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100c87:	48 8b 40 08          	mov    0x8(%rax),%rax
  100c8b:	48 8d 48 08          	lea    0x8(%rax),%rcx
  100c8f:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  100c96:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  100c9a:	48 8b 00             	mov    (%rax),%rax
  100c9d:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
            break;
  100ca1:	e9 15 01 00 00       	jmp    100dbb <printer_vprintf+0x79b>
        case 'C':
            color = va_arg(val, int);
  100ca6:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100cad:	8b 00                	mov    (%rax),%eax
  100caf:	83 f8 2f             	cmp    $0x2f,%eax
  100cb2:	77 30                	ja     100ce4 <printer_vprintf+0x6c4>
  100cb4:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100cbb:	48 8b 50 10          	mov    0x10(%rax),%rdx
  100cbf:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100cc6:	8b 00                	mov    (%rax),%eax
  100cc8:	89 c0                	mov    %eax,%eax
  100cca:	48 01 d0             	add    %rdx,%rax
  100ccd:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  100cd4:	8b 12                	mov    (%rdx),%edx
  100cd6:	8d 4a 08             	lea    0x8(%rdx),%ecx
  100cd9:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  100ce0:	89 0a                	mov    %ecx,(%rdx)
  100ce2:	eb 1a                	jmp    100cfe <printer_vprintf+0x6de>
  100ce4:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100ceb:	48 8b 40 08          	mov    0x8(%rax),%rax
  100cef:	48 8d 48 08          	lea    0x8(%rax),%rcx
  100cf3:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  100cfa:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  100cfe:	8b 00                	mov    (%rax),%eax
  100d00:	89 85 74 ff ff ff    	mov    %eax,-0x8c(%rbp)
            goto done;
  100d06:	e9 6b 03 00 00       	jmp    101076 <printer_vprintf+0xa56>
        case 'c':
            data = numbuf;
  100d0b:	48 8d 45 8c          	lea    -0x74(%rbp),%rax
  100d0f:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
            numbuf[0] = va_arg(val, int);
  100d13:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100d1a:	8b 00                	mov    (%rax),%eax
  100d1c:	83 f8 2f             	cmp    $0x2f,%eax
  100d1f:	77 30                	ja     100d51 <printer_vprintf+0x731>
  100d21:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100d28:	48 8b 50 10          	mov    0x10(%rax),%rdx
  100d2c:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100d33:	8b 00                	mov    (%rax),%eax
  100d35:	89 c0                	mov    %eax,%eax
  100d37:	48 01 d0             	add    %rdx,%rax
  100d3a:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  100d41:	8b 12                	mov    (%rdx),%edx
  100d43:	8d 4a 08             	lea    0x8(%rdx),%ecx
  100d46:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  100d4d:	89 0a                	mov    %ecx,(%rdx)
  100d4f:	eb 1a                	jmp    100d6b <printer_vprintf+0x74b>
  100d51:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100d58:	48 8b 40 08          	mov    0x8(%rax),%rax
  100d5c:	48 8d 48 08          	lea    0x8(%rax),%rcx
  100d60:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  100d67:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  100d6b:	8b 00                	mov    (%rax),%eax
  100d6d:	88 45 8c             	mov    %al,-0x74(%rbp)
            numbuf[1] = '\0';
  100d70:	c6 45 8d 00          	movb   $0x0,-0x73(%rbp)
            break;
  100d74:	eb 45                	jmp    100dbb <printer_vprintf+0x79b>
        default:
            data = numbuf;
  100d76:	48 8d 45 8c          	lea    -0x74(%rbp),%rax
  100d7a:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
            numbuf[0] = (*format ? *format : '%');
  100d7e:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  100d85:	0f b6 00             	movzbl (%rax),%eax
  100d88:	84 c0                	test   %al,%al
  100d8a:	74 0c                	je     100d98 <printer_vprintf+0x778>
  100d8c:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  100d93:	0f b6 00             	movzbl (%rax),%eax
  100d96:	eb 05                	jmp    100d9d <printer_vprintf+0x77d>
  100d98:	b8 25 00 00 00       	mov    $0x25,%eax
  100d9d:	88 45 8c             	mov    %al,-0x74(%rbp)
            numbuf[1] = '\0';
  100da0:	c6 45 8d 00          	movb   $0x0,-0x73(%rbp)
            if (!*format) {
  100da4:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  100dab:	0f b6 00             	movzbl (%rax),%eax
  100dae:	84 c0                	test   %al,%al
  100db0:	75 08                	jne    100dba <printer_vprintf+0x79a>
                format--;
  100db2:	48 83 ad 68 ff ff ff 	subq   $0x1,-0x98(%rbp)
  100db9:	01 
            }
            break;
  100dba:	90                   	nop
        }

        if (flags & FLAG_NUMERIC) {
  100dbb:	8b 45 ec             	mov    -0x14(%rbp),%eax
  100dbe:	83 e0 20             	and    $0x20,%eax
  100dc1:	85 c0                	test   %eax,%eax
  100dc3:	74 1e                	je     100de3 <printer_vprintf+0x7c3>
            data = fill_numbuf(numbuf + NUMBUFSIZ, num, base);
  100dc5:	48 8d 45 8c          	lea    -0x74(%rbp),%rax
  100dc9:	48 83 c0 18          	add    $0x18,%rax
  100dcd:	8b 55 e0             	mov    -0x20(%rbp),%edx
  100dd0:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
  100dd4:	48 89 ce             	mov    %rcx,%rsi
  100dd7:	48 89 c7             	mov    %rax,%rdi
  100dda:	e8 bf f7 ff ff       	call   10059e <fill_numbuf>
  100ddf:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
        }

        const char* prefix = "";
  100de3:	48 c7 45 b8 16 14 10 	movq   $0x101416,-0x48(%rbp)
  100dea:	00 
        if ((flags & FLAG_NUMERIC) && (flags & FLAG_SIGNED)) {
  100deb:	8b 45 ec             	mov    -0x14(%rbp),%eax
  100dee:	83 e0 20             	and    $0x20,%eax
  100df1:	85 c0                	test   %eax,%eax
  100df3:	74 48                	je     100e3d <printer_vprintf+0x81d>
  100df5:	8b 45 ec             	mov    -0x14(%rbp),%eax
  100df8:	83 e0 40             	and    $0x40,%eax
  100dfb:	85 c0                	test   %eax,%eax
  100dfd:	74 3e                	je     100e3d <printer_vprintf+0x81d>
            if (flags & FLAG_NEGATIVE) {
  100dff:	8b 45 ec             	mov    -0x14(%rbp),%eax
  100e02:	25 80 00 00 00       	and    $0x80,%eax
  100e07:	85 c0                	test   %eax,%eax
  100e09:	74 0a                	je     100e15 <printer_vprintf+0x7f5>
                prefix = "-";
  100e0b:	48 c7 45 b8 17 14 10 	movq   $0x101417,-0x48(%rbp)
  100e12:	00 
            if (flags & FLAG_NEGATIVE) {
  100e13:	eb 75                	jmp    100e8a <printer_vprintf+0x86a>
            } else if (flags & FLAG_PLUSPOSITIVE) {
  100e15:	8b 45 ec             	mov    -0x14(%rbp),%eax
  100e18:	83 e0 10             	and    $0x10,%eax
  100e1b:	85 c0                	test   %eax,%eax
  100e1d:	74 0a                	je     100e29 <printer_vprintf+0x809>
                prefix = "+";
  100e1f:	48 c7 45 b8 19 14 10 	movq   $0x101419,-0x48(%rbp)
  100e26:	00 
            if (flags & FLAG_NEGATIVE) {
  100e27:	eb 61                	jmp    100e8a <printer_vprintf+0x86a>
            } else if (flags & FLAG_SPACEPOSITIVE) {
  100e29:	8b 45 ec             	mov    -0x14(%rbp),%eax
  100e2c:	83 e0 08             	and    $0x8,%eax
  100e2f:	85 c0                	test   %eax,%eax
  100e31:	74 57                	je     100e8a <printer_vprintf+0x86a>
                prefix = " ";
  100e33:	48 c7 45 b8 1b 14 10 	movq   $0x10141b,-0x48(%rbp)
  100e3a:	00 
            if (flags & FLAG_NEGATIVE) {
  100e3b:	eb 4d                	jmp    100e8a <printer_vprintf+0x86a>
            }
        } else if ((flags & FLAG_NUMERIC) && (flags & FLAG_ALT)
  100e3d:	8b 45 ec             	mov    -0x14(%rbp),%eax
  100e40:	83 e0 20             	and    $0x20,%eax
  100e43:	85 c0                	test   %eax,%eax
  100e45:	74 44                	je     100e8b <printer_vprintf+0x86b>
  100e47:	8b 45 ec             	mov    -0x14(%rbp),%eax
  100e4a:	83 e0 01             	and    $0x1,%eax
  100e4d:	85 c0                	test   %eax,%eax
  100e4f:	74 3a                	je     100e8b <printer_vprintf+0x86b>
                   && (base == 16 || base == -16)
  100e51:	83 7d e0 10          	cmpl   $0x10,-0x20(%rbp)
  100e55:	74 06                	je     100e5d <printer_vprintf+0x83d>
  100e57:	83 7d e0 f0          	cmpl   $0xfffffff0,-0x20(%rbp)
  100e5b:	75 2e                	jne    100e8b <printer_vprintf+0x86b>
                   && (num || (flags & FLAG_ALT2))) {
  100e5d:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  100e62:	75 0c                	jne    100e70 <printer_vprintf+0x850>
  100e64:	8b 45 ec             	mov    -0x14(%rbp),%eax
  100e67:	25 00 01 00 00       	and    $0x100,%eax
  100e6c:	85 c0                	test   %eax,%eax
  100e6e:	74 1b                	je     100e8b <printer_vprintf+0x86b>
            prefix = (base == -16 ? "0x" : "0X");
  100e70:	83 7d e0 f0          	cmpl   $0xfffffff0,-0x20(%rbp)
  100e74:	75 0a                	jne    100e80 <printer_vprintf+0x860>
  100e76:	48 c7 45 b8 1d 14 10 	movq   $0x10141d,-0x48(%rbp)
  100e7d:	00 
  100e7e:	eb 0b                	jmp    100e8b <printer_vprintf+0x86b>
  100e80:	48 c7 45 b8 20 14 10 	movq   $0x101420,-0x48(%rbp)
  100e87:	00 
  100e88:	eb 01                	jmp    100e8b <printer_vprintf+0x86b>
            if (flags & FLAG_NEGATIVE) {
  100e8a:	90                   	nop
        }

        int len;
        if (precision >= 0 && !(flags & FLAG_NUMERIC)) {
  100e8b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%rbp)
  100e8f:	78 24                	js     100eb5 <printer_vprintf+0x895>
  100e91:	8b 45 ec             	mov    -0x14(%rbp),%eax
  100e94:	83 e0 20             	and    $0x20,%eax
  100e97:	85 c0                	test   %eax,%eax
  100e99:	75 1a                	jne    100eb5 <printer_vprintf+0x895>
            len = strnlen(data, precision);
  100e9b:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  100e9e:	48 63 d0             	movslq %eax,%rdx
  100ea1:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  100ea5:	48 89 d6             	mov    %rdx,%rsi
  100ea8:	48 89 c7             	mov    %rax,%rdi
  100eab:	e8 44 f5 ff ff       	call   1003f4 <strnlen>
  100eb0:	89 45 b4             	mov    %eax,-0x4c(%rbp)
  100eb3:	eb 0f                	jmp    100ec4 <printer_vprintf+0x8a4>
        } else {
            len = strlen(data);
  100eb5:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  100eb9:	48 89 c7             	mov    %rax,%rdi
  100ebc:	e8 02 f5 ff ff       	call   1003c3 <strlen>
  100ec1:	89 45 b4             	mov    %eax,-0x4c(%rbp)
        }
        int zeros;
        if ((flags & FLAG_NUMERIC) && precision >= 0) {
  100ec4:	8b 45 ec             	mov    -0x14(%rbp),%eax
  100ec7:	83 e0 20             	and    $0x20,%eax
  100eca:	85 c0                	test   %eax,%eax
  100ecc:	74 22                	je     100ef0 <printer_vprintf+0x8d0>
  100ece:	83 7d e4 00          	cmpl   $0x0,-0x1c(%rbp)
  100ed2:	78 1c                	js     100ef0 <printer_vprintf+0x8d0>
            zeros = precision > len ? precision - len : 0;
  100ed4:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  100ed7:	3b 45 b4             	cmp    -0x4c(%rbp),%eax
  100eda:	7e 0b                	jle    100ee7 <printer_vprintf+0x8c7>
  100edc:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  100edf:	2b 45 b4             	sub    -0x4c(%rbp),%eax
  100ee2:	89 45 b0             	mov    %eax,-0x50(%rbp)
  100ee5:	eb 65                	jmp    100f4c <printer_vprintf+0x92c>
  100ee7:	c7 45 b0 00 00 00 00 	movl   $0x0,-0x50(%rbp)
  100eee:	eb 5c                	jmp    100f4c <printer_vprintf+0x92c>
        } else if ((flags & FLAG_NUMERIC) && (flags & FLAG_ZERO)
  100ef0:	8b 45 ec             	mov    -0x14(%rbp),%eax
  100ef3:	83 e0 20             	and    $0x20,%eax
  100ef6:	85 c0                	test   %eax,%eax
  100ef8:	74 4b                	je     100f45 <printer_vprintf+0x925>
  100efa:	8b 45 ec             	mov    -0x14(%rbp),%eax
  100efd:	83 e0 02             	and    $0x2,%eax
  100f00:	85 c0                	test   %eax,%eax
  100f02:	74 41                	je     100f45 <printer_vprintf+0x925>
                   && !(flags & FLAG_LEFTJUSTIFY)
  100f04:	8b 45 ec             	mov    -0x14(%rbp),%eax
  100f07:	83 e0 04             	and    $0x4,%eax
  100f0a:	85 c0                	test   %eax,%eax
  100f0c:	75 37                	jne    100f45 <printer_vprintf+0x925>
                   && len + (int) strlen(prefix) < width) {
  100f0e:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  100f12:	48 89 c7             	mov    %rax,%rdi
  100f15:	e8 a9 f4 ff ff       	call   1003c3 <strlen>
  100f1a:	89 c2                	mov    %eax,%edx
  100f1c:	8b 45 b4             	mov    -0x4c(%rbp),%eax
  100f1f:	01 d0                	add    %edx,%eax
  100f21:	39 45 e8             	cmp    %eax,-0x18(%rbp)
  100f24:	7e 1f                	jle    100f45 <printer_vprintf+0x925>
            zeros = width - len - strlen(prefix);
  100f26:	8b 45 e8             	mov    -0x18(%rbp),%eax
  100f29:	2b 45 b4             	sub    -0x4c(%rbp),%eax
  100f2c:	89 c3                	mov    %eax,%ebx
  100f2e:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  100f32:	48 89 c7             	mov    %rax,%rdi
  100f35:	e8 89 f4 ff ff       	call   1003c3 <strlen>
  100f3a:	89 c2                	mov    %eax,%edx
  100f3c:	89 d8                	mov    %ebx,%eax
  100f3e:	29 d0                	sub    %edx,%eax
  100f40:	89 45 b0             	mov    %eax,-0x50(%rbp)
  100f43:	eb 07                	jmp    100f4c <printer_vprintf+0x92c>
        } else {
            zeros = 0;
  100f45:	c7 45 b0 00 00 00 00 	movl   $0x0,-0x50(%rbp)
        }
        width -= len + zeros + strlen(prefix);
  100f4c:	8b 55 b4             	mov    -0x4c(%rbp),%edx
  100f4f:	8b 45 b0             	mov    -0x50(%rbp),%eax
  100f52:	01 d0                	add    %edx,%eax
  100f54:	48 63 d8             	movslq %eax,%rbx
  100f57:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  100f5b:	48 89 c7             	mov    %rax,%rdi
  100f5e:	e8 60 f4 ff ff       	call   1003c3 <strlen>
  100f63:	48 8d 14 03          	lea    (%rbx,%rax,1),%rdx
  100f67:	8b 45 e8             	mov    -0x18(%rbp),%eax
  100f6a:	29 d0                	sub    %edx,%eax
  100f6c:	89 45 e8             	mov    %eax,-0x18(%rbp)
        for (; !(flags & FLAG_LEFTJUSTIFY) && width > 0; --width) {
  100f6f:	eb 25                	jmp    100f96 <printer_vprintf+0x976>
            p->putc(p, ' ', color);
  100f71:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  100f78:	48 8b 08             	mov    (%rax),%rcx
  100f7b:	8b 95 74 ff ff ff    	mov    -0x8c(%rbp),%edx
  100f81:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  100f88:	be 20 00 00 00       	mov    $0x20,%esi
  100f8d:	48 89 c7             	mov    %rax,%rdi
  100f90:	ff d1                	call   *%rcx
        for (; !(flags & FLAG_LEFTJUSTIFY) && width > 0; --width) {
  100f92:	83 6d e8 01          	subl   $0x1,-0x18(%rbp)
  100f96:	8b 45 ec             	mov    -0x14(%rbp),%eax
  100f99:	83 e0 04             	and    $0x4,%eax
  100f9c:	85 c0                	test   %eax,%eax
  100f9e:	75 36                	jne    100fd6 <printer_vprintf+0x9b6>
  100fa0:	83 7d e8 00          	cmpl   $0x0,-0x18(%rbp)
  100fa4:	7f cb                	jg     100f71 <printer_vprintf+0x951>
        }
        for (; *prefix; ++prefix) {
  100fa6:	eb 2e                	jmp    100fd6 <printer_vprintf+0x9b6>
            p->putc(p, *prefix, color);
  100fa8:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  100faf:	4c 8b 00             	mov    (%rax),%r8
  100fb2:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  100fb6:	0f b6 00             	movzbl (%rax),%eax
  100fb9:	8b 95 74 ff ff ff    	mov    -0x8c(%rbp),%edx
  100fbf:	0f b6 c8             	movzbl %al,%ecx
  100fc2:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  100fc9:	89 ce                	mov    %ecx,%esi
  100fcb:	48 89 c7             	mov    %rax,%rdi
  100fce:	41 ff d0             	call   *%r8
        for (; *prefix; ++prefix) {
  100fd1:	48 83 45 b8 01       	addq   $0x1,-0x48(%rbp)
  100fd6:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  100fda:	0f b6 00             	movzbl (%rax),%eax
  100fdd:	84 c0                	test   %al,%al
  100fdf:	75 c7                	jne    100fa8 <printer_vprintf+0x988>
        }
        for (; zeros > 0; --zeros) {
  100fe1:	eb 25                	jmp    101008 <printer_vprintf+0x9e8>
            p->putc(p, '0', color);
  100fe3:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  100fea:	48 8b 08             	mov    (%rax),%rcx
  100fed:	8b 95 74 ff ff ff    	mov    -0x8c(%rbp),%edx
  100ff3:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  100ffa:	be 30 00 00 00       	mov    $0x30,%esi
  100fff:	48 89 c7             	mov    %rax,%rdi
  101002:	ff d1                	call   *%rcx
        for (; zeros > 0; --zeros) {
  101004:	83 6d b0 01          	subl   $0x1,-0x50(%rbp)
  101008:	83 7d b0 00          	cmpl   $0x0,-0x50(%rbp)
  10100c:	7f d5                	jg     100fe3 <printer_vprintf+0x9c3>
        }
        for (; len > 0; ++data, --len) {
  10100e:	eb 32                	jmp    101042 <printer_vprintf+0xa22>
            p->putc(p, *data, color);
  101010:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  101017:	4c 8b 00             	mov    (%rax),%r8
  10101a:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  10101e:	0f b6 00             	movzbl (%rax),%eax
  101021:	8b 95 74 ff ff ff    	mov    -0x8c(%rbp),%edx
  101027:	0f b6 c8             	movzbl %al,%ecx
  10102a:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  101031:	89 ce                	mov    %ecx,%esi
  101033:	48 89 c7             	mov    %rax,%rdi
  101036:	41 ff d0             	call   *%r8
        for (; len > 0; ++data, --len) {
  101039:	48 83 45 c8 01       	addq   $0x1,-0x38(%rbp)
  10103e:	83 6d b4 01          	subl   $0x1,-0x4c(%rbp)
  101042:	83 7d b4 00          	cmpl   $0x0,-0x4c(%rbp)
  101046:	7f c8                	jg     101010 <printer_vprintf+0x9f0>
        }
        for (; width > 0; --width) {
  101048:	eb 25                	jmp    10106f <printer_vprintf+0xa4f>
            p->putc(p, ' ', color);
  10104a:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  101051:	48 8b 08             	mov    (%rax),%rcx
  101054:	8b 95 74 ff ff ff    	mov    -0x8c(%rbp),%edx
  10105a:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  101061:	be 20 00 00 00       	mov    $0x20,%esi
  101066:	48 89 c7             	mov    %rax,%rdi
  101069:	ff d1                	call   *%rcx
        for (; width > 0; --width) {
  10106b:	83 6d e8 01          	subl   $0x1,-0x18(%rbp)
  10106f:	83 7d e8 00          	cmpl   $0x0,-0x18(%rbp)
  101073:	7f d5                	jg     10104a <printer_vprintf+0xa2a>
        }
    done: ;
  101075:	90                   	nop
    for (; *format; ++format) {
  101076:	48 83 85 68 ff ff ff 	addq   $0x1,-0x98(%rbp)
  10107d:	01 
  10107e:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  101085:	0f b6 00             	movzbl (%rax),%eax
  101088:	84 c0                	test   %al,%al
  10108a:	0f 85 bc f5 ff ff    	jne    10064c <printer_vprintf+0x2c>
    }
}
  101090:	90                   	nop
  101091:	90                   	nop
  101092:	48 8b 5d f8          	mov    -0x8(%rbp),%rbx
  101096:	c9                   	leave
  101097:	c3                   	ret

0000000000101098 <console_putc>:
typedef struct console_printer {
    printer p;
    uint16_t* cursor;
} console_printer;

static void console_putc(printer* p, unsigned char c, int color) {
  101098:	55                   	push   %rbp
  101099:	48 89 e5             	mov    %rsp,%rbp
  10109c:	48 83 ec 20          	sub    $0x20,%rsp
  1010a0:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  1010a4:	40 88 75 e7          	mov    %sil,-0x19(%rbp)
  1010a8:	89 55 e0             	mov    %edx,-0x20(%rbp)
    console_printer* cp = (console_printer*) p;
  1010ab:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  1010af:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
    if (cp->cursor >= console + CONSOLE_ROWS * CONSOLE_COLUMNS) {
  1010b3:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  1010b7:	48 8b 40 08          	mov    0x8(%rax),%rax
  1010bb:	ba a0 8f 0b 00       	mov    $0xb8fa0,%edx
  1010c0:	48 39 d0             	cmp    %rdx,%rax
  1010c3:	72 0c                	jb     1010d1 <console_putc+0x39>
        cp->cursor = console;
  1010c5:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  1010c9:	48 c7 40 08 00 80 0b 	movq   $0xb8000,0x8(%rax)
  1010d0:	00 
    }
    if (c == '\n') {
  1010d1:	80 7d e7 0a          	cmpb   $0xa,-0x19(%rbp)
  1010d5:	75 78                	jne    10114f <console_putc+0xb7>
        int pos = (cp->cursor - console) % 80;
  1010d7:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  1010db:	48 8b 40 08          	mov    0x8(%rax),%rax
  1010df:	48 2d 00 80 0b 00    	sub    $0xb8000,%rax
  1010e5:	48 d1 f8             	sar    $1,%rax
  1010e8:	48 89 c1             	mov    %rax,%rcx
  1010eb:	48 ba 67 66 66 66 66 	movabs $0x6666666666666667,%rdx
  1010f2:	66 66 66 
  1010f5:	48 89 c8             	mov    %rcx,%rax
  1010f8:	48 f7 ea             	imul   %rdx
  1010fb:	48 c1 fa 05          	sar    $0x5,%rdx
  1010ff:	48 89 c8             	mov    %rcx,%rax
  101102:	48 c1 f8 3f          	sar    $0x3f,%rax
  101106:	48 29 c2             	sub    %rax,%rdx
  101109:	48 89 d0             	mov    %rdx,%rax
  10110c:	48 c1 e0 02          	shl    $0x2,%rax
  101110:	48 01 d0             	add    %rdx,%rax
  101113:	48 c1 e0 04          	shl    $0x4,%rax
  101117:	48 29 c1             	sub    %rax,%rcx
  10111a:	48 89 ca             	mov    %rcx,%rdx
  10111d:	89 55 fc             	mov    %edx,-0x4(%rbp)
        for (; pos != 80; pos++) {
  101120:	eb 25                	jmp    101147 <console_putc+0xaf>
            *cp->cursor++ = ' ' | color;
  101122:	8b 45 e0             	mov    -0x20(%rbp),%eax
  101125:	83 c8 20             	or     $0x20,%eax
  101128:	89 c6                	mov    %eax,%esi
  10112a:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  10112e:	48 8b 40 08          	mov    0x8(%rax),%rax
  101132:	48 8d 48 02          	lea    0x2(%rax),%rcx
  101136:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  10113a:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  10113e:	89 f2                	mov    %esi,%edx
  101140:	66 89 10             	mov    %dx,(%rax)
        for (; pos != 80; pos++) {
  101143:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  101147:	83 7d fc 50          	cmpl   $0x50,-0x4(%rbp)
  10114b:	75 d5                	jne    101122 <console_putc+0x8a>
        }
    } else {
        *cp->cursor++ = c | color;
    }
}
  10114d:	eb 24                	jmp    101173 <console_putc+0xdb>
        *cp->cursor++ = c | color;
  10114f:	0f b6 45 e7          	movzbl -0x19(%rbp),%eax
  101153:	8b 55 e0             	mov    -0x20(%rbp),%edx
  101156:	09 d0                	or     %edx,%eax
  101158:	89 c6                	mov    %eax,%esi
  10115a:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  10115e:	48 8b 40 08          	mov    0x8(%rax),%rax
  101162:	48 8d 48 02          	lea    0x2(%rax),%rcx
  101166:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  10116a:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  10116e:	89 f2                	mov    %esi,%edx
  101170:	66 89 10             	mov    %dx,(%rax)
}
  101173:	90                   	nop
  101174:	c9                   	leave
  101175:	c3                   	ret

0000000000101176 <console_vprintf>:

int console_vprintf(int cpos, int color, const char* format, va_list val) {
  101176:	55                   	push   %rbp
  101177:	48 89 e5             	mov    %rsp,%rbp
  10117a:	48 83 ec 30          	sub    $0x30,%rsp
  10117e:	89 7d ec             	mov    %edi,-0x14(%rbp)
  101181:	89 75 e8             	mov    %esi,-0x18(%rbp)
  101184:	48 89 55 e0          	mov    %rdx,-0x20(%rbp)
  101188:	48 89 4d d8          	mov    %rcx,-0x28(%rbp)
    struct console_printer cp;
    cp.p.putc = console_putc;
  10118c:	48 c7 45 f0 98 10 10 	movq   $0x101098,-0x10(%rbp)
  101193:	00 
    if (cpos < 0 || cpos >= CONSOLE_ROWS * CONSOLE_COLUMNS) {
  101194:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  101198:	78 09                	js     1011a3 <console_vprintf+0x2d>
  10119a:	81 7d ec cf 07 00 00 	cmpl   $0x7cf,-0x14(%rbp)
  1011a1:	7e 07                	jle    1011aa <console_vprintf+0x34>
        cpos = 0;
  1011a3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%rbp)
    }
    cp.cursor = console + cpos;
  1011aa:	8b 45 ec             	mov    -0x14(%rbp),%eax
  1011ad:	48 98                	cltq
  1011af:	48 01 c0             	add    %rax,%rax
  1011b2:	48 05 00 80 0b 00    	add    $0xb8000,%rax
  1011b8:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    printer_vprintf(&cp.p, color, format, val);
  1011bc:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
  1011c0:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  1011c4:	8b 75 e8             	mov    -0x18(%rbp),%esi
  1011c7:	48 8d 45 f0          	lea    -0x10(%rbp),%rax
  1011cb:	48 89 c7             	mov    %rax,%rdi
  1011ce:	e8 4d f4 ff ff       	call   100620 <printer_vprintf>
    return cp.cursor - console;
  1011d3:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  1011d7:	48 2d 00 80 0b 00    	sub    $0xb8000,%rax
  1011dd:	48 d1 f8             	sar    $1,%rax
}
  1011e0:	c9                   	leave
  1011e1:	c3                   	ret

00000000001011e2 <console_printf>:

int console_printf(int cpos, int color, const char* format, ...) {
  1011e2:	55                   	push   %rbp
  1011e3:	48 89 e5             	mov    %rsp,%rbp
  1011e6:	48 83 ec 60          	sub    $0x60,%rsp
  1011ea:	89 7d ac             	mov    %edi,-0x54(%rbp)
  1011ed:	89 75 a8             	mov    %esi,-0x58(%rbp)
  1011f0:	48 89 55 a0          	mov    %rdx,-0x60(%rbp)
  1011f4:	48 89 4d e8          	mov    %rcx,-0x18(%rbp)
  1011f8:	4c 89 45 f0          	mov    %r8,-0x10(%rbp)
  1011fc:	4c 89 4d f8          	mov    %r9,-0x8(%rbp)
    va_list val;
    va_start(val, format);
  101200:	c7 45 b8 18 00 00 00 	movl   $0x18,-0x48(%rbp)
  101207:	48 8d 45 10          	lea    0x10(%rbp),%rax
  10120b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  10120f:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
  101213:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    cpos = console_vprintf(cpos, color, format, val);
  101217:	48 8d 4d b8          	lea    -0x48(%rbp),%rcx
  10121b:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  10121f:	8b 75 a8             	mov    -0x58(%rbp),%esi
  101222:	8b 45 ac             	mov    -0x54(%rbp),%eax
  101225:	89 c7                	mov    %eax,%edi
  101227:	e8 4a ff ff ff       	call   101176 <console_vprintf>
  10122c:	89 45 ac             	mov    %eax,-0x54(%rbp)
    va_end(val);
    return cpos;
  10122f:	8b 45 ac             	mov    -0x54(%rbp),%eax
}
  101232:	c9                   	leave
  101233:	c3                   	ret

0000000000101234 <string_putc>:
    printer p;
    char* s;
    char* end;
} string_printer;

static void string_putc(printer* p, unsigned char c, int color) {
  101234:	55                   	push   %rbp
  101235:	48 89 e5             	mov    %rsp,%rbp
  101238:	48 83 ec 20          	sub    $0x20,%rsp
  10123c:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  101240:	40 88 75 e7          	mov    %sil,-0x19(%rbp)
  101244:	89 55 e0             	mov    %edx,-0x20(%rbp)
    string_printer* sp = (string_printer*) p;
  101247:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  10124b:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    if (sp->s < sp->end) {
  10124f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  101253:	48 8b 50 08          	mov    0x8(%rax),%rdx
  101257:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  10125b:	48 8b 40 10          	mov    0x10(%rax),%rax
  10125f:	48 39 c2             	cmp    %rax,%rdx
  101262:	73 1a                	jae    10127e <string_putc+0x4a>
        *sp->s++ = c;
  101264:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  101268:	48 8b 40 08          	mov    0x8(%rax),%rax
  10126c:	48 8d 48 01          	lea    0x1(%rax),%rcx
  101270:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  101274:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  101278:	0f b6 55 e7          	movzbl -0x19(%rbp),%edx
  10127c:	88 10                	mov    %dl,(%rax)
    }
    (void) color;
}
  10127e:	90                   	nop
  10127f:	c9                   	leave
  101280:	c3                   	ret

0000000000101281 <vsnprintf>:

int vsnprintf(char* s, size_t size, const char* format, va_list val) {
  101281:	55                   	push   %rbp
  101282:	48 89 e5             	mov    %rsp,%rbp
  101285:	48 83 ec 40          	sub    $0x40,%rsp
  101289:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  10128d:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  101291:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  101295:	48 89 4d c0          	mov    %rcx,-0x40(%rbp)
    string_printer sp;
    sp.p.putc = string_putc;
  101299:	48 c7 45 e8 34 12 10 	movq   $0x101234,-0x18(%rbp)
  1012a0:	00 
    sp.s = s;
  1012a1:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  1012a5:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
    if (size) {
  1012a9:	48 83 7d d0 00       	cmpq   $0x0,-0x30(%rbp)
  1012ae:	74 33                	je     1012e3 <vsnprintf+0x62>
        sp.end = s + size - 1;
  1012b0:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  1012b4:	48 8d 50 ff          	lea    -0x1(%rax),%rdx
  1012b8:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  1012bc:	48 01 d0             	add    %rdx,%rax
  1012bf:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
        printer_vprintf(&sp.p, 0, format, val);
  1012c3:	48 8b 4d c0          	mov    -0x40(%rbp),%rcx
  1012c7:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  1012cb:	48 8d 45 e8          	lea    -0x18(%rbp),%rax
  1012cf:	be 00 00 00 00       	mov    $0x0,%esi
  1012d4:	48 89 c7             	mov    %rax,%rdi
  1012d7:	e8 44 f3 ff ff       	call   100620 <printer_vprintf>
        *sp.s = 0;
  1012dc:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  1012e0:	c6 00 00             	movb   $0x0,(%rax)
    }
    return sp.s - s;
  1012e3:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  1012e7:	48 2b 45 d8          	sub    -0x28(%rbp),%rax
}
  1012eb:	c9                   	leave
  1012ec:	c3                   	ret

00000000001012ed <snprintf>:

int snprintf(char* s, size_t size, const char* format, ...) {
  1012ed:	55                   	push   %rbp
  1012ee:	48 89 e5             	mov    %rsp,%rbp
  1012f1:	48 83 ec 70          	sub    $0x70,%rsp
  1012f5:	48 89 7d a8          	mov    %rdi,-0x58(%rbp)
  1012f9:	48 89 75 a0          	mov    %rsi,-0x60(%rbp)
  1012fd:	48 89 55 98          	mov    %rdx,-0x68(%rbp)
  101301:	48 89 4d e8          	mov    %rcx,-0x18(%rbp)
  101305:	4c 89 45 f0          	mov    %r8,-0x10(%rbp)
  101309:	4c 89 4d f8          	mov    %r9,-0x8(%rbp)
    va_list val;
    va_start(val, format);
  10130d:	c7 45 b0 18 00 00 00 	movl   $0x18,-0x50(%rbp)
  101314:	48 8d 45 10          	lea    0x10(%rbp),%rax
  101318:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  10131c:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
  101320:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
    int n = vsnprintf(s, size, format, val);
  101324:	48 8d 4d b0          	lea    -0x50(%rbp),%rcx
  101328:	48 8b 55 98          	mov    -0x68(%rbp),%rdx
  10132c:	48 8b 75 a0          	mov    -0x60(%rbp),%rsi
  101330:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  101334:	48 89 c7             	mov    %rax,%rdi
  101337:	e8 45 ff ff ff       	call   101281 <vsnprintf>
  10133c:	89 45 cc             	mov    %eax,-0x34(%rbp)
    va_end(val);
    return n;
  10133f:	8b 45 cc             	mov    -0x34(%rbp),%eax
}
  101342:	c9                   	leave
  101343:	c3                   	ret

0000000000101344 <console_clear>:


// console_clear
//    Erases the console and moves the cursor to the upper left (CPOS(0, 0)).

void console_clear(void) {
  101344:	55                   	push   %rbp
  101345:	48 89 e5             	mov    %rsp,%rbp
  101348:	48 83 ec 10          	sub    $0x10,%rsp
    for (int i = 0; i < CONSOLE_ROWS * CONSOLE_COLUMNS; ++i) {
  10134c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  101353:	eb 13                	jmp    101368 <console_clear+0x24>
        console[i] = ' ' | 0x0700;
  101355:	8b 45 fc             	mov    -0x4(%rbp),%eax
  101358:	48 98                	cltq
  10135a:	66 c7 84 00 00 80 0b 	movw   $0x720,0xb8000(%rax,%rax,1)
  101361:	00 20 07 
    for (int i = 0; i < CONSOLE_ROWS * CONSOLE_COLUMNS; ++i) {
  101364:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  101368:	81 7d fc cf 07 00 00 	cmpl   $0x7cf,-0x4(%rbp)
  10136f:	7e e4                	jle    101355 <console_clear+0x11>
    }
    cursorpos = 0;
  101371:	c7 05 81 7c fb ff 00 	movl   $0x0,-0x4837f(%rip)        # b8ffc <cursorpos>
  101378:	00 00 00 
}
  10137b:	90                   	nop
  10137c:	c9                   	leave
  10137d:	c3                   	ret
