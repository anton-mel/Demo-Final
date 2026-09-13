
obj/p-allocator.full:     file format elf64-x86-64


Disassembly of section .text:

00000000001c0000 <process_main>:
uint8_t *heap_bottom;
uint8_t *stack_bottom;



void process_main(void) {
  1c0000:	55                   	push   %rbp
  1c0001:	48 89 e5             	mov    %rsp,%rbp
  1c0004:	53                   	push   %rbx
  1c0005:	48 83 ec 08          	sub    $0x8,%rsp

// getpid
//    Return current process ID.
static inline pid_t getpid(void) {
    pid_t result;
    asm volatile ("int %1" : "=a" (result)
  1c0009:	cd 31                	int    $0x31
  1c000b:	89 c3                	mov    %eax,%ebx
    pid_t p = getpid();
    srand(p);
  1c000d:	89 c7                	mov    %eax,%edi
  1c000f:	e8 07 05 00 00       	call   1c051b <srand>
    heap_bottom = heap_top = ROUNDUP((uint8_t*) end, PAGESIZE);
  1c0014:	b8 27 30 1c 00       	mov    $0x1c3027,%eax
  1c0019:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  1c001f:	48 89 05 ea 1f 00 00 	mov    %rax,0x1fea(%rip)        # 1c2010 <heap_top>
  1c0026:	48 89 05 db 1f 00 00 	mov    %rax,0x1fdb(%rip)        # 1c2008 <heap_bottom>
    return rbp;
}

static inline uintptr_t read_rsp(void) {
    uintptr_t rsp;
    asm volatile("movq %%rsp,%0" : "=r" (rsp));
  1c002d:	48 89 e2             	mov    %rsp,%rdx
    stack_bottom = ROUNDDOWN((uint8_t*) read_rsp() - 1, PAGESIZE);
  1c0030:	48 83 ea 01          	sub    $0x1,%rdx
  1c0034:	48 81 e2 00 f0 ff ff 	and    $0xfffffffffffff000,%rdx
  1c003b:	48 89 15 be 1f 00 00 	mov    %rdx,0x1fbe(%rip)        # 1c2000 <stack_bottom>

    while(heap_top + PAGESIZE < stack_bottom) {
  1c0042:	48 05 00 10 00 00    	add    $0x1000,%rax
  1c0048:	48 39 d0             	cmp    %rdx,%rax
  1c004b:	73 3a                	jae    1c0087 <process_main+0x87>
//     On success, sbrk() returns the previous program break
//     (If the break was increased, then this value is a pointer to the start of the newly allocated memory)
//      On error, (void *) -1 is returned
static inline void * sbrk(const intptr_t increment) {
    static void * result;
    asm volatile ("int %1" :  "=a" (result)
  1c004d:	bf 00 10 00 00       	mov    $0x1000,%edi
  1c0052:	cd 3a                	int    $0x3a
  1c0054:	48 89 05 bd 1f 00 00 	mov    %rax,0x1fbd(%rip)        # 1c2018 <result.0>

        void * ret = sbrk(PAGESIZE);
        if(ret == (void *) -1) break;
  1c005b:	48 83 f8 ff          	cmp    $0xffffffffffffffff,%rax
  1c005f:	74 26                	je     1c0087 <process_main+0x87>

        *heap_top = p;      /* check we have write access to new page */
  1c0061:	48 8b 15 a8 1f 00 00 	mov    0x1fa8(%rip),%rdx        # 1c2010 <heap_top>
  1c0068:	88 1a                	mov    %bl,(%rdx)
        heap_top = (uint8_t *)ret + PAGESIZE;
  1c006a:	48 8d 90 00 10 00 00 	lea    0x1000(%rax),%rdx
  1c0071:	48 89 15 98 1f 00 00 	mov    %rdx,0x1f98(%rip)        # 1c2010 <heap_top>
    while(heap_top + PAGESIZE < stack_bottom) {
  1c0078:	48 05 00 20 00 00    	add    $0x2000,%rax
  1c007e:	48 3b 05 7b 1f 00 00 	cmp    0x1f7b(%rip),%rax        # 1c2000 <stack_bottom>
  1c0085:	72 cb                	jb     1c0052 <process_main+0x52>
    }

    TEST_PASS();
  1c0087:	bf 20 13 1c 00       	mov    $0x1c1320,%edi
  1c008c:	b8 00 00 00 00       	mov    $0x0,%eax
  1c0091:	e8 90 00 00 00       	call   1c0126 <kernel_panic>

00000000001c0096 <app_printf>:
#include "process.h"

// app_printf
//     A version of console_printf that picks a sensible color by process ID.

void app_printf(int colorid, const char* format, ...) {
  1c0096:	55                   	push   %rbp
  1c0097:	48 89 e5             	mov    %rsp,%rbp
  1c009a:	48 83 ec 50          	sub    $0x50,%rsp
  1c009e:	49 89 f2             	mov    %rsi,%r10
  1c00a1:	48 89 55 e0          	mov    %rdx,-0x20(%rbp)
  1c00a5:	48 89 4d e8          	mov    %rcx,-0x18(%rbp)
  1c00a9:	4c 89 45 f0          	mov    %r8,-0x10(%rbp)
  1c00ad:	4c 89 4d f8          	mov    %r9,-0x8(%rbp)
    int color;
    if (colorid < 0) {
        color = 0x0700;
  1c00b1:	be 00 07 00 00       	mov    $0x700,%esi
    if (colorid < 0) {
  1c00b6:	85 ff                	test   %edi,%edi
  1c00b8:	78 2e                	js     1c00e8 <app_printf+0x52>
    } else {
        static const uint8_t col[] = { 0x0E, 0x0F, 0x0C, 0x0A, 0x09 };
        color = col[colorid % sizeof(col)] << 8;
  1c00ba:	48 63 ff             	movslq %edi,%rdi
  1c00bd:	48 ba cd cc cc cc cc 	movabs $0xcccccccccccccccd,%rdx
  1c00c4:	cc cc cc 
  1c00c7:	48 89 f8             	mov    %rdi,%rax
  1c00ca:	48 f7 e2             	mul    %rdx
  1c00cd:	48 89 d0             	mov    %rdx,%rax
  1c00d0:	48 c1 e8 02          	shr    $0x2,%rax
  1c00d4:	48 83 e2 fc          	and    $0xfffffffffffffffc,%rdx
  1c00d8:	48 01 c2             	add    %rax,%rdx
  1c00db:	48 29 d7             	sub    %rdx,%rdi
  1c00de:	0f b6 b7 72 13 1c 00 	movzbl 0x1c1372(%rdi),%esi
  1c00e5:	c1 e6 08             	shl    $0x8,%esi
    }

    va_list val;
    va_start(val, format);
  1c00e8:	c7 45 b8 10 00 00 00 	movl   $0x10,-0x48(%rbp)
  1c00ef:	48 8d 45 10          	lea    0x10(%rbp),%rax
  1c00f3:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  1c00f7:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
  1c00fb:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    cursorpos = console_vprintf(cursorpos, color, format, val);
  1c00ff:	48 8d 4d b8          	lea    -0x48(%rbp),%rcx
  1c0103:	4c 89 d2             	mov    %r10,%rdx
  1c0106:	8b 3d f0 8e ef ff    	mov    -0x107110(%rip),%edi        # b8ffc <cursorpos>
  1c010c:	e8 03 10 00 00       	call   1c1114 <console_vprintf>
    va_end(val);

    if (CROW(cursorpos) >= 23) {
        cursorpos = CPOS(0, 0);
  1c0111:	3d 30 07 00 00       	cmp    $0x730,%eax
  1c0116:	ba 00 00 00 00       	mov    $0x0,%edx
  1c011b:	0f 4d c2             	cmovge %edx,%eax
  1c011e:	89 05 d8 8e ef ff    	mov    %eax,-0x107128(%rip)        # b8ffc <cursorpos>
    }
}
  1c0124:	c9                   	leave
  1c0125:	c3                   	ret

00000000001c0126 <kernel_panic>:


// kernel_panic, assert_fail
//     Call the INT_SYS_PANIC system call so the kernel loops until Control-C.

void kernel_panic(const char* format, ...) {
  1c0126:	55                   	push   %rbp
  1c0127:	48 89 e5             	mov    %rsp,%rbp
  1c012a:	53                   	push   %rbx
  1c012b:	48 81 ec f8 00 00 00 	sub    $0xf8,%rsp
  1c0132:	48 89 fb             	mov    %rdi,%rbx
  1c0135:	48 89 75 c8          	mov    %rsi,-0x38(%rbp)
  1c0139:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
  1c013d:	48 89 4d d8          	mov    %rcx,-0x28(%rbp)
  1c0141:	4c 89 45 e0          	mov    %r8,-0x20(%rbp)
  1c0145:	4c 89 4d e8          	mov    %r9,-0x18(%rbp)
    va_list val;
    va_start(val, format);
  1c0149:	c7 45 a8 08 00 00 00 	movl   $0x8,-0x58(%rbp)
  1c0150:	48 8d 45 10          	lea    0x10(%rbp),%rax
  1c0154:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
  1c0158:	48 8d 45 c0          	lea    -0x40(%rbp),%rax
  1c015c:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
    char buf[160];
    memcpy(buf, "PANIC: ", 7);
  1c0160:	48 8d bd 08 ff ff ff 	lea    -0xf8(%rbp),%rdi
  1c0167:	ba 07 00 00 00       	mov    $0x7,%edx
  1c016c:	be 65 13 1c 00       	mov    $0x1c1365,%esi
  1c0171:	e8 ae 00 00 00       	call   1c0224 <memcpy>
    int len = vsnprintf(&buf[7], sizeof(buf) - 7, format, val) + 7;
  1c0176:	48 8d 4d a8          	lea    -0x58(%rbp),%rcx
  1c017a:	48 8d bd 0f ff ff ff 	lea    -0xf1(%rbp),%rdi
  1c0181:	48 89 da             	mov    %rbx,%rdx
  1c0184:	be 99 00 00 00       	mov    $0x99,%esi
  1c0189:	e8 91 10 00 00       	call   1c121f <vsnprintf>
  1c018e:	8d 50 07             	lea    0x7(%rax),%edx
    va_end(val);
    if (len > 0 && buf[len - 1] != '\n') {
  1c0191:	85 d2                	test   %edx,%edx
  1c0193:	7e 0f                	jle    1c01a4 <kernel_panic+0x7e>
  1c0195:	83 c0 06             	add    $0x6,%eax
  1c0198:	48 98                	cltq
  1c019a:	80 bc 05 08 ff ff ff 	cmpb   $0xa,-0xf8(%rbp,%rax,1)
  1c01a1:	0a 
  1c01a2:	75 2a                	jne    1c01ce <kernel_panic+0xa8>
        strcpy(buf + len - (len == (int) sizeof(buf) - 1), "\n");
    }
    (void) console_printf(CPOS(23, 0), 0xC000, "%s", buf);
  1c01a4:	48 8d 9d 08 ff ff ff 	lea    -0xf8(%rbp),%rbx
  1c01ab:	48 89 d9             	mov    %rbx,%rcx
  1c01ae:	ba 6f 13 1c 00       	mov    $0x1c136f,%edx
  1c01b3:	be 00 c0 00 00       	mov    $0xc000,%esi
  1c01b8:	bf 30 07 00 00       	mov    $0x730,%edi
  1c01bd:	b8 00 00 00 00       	mov    $0x0,%eax
  1c01c2:	e8 b9 0f 00 00       	call   1c1180 <console_printf>
    asm volatile ("int %0" : /* no result */
  1c01c7:	48 89 df             	mov    %rbx,%rdi
  1c01ca:	cd 30                	int    $0x30
 loop: goto loop;
  1c01cc:	eb fe                	jmp    1c01cc <kernel_panic+0xa6>
        strcpy(buf + len - (len == (int) sizeof(buf) - 1), "\n");
  1c01ce:	48 63 c2             	movslq %edx,%rax
  1c01d1:	81 fa 9f 00 00 00    	cmp    $0x9f,%edx
  1c01d7:	0f 94 c2             	sete   %dl
  1c01da:	0f b6 d2             	movzbl %dl,%edx
  1c01dd:	48 29 d0             	sub    %rdx,%rax
  1c01e0:	48 8d bc 05 08 ff ff 	lea    -0xf8(%rbp,%rax,1),%rdi
  1c01e7:	ff 
  1c01e8:	be 6d 13 1c 00       	mov    $0x1c136d,%esi
  1c01ed:	e8 df 01 00 00       	call   1c03d1 <strcpy>
  1c01f2:	eb b0                	jmp    1c01a4 <kernel_panic+0x7e>

00000000001c01f4 <assert_fail>:
    panic(buf);
 spinloop: goto spinloop;       // should never get here
}

void assert_fail(const char* file, int line, const char* msg) {
  1c01f4:	55                   	push   %rbp
  1c01f5:	48 89 e5             	mov    %rsp,%rbp
  1c01f8:	48 89 f9             	mov    %rdi,%rcx
  1c01fb:	41 89 f0             	mov    %esi,%r8d
  1c01fe:	49 89 d1             	mov    %rdx,%r9
    (void) console_printf(CPOS(23, 0), 0xC000,
  1c0201:	ba 40 13 1c 00       	mov    $0x1c1340,%edx
  1c0206:	be 00 c0 00 00       	mov    $0xc000,%esi
  1c020b:	bf 30 07 00 00       	mov    $0x730,%edi
  1c0210:	b8 00 00 00 00       	mov    $0x0,%eax
  1c0215:	e8 66 0f 00 00       	call   1c1180 <console_printf>
    asm volatile ("int %0" : /* no result */
  1c021a:	bf 00 00 00 00       	mov    $0x0,%edi
  1c021f:	cd 30                	int    $0x30
  1c0221:	90                   	nop
 loop: goto loop;
  1c0222:	eb fe                	jmp    1c0222 <assert_fail+0x2e>

00000000001c0224 <memcpy>:


// memcpy, memmove, memset, strcmp, strlen, strnlen
//    We must provide our own implementations.

void* memcpy(void* dst, const void* src, size_t n) {
  1c0224:	55                   	push   %rbp
  1c0225:	48 89 e5             	mov    %rsp,%rbp
  1c0228:	48 83 ec 28          	sub    $0x28,%rsp
  1c022c:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  1c0230:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  1c0234:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
    const char* s = (const char*) src;
  1c0238:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  1c023c:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    for (char* d = (char*) dst; n > 0; --n, ++s, ++d) {
  1c0240:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  1c0244:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  1c0248:	eb 1c                	jmp    1c0266 <memcpy+0x42>
        *d = *s;
  1c024a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  1c024e:	0f b6 10             	movzbl (%rax),%edx
  1c0251:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  1c0255:	88 10                	mov    %dl,(%rax)
    for (char* d = (char*) dst; n > 0; --n, ++s, ++d) {
  1c0257:	48 83 6d d8 01       	subq   $0x1,-0x28(%rbp)
  1c025c:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  1c0261:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
  1c0266:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  1c026b:	75 dd                	jne    1c024a <memcpy+0x26>
    }
    return dst;
  1c026d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
  1c0271:	c9                   	leave
  1c0272:	c3                   	ret

00000000001c0273 <memmove>:

void* memmove(void* dst, const void* src, size_t n) {
  1c0273:	55                   	push   %rbp
  1c0274:	48 89 e5             	mov    %rsp,%rbp
  1c0277:	48 83 ec 28          	sub    $0x28,%rsp
  1c027b:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  1c027f:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  1c0283:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
    const char* s = (const char*) src;
  1c0287:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  1c028b:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    char* d = (char*) dst;
  1c028f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  1c0293:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
    if (s < d && s + n > d) {
  1c0297:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  1c029b:	48 3b 45 f0          	cmp    -0x10(%rbp),%rax
  1c029f:	73 6a                	jae    1c030b <memmove+0x98>
  1c02a1:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  1c02a5:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  1c02a9:	48 01 d0             	add    %rdx,%rax
  1c02ac:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
  1c02b0:	73 59                	jae    1c030b <memmove+0x98>
        s += n, d += n;
  1c02b2:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  1c02b6:	48 01 45 f8          	add    %rax,-0x8(%rbp)
  1c02ba:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  1c02be:	48 01 45 f0          	add    %rax,-0x10(%rbp)
        while (n-- > 0) {
  1c02c2:	eb 17                	jmp    1c02db <memmove+0x68>
            *--d = *--s;
  1c02c4:	48 83 6d f8 01       	subq   $0x1,-0x8(%rbp)
  1c02c9:	48 83 6d f0 01       	subq   $0x1,-0x10(%rbp)
  1c02ce:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  1c02d2:	0f b6 10             	movzbl (%rax),%edx
  1c02d5:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  1c02d9:	88 10                	mov    %dl,(%rax)
        while (n-- > 0) {
  1c02db:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  1c02df:	48 8d 50 ff          	lea    -0x1(%rax),%rdx
  1c02e3:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  1c02e7:	48 85 c0             	test   %rax,%rax
  1c02ea:	75 d8                	jne    1c02c4 <memmove+0x51>
    if (s < d && s + n > d) {
  1c02ec:	eb 2e                	jmp    1c031c <memmove+0xa9>
        }
    } else {
        while (n-- > 0) {
            *d++ = *s++;
  1c02ee:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  1c02f2:	48 8d 42 01          	lea    0x1(%rdx),%rax
  1c02f6:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  1c02fa:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  1c02fe:	48 8d 48 01          	lea    0x1(%rax),%rcx
  1c0302:	48 89 4d f0          	mov    %rcx,-0x10(%rbp)
  1c0306:	0f b6 12             	movzbl (%rdx),%edx
  1c0309:	88 10                	mov    %dl,(%rax)
        while (n-- > 0) {
  1c030b:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  1c030f:	48 8d 50 ff          	lea    -0x1(%rax),%rdx
  1c0313:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  1c0317:	48 85 c0             	test   %rax,%rax
  1c031a:	75 d2                	jne    1c02ee <memmove+0x7b>
        }
    }
    return dst;
  1c031c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
  1c0320:	c9                   	leave
  1c0321:	c3                   	ret

00000000001c0322 <memset>:

void* memset(void* v, int c, size_t n) {
  1c0322:	55                   	push   %rbp
  1c0323:	48 89 e5             	mov    %rsp,%rbp
  1c0326:	48 83 ec 28          	sub    $0x28,%rsp
  1c032a:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  1c032e:	89 75 e4             	mov    %esi,-0x1c(%rbp)
  1c0331:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
    for (char* p = (char*) v; n > 0; ++p, --n) {
  1c0335:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  1c0339:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  1c033d:	eb 15                	jmp    1c0354 <memset+0x32>
        *p = c;
  1c033f:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  1c0342:	89 c2                	mov    %eax,%edx
  1c0344:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  1c0348:	88 10                	mov    %dl,(%rax)
    for (char* p = (char*) v; n > 0; ++p, --n) {
  1c034a:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  1c034f:	48 83 6d d8 01       	subq   $0x1,-0x28(%rbp)
  1c0354:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  1c0359:	75 e4                	jne    1c033f <memset+0x1d>
    }
    return v;
  1c035b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
  1c035f:	c9                   	leave
  1c0360:	c3                   	ret

00000000001c0361 <strlen>:

size_t strlen(const char* s) {
  1c0361:	55                   	push   %rbp
  1c0362:	48 89 e5             	mov    %rsp,%rbp
  1c0365:	48 83 ec 18          	sub    $0x18,%rsp
  1c0369:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
    size_t n;
    for (n = 0; *s != '\0'; ++s) {
  1c036d:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
  1c0374:	00 
  1c0375:	eb 0a                	jmp    1c0381 <strlen+0x20>
        ++n;
  1c0377:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
    for (n = 0; *s != '\0'; ++s) {
  1c037c:	48 83 45 e8 01       	addq   $0x1,-0x18(%rbp)
  1c0381:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  1c0385:	0f b6 00             	movzbl (%rax),%eax
  1c0388:	84 c0                	test   %al,%al
  1c038a:	75 eb                	jne    1c0377 <strlen+0x16>
    }
    return n;
  1c038c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  1c0390:	c9                   	leave
  1c0391:	c3                   	ret

00000000001c0392 <strnlen>:

size_t strnlen(const char* s, size_t maxlen) {
  1c0392:	55                   	push   %rbp
  1c0393:	48 89 e5             	mov    %rsp,%rbp
  1c0396:	48 83 ec 20          	sub    $0x20,%rsp
  1c039a:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  1c039e:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
    size_t n;
    for (n = 0; n != maxlen && *s != '\0'; ++s) {
  1c03a2:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
  1c03a9:	00 
  1c03aa:	eb 0a                	jmp    1c03b6 <strnlen+0x24>
        ++n;
  1c03ac:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
    for (n = 0; n != maxlen && *s != '\0'; ++s) {
  1c03b1:	48 83 45 e8 01       	addq   $0x1,-0x18(%rbp)
  1c03b6:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  1c03ba:	48 3b 45 e0          	cmp    -0x20(%rbp),%rax
  1c03be:	74 0b                	je     1c03cb <strnlen+0x39>
  1c03c0:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  1c03c4:	0f b6 00             	movzbl (%rax),%eax
  1c03c7:	84 c0                	test   %al,%al
  1c03c9:	75 e1                	jne    1c03ac <strnlen+0x1a>
    }
    return n;
  1c03cb:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  1c03cf:	c9                   	leave
  1c03d0:	c3                   	ret

00000000001c03d1 <strcpy>:

char* strcpy(char* dst, const char* src) {
  1c03d1:	55                   	push   %rbp
  1c03d2:	48 89 e5             	mov    %rsp,%rbp
  1c03d5:	48 83 ec 20          	sub    $0x20,%rsp
  1c03d9:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  1c03dd:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
    char* d = dst;
  1c03e1:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  1c03e5:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    do {
        *d++ = *src++;
  1c03e9:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  1c03ed:	48 8d 42 01          	lea    0x1(%rdx),%rax
  1c03f1:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  1c03f5:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  1c03f9:	48 8d 48 01          	lea    0x1(%rax),%rcx
  1c03fd:	48 89 4d f8          	mov    %rcx,-0x8(%rbp)
  1c0401:	0f b6 12             	movzbl (%rdx),%edx
  1c0404:	88 10                	mov    %dl,(%rax)
    } while (d[-1]);
  1c0406:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  1c040a:	48 83 e8 01          	sub    $0x1,%rax
  1c040e:	0f b6 00             	movzbl (%rax),%eax
  1c0411:	84 c0                	test   %al,%al
  1c0413:	75 d4                	jne    1c03e9 <strcpy+0x18>
    return dst;
  1c0415:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
  1c0419:	c9                   	leave
  1c041a:	c3                   	ret

00000000001c041b <strcmp>:

int strcmp(const char* a, const char* b) {
  1c041b:	55                   	push   %rbp
  1c041c:	48 89 e5             	mov    %rsp,%rbp
  1c041f:	48 83 ec 10          	sub    $0x10,%rsp
  1c0423:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  1c0427:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
    while (*a && *b && *a == *b) {
  1c042b:	eb 0a                	jmp    1c0437 <strcmp+0x1c>
        ++a, ++b;
  1c042d:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  1c0432:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
    while (*a && *b && *a == *b) {
  1c0437:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  1c043b:	0f b6 00             	movzbl (%rax),%eax
  1c043e:	84 c0                	test   %al,%al
  1c0440:	74 1d                	je     1c045f <strcmp+0x44>
  1c0442:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  1c0446:	0f b6 00             	movzbl (%rax),%eax
  1c0449:	84 c0                	test   %al,%al
  1c044b:	74 12                	je     1c045f <strcmp+0x44>
  1c044d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  1c0451:	0f b6 10             	movzbl (%rax),%edx
  1c0454:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  1c0458:	0f b6 00             	movzbl (%rax),%eax
  1c045b:	38 c2                	cmp    %al,%dl
  1c045d:	74 ce                	je     1c042d <strcmp+0x12>
    }
    return ((unsigned char) *a > (unsigned char) *b)
  1c045f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  1c0463:	0f b6 00             	movzbl (%rax),%eax
  1c0466:	89 c2                	mov    %eax,%edx
  1c0468:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  1c046c:	0f b6 00             	movzbl (%rax),%eax
  1c046f:	38 d0                	cmp    %dl,%al
  1c0471:	0f 92 c0             	setb   %al
  1c0474:	0f b6 d0             	movzbl %al,%edx
        - ((unsigned char) *a < (unsigned char) *b);
  1c0477:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  1c047b:	0f b6 00             	movzbl (%rax),%eax
  1c047e:	89 c1                	mov    %eax,%ecx
  1c0480:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  1c0484:	0f b6 00             	movzbl (%rax),%eax
  1c0487:	38 c1                	cmp    %al,%cl
  1c0489:	0f 92 c0             	setb   %al
  1c048c:	0f b6 c0             	movzbl %al,%eax
  1c048f:	29 c2                	sub    %eax,%edx
  1c0491:	89 d0                	mov    %edx,%eax
}
  1c0493:	c9                   	leave
  1c0494:	c3                   	ret

00000000001c0495 <strchr>:

char* strchr(const char* s, int c) {
  1c0495:	55                   	push   %rbp
  1c0496:	48 89 e5             	mov    %rsp,%rbp
  1c0499:	48 83 ec 10          	sub    $0x10,%rsp
  1c049d:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  1c04a1:	89 75 f4             	mov    %esi,-0xc(%rbp)
    while (*s && *s != (char) c) {
  1c04a4:	eb 05                	jmp    1c04ab <strchr+0x16>
        ++s;
  1c04a6:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
    while (*s && *s != (char) c) {
  1c04ab:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  1c04af:	0f b6 00             	movzbl (%rax),%eax
  1c04b2:	84 c0                	test   %al,%al
  1c04b4:	74 0e                	je     1c04c4 <strchr+0x2f>
  1c04b6:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  1c04ba:	0f b6 00             	movzbl (%rax),%eax
  1c04bd:	8b 55 f4             	mov    -0xc(%rbp),%edx
  1c04c0:	38 d0                	cmp    %dl,%al
  1c04c2:	75 e2                	jne    1c04a6 <strchr+0x11>
    }
    if (*s == (char) c) {
  1c04c4:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  1c04c8:	0f b6 00             	movzbl (%rax),%eax
  1c04cb:	8b 55 f4             	mov    -0xc(%rbp),%edx
  1c04ce:	38 d0                	cmp    %dl,%al
  1c04d0:	75 06                	jne    1c04d8 <strchr+0x43>
        return (char*) s;
  1c04d2:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  1c04d6:	eb 05                	jmp    1c04dd <strchr+0x48>
    } else {
        return NULL;
  1c04d8:	b8 00 00 00 00       	mov    $0x0,%eax
    }
}
  1c04dd:	c9                   	leave
  1c04de:	c3                   	ret

00000000001c04df <rand>:
// rand, srand

static int rand_seed_set;
static unsigned rand_seed;

int rand(void) {
  1c04df:	55                   	push   %rbp
  1c04e0:	48 89 e5             	mov    %rsp,%rbp
    if (!rand_seed_set) {
  1c04e3:	8b 05 37 1b 00 00    	mov    0x1b37(%rip),%eax        # 1c2020 <rand_seed_set>
  1c04e9:	85 c0                	test   %eax,%eax
  1c04eb:	75 0a                	jne    1c04f7 <rand+0x18>
        srand(819234718U);
  1c04ed:	bf 9e 87 d4 30       	mov    $0x30d4879e,%edi
  1c04f2:	e8 24 00 00 00       	call   1c051b <srand>
    }
    rand_seed = rand_seed * 1664525U + 1013904223U;
  1c04f7:	8b 05 27 1b 00 00    	mov    0x1b27(%rip),%eax        # 1c2024 <rand_seed>
  1c04fd:	69 c0 0d 66 19 00    	imul   $0x19660d,%eax,%eax
  1c0503:	05 5f f3 6e 3c       	add    $0x3c6ef35f,%eax
  1c0508:	89 05 16 1b 00 00    	mov    %eax,0x1b16(%rip)        # 1c2024 <rand_seed>
    return rand_seed & RAND_MAX;
  1c050e:	8b 05 10 1b 00 00    	mov    0x1b10(%rip),%eax        # 1c2024 <rand_seed>
  1c0514:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
}
  1c0519:	5d                   	pop    %rbp
  1c051a:	c3                   	ret

00000000001c051b <srand>:

void srand(unsigned seed) {
  1c051b:	55                   	push   %rbp
  1c051c:	48 89 e5             	mov    %rsp,%rbp
  1c051f:	48 83 ec 08          	sub    $0x8,%rsp
  1c0523:	89 7d fc             	mov    %edi,-0x4(%rbp)
    rand_seed = seed;
  1c0526:	8b 45 fc             	mov    -0x4(%rbp),%eax
  1c0529:	89 05 f5 1a 00 00    	mov    %eax,0x1af5(%rip)        # 1c2024 <rand_seed>
    rand_seed_set = 1;
  1c052f:	c7 05 e7 1a 00 00 01 	movl   $0x1,0x1ae7(%rip)        # 1c2020 <rand_seed_set>
  1c0536:	00 00 00 
}
  1c0539:	90                   	nop
  1c053a:	c9                   	leave
  1c053b:	c3                   	ret

00000000001c053c <fill_numbuf>:
//    Print a message onto the console, starting at the given cursor position.

// snprintf, vsnprintf
//    Format a string into a buffer.

static char* fill_numbuf(char* numbuf_end, unsigned long val, int base) {
  1c053c:	55                   	push   %rbp
  1c053d:	48 89 e5             	mov    %rsp,%rbp
  1c0540:	48 83 ec 28          	sub    $0x28,%rsp
  1c0544:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  1c0548:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  1c054c:	89 55 dc             	mov    %edx,-0x24(%rbp)
    static const char upper_digits[] = "0123456789ABCDEF";
    static const char lower_digits[] = "0123456789abcdef";

    const char* digits = upper_digits;
  1c054f:	48 c7 45 f8 a0 13 1c 	movq   $0x1c13a0,-0x8(%rbp)
  1c0556:	00 
    if (base < 0) {
  1c0557:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
  1c055b:	79 0b                	jns    1c0568 <fill_numbuf+0x2c>
        digits = lower_digits;
  1c055d:	48 c7 45 f8 c0 13 1c 	movq   $0x1c13c0,-0x8(%rbp)
  1c0564:	00 
        base = -base;
  1c0565:	f7 5d dc             	negl   -0x24(%rbp)
    }

    *--numbuf_end = '\0';
  1c0568:	48 83 6d e8 01       	subq   $0x1,-0x18(%rbp)
  1c056d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  1c0571:	c6 00 00             	movb   $0x0,(%rax)
    do {
        *--numbuf_end = digits[val % base];
  1c0574:	8b 45 dc             	mov    -0x24(%rbp),%eax
  1c0577:	48 63 c8             	movslq %eax,%rcx
  1c057a:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  1c057e:	ba 00 00 00 00       	mov    $0x0,%edx
  1c0583:	48 f7 f1             	div    %rcx
  1c0586:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  1c058a:	48 01 d0             	add    %rdx,%rax
  1c058d:	48 83 6d e8 01       	subq   $0x1,-0x18(%rbp)
  1c0592:	0f b6 10             	movzbl (%rax),%edx
  1c0595:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  1c0599:	88 10                	mov    %dl,(%rax)
        val /= base;
  1c059b:	8b 45 dc             	mov    -0x24(%rbp),%eax
  1c059e:	48 63 f0             	movslq %eax,%rsi
  1c05a1:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  1c05a5:	ba 00 00 00 00       	mov    $0x0,%edx
  1c05aa:	48 f7 f6             	div    %rsi
  1c05ad:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
    } while (val != 0);
  1c05b1:	48 83 7d e0 00       	cmpq   $0x0,-0x20(%rbp)
  1c05b6:	75 bc                	jne    1c0574 <fill_numbuf+0x38>
    return numbuf_end;
  1c05b8:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
  1c05bc:	c9                   	leave
  1c05bd:	c3                   	ret

00000000001c05be <printer_vprintf>:
#define FLAG_NUMERIC            (1<<5)
#define FLAG_SIGNED             (1<<6)
#define FLAG_NEGATIVE           (1<<7)
#define FLAG_ALT2               (1<<8)

void printer_vprintf(printer* p, int color, const char* format, va_list val) {
  1c05be:	55                   	push   %rbp
  1c05bf:	48 89 e5             	mov    %rsp,%rbp
  1c05c2:	53                   	push   %rbx
  1c05c3:	48 81 ec 98 00 00 00 	sub    $0x98,%rsp
  1c05ca:	48 89 bd 78 ff ff ff 	mov    %rdi,-0x88(%rbp)
  1c05d1:	89 b5 74 ff ff ff    	mov    %esi,-0x8c(%rbp)
  1c05d7:	48 89 95 68 ff ff ff 	mov    %rdx,-0x98(%rbp)
  1c05de:	48 89 8d 60 ff ff ff 	mov    %rcx,-0xa0(%rbp)
#define NUMBUFSIZ 24
    char numbuf[NUMBUFSIZ];

    for (; *format; ++format) {
  1c05e5:	e9 32 0a 00 00       	jmp    1c101c <printer_vprintf+0xa5e>
        if (*format != '%') {
  1c05ea:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  1c05f1:	0f b6 00             	movzbl (%rax),%eax
  1c05f4:	3c 25                	cmp    $0x25,%al
  1c05f6:	74 31                	je     1c0629 <printer_vprintf+0x6b>
            p->putc(p, *format, color);
  1c05f8:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  1c05ff:	4c 8b 00             	mov    (%rax),%r8
  1c0602:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  1c0609:	0f b6 00             	movzbl (%rax),%eax
  1c060c:	8b 95 74 ff ff ff    	mov    -0x8c(%rbp),%edx
  1c0612:	0f b6 c8             	movzbl %al,%ecx
  1c0615:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  1c061c:	89 ce                	mov    %ecx,%esi
  1c061e:	48 89 c7             	mov    %rax,%rdi
  1c0621:	41 ff d0             	call   *%r8
            continue;
  1c0624:	e9 eb 09 00 00       	jmp    1c1014 <printer_vprintf+0xa56>
        }

        // process flags
        int flags = 0;
  1c0629:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%rbp)
        for (++format; *format; ++format) {
  1c0630:	48 83 85 68 ff ff ff 	addq   $0x1,-0x98(%rbp)
  1c0637:	01 
  1c0638:	eb 44                	jmp    1c067e <printer_vprintf+0xc0>
            const char* flagc = strchr(flag_chars, *format);
  1c063a:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  1c0641:	0f b6 00             	movzbl (%rax),%eax
  1c0644:	0f be c0             	movsbl %al,%eax
  1c0647:	89 c6                	mov    %eax,%esi
  1c0649:	bf 80 13 1c 00       	mov    $0x1c1380,%edi
  1c064e:	e8 42 fe ff ff       	call   1c0495 <strchr>
  1c0653:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
            if (flagc) {
  1c0657:	48 83 7d a8 00       	cmpq   $0x0,-0x58(%rbp)
  1c065c:	74 30                	je     1c068e <printer_vprintf+0xd0>
                flags |= 1 << (flagc - flag_chars);
  1c065e:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  1c0662:	48 2d 80 13 1c 00    	sub    $0x1c1380,%rax
  1c0668:	ba 01 00 00 00       	mov    $0x1,%edx
  1c066d:	89 c1                	mov    %eax,%ecx
  1c066f:	d3 e2                	shl    %cl,%edx
  1c0671:	89 d0                	mov    %edx,%eax
  1c0673:	09 45 ec             	or     %eax,-0x14(%rbp)
        for (++format; *format; ++format) {
  1c0676:	48 83 85 68 ff ff ff 	addq   $0x1,-0x98(%rbp)
  1c067d:	01 
  1c067e:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  1c0685:	0f b6 00             	movzbl (%rax),%eax
  1c0688:	84 c0                	test   %al,%al
  1c068a:	75 ae                	jne    1c063a <printer_vprintf+0x7c>
  1c068c:	eb 01                	jmp    1c068f <printer_vprintf+0xd1>
            } else {
                break;
  1c068e:	90                   	nop
            }
        }

        // process width
        int width = -1;
  1c068f:	c7 45 e8 ff ff ff ff 	movl   $0xffffffff,-0x18(%rbp)
        if (*format >= '1' && *format <= '9') {
  1c0696:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  1c069d:	0f b6 00             	movzbl (%rax),%eax
  1c06a0:	3c 30                	cmp    $0x30,%al
  1c06a2:	7e 67                	jle    1c070b <printer_vprintf+0x14d>
  1c06a4:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  1c06ab:	0f b6 00             	movzbl (%rax),%eax
  1c06ae:	3c 39                	cmp    $0x39,%al
  1c06b0:	7f 59                	jg     1c070b <printer_vprintf+0x14d>
            for (width = 0; *format >= '0' && *format <= '9'; ) {
  1c06b2:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%rbp)
  1c06b9:	eb 2e                	jmp    1c06e9 <printer_vprintf+0x12b>
                width = 10 * width + *format++ - '0';
  1c06bb:	8b 55 e8             	mov    -0x18(%rbp),%edx
  1c06be:	89 d0                	mov    %edx,%eax
  1c06c0:	c1 e0 02             	shl    $0x2,%eax
  1c06c3:	01 d0                	add    %edx,%eax
  1c06c5:	01 c0                	add    %eax,%eax
  1c06c7:	89 c1                	mov    %eax,%ecx
  1c06c9:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  1c06d0:	48 8d 50 01          	lea    0x1(%rax),%rdx
  1c06d4:	48 89 95 68 ff ff ff 	mov    %rdx,-0x98(%rbp)
  1c06db:	0f b6 00             	movzbl (%rax),%eax
  1c06de:	0f be c0             	movsbl %al,%eax
  1c06e1:	01 c8                	add    %ecx,%eax
  1c06e3:	83 e8 30             	sub    $0x30,%eax
  1c06e6:	89 45 e8             	mov    %eax,-0x18(%rbp)
            for (width = 0; *format >= '0' && *format <= '9'; ) {
  1c06e9:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  1c06f0:	0f b6 00             	movzbl (%rax),%eax
  1c06f3:	3c 2f                	cmp    $0x2f,%al
  1c06f5:	0f 8e 85 00 00 00    	jle    1c0780 <printer_vprintf+0x1c2>
  1c06fb:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  1c0702:	0f b6 00             	movzbl (%rax),%eax
  1c0705:	3c 39                	cmp    $0x39,%al
  1c0707:	7e b2                	jle    1c06bb <printer_vprintf+0xfd>
        if (*format >= '1' && *format <= '9') {
  1c0709:	eb 75                	jmp    1c0780 <printer_vprintf+0x1c2>
            }
        } else if (*format == '*') {
  1c070b:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  1c0712:	0f b6 00             	movzbl (%rax),%eax
  1c0715:	3c 2a                	cmp    $0x2a,%al
  1c0717:	75 68                	jne    1c0781 <printer_vprintf+0x1c3>
            width = va_arg(val, int);
  1c0719:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1c0720:	8b 00                	mov    (%rax),%eax
  1c0722:	83 f8 2f             	cmp    $0x2f,%eax
  1c0725:	77 30                	ja     1c0757 <printer_vprintf+0x199>
  1c0727:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1c072e:	48 8b 50 10          	mov    0x10(%rax),%rdx
  1c0732:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1c0739:	8b 00                	mov    (%rax),%eax
  1c073b:	89 c0                	mov    %eax,%eax
  1c073d:	48 01 d0             	add    %rdx,%rax
  1c0740:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  1c0747:	8b 12                	mov    (%rdx),%edx
  1c0749:	8d 4a 08             	lea    0x8(%rdx),%ecx
  1c074c:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  1c0753:	89 0a                	mov    %ecx,(%rdx)
  1c0755:	eb 1a                	jmp    1c0771 <printer_vprintf+0x1b3>
  1c0757:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1c075e:	48 8b 40 08          	mov    0x8(%rax),%rax
  1c0762:	48 8d 48 08          	lea    0x8(%rax),%rcx
  1c0766:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  1c076d:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  1c0771:	8b 00                	mov    (%rax),%eax
  1c0773:	89 45 e8             	mov    %eax,-0x18(%rbp)
            ++format;
  1c0776:	48 83 85 68 ff ff ff 	addq   $0x1,-0x98(%rbp)
  1c077d:	01 
  1c077e:	eb 01                	jmp    1c0781 <printer_vprintf+0x1c3>
        if (*format >= '1' && *format <= '9') {
  1c0780:	90                   	nop
        }

        // process precision
        int precision = -1;
  1c0781:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%rbp)
        if (*format == '.') {
  1c0788:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  1c078f:	0f b6 00             	movzbl (%rax),%eax
  1c0792:	3c 2e                	cmp    $0x2e,%al
  1c0794:	0f 85 00 01 00 00    	jne    1c089a <printer_vprintf+0x2dc>
            ++format;
  1c079a:	48 83 85 68 ff ff ff 	addq   $0x1,-0x98(%rbp)
  1c07a1:	01 
            if (*format >= '0' && *format <= '9') {
  1c07a2:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  1c07a9:	0f b6 00             	movzbl (%rax),%eax
  1c07ac:	3c 2f                	cmp    $0x2f,%al
  1c07ae:	7e 67                	jle    1c0817 <printer_vprintf+0x259>
  1c07b0:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  1c07b7:	0f b6 00             	movzbl (%rax),%eax
  1c07ba:	3c 39                	cmp    $0x39,%al
  1c07bc:	7f 59                	jg     1c0817 <printer_vprintf+0x259>
                for (precision = 0; *format >= '0' && *format <= '9'; ) {
  1c07be:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%rbp)
  1c07c5:	eb 2e                	jmp    1c07f5 <printer_vprintf+0x237>
                    precision = 10 * precision + *format++ - '0';
  1c07c7:	8b 55 e4             	mov    -0x1c(%rbp),%edx
  1c07ca:	89 d0                	mov    %edx,%eax
  1c07cc:	c1 e0 02             	shl    $0x2,%eax
  1c07cf:	01 d0                	add    %edx,%eax
  1c07d1:	01 c0                	add    %eax,%eax
  1c07d3:	89 c1                	mov    %eax,%ecx
  1c07d5:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  1c07dc:	48 8d 50 01          	lea    0x1(%rax),%rdx
  1c07e0:	48 89 95 68 ff ff ff 	mov    %rdx,-0x98(%rbp)
  1c07e7:	0f b6 00             	movzbl (%rax),%eax
  1c07ea:	0f be c0             	movsbl %al,%eax
  1c07ed:	01 c8                	add    %ecx,%eax
  1c07ef:	83 e8 30             	sub    $0x30,%eax
  1c07f2:	89 45 e4             	mov    %eax,-0x1c(%rbp)
                for (precision = 0; *format >= '0' && *format <= '9'; ) {
  1c07f5:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  1c07fc:	0f b6 00             	movzbl (%rax),%eax
  1c07ff:	3c 2f                	cmp    $0x2f,%al
  1c0801:	0f 8e 85 00 00 00    	jle    1c088c <printer_vprintf+0x2ce>
  1c0807:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  1c080e:	0f b6 00             	movzbl (%rax),%eax
  1c0811:	3c 39                	cmp    $0x39,%al
  1c0813:	7e b2                	jle    1c07c7 <printer_vprintf+0x209>
            if (*format >= '0' && *format <= '9') {
  1c0815:	eb 75                	jmp    1c088c <printer_vprintf+0x2ce>
                }
            } else if (*format == '*') {
  1c0817:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  1c081e:	0f b6 00             	movzbl (%rax),%eax
  1c0821:	3c 2a                	cmp    $0x2a,%al
  1c0823:	75 68                	jne    1c088d <printer_vprintf+0x2cf>
                precision = va_arg(val, int);
  1c0825:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1c082c:	8b 00                	mov    (%rax),%eax
  1c082e:	83 f8 2f             	cmp    $0x2f,%eax
  1c0831:	77 30                	ja     1c0863 <printer_vprintf+0x2a5>
  1c0833:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1c083a:	48 8b 50 10          	mov    0x10(%rax),%rdx
  1c083e:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1c0845:	8b 00                	mov    (%rax),%eax
  1c0847:	89 c0                	mov    %eax,%eax
  1c0849:	48 01 d0             	add    %rdx,%rax
  1c084c:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  1c0853:	8b 12                	mov    (%rdx),%edx
  1c0855:	8d 4a 08             	lea    0x8(%rdx),%ecx
  1c0858:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  1c085f:	89 0a                	mov    %ecx,(%rdx)
  1c0861:	eb 1a                	jmp    1c087d <printer_vprintf+0x2bf>
  1c0863:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1c086a:	48 8b 40 08          	mov    0x8(%rax),%rax
  1c086e:	48 8d 48 08          	lea    0x8(%rax),%rcx
  1c0872:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  1c0879:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  1c087d:	8b 00                	mov    (%rax),%eax
  1c087f:	89 45 e4             	mov    %eax,-0x1c(%rbp)
                ++format;
  1c0882:	48 83 85 68 ff ff ff 	addq   $0x1,-0x98(%rbp)
  1c0889:	01 
  1c088a:	eb 01                	jmp    1c088d <printer_vprintf+0x2cf>
            if (*format >= '0' && *format <= '9') {
  1c088c:	90                   	nop
            }
            if (precision < 0) {
  1c088d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%rbp)
  1c0891:	79 07                	jns    1c089a <printer_vprintf+0x2dc>
                precision = 0;
  1c0893:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%rbp)
            }
        }

        // process main conversion character
        int base = 10;
  1c089a:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%rbp)
        unsigned long num = 0;
  1c08a1:	48 c7 45 d8 00 00 00 	movq   $0x0,-0x28(%rbp)
  1c08a8:	00 
        int length = 0;
  1c08a9:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%rbp)
        char* data = "";
  1c08b0:	48 c7 45 c8 86 13 1c 	movq   $0x1c1386,-0x38(%rbp)
  1c08b7:	00 
    again:
        switch (*format) {
  1c08b8:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  1c08bf:	0f b6 00             	movzbl (%rax),%eax
  1c08c2:	0f be c0             	movsbl %al,%eax
  1c08c5:	83 f8 7a             	cmp    $0x7a,%eax
  1c08c8:	0f 84 a4 00 00 00    	je     1c0972 <printer_vprintf+0x3b4>
  1c08ce:	83 f8 7a             	cmp    $0x7a,%eax
  1c08d1:	0f 8f 3d 04 00 00    	jg     1c0d14 <printer_vprintf+0x756>
  1c08d7:	83 f8 78             	cmp    $0x78,%eax
  1c08da:	0f 84 76 02 00 00    	je     1c0b56 <printer_vprintf+0x598>
  1c08e0:	83 f8 78             	cmp    $0x78,%eax
  1c08e3:	0f 8f 2b 04 00 00    	jg     1c0d14 <printer_vprintf+0x756>
  1c08e9:	83 f8 75             	cmp    $0x75,%eax
  1c08ec:	0f 84 94 01 00 00    	je     1c0a86 <printer_vprintf+0x4c8>
  1c08f2:	83 f8 75             	cmp    $0x75,%eax
  1c08f5:	0f 8f 19 04 00 00    	jg     1c0d14 <printer_vprintf+0x756>
  1c08fb:	83 f8 73             	cmp    $0x73,%eax
  1c08fe:	0f 84 dc 02 00 00    	je     1c0be0 <printer_vprintf+0x622>
  1c0904:	83 f8 73             	cmp    $0x73,%eax
  1c0907:	0f 8f 07 04 00 00    	jg     1c0d14 <printer_vprintf+0x756>
  1c090d:	83 f8 70             	cmp    $0x70,%eax
  1c0910:	0f 84 58 02 00 00    	je     1c0b6e <printer_vprintf+0x5b0>
  1c0916:	83 f8 70             	cmp    $0x70,%eax
  1c0919:	0f 8f f5 03 00 00    	jg     1c0d14 <printer_vprintf+0x756>
  1c091f:	83 f8 6c             	cmp    $0x6c,%eax
  1c0922:	74 4e                	je     1c0972 <printer_vprintf+0x3b4>
  1c0924:	83 f8 6c             	cmp    $0x6c,%eax
  1c0927:	0f 8f e7 03 00 00    	jg     1c0d14 <printer_vprintf+0x756>
  1c092d:	83 f8 69             	cmp    $0x69,%eax
  1c0930:	74 54                	je     1c0986 <printer_vprintf+0x3c8>
  1c0932:	83 f8 69             	cmp    $0x69,%eax
  1c0935:	0f 8f d9 03 00 00    	jg     1c0d14 <printer_vprintf+0x756>
  1c093b:	83 f8 64             	cmp    $0x64,%eax
  1c093e:	74 46                	je     1c0986 <printer_vprintf+0x3c8>
  1c0940:	83 f8 64             	cmp    $0x64,%eax
  1c0943:	0f 8f cb 03 00 00    	jg     1c0d14 <printer_vprintf+0x756>
  1c0949:	83 f8 63             	cmp    $0x63,%eax
  1c094c:	0f 84 57 03 00 00    	je     1c0ca9 <printer_vprintf+0x6eb>
  1c0952:	83 f8 63             	cmp    $0x63,%eax
  1c0955:	0f 8f b9 03 00 00    	jg     1c0d14 <printer_vprintf+0x756>
  1c095b:	83 f8 43             	cmp    $0x43,%eax
  1c095e:	0f 84 e0 02 00 00    	je     1c0c44 <printer_vprintf+0x686>
  1c0964:	83 f8 58             	cmp    $0x58,%eax
  1c0967:	0f 84 f5 01 00 00    	je     1c0b62 <printer_vprintf+0x5a4>
  1c096d:	e9 a2 03 00 00       	jmp    1c0d14 <printer_vprintf+0x756>
        case 'l':
        case 'z':
            length = 1;
  1c0972:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%rbp)
            ++format;
  1c0979:	48 83 85 68 ff ff ff 	addq   $0x1,-0x98(%rbp)
  1c0980:	01 
            goto again;
  1c0981:	e9 32 ff ff ff       	jmp    1c08b8 <printer_vprintf+0x2fa>
        case 'd':
        case 'i': {
            long x = length ? va_arg(val, long) : va_arg(val, int);
  1c0986:	83 7d d4 00          	cmpl   $0x0,-0x2c(%rbp)
  1c098a:	74 61                	je     1c09ed <printer_vprintf+0x42f>
  1c098c:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1c0993:	8b 00                	mov    (%rax),%eax
  1c0995:	83 f8 2f             	cmp    $0x2f,%eax
  1c0998:	77 30                	ja     1c09ca <printer_vprintf+0x40c>
  1c099a:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1c09a1:	48 8b 50 10          	mov    0x10(%rax),%rdx
  1c09a5:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1c09ac:	8b 00                	mov    (%rax),%eax
  1c09ae:	89 c0                	mov    %eax,%eax
  1c09b0:	48 01 d0             	add    %rdx,%rax
  1c09b3:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  1c09ba:	8b 12                	mov    (%rdx),%edx
  1c09bc:	8d 4a 08             	lea    0x8(%rdx),%ecx
  1c09bf:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  1c09c6:	89 0a                	mov    %ecx,(%rdx)
  1c09c8:	eb 1a                	jmp    1c09e4 <printer_vprintf+0x426>
  1c09ca:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1c09d1:	48 8b 40 08          	mov    0x8(%rax),%rax
  1c09d5:	48 8d 48 08          	lea    0x8(%rax),%rcx
  1c09d9:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  1c09e0:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  1c09e4:	48 8b 00             	mov    (%rax),%rax
  1c09e7:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  1c09eb:	eb 60                	jmp    1c0a4d <printer_vprintf+0x48f>
  1c09ed:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1c09f4:	8b 00                	mov    (%rax),%eax
  1c09f6:	83 f8 2f             	cmp    $0x2f,%eax
  1c09f9:	77 30                	ja     1c0a2b <printer_vprintf+0x46d>
  1c09fb:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1c0a02:	48 8b 50 10          	mov    0x10(%rax),%rdx
  1c0a06:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1c0a0d:	8b 00                	mov    (%rax),%eax
  1c0a0f:	89 c0                	mov    %eax,%eax
  1c0a11:	48 01 d0             	add    %rdx,%rax
  1c0a14:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  1c0a1b:	8b 12                	mov    (%rdx),%edx
  1c0a1d:	8d 4a 08             	lea    0x8(%rdx),%ecx
  1c0a20:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  1c0a27:	89 0a                	mov    %ecx,(%rdx)
  1c0a29:	eb 1a                	jmp    1c0a45 <printer_vprintf+0x487>
  1c0a2b:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1c0a32:	48 8b 40 08          	mov    0x8(%rax),%rax
  1c0a36:	48 8d 48 08          	lea    0x8(%rax),%rcx
  1c0a3a:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  1c0a41:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  1c0a45:	8b 00                	mov    (%rax),%eax
  1c0a47:	48 98                	cltq
  1c0a49:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
            int negative = x < 0 ? FLAG_NEGATIVE : 0;
  1c0a4d:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  1c0a51:	48 c1 f8 38          	sar    $0x38,%rax
  1c0a55:	25 80 00 00 00       	and    $0x80,%eax
  1c0a5a:	89 45 a4             	mov    %eax,-0x5c(%rbp)
            num = negative ? -x : x;
  1c0a5d:	83 7d a4 00          	cmpl   $0x0,-0x5c(%rbp)
  1c0a61:	74 0d                	je     1c0a70 <printer_vprintf+0x4b2>
  1c0a63:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  1c0a67:	48 f7 d8             	neg    %rax
  1c0a6a:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
  1c0a6e:	eb 08                	jmp    1c0a78 <printer_vprintf+0x4ba>
  1c0a70:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  1c0a74:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
            flags |= FLAG_NUMERIC | FLAG_SIGNED | negative;
  1c0a78:	8b 45 a4             	mov    -0x5c(%rbp),%eax
  1c0a7b:	83 c8 60             	or     $0x60,%eax
  1c0a7e:	09 45 ec             	or     %eax,-0x14(%rbp)
            break;
  1c0a81:	e9 d3 02 00 00       	jmp    1c0d59 <printer_vprintf+0x79b>
        }
        case 'u':
        format_unsigned:
            num = length ? va_arg(val, unsigned long) : va_arg(val, unsigned);
  1c0a86:	83 7d d4 00          	cmpl   $0x0,-0x2c(%rbp)
  1c0a8a:	74 61                	je     1c0aed <printer_vprintf+0x52f>
  1c0a8c:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1c0a93:	8b 00                	mov    (%rax),%eax
  1c0a95:	83 f8 2f             	cmp    $0x2f,%eax
  1c0a98:	77 30                	ja     1c0aca <printer_vprintf+0x50c>
  1c0a9a:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1c0aa1:	48 8b 50 10          	mov    0x10(%rax),%rdx
  1c0aa5:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1c0aac:	8b 00                	mov    (%rax),%eax
  1c0aae:	89 c0                	mov    %eax,%eax
  1c0ab0:	48 01 d0             	add    %rdx,%rax
  1c0ab3:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  1c0aba:	8b 12                	mov    (%rdx),%edx
  1c0abc:	8d 4a 08             	lea    0x8(%rdx),%ecx
  1c0abf:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  1c0ac6:	89 0a                	mov    %ecx,(%rdx)
  1c0ac8:	eb 1a                	jmp    1c0ae4 <printer_vprintf+0x526>
  1c0aca:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1c0ad1:	48 8b 40 08          	mov    0x8(%rax),%rax
  1c0ad5:	48 8d 48 08          	lea    0x8(%rax),%rcx
  1c0ad9:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  1c0ae0:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  1c0ae4:	48 8b 00             	mov    (%rax),%rax
  1c0ae7:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
  1c0aeb:	eb 60                	jmp    1c0b4d <printer_vprintf+0x58f>
  1c0aed:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1c0af4:	8b 00                	mov    (%rax),%eax
  1c0af6:	83 f8 2f             	cmp    $0x2f,%eax
  1c0af9:	77 30                	ja     1c0b2b <printer_vprintf+0x56d>
  1c0afb:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1c0b02:	48 8b 50 10          	mov    0x10(%rax),%rdx
  1c0b06:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1c0b0d:	8b 00                	mov    (%rax),%eax
  1c0b0f:	89 c0                	mov    %eax,%eax
  1c0b11:	48 01 d0             	add    %rdx,%rax
  1c0b14:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  1c0b1b:	8b 12                	mov    (%rdx),%edx
  1c0b1d:	8d 4a 08             	lea    0x8(%rdx),%ecx
  1c0b20:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  1c0b27:	89 0a                	mov    %ecx,(%rdx)
  1c0b29:	eb 1a                	jmp    1c0b45 <printer_vprintf+0x587>
  1c0b2b:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1c0b32:	48 8b 40 08          	mov    0x8(%rax),%rax
  1c0b36:	48 8d 48 08          	lea    0x8(%rax),%rcx
  1c0b3a:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  1c0b41:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  1c0b45:	8b 00                	mov    (%rax),%eax
  1c0b47:	89 c0                	mov    %eax,%eax
  1c0b49:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
            flags |= FLAG_NUMERIC;
  1c0b4d:	83 4d ec 20          	orl    $0x20,-0x14(%rbp)
            break;
  1c0b51:	e9 03 02 00 00       	jmp    1c0d59 <printer_vprintf+0x79b>
        case 'x':
            base = -16;
  1c0b56:	c7 45 e0 f0 ff ff ff 	movl   $0xfffffff0,-0x20(%rbp)
            goto format_unsigned;
  1c0b5d:	e9 24 ff ff ff       	jmp    1c0a86 <printer_vprintf+0x4c8>
        case 'X':
            base = 16;
  1c0b62:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%rbp)
            goto format_unsigned;
  1c0b69:	e9 18 ff ff ff       	jmp    1c0a86 <printer_vprintf+0x4c8>
        case 'p':
            num = (uintptr_t) va_arg(val, void*);
  1c0b6e:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1c0b75:	8b 00                	mov    (%rax),%eax
  1c0b77:	83 f8 2f             	cmp    $0x2f,%eax
  1c0b7a:	77 30                	ja     1c0bac <printer_vprintf+0x5ee>
  1c0b7c:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1c0b83:	48 8b 50 10          	mov    0x10(%rax),%rdx
  1c0b87:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1c0b8e:	8b 00                	mov    (%rax),%eax
  1c0b90:	89 c0                	mov    %eax,%eax
  1c0b92:	48 01 d0             	add    %rdx,%rax
  1c0b95:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  1c0b9c:	8b 12                	mov    (%rdx),%edx
  1c0b9e:	8d 4a 08             	lea    0x8(%rdx),%ecx
  1c0ba1:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  1c0ba8:	89 0a                	mov    %ecx,(%rdx)
  1c0baa:	eb 1a                	jmp    1c0bc6 <printer_vprintf+0x608>
  1c0bac:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1c0bb3:	48 8b 40 08          	mov    0x8(%rax),%rax
  1c0bb7:	48 8d 48 08          	lea    0x8(%rax),%rcx
  1c0bbb:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  1c0bc2:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  1c0bc6:	48 8b 00             	mov    (%rax),%rax
  1c0bc9:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
            base = -16;
  1c0bcd:	c7 45 e0 f0 ff ff ff 	movl   $0xfffffff0,-0x20(%rbp)
            flags |= FLAG_ALT | FLAG_ALT2 | FLAG_NUMERIC;
  1c0bd4:	81 4d ec 21 01 00 00 	orl    $0x121,-0x14(%rbp)
            break;
  1c0bdb:	e9 79 01 00 00       	jmp    1c0d59 <printer_vprintf+0x79b>
        case 's':
            data = va_arg(val, char*);
  1c0be0:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1c0be7:	8b 00                	mov    (%rax),%eax
  1c0be9:	83 f8 2f             	cmp    $0x2f,%eax
  1c0bec:	77 30                	ja     1c0c1e <printer_vprintf+0x660>
  1c0bee:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1c0bf5:	48 8b 50 10          	mov    0x10(%rax),%rdx
  1c0bf9:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1c0c00:	8b 00                	mov    (%rax),%eax
  1c0c02:	89 c0                	mov    %eax,%eax
  1c0c04:	48 01 d0             	add    %rdx,%rax
  1c0c07:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  1c0c0e:	8b 12                	mov    (%rdx),%edx
  1c0c10:	8d 4a 08             	lea    0x8(%rdx),%ecx
  1c0c13:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  1c0c1a:	89 0a                	mov    %ecx,(%rdx)
  1c0c1c:	eb 1a                	jmp    1c0c38 <printer_vprintf+0x67a>
  1c0c1e:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1c0c25:	48 8b 40 08          	mov    0x8(%rax),%rax
  1c0c29:	48 8d 48 08          	lea    0x8(%rax),%rcx
  1c0c2d:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  1c0c34:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  1c0c38:	48 8b 00             	mov    (%rax),%rax
  1c0c3b:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
            break;
  1c0c3f:	e9 15 01 00 00       	jmp    1c0d59 <printer_vprintf+0x79b>
        case 'C':
            color = va_arg(val, int);
  1c0c44:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1c0c4b:	8b 00                	mov    (%rax),%eax
  1c0c4d:	83 f8 2f             	cmp    $0x2f,%eax
  1c0c50:	77 30                	ja     1c0c82 <printer_vprintf+0x6c4>
  1c0c52:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1c0c59:	48 8b 50 10          	mov    0x10(%rax),%rdx
  1c0c5d:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1c0c64:	8b 00                	mov    (%rax),%eax
  1c0c66:	89 c0                	mov    %eax,%eax
  1c0c68:	48 01 d0             	add    %rdx,%rax
  1c0c6b:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  1c0c72:	8b 12                	mov    (%rdx),%edx
  1c0c74:	8d 4a 08             	lea    0x8(%rdx),%ecx
  1c0c77:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  1c0c7e:	89 0a                	mov    %ecx,(%rdx)
  1c0c80:	eb 1a                	jmp    1c0c9c <printer_vprintf+0x6de>
  1c0c82:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1c0c89:	48 8b 40 08          	mov    0x8(%rax),%rax
  1c0c8d:	48 8d 48 08          	lea    0x8(%rax),%rcx
  1c0c91:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  1c0c98:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  1c0c9c:	8b 00                	mov    (%rax),%eax
  1c0c9e:	89 85 74 ff ff ff    	mov    %eax,-0x8c(%rbp)
            goto done;
  1c0ca4:	e9 6b 03 00 00       	jmp    1c1014 <printer_vprintf+0xa56>
        case 'c':
            data = numbuf;
  1c0ca9:	48 8d 45 8c          	lea    -0x74(%rbp),%rax
  1c0cad:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
            numbuf[0] = va_arg(val, int);
  1c0cb1:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1c0cb8:	8b 00                	mov    (%rax),%eax
  1c0cba:	83 f8 2f             	cmp    $0x2f,%eax
  1c0cbd:	77 30                	ja     1c0cef <printer_vprintf+0x731>
  1c0cbf:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1c0cc6:	48 8b 50 10          	mov    0x10(%rax),%rdx
  1c0cca:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1c0cd1:	8b 00                	mov    (%rax),%eax
  1c0cd3:	89 c0                	mov    %eax,%eax
  1c0cd5:	48 01 d0             	add    %rdx,%rax
  1c0cd8:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  1c0cdf:	8b 12                	mov    (%rdx),%edx
  1c0ce1:	8d 4a 08             	lea    0x8(%rdx),%ecx
  1c0ce4:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  1c0ceb:	89 0a                	mov    %ecx,(%rdx)
  1c0ced:	eb 1a                	jmp    1c0d09 <printer_vprintf+0x74b>
  1c0cef:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1c0cf6:	48 8b 40 08          	mov    0x8(%rax),%rax
  1c0cfa:	48 8d 48 08          	lea    0x8(%rax),%rcx
  1c0cfe:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  1c0d05:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  1c0d09:	8b 00                	mov    (%rax),%eax
  1c0d0b:	88 45 8c             	mov    %al,-0x74(%rbp)
            numbuf[1] = '\0';
  1c0d0e:	c6 45 8d 00          	movb   $0x0,-0x73(%rbp)
            break;
  1c0d12:	eb 45                	jmp    1c0d59 <printer_vprintf+0x79b>
        default:
            data = numbuf;
  1c0d14:	48 8d 45 8c          	lea    -0x74(%rbp),%rax
  1c0d18:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
            numbuf[0] = (*format ? *format : '%');
  1c0d1c:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  1c0d23:	0f b6 00             	movzbl (%rax),%eax
  1c0d26:	84 c0                	test   %al,%al
  1c0d28:	74 0c                	je     1c0d36 <printer_vprintf+0x778>
  1c0d2a:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  1c0d31:	0f b6 00             	movzbl (%rax),%eax
  1c0d34:	eb 05                	jmp    1c0d3b <printer_vprintf+0x77d>
  1c0d36:	b8 25 00 00 00       	mov    $0x25,%eax
  1c0d3b:	88 45 8c             	mov    %al,-0x74(%rbp)
            numbuf[1] = '\0';
  1c0d3e:	c6 45 8d 00          	movb   $0x0,-0x73(%rbp)
            if (!*format) {
  1c0d42:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  1c0d49:	0f b6 00             	movzbl (%rax),%eax
  1c0d4c:	84 c0                	test   %al,%al
  1c0d4e:	75 08                	jne    1c0d58 <printer_vprintf+0x79a>
                format--;
  1c0d50:	48 83 ad 68 ff ff ff 	subq   $0x1,-0x98(%rbp)
  1c0d57:	01 
            }
            break;
  1c0d58:	90                   	nop
        }

        if (flags & FLAG_NUMERIC) {
  1c0d59:	8b 45 ec             	mov    -0x14(%rbp),%eax
  1c0d5c:	83 e0 20             	and    $0x20,%eax
  1c0d5f:	85 c0                	test   %eax,%eax
  1c0d61:	74 1e                	je     1c0d81 <printer_vprintf+0x7c3>
            data = fill_numbuf(numbuf + NUMBUFSIZ, num, base);
  1c0d63:	48 8d 45 8c          	lea    -0x74(%rbp),%rax
  1c0d67:	48 83 c0 18          	add    $0x18,%rax
  1c0d6b:	8b 55 e0             	mov    -0x20(%rbp),%edx
  1c0d6e:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
  1c0d72:	48 89 ce             	mov    %rcx,%rsi
  1c0d75:	48 89 c7             	mov    %rax,%rdi
  1c0d78:	e8 bf f7 ff ff       	call   1c053c <fill_numbuf>
  1c0d7d:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
        }

        const char* prefix = "";
  1c0d81:	48 c7 45 b8 86 13 1c 	movq   $0x1c1386,-0x48(%rbp)
  1c0d88:	00 
        if ((flags & FLAG_NUMERIC) && (flags & FLAG_SIGNED)) {
  1c0d89:	8b 45 ec             	mov    -0x14(%rbp),%eax
  1c0d8c:	83 e0 20             	and    $0x20,%eax
  1c0d8f:	85 c0                	test   %eax,%eax
  1c0d91:	74 48                	je     1c0ddb <printer_vprintf+0x81d>
  1c0d93:	8b 45 ec             	mov    -0x14(%rbp),%eax
  1c0d96:	83 e0 40             	and    $0x40,%eax
  1c0d99:	85 c0                	test   %eax,%eax
  1c0d9b:	74 3e                	je     1c0ddb <printer_vprintf+0x81d>
            if (flags & FLAG_NEGATIVE) {
  1c0d9d:	8b 45 ec             	mov    -0x14(%rbp),%eax
  1c0da0:	25 80 00 00 00       	and    $0x80,%eax
  1c0da5:	85 c0                	test   %eax,%eax
  1c0da7:	74 0a                	je     1c0db3 <printer_vprintf+0x7f5>
                prefix = "-";
  1c0da9:	48 c7 45 b8 87 13 1c 	movq   $0x1c1387,-0x48(%rbp)
  1c0db0:	00 
            if (flags & FLAG_NEGATIVE) {
  1c0db1:	eb 75                	jmp    1c0e28 <printer_vprintf+0x86a>
            } else if (flags & FLAG_PLUSPOSITIVE) {
  1c0db3:	8b 45 ec             	mov    -0x14(%rbp),%eax
  1c0db6:	83 e0 10             	and    $0x10,%eax
  1c0db9:	85 c0                	test   %eax,%eax
  1c0dbb:	74 0a                	je     1c0dc7 <printer_vprintf+0x809>
                prefix = "+";
  1c0dbd:	48 c7 45 b8 89 13 1c 	movq   $0x1c1389,-0x48(%rbp)
  1c0dc4:	00 
            if (flags & FLAG_NEGATIVE) {
  1c0dc5:	eb 61                	jmp    1c0e28 <printer_vprintf+0x86a>
            } else if (flags & FLAG_SPACEPOSITIVE) {
  1c0dc7:	8b 45 ec             	mov    -0x14(%rbp),%eax
  1c0dca:	83 e0 08             	and    $0x8,%eax
  1c0dcd:	85 c0                	test   %eax,%eax
  1c0dcf:	74 57                	je     1c0e28 <printer_vprintf+0x86a>
                prefix = " ";
  1c0dd1:	48 c7 45 b8 8b 13 1c 	movq   $0x1c138b,-0x48(%rbp)
  1c0dd8:	00 
            if (flags & FLAG_NEGATIVE) {
  1c0dd9:	eb 4d                	jmp    1c0e28 <printer_vprintf+0x86a>
            }
        } else if ((flags & FLAG_NUMERIC) && (flags & FLAG_ALT)
  1c0ddb:	8b 45 ec             	mov    -0x14(%rbp),%eax
  1c0dde:	83 e0 20             	and    $0x20,%eax
  1c0de1:	85 c0                	test   %eax,%eax
  1c0de3:	74 44                	je     1c0e29 <printer_vprintf+0x86b>
  1c0de5:	8b 45 ec             	mov    -0x14(%rbp),%eax
  1c0de8:	83 e0 01             	and    $0x1,%eax
  1c0deb:	85 c0                	test   %eax,%eax
  1c0ded:	74 3a                	je     1c0e29 <printer_vprintf+0x86b>
                   && (base == 16 || base == -16)
  1c0def:	83 7d e0 10          	cmpl   $0x10,-0x20(%rbp)
  1c0df3:	74 06                	je     1c0dfb <printer_vprintf+0x83d>
  1c0df5:	83 7d e0 f0          	cmpl   $0xfffffff0,-0x20(%rbp)
  1c0df9:	75 2e                	jne    1c0e29 <printer_vprintf+0x86b>
                   && (num || (flags & FLAG_ALT2))) {
  1c0dfb:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  1c0e00:	75 0c                	jne    1c0e0e <printer_vprintf+0x850>
  1c0e02:	8b 45 ec             	mov    -0x14(%rbp),%eax
  1c0e05:	25 00 01 00 00       	and    $0x100,%eax
  1c0e0a:	85 c0                	test   %eax,%eax
  1c0e0c:	74 1b                	je     1c0e29 <printer_vprintf+0x86b>
            prefix = (base == -16 ? "0x" : "0X");
  1c0e0e:	83 7d e0 f0          	cmpl   $0xfffffff0,-0x20(%rbp)
  1c0e12:	75 0a                	jne    1c0e1e <printer_vprintf+0x860>
  1c0e14:	48 c7 45 b8 8d 13 1c 	movq   $0x1c138d,-0x48(%rbp)
  1c0e1b:	00 
  1c0e1c:	eb 0b                	jmp    1c0e29 <printer_vprintf+0x86b>
  1c0e1e:	48 c7 45 b8 90 13 1c 	movq   $0x1c1390,-0x48(%rbp)
  1c0e25:	00 
  1c0e26:	eb 01                	jmp    1c0e29 <printer_vprintf+0x86b>
            if (flags & FLAG_NEGATIVE) {
  1c0e28:	90                   	nop
        }

        int len;
        if (precision >= 0 && !(flags & FLAG_NUMERIC)) {
  1c0e29:	83 7d e4 00          	cmpl   $0x0,-0x1c(%rbp)
  1c0e2d:	78 24                	js     1c0e53 <printer_vprintf+0x895>
  1c0e2f:	8b 45 ec             	mov    -0x14(%rbp),%eax
  1c0e32:	83 e0 20             	and    $0x20,%eax
  1c0e35:	85 c0                	test   %eax,%eax
  1c0e37:	75 1a                	jne    1c0e53 <printer_vprintf+0x895>
            len = strnlen(data, precision);
  1c0e39:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  1c0e3c:	48 63 d0             	movslq %eax,%rdx
  1c0e3f:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  1c0e43:	48 89 d6             	mov    %rdx,%rsi
  1c0e46:	48 89 c7             	mov    %rax,%rdi
  1c0e49:	e8 44 f5 ff ff       	call   1c0392 <strnlen>
  1c0e4e:	89 45 b4             	mov    %eax,-0x4c(%rbp)
  1c0e51:	eb 0f                	jmp    1c0e62 <printer_vprintf+0x8a4>
        } else {
            len = strlen(data);
  1c0e53:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  1c0e57:	48 89 c7             	mov    %rax,%rdi
  1c0e5a:	e8 02 f5 ff ff       	call   1c0361 <strlen>
  1c0e5f:	89 45 b4             	mov    %eax,-0x4c(%rbp)
        }
        int zeros;
        if ((flags & FLAG_NUMERIC) && precision >= 0) {
  1c0e62:	8b 45 ec             	mov    -0x14(%rbp),%eax
  1c0e65:	83 e0 20             	and    $0x20,%eax
  1c0e68:	85 c0                	test   %eax,%eax
  1c0e6a:	74 22                	je     1c0e8e <printer_vprintf+0x8d0>
  1c0e6c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%rbp)
  1c0e70:	78 1c                	js     1c0e8e <printer_vprintf+0x8d0>
            zeros = precision > len ? precision - len : 0;
  1c0e72:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  1c0e75:	3b 45 b4             	cmp    -0x4c(%rbp),%eax
  1c0e78:	7e 0b                	jle    1c0e85 <printer_vprintf+0x8c7>
  1c0e7a:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  1c0e7d:	2b 45 b4             	sub    -0x4c(%rbp),%eax
  1c0e80:	89 45 b0             	mov    %eax,-0x50(%rbp)
  1c0e83:	eb 65                	jmp    1c0eea <printer_vprintf+0x92c>
  1c0e85:	c7 45 b0 00 00 00 00 	movl   $0x0,-0x50(%rbp)
  1c0e8c:	eb 5c                	jmp    1c0eea <printer_vprintf+0x92c>
        } else if ((flags & FLAG_NUMERIC) && (flags & FLAG_ZERO)
  1c0e8e:	8b 45 ec             	mov    -0x14(%rbp),%eax
  1c0e91:	83 e0 20             	and    $0x20,%eax
  1c0e94:	85 c0                	test   %eax,%eax
  1c0e96:	74 4b                	je     1c0ee3 <printer_vprintf+0x925>
  1c0e98:	8b 45 ec             	mov    -0x14(%rbp),%eax
  1c0e9b:	83 e0 02             	and    $0x2,%eax
  1c0e9e:	85 c0                	test   %eax,%eax
  1c0ea0:	74 41                	je     1c0ee3 <printer_vprintf+0x925>
                   && !(flags & FLAG_LEFTJUSTIFY)
  1c0ea2:	8b 45 ec             	mov    -0x14(%rbp),%eax
  1c0ea5:	83 e0 04             	and    $0x4,%eax
  1c0ea8:	85 c0                	test   %eax,%eax
  1c0eaa:	75 37                	jne    1c0ee3 <printer_vprintf+0x925>
                   && len + (int) strlen(prefix) < width) {
  1c0eac:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  1c0eb0:	48 89 c7             	mov    %rax,%rdi
  1c0eb3:	e8 a9 f4 ff ff       	call   1c0361 <strlen>
  1c0eb8:	89 c2                	mov    %eax,%edx
  1c0eba:	8b 45 b4             	mov    -0x4c(%rbp),%eax
  1c0ebd:	01 d0                	add    %edx,%eax
  1c0ebf:	39 45 e8             	cmp    %eax,-0x18(%rbp)
  1c0ec2:	7e 1f                	jle    1c0ee3 <printer_vprintf+0x925>
            zeros = width - len - strlen(prefix);
  1c0ec4:	8b 45 e8             	mov    -0x18(%rbp),%eax
  1c0ec7:	2b 45 b4             	sub    -0x4c(%rbp),%eax
  1c0eca:	89 c3                	mov    %eax,%ebx
  1c0ecc:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  1c0ed0:	48 89 c7             	mov    %rax,%rdi
  1c0ed3:	e8 89 f4 ff ff       	call   1c0361 <strlen>
  1c0ed8:	89 c2                	mov    %eax,%edx
  1c0eda:	89 d8                	mov    %ebx,%eax
  1c0edc:	29 d0                	sub    %edx,%eax
  1c0ede:	89 45 b0             	mov    %eax,-0x50(%rbp)
  1c0ee1:	eb 07                	jmp    1c0eea <printer_vprintf+0x92c>
        } else {
            zeros = 0;
  1c0ee3:	c7 45 b0 00 00 00 00 	movl   $0x0,-0x50(%rbp)
        }
        width -= len + zeros + strlen(prefix);
  1c0eea:	8b 55 b4             	mov    -0x4c(%rbp),%edx
  1c0eed:	8b 45 b0             	mov    -0x50(%rbp),%eax
  1c0ef0:	01 d0                	add    %edx,%eax
  1c0ef2:	48 63 d8             	movslq %eax,%rbx
  1c0ef5:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  1c0ef9:	48 89 c7             	mov    %rax,%rdi
  1c0efc:	e8 60 f4 ff ff       	call   1c0361 <strlen>
  1c0f01:	48 8d 14 03          	lea    (%rbx,%rax,1),%rdx
  1c0f05:	8b 45 e8             	mov    -0x18(%rbp),%eax
  1c0f08:	29 d0                	sub    %edx,%eax
  1c0f0a:	89 45 e8             	mov    %eax,-0x18(%rbp)
        for (; !(flags & FLAG_LEFTJUSTIFY) && width > 0; --width) {
  1c0f0d:	eb 25                	jmp    1c0f34 <printer_vprintf+0x976>
            p->putc(p, ' ', color);
  1c0f0f:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  1c0f16:	48 8b 08             	mov    (%rax),%rcx
  1c0f19:	8b 95 74 ff ff ff    	mov    -0x8c(%rbp),%edx
  1c0f1f:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  1c0f26:	be 20 00 00 00       	mov    $0x20,%esi
  1c0f2b:	48 89 c7             	mov    %rax,%rdi
  1c0f2e:	ff d1                	call   *%rcx
        for (; !(flags & FLAG_LEFTJUSTIFY) && width > 0; --width) {
  1c0f30:	83 6d e8 01          	subl   $0x1,-0x18(%rbp)
  1c0f34:	8b 45 ec             	mov    -0x14(%rbp),%eax
  1c0f37:	83 e0 04             	and    $0x4,%eax
  1c0f3a:	85 c0                	test   %eax,%eax
  1c0f3c:	75 36                	jne    1c0f74 <printer_vprintf+0x9b6>
  1c0f3e:	83 7d e8 00          	cmpl   $0x0,-0x18(%rbp)
  1c0f42:	7f cb                	jg     1c0f0f <printer_vprintf+0x951>
        }
        for (; *prefix; ++prefix) {
  1c0f44:	eb 2e                	jmp    1c0f74 <printer_vprintf+0x9b6>
            p->putc(p, *prefix, color);
  1c0f46:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  1c0f4d:	4c 8b 00             	mov    (%rax),%r8
  1c0f50:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  1c0f54:	0f b6 00             	movzbl (%rax),%eax
  1c0f57:	8b 95 74 ff ff ff    	mov    -0x8c(%rbp),%edx
  1c0f5d:	0f b6 c8             	movzbl %al,%ecx
  1c0f60:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  1c0f67:	89 ce                	mov    %ecx,%esi
  1c0f69:	48 89 c7             	mov    %rax,%rdi
  1c0f6c:	41 ff d0             	call   *%r8
        for (; *prefix; ++prefix) {
  1c0f6f:	48 83 45 b8 01       	addq   $0x1,-0x48(%rbp)
  1c0f74:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  1c0f78:	0f b6 00             	movzbl (%rax),%eax
  1c0f7b:	84 c0                	test   %al,%al
  1c0f7d:	75 c7                	jne    1c0f46 <printer_vprintf+0x988>
        }
        for (; zeros > 0; --zeros) {
  1c0f7f:	eb 25                	jmp    1c0fa6 <printer_vprintf+0x9e8>
            p->putc(p, '0', color);
  1c0f81:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  1c0f88:	48 8b 08             	mov    (%rax),%rcx
  1c0f8b:	8b 95 74 ff ff ff    	mov    -0x8c(%rbp),%edx
  1c0f91:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  1c0f98:	be 30 00 00 00       	mov    $0x30,%esi
  1c0f9d:	48 89 c7             	mov    %rax,%rdi
  1c0fa0:	ff d1                	call   *%rcx
        for (; zeros > 0; --zeros) {
  1c0fa2:	83 6d b0 01          	subl   $0x1,-0x50(%rbp)
  1c0fa6:	83 7d b0 00          	cmpl   $0x0,-0x50(%rbp)
  1c0faa:	7f d5                	jg     1c0f81 <printer_vprintf+0x9c3>
        }
        for (; len > 0; ++data, --len) {
  1c0fac:	eb 32                	jmp    1c0fe0 <printer_vprintf+0xa22>
            p->putc(p, *data, color);
  1c0fae:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  1c0fb5:	4c 8b 00             	mov    (%rax),%r8
  1c0fb8:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  1c0fbc:	0f b6 00             	movzbl (%rax),%eax
  1c0fbf:	8b 95 74 ff ff ff    	mov    -0x8c(%rbp),%edx
  1c0fc5:	0f b6 c8             	movzbl %al,%ecx
  1c0fc8:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  1c0fcf:	89 ce                	mov    %ecx,%esi
  1c0fd1:	48 89 c7             	mov    %rax,%rdi
  1c0fd4:	41 ff d0             	call   *%r8
        for (; len > 0; ++data, --len) {
  1c0fd7:	48 83 45 c8 01       	addq   $0x1,-0x38(%rbp)
  1c0fdc:	83 6d b4 01          	subl   $0x1,-0x4c(%rbp)
  1c0fe0:	83 7d b4 00          	cmpl   $0x0,-0x4c(%rbp)
  1c0fe4:	7f c8                	jg     1c0fae <printer_vprintf+0x9f0>
        }
        for (; width > 0; --width) {
  1c0fe6:	eb 25                	jmp    1c100d <printer_vprintf+0xa4f>
            p->putc(p, ' ', color);
  1c0fe8:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  1c0fef:	48 8b 08             	mov    (%rax),%rcx
  1c0ff2:	8b 95 74 ff ff ff    	mov    -0x8c(%rbp),%edx
  1c0ff8:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  1c0fff:	be 20 00 00 00       	mov    $0x20,%esi
  1c1004:	48 89 c7             	mov    %rax,%rdi
  1c1007:	ff d1                	call   *%rcx
        for (; width > 0; --width) {
  1c1009:	83 6d e8 01          	subl   $0x1,-0x18(%rbp)
  1c100d:	83 7d e8 00          	cmpl   $0x0,-0x18(%rbp)
  1c1011:	7f d5                	jg     1c0fe8 <printer_vprintf+0xa2a>
        }
    done: ;
  1c1013:	90                   	nop
    for (; *format; ++format) {
  1c1014:	48 83 85 68 ff ff ff 	addq   $0x1,-0x98(%rbp)
  1c101b:	01 
  1c101c:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  1c1023:	0f b6 00             	movzbl (%rax),%eax
  1c1026:	84 c0                	test   %al,%al
  1c1028:	0f 85 bc f5 ff ff    	jne    1c05ea <printer_vprintf+0x2c>
    }
}
  1c102e:	90                   	nop
  1c102f:	90                   	nop
  1c1030:	48 8b 5d f8          	mov    -0x8(%rbp),%rbx
  1c1034:	c9                   	leave
  1c1035:	c3                   	ret

00000000001c1036 <console_putc>:
typedef struct console_printer {
    printer p;
    uint16_t* cursor;
} console_printer;

static void console_putc(printer* p, unsigned char c, int color) {
  1c1036:	55                   	push   %rbp
  1c1037:	48 89 e5             	mov    %rsp,%rbp
  1c103a:	48 83 ec 20          	sub    $0x20,%rsp
  1c103e:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  1c1042:	40 88 75 e7          	mov    %sil,-0x19(%rbp)
  1c1046:	89 55 e0             	mov    %edx,-0x20(%rbp)
    console_printer* cp = (console_printer*) p;
  1c1049:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  1c104d:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
    if (cp->cursor >= console + CONSOLE_ROWS * CONSOLE_COLUMNS) {
  1c1051:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  1c1055:	48 8b 40 08          	mov    0x8(%rax),%rax
  1c1059:	ba a0 8f 0b 00       	mov    $0xb8fa0,%edx
  1c105e:	48 39 d0             	cmp    %rdx,%rax
  1c1061:	72 0c                	jb     1c106f <console_putc+0x39>
        cp->cursor = console;
  1c1063:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  1c1067:	48 c7 40 08 00 80 0b 	movq   $0xb8000,0x8(%rax)
  1c106e:	00 
    }
    if (c == '\n') {
  1c106f:	80 7d e7 0a          	cmpb   $0xa,-0x19(%rbp)
  1c1073:	75 78                	jne    1c10ed <console_putc+0xb7>
        int pos = (cp->cursor - console) % 80;
  1c1075:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  1c1079:	48 8b 40 08          	mov    0x8(%rax),%rax
  1c107d:	48 2d 00 80 0b 00    	sub    $0xb8000,%rax
  1c1083:	48 d1 f8             	sar    $1,%rax
  1c1086:	48 89 c1             	mov    %rax,%rcx
  1c1089:	48 ba 67 66 66 66 66 	movabs $0x6666666666666667,%rdx
  1c1090:	66 66 66 
  1c1093:	48 89 c8             	mov    %rcx,%rax
  1c1096:	48 f7 ea             	imul   %rdx
  1c1099:	48 c1 fa 05          	sar    $0x5,%rdx
  1c109d:	48 89 c8             	mov    %rcx,%rax
  1c10a0:	48 c1 f8 3f          	sar    $0x3f,%rax
  1c10a4:	48 29 c2             	sub    %rax,%rdx
  1c10a7:	48 89 d0             	mov    %rdx,%rax
  1c10aa:	48 c1 e0 02          	shl    $0x2,%rax
  1c10ae:	48 01 d0             	add    %rdx,%rax
  1c10b1:	48 c1 e0 04          	shl    $0x4,%rax
  1c10b5:	48 29 c1             	sub    %rax,%rcx
  1c10b8:	48 89 ca             	mov    %rcx,%rdx
  1c10bb:	89 55 fc             	mov    %edx,-0x4(%rbp)
        for (; pos != 80; pos++) {
  1c10be:	eb 25                	jmp    1c10e5 <console_putc+0xaf>
            *cp->cursor++ = ' ' | color;
  1c10c0:	8b 45 e0             	mov    -0x20(%rbp),%eax
  1c10c3:	83 c8 20             	or     $0x20,%eax
  1c10c6:	89 c6                	mov    %eax,%esi
  1c10c8:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  1c10cc:	48 8b 40 08          	mov    0x8(%rax),%rax
  1c10d0:	48 8d 48 02          	lea    0x2(%rax),%rcx
  1c10d4:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  1c10d8:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  1c10dc:	89 f2                	mov    %esi,%edx
  1c10de:	66 89 10             	mov    %dx,(%rax)
        for (; pos != 80; pos++) {
  1c10e1:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  1c10e5:	83 7d fc 50          	cmpl   $0x50,-0x4(%rbp)
  1c10e9:	75 d5                	jne    1c10c0 <console_putc+0x8a>
        }
    } else {
        *cp->cursor++ = c | color;
    }
}
  1c10eb:	eb 24                	jmp    1c1111 <console_putc+0xdb>
        *cp->cursor++ = c | color;
  1c10ed:	0f b6 45 e7          	movzbl -0x19(%rbp),%eax
  1c10f1:	8b 55 e0             	mov    -0x20(%rbp),%edx
  1c10f4:	09 d0                	or     %edx,%eax
  1c10f6:	89 c6                	mov    %eax,%esi
  1c10f8:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  1c10fc:	48 8b 40 08          	mov    0x8(%rax),%rax
  1c1100:	48 8d 48 02          	lea    0x2(%rax),%rcx
  1c1104:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  1c1108:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  1c110c:	89 f2                	mov    %esi,%edx
  1c110e:	66 89 10             	mov    %dx,(%rax)
}
  1c1111:	90                   	nop
  1c1112:	c9                   	leave
  1c1113:	c3                   	ret

00000000001c1114 <console_vprintf>:

int console_vprintf(int cpos, int color, const char* format, va_list val) {
  1c1114:	55                   	push   %rbp
  1c1115:	48 89 e5             	mov    %rsp,%rbp
  1c1118:	48 83 ec 30          	sub    $0x30,%rsp
  1c111c:	89 7d ec             	mov    %edi,-0x14(%rbp)
  1c111f:	89 75 e8             	mov    %esi,-0x18(%rbp)
  1c1122:	48 89 55 e0          	mov    %rdx,-0x20(%rbp)
  1c1126:	48 89 4d d8          	mov    %rcx,-0x28(%rbp)
    struct console_printer cp;
    cp.p.putc = console_putc;
  1c112a:	48 c7 45 f0 36 10 1c 	movq   $0x1c1036,-0x10(%rbp)
  1c1131:	00 
    if (cpos < 0 || cpos >= CONSOLE_ROWS * CONSOLE_COLUMNS) {
  1c1132:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  1c1136:	78 09                	js     1c1141 <console_vprintf+0x2d>
  1c1138:	81 7d ec cf 07 00 00 	cmpl   $0x7cf,-0x14(%rbp)
  1c113f:	7e 07                	jle    1c1148 <console_vprintf+0x34>
        cpos = 0;
  1c1141:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%rbp)
    }
    cp.cursor = console + cpos;
  1c1148:	8b 45 ec             	mov    -0x14(%rbp),%eax
  1c114b:	48 98                	cltq
  1c114d:	48 01 c0             	add    %rax,%rax
  1c1150:	48 05 00 80 0b 00    	add    $0xb8000,%rax
  1c1156:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    printer_vprintf(&cp.p, color, format, val);
  1c115a:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
  1c115e:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  1c1162:	8b 75 e8             	mov    -0x18(%rbp),%esi
  1c1165:	48 8d 45 f0          	lea    -0x10(%rbp),%rax
  1c1169:	48 89 c7             	mov    %rax,%rdi
  1c116c:	e8 4d f4 ff ff       	call   1c05be <printer_vprintf>
    return cp.cursor - console;
  1c1171:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  1c1175:	48 2d 00 80 0b 00    	sub    $0xb8000,%rax
  1c117b:	48 d1 f8             	sar    $1,%rax
}
  1c117e:	c9                   	leave
  1c117f:	c3                   	ret

00000000001c1180 <console_printf>:

int console_printf(int cpos, int color, const char* format, ...) {
  1c1180:	55                   	push   %rbp
  1c1181:	48 89 e5             	mov    %rsp,%rbp
  1c1184:	48 83 ec 60          	sub    $0x60,%rsp
  1c1188:	89 7d ac             	mov    %edi,-0x54(%rbp)
  1c118b:	89 75 a8             	mov    %esi,-0x58(%rbp)
  1c118e:	48 89 55 a0          	mov    %rdx,-0x60(%rbp)
  1c1192:	48 89 4d e8          	mov    %rcx,-0x18(%rbp)
  1c1196:	4c 89 45 f0          	mov    %r8,-0x10(%rbp)
  1c119a:	4c 89 4d f8          	mov    %r9,-0x8(%rbp)
    va_list val;
    va_start(val, format);
  1c119e:	c7 45 b8 18 00 00 00 	movl   $0x18,-0x48(%rbp)
  1c11a5:	48 8d 45 10          	lea    0x10(%rbp),%rax
  1c11a9:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  1c11ad:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
  1c11b1:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    cpos = console_vprintf(cpos, color, format, val);
  1c11b5:	48 8d 4d b8          	lea    -0x48(%rbp),%rcx
  1c11b9:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  1c11bd:	8b 75 a8             	mov    -0x58(%rbp),%esi
  1c11c0:	8b 45 ac             	mov    -0x54(%rbp),%eax
  1c11c3:	89 c7                	mov    %eax,%edi
  1c11c5:	e8 4a ff ff ff       	call   1c1114 <console_vprintf>
  1c11ca:	89 45 ac             	mov    %eax,-0x54(%rbp)
    va_end(val);
    return cpos;
  1c11cd:	8b 45 ac             	mov    -0x54(%rbp),%eax
}
  1c11d0:	c9                   	leave
  1c11d1:	c3                   	ret

00000000001c11d2 <string_putc>:
    printer p;
    char* s;
    char* end;
} string_printer;

static void string_putc(printer* p, unsigned char c, int color) {
  1c11d2:	55                   	push   %rbp
  1c11d3:	48 89 e5             	mov    %rsp,%rbp
  1c11d6:	48 83 ec 20          	sub    $0x20,%rsp
  1c11da:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  1c11de:	40 88 75 e7          	mov    %sil,-0x19(%rbp)
  1c11e2:	89 55 e0             	mov    %edx,-0x20(%rbp)
    string_printer* sp = (string_printer*) p;
  1c11e5:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  1c11e9:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    if (sp->s < sp->end) {
  1c11ed:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  1c11f1:	48 8b 50 08          	mov    0x8(%rax),%rdx
  1c11f5:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  1c11f9:	48 8b 40 10          	mov    0x10(%rax),%rax
  1c11fd:	48 39 c2             	cmp    %rax,%rdx
  1c1200:	73 1a                	jae    1c121c <string_putc+0x4a>
        *sp->s++ = c;
  1c1202:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  1c1206:	48 8b 40 08          	mov    0x8(%rax),%rax
  1c120a:	48 8d 48 01          	lea    0x1(%rax),%rcx
  1c120e:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  1c1212:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  1c1216:	0f b6 55 e7          	movzbl -0x19(%rbp),%edx
  1c121a:	88 10                	mov    %dl,(%rax)
    }
    (void) color;
}
  1c121c:	90                   	nop
  1c121d:	c9                   	leave
  1c121e:	c3                   	ret

00000000001c121f <vsnprintf>:

int vsnprintf(char* s, size_t size, const char* format, va_list val) {
  1c121f:	55                   	push   %rbp
  1c1220:	48 89 e5             	mov    %rsp,%rbp
  1c1223:	48 83 ec 40          	sub    $0x40,%rsp
  1c1227:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  1c122b:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  1c122f:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  1c1233:	48 89 4d c0          	mov    %rcx,-0x40(%rbp)
    string_printer sp;
    sp.p.putc = string_putc;
  1c1237:	48 c7 45 e8 d2 11 1c 	movq   $0x1c11d2,-0x18(%rbp)
  1c123e:	00 
    sp.s = s;
  1c123f:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  1c1243:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
    if (size) {
  1c1247:	48 83 7d d0 00       	cmpq   $0x0,-0x30(%rbp)
  1c124c:	74 33                	je     1c1281 <vsnprintf+0x62>
        sp.end = s + size - 1;
  1c124e:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  1c1252:	48 8d 50 ff          	lea    -0x1(%rax),%rdx
  1c1256:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  1c125a:	48 01 d0             	add    %rdx,%rax
  1c125d:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
        printer_vprintf(&sp.p, 0, format, val);
  1c1261:	48 8b 4d c0          	mov    -0x40(%rbp),%rcx
  1c1265:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  1c1269:	48 8d 45 e8          	lea    -0x18(%rbp),%rax
  1c126d:	be 00 00 00 00       	mov    $0x0,%esi
  1c1272:	48 89 c7             	mov    %rax,%rdi
  1c1275:	e8 44 f3 ff ff       	call   1c05be <printer_vprintf>
        *sp.s = 0;
  1c127a:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  1c127e:	c6 00 00             	movb   $0x0,(%rax)
    }
    return sp.s - s;
  1c1281:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  1c1285:	48 2b 45 d8          	sub    -0x28(%rbp),%rax
}
  1c1289:	c9                   	leave
  1c128a:	c3                   	ret

00000000001c128b <snprintf>:

int snprintf(char* s, size_t size, const char* format, ...) {
  1c128b:	55                   	push   %rbp
  1c128c:	48 89 e5             	mov    %rsp,%rbp
  1c128f:	48 83 ec 70          	sub    $0x70,%rsp
  1c1293:	48 89 7d a8          	mov    %rdi,-0x58(%rbp)
  1c1297:	48 89 75 a0          	mov    %rsi,-0x60(%rbp)
  1c129b:	48 89 55 98          	mov    %rdx,-0x68(%rbp)
  1c129f:	48 89 4d e8          	mov    %rcx,-0x18(%rbp)
  1c12a3:	4c 89 45 f0          	mov    %r8,-0x10(%rbp)
  1c12a7:	4c 89 4d f8          	mov    %r9,-0x8(%rbp)
    va_list val;
    va_start(val, format);
  1c12ab:	c7 45 b0 18 00 00 00 	movl   $0x18,-0x50(%rbp)
  1c12b2:	48 8d 45 10          	lea    0x10(%rbp),%rax
  1c12b6:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  1c12ba:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
  1c12be:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
    int n = vsnprintf(s, size, format, val);
  1c12c2:	48 8d 4d b0          	lea    -0x50(%rbp),%rcx
  1c12c6:	48 8b 55 98          	mov    -0x68(%rbp),%rdx
  1c12ca:	48 8b 75 a0          	mov    -0x60(%rbp),%rsi
  1c12ce:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  1c12d2:	48 89 c7             	mov    %rax,%rdi
  1c12d5:	e8 45 ff ff ff       	call   1c121f <vsnprintf>
  1c12da:	89 45 cc             	mov    %eax,-0x34(%rbp)
    va_end(val);
    return n;
  1c12dd:	8b 45 cc             	mov    -0x34(%rbp),%eax
}
  1c12e0:	c9                   	leave
  1c12e1:	c3                   	ret

00000000001c12e2 <console_clear>:


// console_clear
//    Erases the console and moves the cursor to the upper left (CPOS(0, 0)).

void console_clear(void) {
  1c12e2:	55                   	push   %rbp
  1c12e3:	48 89 e5             	mov    %rsp,%rbp
  1c12e6:	48 83 ec 10          	sub    $0x10,%rsp
    for (int i = 0; i < CONSOLE_ROWS * CONSOLE_COLUMNS; ++i) {
  1c12ea:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  1c12f1:	eb 13                	jmp    1c1306 <console_clear+0x24>
        console[i] = ' ' | 0x0700;
  1c12f3:	8b 45 fc             	mov    -0x4(%rbp),%eax
  1c12f6:	48 98                	cltq
  1c12f8:	66 c7 84 00 00 80 0b 	movw   $0x720,0xb8000(%rax,%rax,1)
  1c12ff:	00 20 07 
    for (int i = 0; i < CONSOLE_ROWS * CONSOLE_COLUMNS; ++i) {
  1c1302:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  1c1306:	81 7d fc cf 07 00 00 	cmpl   $0x7cf,-0x4(%rbp)
  1c130d:	7e e4                	jle    1c12f3 <console_clear+0x11>
    }
    cursorpos = 0;
  1c130f:	c7 05 e3 7c ef ff 00 	movl   $0x0,-0x10831d(%rip)        # b8ffc <cursorpos>
  1c1316:	00 00 00 
}
  1c1319:	90                   	nop
  1c131a:	c9                   	leave
  1c131b:	c3                   	ret
