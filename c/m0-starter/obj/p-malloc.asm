
obj/p-malloc.full:     file format elf64-x86-64


Disassembly of section .text:

0000000000100000 <process_main>:
extern uint8_t end[];

uint8_t* heap_top;
uint8_t* stack_bottom;

void process_main(void) {
  100000:	55                   	push   %rbp
  100001:	48 89 e5             	mov    %rsp,%rbp
  100004:	53                   	push   %rbx
  100005:	48 83 ec 08          	sub    $0x8,%rsp

// getpid
//    Return current process ID.
static inline pid_t getpid(void) {
    pid_t result;
    asm volatile ("int %1" : "=a" (result)
  100009:	cd 31                	int    $0x31
  10000b:	89 c3                	mov    %eax,%ebx
    pid_t p = getpid();

    heap_top = ROUNDUP((uint8_t*) end, PAGESIZE);
  10000d:	b8 17 30 10 00       	mov    $0x103017,%eax
  100012:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  100018:	48 89 05 e9 1f 00 00 	mov    %rax,0x1fe9(%rip)        # 102008 <heap_top>
    return rbp;
}

static inline uintptr_t read_rsp(void) {
    uintptr_t rsp;
    asm volatile("movq %%rsp,%0" : "=r" (rsp));
  10001f:	48 89 e0             	mov    %rsp,%rax

    // The bottom of the stack is the first address on the current
    // stack page (this process never needs more than one stack page).
    stack_bottom = ROUNDDOWN((uint8_t*) read_rsp() - 1, PAGESIZE);
  100022:	48 83 e8 01          	sub    $0x1,%rax
  100026:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
  10002c:	48 89 05 cd 1f 00 00 	mov    %rax,0x1fcd(%rip)        # 102000 <stack_bottom>
  100033:	eb 02                	jmp    100037 <process_main+0x37>

// yield
//    Yield control of the CPU to the kernel. The kernel will pick another
//    process to run, if possible.
static inline void yield(void) {
    asm volatile ("int %0" : /* no result */
  100035:	cd 32                	int    $0x32

    // Allocate heap pages until (1) hit the stack (out of address space)
    // or (2) allocation fails (out of physical memory).
    while (1) {
	if ((rand() % ALLOC_SLOWDOWN) < p) {
  100037:	e8 0a 03 00 00       	call   100346 <rand>
  10003c:	48 63 d0             	movslq %eax,%rdx
  10003f:	48 69 d2 1f 85 eb 51 	imul   $0x51eb851f,%rdx,%rdx
  100046:	48 c1 fa 25          	sar    $0x25,%rdx
  10004a:	89 c1                	mov    %eax,%ecx
  10004c:	c1 f9 1f             	sar    $0x1f,%ecx
  10004f:	29 ca                	sub    %ecx,%edx
  100051:	6b d2 64             	imul   $0x64,%edx,%edx
  100054:	29 d0                	sub    %edx,%eax
  100056:	39 d8                	cmp    %ebx,%eax
  100058:	7d db                	jge    100035 <process_main+0x35>
	    void * ret = malloc(PAGESIZE);
  10005a:	bf 00 10 00 00       	mov    $0x1000,%edi
  10005f:	e8 0e 00 00 00       	call   100072 <malloc>
	    if(ret == NULL)
  100064:	48 85 c0             	test   %rax,%rax
  100067:	74 04                	je     10006d <process_main+0x6d>
		break;
	    *((int*)ret) = p;       // check we have write access
  100069:	89 18                	mov    %ebx,(%rax)
  10006b:	eb c8                	jmp    100035 <process_main+0x35>
  10006d:	cd 32                	int    $0x32
	}
	yield();
    }
    // After running out of memory, do nothing forever
    while (1) {
  10006f:	eb fc                	jmp    10006d <process_main+0x6d>

0000000000100071 <free>:
#include "malloc.h"

void free(void *firstbyte) {
    return;
}
  100071:	c3                   	ret

0000000000100072 <malloc>:

void *malloc(uint64_t numbytes) {
    return 0 ;
}
  100072:	b8 00 00 00 00       	mov    $0x0,%eax
  100077:	c3                   	ret

0000000000100078 <calloc>:


void * calloc(uint64_t num, uint64_t sz) {
    return 0;
}
  100078:	b8 00 00 00 00       	mov    $0x0,%eax
  10007d:	c3                   	ret

000000000010007e <realloc>:

void * realloc(void * ptr, uint64_t sz) {
    return 0;
}
  10007e:	b8 00 00 00 00       	mov    $0x0,%eax
  100083:	c3                   	ret

0000000000100084 <defrag>:

void defrag() {
}
  100084:	c3                   	ret

0000000000100085 <heap_info>:

int heap_info(heap_info_struct * info) {
    return 0;
}
  100085:	b8 00 00 00 00       	mov    $0x0,%eax
  10008a:	c3                   	ret

000000000010008b <memcpy>:


// memcpy, memmove, memset, strcmp, strlen, strnlen
//    We must provide our own implementations.

void* memcpy(void* dst, const void* src, size_t n) {
  10008b:	55                   	push   %rbp
  10008c:	48 89 e5             	mov    %rsp,%rbp
  10008f:	48 83 ec 28          	sub    $0x28,%rsp
  100093:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  100097:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  10009b:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
    const char* s = (const char*) src;
  10009f:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  1000a3:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    for (char* d = (char*) dst; n > 0; --n, ++s, ++d) {
  1000a7:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  1000ab:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
  1000af:	eb 1c                	jmp    1000cd <memcpy+0x42>
        *d = *s;
  1000b1:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  1000b5:	0f b6 10             	movzbl (%rax),%edx
  1000b8:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  1000bc:	88 10                	mov    %dl,(%rax)
    for (char* d = (char*) dst; n > 0; --n, ++s, ++d) {
  1000be:	48 83 6d d8 01       	subq   $0x1,-0x28(%rbp)
  1000c3:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  1000c8:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
  1000cd:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  1000d2:	75 dd                	jne    1000b1 <memcpy+0x26>
    }
    return dst;
  1000d4:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
  1000d8:	c9                   	leave
  1000d9:	c3                   	ret

00000000001000da <memmove>:

void* memmove(void* dst, const void* src, size_t n) {
  1000da:	55                   	push   %rbp
  1000db:	48 89 e5             	mov    %rsp,%rbp
  1000de:	48 83 ec 28          	sub    $0x28,%rsp
  1000e2:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  1000e6:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  1000ea:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
    const char* s = (const char*) src;
  1000ee:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  1000f2:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    char* d = (char*) dst;
  1000f6:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  1000fa:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
    if (s < d && s + n > d) {
  1000fe:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  100102:	48 3b 45 f0          	cmp    -0x10(%rbp),%rax
  100106:	73 6a                	jae    100172 <memmove+0x98>
  100108:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  10010c:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  100110:	48 01 d0             	add    %rdx,%rax
  100113:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
  100117:	73 59                	jae    100172 <memmove+0x98>
        s += n, d += n;
  100119:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  10011d:	48 01 45 f8          	add    %rax,-0x8(%rbp)
  100121:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  100125:	48 01 45 f0          	add    %rax,-0x10(%rbp)
        while (n-- > 0) {
  100129:	eb 17                	jmp    100142 <memmove+0x68>
            *--d = *--s;
  10012b:	48 83 6d f8 01       	subq   $0x1,-0x8(%rbp)
  100130:	48 83 6d f0 01       	subq   $0x1,-0x10(%rbp)
  100135:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  100139:	0f b6 10             	movzbl (%rax),%edx
  10013c:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  100140:	88 10                	mov    %dl,(%rax)
        while (n-- > 0) {
  100142:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  100146:	48 8d 50 ff          	lea    -0x1(%rax),%rdx
  10014a:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  10014e:	48 85 c0             	test   %rax,%rax
  100151:	75 d8                	jne    10012b <memmove+0x51>
    if (s < d && s + n > d) {
  100153:	eb 2e                	jmp    100183 <memmove+0xa9>
        }
    } else {
        while (n-- > 0) {
            *d++ = *s++;
  100155:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  100159:	48 8d 42 01          	lea    0x1(%rdx),%rax
  10015d:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  100161:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  100165:	48 8d 48 01          	lea    0x1(%rax),%rcx
  100169:	48 89 4d f0          	mov    %rcx,-0x10(%rbp)
  10016d:	0f b6 12             	movzbl (%rdx),%edx
  100170:	88 10                	mov    %dl,(%rax)
        while (n-- > 0) {
  100172:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  100176:	48 8d 50 ff          	lea    -0x1(%rax),%rdx
  10017a:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
  10017e:	48 85 c0             	test   %rax,%rax
  100181:	75 d2                	jne    100155 <memmove+0x7b>
        }
    }
    return dst;
  100183:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
  100187:	c9                   	leave
  100188:	c3                   	ret

0000000000100189 <memset>:

void* memset(void* v, int c, size_t n) {
  100189:	55                   	push   %rbp
  10018a:	48 89 e5             	mov    %rsp,%rbp
  10018d:	48 83 ec 28          	sub    $0x28,%rsp
  100191:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  100195:	89 75 e4             	mov    %esi,-0x1c(%rbp)
  100198:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
    for (char* p = (char*) v; n > 0; ++p, --n) {
  10019c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  1001a0:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  1001a4:	eb 15                	jmp    1001bb <memset+0x32>
        *p = c;
  1001a6:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  1001a9:	89 c2                	mov    %eax,%edx
  1001ab:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  1001af:	88 10                	mov    %dl,(%rax)
    for (char* p = (char*) v; n > 0; ++p, --n) {
  1001b1:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  1001b6:	48 83 6d d8 01       	subq   $0x1,-0x28(%rbp)
  1001bb:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  1001c0:	75 e4                	jne    1001a6 <memset+0x1d>
    }
    return v;
  1001c2:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
  1001c6:	c9                   	leave
  1001c7:	c3                   	ret

00000000001001c8 <strlen>:

size_t strlen(const char* s) {
  1001c8:	55                   	push   %rbp
  1001c9:	48 89 e5             	mov    %rsp,%rbp
  1001cc:	48 83 ec 18          	sub    $0x18,%rsp
  1001d0:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
    size_t n;
    for (n = 0; *s != '\0'; ++s) {
  1001d4:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
  1001db:	00 
  1001dc:	eb 0a                	jmp    1001e8 <strlen+0x20>
        ++n;
  1001de:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
    for (n = 0; *s != '\0'; ++s) {
  1001e3:	48 83 45 e8 01       	addq   $0x1,-0x18(%rbp)
  1001e8:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  1001ec:	0f b6 00             	movzbl (%rax),%eax
  1001ef:	84 c0                	test   %al,%al
  1001f1:	75 eb                	jne    1001de <strlen+0x16>
    }
    return n;
  1001f3:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  1001f7:	c9                   	leave
  1001f8:	c3                   	ret

00000000001001f9 <strnlen>:

size_t strnlen(const char* s, size_t maxlen) {
  1001f9:	55                   	push   %rbp
  1001fa:	48 89 e5             	mov    %rsp,%rbp
  1001fd:	48 83 ec 20          	sub    $0x20,%rsp
  100201:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  100205:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
    size_t n;
    for (n = 0; n != maxlen && *s != '\0'; ++s) {
  100209:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
  100210:	00 
  100211:	eb 0a                	jmp    10021d <strnlen+0x24>
        ++n;
  100213:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
    for (n = 0; n != maxlen && *s != '\0'; ++s) {
  100218:	48 83 45 e8 01       	addq   $0x1,-0x18(%rbp)
  10021d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  100221:	48 3b 45 e0          	cmp    -0x20(%rbp),%rax
  100225:	74 0b                	je     100232 <strnlen+0x39>
  100227:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  10022b:	0f b6 00             	movzbl (%rax),%eax
  10022e:	84 c0                	test   %al,%al
  100230:	75 e1                	jne    100213 <strnlen+0x1a>
    }
    return n;
  100232:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
  100236:	c9                   	leave
  100237:	c3                   	ret

0000000000100238 <strcpy>:

char* strcpy(char* dst, const char* src) {
  100238:	55                   	push   %rbp
  100239:	48 89 e5             	mov    %rsp,%rbp
  10023c:	48 83 ec 20          	sub    $0x20,%rsp
  100240:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  100244:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
    char* d = dst;
  100248:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  10024c:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    do {
        *d++ = *src++;
  100250:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  100254:	48 8d 42 01          	lea    0x1(%rdx),%rax
  100258:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
  10025c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  100260:	48 8d 48 01          	lea    0x1(%rax),%rcx
  100264:	48 89 4d f8          	mov    %rcx,-0x8(%rbp)
  100268:	0f b6 12             	movzbl (%rdx),%edx
  10026b:	88 10                	mov    %dl,(%rax)
    } while (d[-1]);
  10026d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  100271:	48 83 e8 01          	sub    $0x1,%rax
  100275:	0f b6 00             	movzbl (%rax),%eax
  100278:	84 c0                	test   %al,%al
  10027a:	75 d4                	jne    100250 <strcpy+0x18>
    return dst;
  10027c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
  100280:	c9                   	leave
  100281:	c3                   	ret

0000000000100282 <strcmp>:

int strcmp(const char* a, const char* b) {
  100282:	55                   	push   %rbp
  100283:	48 89 e5             	mov    %rsp,%rbp
  100286:	48 83 ec 10          	sub    $0x10,%rsp
  10028a:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  10028e:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
    while (*a && *b && *a == *b) {
  100292:	eb 0a                	jmp    10029e <strcmp+0x1c>
        ++a, ++b;
  100294:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
  100299:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
    while (*a && *b && *a == *b) {
  10029e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  1002a2:	0f b6 00             	movzbl (%rax),%eax
  1002a5:	84 c0                	test   %al,%al
  1002a7:	74 1d                	je     1002c6 <strcmp+0x44>
  1002a9:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  1002ad:	0f b6 00             	movzbl (%rax),%eax
  1002b0:	84 c0                	test   %al,%al
  1002b2:	74 12                	je     1002c6 <strcmp+0x44>
  1002b4:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  1002b8:	0f b6 10             	movzbl (%rax),%edx
  1002bb:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  1002bf:	0f b6 00             	movzbl (%rax),%eax
  1002c2:	38 c2                	cmp    %al,%dl
  1002c4:	74 ce                	je     100294 <strcmp+0x12>
    }
    return ((unsigned char) *a > (unsigned char) *b)
  1002c6:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  1002ca:	0f b6 00             	movzbl (%rax),%eax
  1002cd:	89 c2                	mov    %eax,%edx
  1002cf:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  1002d3:	0f b6 00             	movzbl (%rax),%eax
  1002d6:	38 d0                	cmp    %dl,%al
  1002d8:	0f 92 c0             	setb   %al
  1002db:	0f b6 d0             	movzbl %al,%edx
        - ((unsigned char) *a < (unsigned char) *b);
  1002de:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  1002e2:	0f b6 00             	movzbl (%rax),%eax
  1002e5:	89 c1                	mov    %eax,%ecx
  1002e7:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  1002eb:	0f b6 00             	movzbl (%rax),%eax
  1002ee:	38 c1                	cmp    %al,%cl
  1002f0:	0f 92 c0             	setb   %al
  1002f3:	0f b6 c0             	movzbl %al,%eax
  1002f6:	29 c2                	sub    %eax,%edx
  1002f8:	89 d0                	mov    %edx,%eax
}
  1002fa:	c9                   	leave
  1002fb:	c3                   	ret

00000000001002fc <strchr>:

char* strchr(const char* s, int c) {
  1002fc:	55                   	push   %rbp
  1002fd:	48 89 e5             	mov    %rsp,%rbp
  100300:	48 83 ec 10          	sub    $0x10,%rsp
  100304:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  100308:	89 75 f4             	mov    %esi,-0xc(%rbp)
    while (*s && *s != (char) c) {
  10030b:	eb 05                	jmp    100312 <strchr+0x16>
        ++s;
  10030d:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
    while (*s && *s != (char) c) {
  100312:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  100316:	0f b6 00             	movzbl (%rax),%eax
  100319:	84 c0                	test   %al,%al
  10031b:	74 0e                	je     10032b <strchr+0x2f>
  10031d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  100321:	0f b6 00             	movzbl (%rax),%eax
  100324:	8b 55 f4             	mov    -0xc(%rbp),%edx
  100327:	38 d0                	cmp    %dl,%al
  100329:	75 e2                	jne    10030d <strchr+0x11>
    }
    if (*s == (char) c) {
  10032b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  10032f:	0f b6 00             	movzbl (%rax),%eax
  100332:	8b 55 f4             	mov    -0xc(%rbp),%edx
  100335:	38 d0                	cmp    %dl,%al
  100337:	75 06                	jne    10033f <strchr+0x43>
        return (char*) s;
  100339:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  10033d:	eb 05                	jmp    100344 <strchr+0x48>
    } else {
        return NULL;
  10033f:	b8 00 00 00 00       	mov    $0x0,%eax
    }
}
  100344:	c9                   	leave
  100345:	c3                   	ret

0000000000100346 <rand>:
// rand, srand

static int rand_seed_set;
static unsigned rand_seed;

int rand(void) {
  100346:	55                   	push   %rbp
  100347:	48 89 e5             	mov    %rsp,%rbp
    if (!rand_seed_set) {
  10034a:	8b 05 c0 1c 00 00    	mov    0x1cc0(%rip),%eax        # 102010 <rand_seed_set>
  100350:	85 c0                	test   %eax,%eax
  100352:	75 0a                	jne    10035e <rand+0x18>
        srand(819234718U);
  100354:	bf 9e 87 d4 30       	mov    $0x30d4879e,%edi
  100359:	e8 24 00 00 00       	call   100382 <srand>
    }
    rand_seed = rand_seed * 1664525U + 1013904223U;
  10035e:	8b 05 b0 1c 00 00    	mov    0x1cb0(%rip),%eax        # 102014 <rand_seed>
  100364:	69 c0 0d 66 19 00    	imul   $0x19660d,%eax,%eax
  10036a:	05 5f f3 6e 3c       	add    $0x3c6ef35f,%eax
  10036f:	89 05 9f 1c 00 00    	mov    %eax,0x1c9f(%rip)        # 102014 <rand_seed>
    return rand_seed & RAND_MAX;
  100375:	8b 05 99 1c 00 00    	mov    0x1c99(%rip),%eax        # 102014 <rand_seed>
  10037b:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
}
  100380:	5d                   	pop    %rbp
  100381:	c3                   	ret

0000000000100382 <srand>:

void srand(unsigned seed) {
  100382:	55                   	push   %rbp
  100383:	48 89 e5             	mov    %rsp,%rbp
  100386:	48 83 ec 08          	sub    $0x8,%rsp
  10038a:	89 7d fc             	mov    %edi,-0x4(%rbp)
    rand_seed = seed;
  10038d:	8b 45 fc             	mov    -0x4(%rbp),%eax
  100390:	89 05 7e 1c 00 00    	mov    %eax,0x1c7e(%rip)        # 102014 <rand_seed>
    rand_seed_set = 1;
  100396:	c7 05 70 1c 00 00 01 	movl   $0x1,0x1c70(%rip)        # 102010 <rand_seed_set>
  10039d:	00 00 00 
}
  1003a0:	90                   	nop
  1003a1:	c9                   	leave
  1003a2:	c3                   	ret

00000000001003a3 <fill_numbuf>:
//    Print a message onto the console, starting at the given cursor position.

// snprintf, vsnprintf
//    Format a string into a buffer.

static char* fill_numbuf(char* numbuf_end, unsigned long val, int base) {
  1003a3:	55                   	push   %rbp
  1003a4:	48 89 e5             	mov    %rsp,%rbp
  1003a7:	48 83 ec 28          	sub    $0x28,%rsp
  1003ab:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  1003af:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
  1003b3:	89 55 dc             	mov    %edx,-0x24(%rbp)
    static const char upper_digits[] = "0123456789ABCDEF";
    static const char lower_digits[] = "0123456789abcdef";

    const char* digits = upper_digits;
  1003b6:	48 c7 45 f8 b0 11 10 	movq   $0x1011b0,-0x8(%rbp)
  1003bd:	00 
    if (base < 0) {
  1003be:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
  1003c2:	79 0b                	jns    1003cf <fill_numbuf+0x2c>
        digits = lower_digits;
  1003c4:	48 c7 45 f8 d0 11 10 	movq   $0x1011d0,-0x8(%rbp)
  1003cb:	00 
        base = -base;
  1003cc:	f7 5d dc             	negl   -0x24(%rbp)
    }

    *--numbuf_end = '\0';
  1003cf:	48 83 6d e8 01       	subq   $0x1,-0x18(%rbp)
  1003d4:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  1003d8:	c6 00 00             	movb   $0x0,(%rax)
    do {
        *--numbuf_end = digits[val % base];
  1003db:	8b 45 dc             	mov    -0x24(%rbp),%eax
  1003de:	48 63 c8             	movslq %eax,%rcx
  1003e1:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  1003e5:	ba 00 00 00 00       	mov    $0x0,%edx
  1003ea:	48 f7 f1             	div    %rcx
  1003ed:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  1003f1:	48 01 d0             	add    %rdx,%rax
  1003f4:	48 83 6d e8 01       	subq   $0x1,-0x18(%rbp)
  1003f9:	0f b6 10             	movzbl (%rax),%edx
  1003fc:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  100400:	88 10                	mov    %dl,(%rax)
        val /= base;
  100402:	8b 45 dc             	mov    -0x24(%rbp),%eax
  100405:	48 63 f0             	movslq %eax,%rsi
  100408:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  10040c:	ba 00 00 00 00       	mov    $0x0,%edx
  100411:	48 f7 f6             	div    %rsi
  100414:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
    } while (val != 0);
  100418:	48 83 7d e0 00       	cmpq   $0x0,-0x20(%rbp)
  10041d:	75 bc                	jne    1003db <fill_numbuf+0x38>
    return numbuf_end;
  10041f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
  100423:	c9                   	leave
  100424:	c3                   	ret

0000000000100425 <printer_vprintf>:
#define FLAG_NUMERIC            (1<<5)
#define FLAG_SIGNED             (1<<6)
#define FLAG_NEGATIVE           (1<<7)
#define FLAG_ALT2               (1<<8)

void printer_vprintf(printer* p, int color, const char* format, va_list val) {
  100425:	55                   	push   %rbp
  100426:	48 89 e5             	mov    %rsp,%rbp
  100429:	53                   	push   %rbx
  10042a:	48 81 ec 98 00 00 00 	sub    $0x98,%rsp
  100431:	48 89 bd 78 ff ff ff 	mov    %rdi,-0x88(%rbp)
  100438:	89 b5 74 ff ff ff    	mov    %esi,-0x8c(%rbp)
  10043e:	48 89 95 68 ff ff ff 	mov    %rdx,-0x98(%rbp)
  100445:	48 89 8d 60 ff ff ff 	mov    %rcx,-0xa0(%rbp)
#define NUMBUFSIZ 24
    char numbuf[NUMBUFSIZ];

    for (; *format; ++format) {
  10044c:	e9 32 0a 00 00       	jmp    100e83 <printer_vprintf+0xa5e>
        if (*format != '%') {
  100451:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  100458:	0f b6 00             	movzbl (%rax),%eax
  10045b:	3c 25                	cmp    $0x25,%al
  10045d:	74 31                	je     100490 <printer_vprintf+0x6b>
            p->putc(p, *format, color);
  10045f:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  100466:	4c 8b 00             	mov    (%rax),%r8
  100469:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  100470:	0f b6 00             	movzbl (%rax),%eax
  100473:	8b 95 74 ff ff ff    	mov    -0x8c(%rbp),%edx
  100479:	0f b6 c8             	movzbl %al,%ecx
  10047c:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  100483:	89 ce                	mov    %ecx,%esi
  100485:	48 89 c7             	mov    %rax,%rdi
  100488:	41 ff d0             	call   *%r8
            continue;
  10048b:	e9 eb 09 00 00       	jmp    100e7b <printer_vprintf+0xa56>
        }

        // process flags
        int flags = 0;
  100490:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%rbp)
        for (++format; *format; ++format) {
  100497:	48 83 85 68 ff ff ff 	addq   $0x1,-0x98(%rbp)
  10049e:	01 
  10049f:	eb 44                	jmp    1004e5 <printer_vprintf+0xc0>
            const char* flagc = strchr(flag_chars, *format);
  1004a1:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  1004a8:	0f b6 00             	movzbl (%rax),%eax
  1004ab:	0f be c0             	movsbl %al,%eax
  1004ae:	89 c6                	mov    %eax,%esi
  1004b0:	bf 90 11 10 00       	mov    $0x101190,%edi
  1004b5:	e8 42 fe ff ff       	call   1002fc <strchr>
  1004ba:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
            if (flagc) {
  1004be:	48 83 7d a8 00       	cmpq   $0x0,-0x58(%rbp)
  1004c3:	74 30                	je     1004f5 <printer_vprintf+0xd0>
                flags |= 1 << (flagc - flag_chars);
  1004c5:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  1004c9:	48 2d 90 11 10 00    	sub    $0x101190,%rax
  1004cf:	ba 01 00 00 00       	mov    $0x1,%edx
  1004d4:	89 c1                	mov    %eax,%ecx
  1004d6:	d3 e2                	shl    %cl,%edx
  1004d8:	89 d0                	mov    %edx,%eax
  1004da:	09 45 ec             	or     %eax,-0x14(%rbp)
        for (++format; *format; ++format) {
  1004dd:	48 83 85 68 ff ff ff 	addq   $0x1,-0x98(%rbp)
  1004e4:	01 
  1004e5:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  1004ec:	0f b6 00             	movzbl (%rax),%eax
  1004ef:	84 c0                	test   %al,%al
  1004f1:	75 ae                	jne    1004a1 <printer_vprintf+0x7c>
  1004f3:	eb 01                	jmp    1004f6 <printer_vprintf+0xd1>
            } else {
                break;
  1004f5:	90                   	nop
            }
        }

        // process width
        int width = -1;
  1004f6:	c7 45 e8 ff ff ff ff 	movl   $0xffffffff,-0x18(%rbp)
        if (*format >= '1' && *format <= '9') {
  1004fd:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  100504:	0f b6 00             	movzbl (%rax),%eax
  100507:	3c 30                	cmp    $0x30,%al
  100509:	7e 67                	jle    100572 <printer_vprintf+0x14d>
  10050b:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  100512:	0f b6 00             	movzbl (%rax),%eax
  100515:	3c 39                	cmp    $0x39,%al
  100517:	7f 59                	jg     100572 <printer_vprintf+0x14d>
            for (width = 0; *format >= '0' && *format <= '9'; ) {
  100519:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%rbp)
  100520:	eb 2e                	jmp    100550 <printer_vprintf+0x12b>
                width = 10 * width + *format++ - '0';
  100522:	8b 55 e8             	mov    -0x18(%rbp),%edx
  100525:	89 d0                	mov    %edx,%eax
  100527:	c1 e0 02             	shl    $0x2,%eax
  10052a:	01 d0                	add    %edx,%eax
  10052c:	01 c0                	add    %eax,%eax
  10052e:	89 c1                	mov    %eax,%ecx
  100530:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  100537:	48 8d 50 01          	lea    0x1(%rax),%rdx
  10053b:	48 89 95 68 ff ff ff 	mov    %rdx,-0x98(%rbp)
  100542:	0f b6 00             	movzbl (%rax),%eax
  100545:	0f be c0             	movsbl %al,%eax
  100548:	01 c8                	add    %ecx,%eax
  10054a:	83 e8 30             	sub    $0x30,%eax
  10054d:	89 45 e8             	mov    %eax,-0x18(%rbp)
            for (width = 0; *format >= '0' && *format <= '9'; ) {
  100550:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  100557:	0f b6 00             	movzbl (%rax),%eax
  10055a:	3c 2f                	cmp    $0x2f,%al
  10055c:	0f 8e 85 00 00 00    	jle    1005e7 <printer_vprintf+0x1c2>
  100562:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  100569:	0f b6 00             	movzbl (%rax),%eax
  10056c:	3c 39                	cmp    $0x39,%al
  10056e:	7e b2                	jle    100522 <printer_vprintf+0xfd>
        if (*format >= '1' && *format <= '9') {
  100570:	eb 75                	jmp    1005e7 <printer_vprintf+0x1c2>
            }
        } else if (*format == '*') {
  100572:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  100579:	0f b6 00             	movzbl (%rax),%eax
  10057c:	3c 2a                	cmp    $0x2a,%al
  10057e:	75 68                	jne    1005e8 <printer_vprintf+0x1c3>
            width = va_arg(val, int);
  100580:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100587:	8b 00                	mov    (%rax),%eax
  100589:	83 f8 2f             	cmp    $0x2f,%eax
  10058c:	77 30                	ja     1005be <printer_vprintf+0x199>
  10058e:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100595:	48 8b 50 10          	mov    0x10(%rax),%rdx
  100599:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1005a0:	8b 00                	mov    (%rax),%eax
  1005a2:	89 c0                	mov    %eax,%eax
  1005a4:	48 01 d0             	add    %rdx,%rax
  1005a7:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  1005ae:	8b 12                	mov    (%rdx),%edx
  1005b0:	8d 4a 08             	lea    0x8(%rdx),%ecx
  1005b3:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  1005ba:	89 0a                	mov    %ecx,(%rdx)
  1005bc:	eb 1a                	jmp    1005d8 <printer_vprintf+0x1b3>
  1005be:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1005c5:	48 8b 40 08          	mov    0x8(%rax),%rax
  1005c9:	48 8d 48 08          	lea    0x8(%rax),%rcx
  1005cd:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  1005d4:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  1005d8:	8b 00                	mov    (%rax),%eax
  1005da:	89 45 e8             	mov    %eax,-0x18(%rbp)
            ++format;
  1005dd:	48 83 85 68 ff ff ff 	addq   $0x1,-0x98(%rbp)
  1005e4:	01 
  1005e5:	eb 01                	jmp    1005e8 <printer_vprintf+0x1c3>
        if (*format >= '1' && *format <= '9') {
  1005e7:	90                   	nop
        }

        // process precision
        int precision = -1;
  1005e8:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%rbp)
        if (*format == '.') {
  1005ef:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  1005f6:	0f b6 00             	movzbl (%rax),%eax
  1005f9:	3c 2e                	cmp    $0x2e,%al
  1005fb:	0f 85 00 01 00 00    	jne    100701 <printer_vprintf+0x2dc>
            ++format;
  100601:	48 83 85 68 ff ff ff 	addq   $0x1,-0x98(%rbp)
  100608:	01 
            if (*format >= '0' && *format <= '9') {
  100609:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  100610:	0f b6 00             	movzbl (%rax),%eax
  100613:	3c 2f                	cmp    $0x2f,%al
  100615:	7e 67                	jle    10067e <printer_vprintf+0x259>
  100617:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  10061e:	0f b6 00             	movzbl (%rax),%eax
  100621:	3c 39                	cmp    $0x39,%al
  100623:	7f 59                	jg     10067e <printer_vprintf+0x259>
                for (precision = 0; *format >= '0' && *format <= '9'; ) {
  100625:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%rbp)
  10062c:	eb 2e                	jmp    10065c <printer_vprintf+0x237>
                    precision = 10 * precision + *format++ - '0';
  10062e:	8b 55 e4             	mov    -0x1c(%rbp),%edx
  100631:	89 d0                	mov    %edx,%eax
  100633:	c1 e0 02             	shl    $0x2,%eax
  100636:	01 d0                	add    %edx,%eax
  100638:	01 c0                	add    %eax,%eax
  10063a:	89 c1                	mov    %eax,%ecx
  10063c:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  100643:	48 8d 50 01          	lea    0x1(%rax),%rdx
  100647:	48 89 95 68 ff ff ff 	mov    %rdx,-0x98(%rbp)
  10064e:	0f b6 00             	movzbl (%rax),%eax
  100651:	0f be c0             	movsbl %al,%eax
  100654:	01 c8                	add    %ecx,%eax
  100656:	83 e8 30             	sub    $0x30,%eax
  100659:	89 45 e4             	mov    %eax,-0x1c(%rbp)
                for (precision = 0; *format >= '0' && *format <= '9'; ) {
  10065c:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  100663:	0f b6 00             	movzbl (%rax),%eax
  100666:	3c 2f                	cmp    $0x2f,%al
  100668:	0f 8e 85 00 00 00    	jle    1006f3 <printer_vprintf+0x2ce>
  10066e:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  100675:	0f b6 00             	movzbl (%rax),%eax
  100678:	3c 39                	cmp    $0x39,%al
  10067a:	7e b2                	jle    10062e <printer_vprintf+0x209>
            if (*format >= '0' && *format <= '9') {
  10067c:	eb 75                	jmp    1006f3 <printer_vprintf+0x2ce>
                }
            } else if (*format == '*') {
  10067e:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  100685:	0f b6 00             	movzbl (%rax),%eax
  100688:	3c 2a                	cmp    $0x2a,%al
  10068a:	75 68                	jne    1006f4 <printer_vprintf+0x2cf>
                precision = va_arg(val, int);
  10068c:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100693:	8b 00                	mov    (%rax),%eax
  100695:	83 f8 2f             	cmp    $0x2f,%eax
  100698:	77 30                	ja     1006ca <printer_vprintf+0x2a5>
  10069a:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1006a1:	48 8b 50 10          	mov    0x10(%rax),%rdx
  1006a5:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1006ac:	8b 00                	mov    (%rax),%eax
  1006ae:	89 c0                	mov    %eax,%eax
  1006b0:	48 01 d0             	add    %rdx,%rax
  1006b3:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  1006ba:	8b 12                	mov    (%rdx),%edx
  1006bc:	8d 4a 08             	lea    0x8(%rdx),%ecx
  1006bf:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  1006c6:	89 0a                	mov    %ecx,(%rdx)
  1006c8:	eb 1a                	jmp    1006e4 <printer_vprintf+0x2bf>
  1006ca:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1006d1:	48 8b 40 08          	mov    0x8(%rax),%rax
  1006d5:	48 8d 48 08          	lea    0x8(%rax),%rcx
  1006d9:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  1006e0:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  1006e4:	8b 00                	mov    (%rax),%eax
  1006e6:	89 45 e4             	mov    %eax,-0x1c(%rbp)
                ++format;
  1006e9:	48 83 85 68 ff ff ff 	addq   $0x1,-0x98(%rbp)
  1006f0:	01 
  1006f1:	eb 01                	jmp    1006f4 <printer_vprintf+0x2cf>
            if (*format >= '0' && *format <= '9') {
  1006f3:	90                   	nop
            }
            if (precision < 0) {
  1006f4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%rbp)
  1006f8:	79 07                	jns    100701 <printer_vprintf+0x2dc>
                precision = 0;
  1006fa:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%rbp)
            }
        }

        // process main conversion character
        int base = 10;
  100701:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%rbp)
        unsigned long num = 0;
  100708:	48 c7 45 d8 00 00 00 	movq   $0x0,-0x28(%rbp)
  10070f:	00 
        int length = 0;
  100710:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%rbp)
        char* data = "";
  100717:	48 c7 45 c8 96 11 10 	movq   $0x101196,-0x38(%rbp)
  10071e:	00 
    again:
        switch (*format) {
  10071f:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  100726:	0f b6 00             	movzbl (%rax),%eax
  100729:	0f be c0             	movsbl %al,%eax
  10072c:	83 f8 7a             	cmp    $0x7a,%eax
  10072f:	0f 84 a4 00 00 00    	je     1007d9 <printer_vprintf+0x3b4>
  100735:	83 f8 7a             	cmp    $0x7a,%eax
  100738:	0f 8f 3d 04 00 00    	jg     100b7b <printer_vprintf+0x756>
  10073e:	83 f8 78             	cmp    $0x78,%eax
  100741:	0f 84 76 02 00 00    	je     1009bd <printer_vprintf+0x598>
  100747:	83 f8 78             	cmp    $0x78,%eax
  10074a:	0f 8f 2b 04 00 00    	jg     100b7b <printer_vprintf+0x756>
  100750:	83 f8 75             	cmp    $0x75,%eax
  100753:	0f 84 94 01 00 00    	je     1008ed <printer_vprintf+0x4c8>
  100759:	83 f8 75             	cmp    $0x75,%eax
  10075c:	0f 8f 19 04 00 00    	jg     100b7b <printer_vprintf+0x756>
  100762:	83 f8 73             	cmp    $0x73,%eax
  100765:	0f 84 dc 02 00 00    	je     100a47 <printer_vprintf+0x622>
  10076b:	83 f8 73             	cmp    $0x73,%eax
  10076e:	0f 8f 07 04 00 00    	jg     100b7b <printer_vprintf+0x756>
  100774:	83 f8 70             	cmp    $0x70,%eax
  100777:	0f 84 58 02 00 00    	je     1009d5 <printer_vprintf+0x5b0>
  10077d:	83 f8 70             	cmp    $0x70,%eax
  100780:	0f 8f f5 03 00 00    	jg     100b7b <printer_vprintf+0x756>
  100786:	83 f8 6c             	cmp    $0x6c,%eax
  100789:	74 4e                	je     1007d9 <printer_vprintf+0x3b4>
  10078b:	83 f8 6c             	cmp    $0x6c,%eax
  10078e:	0f 8f e7 03 00 00    	jg     100b7b <printer_vprintf+0x756>
  100794:	83 f8 69             	cmp    $0x69,%eax
  100797:	74 54                	je     1007ed <printer_vprintf+0x3c8>
  100799:	83 f8 69             	cmp    $0x69,%eax
  10079c:	0f 8f d9 03 00 00    	jg     100b7b <printer_vprintf+0x756>
  1007a2:	83 f8 64             	cmp    $0x64,%eax
  1007a5:	74 46                	je     1007ed <printer_vprintf+0x3c8>
  1007a7:	83 f8 64             	cmp    $0x64,%eax
  1007aa:	0f 8f cb 03 00 00    	jg     100b7b <printer_vprintf+0x756>
  1007b0:	83 f8 63             	cmp    $0x63,%eax
  1007b3:	0f 84 57 03 00 00    	je     100b10 <printer_vprintf+0x6eb>
  1007b9:	83 f8 63             	cmp    $0x63,%eax
  1007bc:	0f 8f b9 03 00 00    	jg     100b7b <printer_vprintf+0x756>
  1007c2:	83 f8 43             	cmp    $0x43,%eax
  1007c5:	0f 84 e0 02 00 00    	je     100aab <printer_vprintf+0x686>
  1007cb:	83 f8 58             	cmp    $0x58,%eax
  1007ce:	0f 84 f5 01 00 00    	je     1009c9 <printer_vprintf+0x5a4>
  1007d4:	e9 a2 03 00 00       	jmp    100b7b <printer_vprintf+0x756>
        case 'l':
        case 'z':
            length = 1;
  1007d9:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%rbp)
            ++format;
  1007e0:	48 83 85 68 ff ff ff 	addq   $0x1,-0x98(%rbp)
  1007e7:	01 
            goto again;
  1007e8:	e9 32 ff ff ff       	jmp    10071f <printer_vprintf+0x2fa>
        case 'd':
        case 'i': {
            long x = length ? va_arg(val, long) : va_arg(val, int);
  1007ed:	83 7d d4 00          	cmpl   $0x0,-0x2c(%rbp)
  1007f1:	74 61                	je     100854 <printer_vprintf+0x42f>
  1007f3:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1007fa:	8b 00                	mov    (%rax),%eax
  1007fc:	83 f8 2f             	cmp    $0x2f,%eax
  1007ff:	77 30                	ja     100831 <printer_vprintf+0x40c>
  100801:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100808:	48 8b 50 10          	mov    0x10(%rax),%rdx
  10080c:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100813:	8b 00                	mov    (%rax),%eax
  100815:	89 c0                	mov    %eax,%eax
  100817:	48 01 d0             	add    %rdx,%rax
  10081a:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  100821:	8b 12                	mov    (%rdx),%edx
  100823:	8d 4a 08             	lea    0x8(%rdx),%ecx
  100826:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  10082d:	89 0a                	mov    %ecx,(%rdx)
  10082f:	eb 1a                	jmp    10084b <printer_vprintf+0x426>
  100831:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100838:	48 8b 40 08          	mov    0x8(%rax),%rax
  10083c:	48 8d 48 08          	lea    0x8(%rax),%rcx
  100840:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  100847:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  10084b:	48 8b 00             	mov    (%rax),%rax
  10084e:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  100852:	eb 60                	jmp    1008b4 <printer_vprintf+0x48f>
  100854:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  10085b:	8b 00                	mov    (%rax),%eax
  10085d:	83 f8 2f             	cmp    $0x2f,%eax
  100860:	77 30                	ja     100892 <printer_vprintf+0x46d>
  100862:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100869:	48 8b 50 10          	mov    0x10(%rax),%rdx
  10086d:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100874:	8b 00                	mov    (%rax),%eax
  100876:	89 c0                	mov    %eax,%eax
  100878:	48 01 d0             	add    %rdx,%rax
  10087b:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  100882:	8b 12                	mov    (%rdx),%edx
  100884:	8d 4a 08             	lea    0x8(%rdx),%ecx
  100887:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  10088e:	89 0a                	mov    %ecx,(%rdx)
  100890:	eb 1a                	jmp    1008ac <printer_vprintf+0x487>
  100892:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100899:	48 8b 40 08          	mov    0x8(%rax),%rax
  10089d:	48 8d 48 08          	lea    0x8(%rax),%rcx
  1008a1:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  1008a8:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  1008ac:	8b 00                	mov    (%rax),%eax
  1008ae:	48 98                	cltq
  1008b0:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
            int negative = x < 0 ? FLAG_NEGATIVE : 0;
  1008b4:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  1008b8:	48 c1 f8 38          	sar    $0x38,%rax
  1008bc:	25 80 00 00 00       	and    $0x80,%eax
  1008c1:	89 45 a4             	mov    %eax,-0x5c(%rbp)
            num = negative ? -x : x;
  1008c4:	83 7d a4 00          	cmpl   $0x0,-0x5c(%rbp)
  1008c8:	74 0d                	je     1008d7 <printer_vprintf+0x4b2>
  1008ca:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  1008ce:	48 f7 d8             	neg    %rax
  1008d1:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
  1008d5:	eb 08                	jmp    1008df <printer_vprintf+0x4ba>
  1008d7:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
  1008db:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
            flags |= FLAG_NUMERIC | FLAG_SIGNED | negative;
  1008df:	8b 45 a4             	mov    -0x5c(%rbp),%eax
  1008e2:	83 c8 60             	or     $0x60,%eax
  1008e5:	09 45 ec             	or     %eax,-0x14(%rbp)
            break;
  1008e8:	e9 d3 02 00 00       	jmp    100bc0 <printer_vprintf+0x79b>
        }
        case 'u':
        format_unsigned:
            num = length ? va_arg(val, unsigned long) : va_arg(val, unsigned);
  1008ed:	83 7d d4 00          	cmpl   $0x0,-0x2c(%rbp)
  1008f1:	74 61                	je     100954 <printer_vprintf+0x52f>
  1008f3:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1008fa:	8b 00                	mov    (%rax),%eax
  1008fc:	83 f8 2f             	cmp    $0x2f,%eax
  1008ff:	77 30                	ja     100931 <printer_vprintf+0x50c>
  100901:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100908:	48 8b 50 10          	mov    0x10(%rax),%rdx
  10090c:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100913:	8b 00                	mov    (%rax),%eax
  100915:	89 c0                	mov    %eax,%eax
  100917:	48 01 d0             	add    %rdx,%rax
  10091a:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  100921:	8b 12                	mov    (%rdx),%edx
  100923:	8d 4a 08             	lea    0x8(%rdx),%ecx
  100926:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  10092d:	89 0a                	mov    %ecx,(%rdx)
  10092f:	eb 1a                	jmp    10094b <printer_vprintf+0x526>
  100931:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100938:	48 8b 40 08          	mov    0x8(%rax),%rax
  10093c:	48 8d 48 08          	lea    0x8(%rax),%rcx
  100940:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  100947:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  10094b:	48 8b 00             	mov    (%rax),%rax
  10094e:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
  100952:	eb 60                	jmp    1009b4 <printer_vprintf+0x58f>
  100954:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  10095b:	8b 00                	mov    (%rax),%eax
  10095d:	83 f8 2f             	cmp    $0x2f,%eax
  100960:	77 30                	ja     100992 <printer_vprintf+0x56d>
  100962:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100969:	48 8b 50 10          	mov    0x10(%rax),%rdx
  10096d:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100974:	8b 00                	mov    (%rax),%eax
  100976:	89 c0                	mov    %eax,%eax
  100978:	48 01 d0             	add    %rdx,%rax
  10097b:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  100982:	8b 12                	mov    (%rdx),%edx
  100984:	8d 4a 08             	lea    0x8(%rdx),%ecx
  100987:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  10098e:	89 0a                	mov    %ecx,(%rdx)
  100990:	eb 1a                	jmp    1009ac <printer_vprintf+0x587>
  100992:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100999:	48 8b 40 08          	mov    0x8(%rax),%rax
  10099d:	48 8d 48 08          	lea    0x8(%rax),%rcx
  1009a1:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  1009a8:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  1009ac:	8b 00                	mov    (%rax),%eax
  1009ae:	89 c0                	mov    %eax,%eax
  1009b0:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
            flags |= FLAG_NUMERIC;
  1009b4:	83 4d ec 20          	orl    $0x20,-0x14(%rbp)
            break;
  1009b8:	e9 03 02 00 00       	jmp    100bc0 <printer_vprintf+0x79b>
        case 'x':
            base = -16;
  1009bd:	c7 45 e0 f0 ff ff ff 	movl   $0xfffffff0,-0x20(%rbp)
            goto format_unsigned;
  1009c4:	e9 24 ff ff ff       	jmp    1008ed <printer_vprintf+0x4c8>
        case 'X':
            base = 16;
  1009c9:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%rbp)
            goto format_unsigned;
  1009d0:	e9 18 ff ff ff       	jmp    1008ed <printer_vprintf+0x4c8>
        case 'p':
            num = (uintptr_t) va_arg(val, void*);
  1009d5:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1009dc:	8b 00                	mov    (%rax),%eax
  1009de:	83 f8 2f             	cmp    $0x2f,%eax
  1009e1:	77 30                	ja     100a13 <printer_vprintf+0x5ee>
  1009e3:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1009ea:	48 8b 50 10          	mov    0x10(%rax),%rdx
  1009ee:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  1009f5:	8b 00                	mov    (%rax),%eax
  1009f7:	89 c0                	mov    %eax,%eax
  1009f9:	48 01 d0             	add    %rdx,%rax
  1009fc:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  100a03:	8b 12                	mov    (%rdx),%edx
  100a05:	8d 4a 08             	lea    0x8(%rdx),%ecx
  100a08:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  100a0f:	89 0a                	mov    %ecx,(%rdx)
  100a11:	eb 1a                	jmp    100a2d <printer_vprintf+0x608>
  100a13:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100a1a:	48 8b 40 08          	mov    0x8(%rax),%rax
  100a1e:	48 8d 48 08          	lea    0x8(%rax),%rcx
  100a22:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  100a29:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  100a2d:	48 8b 00             	mov    (%rax),%rax
  100a30:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
            base = -16;
  100a34:	c7 45 e0 f0 ff ff ff 	movl   $0xfffffff0,-0x20(%rbp)
            flags |= FLAG_ALT | FLAG_ALT2 | FLAG_NUMERIC;
  100a3b:	81 4d ec 21 01 00 00 	orl    $0x121,-0x14(%rbp)
            break;
  100a42:	e9 79 01 00 00       	jmp    100bc0 <printer_vprintf+0x79b>
        case 's':
            data = va_arg(val, char*);
  100a47:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100a4e:	8b 00                	mov    (%rax),%eax
  100a50:	83 f8 2f             	cmp    $0x2f,%eax
  100a53:	77 30                	ja     100a85 <printer_vprintf+0x660>
  100a55:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100a5c:	48 8b 50 10          	mov    0x10(%rax),%rdx
  100a60:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100a67:	8b 00                	mov    (%rax),%eax
  100a69:	89 c0                	mov    %eax,%eax
  100a6b:	48 01 d0             	add    %rdx,%rax
  100a6e:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  100a75:	8b 12                	mov    (%rdx),%edx
  100a77:	8d 4a 08             	lea    0x8(%rdx),%ecx
  100a7a:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  100a81:	89 0a                	mov    %ecx,(%rdx)
  100a83:	eb 1a                	jmp    100a9f <printer_vprintf+0x67a>
  100a85:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100a8c:	48 8b 40 08          	mov    0x8(%rax),%rax
  100a90:	48 8d 48 08          	lea    0x8(%rax),%rcx
  100a94:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  100a9b:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  100a9f:	48 8b 00             	mov    (%rax),%rax
  100aa2:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
            break;
  100aa6:	e9 15 01 00 00       	jmp    100bc0 <printer_vprintf+0x79b>
        case 'C':
            color = va_arg(val, int);
  100aab:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100ab2:	8b 00                	mov    (%rax),%eax
  100ab4:	83 f8 2f             	cmp    $0x2f,%eax
  100ab7:	77 30                	ja     100ae9 <printer_vprintf+0x6c4>
  100ab9:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100ac0:	48 8b 50 10          	mov    0x10(%rax),%rdx
  100ac4:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100acb:	8b 00                	mov    (%rax),%eax
  100acd:	89 c0                	mov    %eax,%eax
  100acf:	48 01 d0             	add    %rdx,%rax
  100ad2:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  100ad9:	8b 12                	mov    (%rdx),%edx
  100adb:	8d 4a 08             	lea    0x8(%rdx),%ecx
  100ade:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  100ae5:	89 0a                	mov    %ecx,(%rdx)
  100ae7:	eb 1a                	jmp    100b03 <printer_vprintf+0x6de>
  100ae9:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100af0:	48 8b 40 08          	mov    0x8(%rax),%rax
  100af4:	48 8d 48 08          	lea    0x8(%rax),%rcx
  100af8:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  100aff:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  100b03:	8b 00                	mov    (%rax),%eax
  100b05:	89 85 74 ff ff ff    	mov    %eax,-0x8c(%rbp)
            goto done;
  100b0b:	e9 6b 03 00 00       	jmp    100e7b <printer_vprintf+0xa56>
        case 'c':
            data = numbuf;
  100b10:	48 8d 45 8c          	lea    -0x74(%rbp),%rax
  100b14:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
            numbuf[0] = va_arg(val, int);
  100b18:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100b1f:	8b 00                	mov    (%rax),%eax
  100b21:	83 f8 2f             	cmp    $0x2f,%eax
  100b24:	77 30                	ja     100b56 <printer_vprintf+0x731>
  100b26:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100b2d:	48 8b 50 10          	mov    0x10(%rax),%rdx
  100b31:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100b38:	8b 00                	mov    (%rax),%eax
  100b3a:	89 c0                	mov    %eax,%eax
  100b3c:	48 01 d0             	add    %rdx,%rax
  100b3f:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  100b46:	8b 12                	mov    (%rdx),%edx
  100b48:	8d 4a 08             	lea    0x8(%rdx),%ecx
  100b4b:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  100b52:	89 0a                	mov    %ecx,(%rdx)
  100b54:	eb 1a                	jmp    100b70 <printer_vprintf+0x74b>
  100b56:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
  100b5d:	48 8b 40 08          	mov    0x8(%rax),%rax
  100b61:	48 8d 48 08          	lea    0x8(%rax),%rcx
  100b65:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
  100b6c:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  100b70:	8b 00                	mov    (%rax),%eax
  100b72:	88 45 8c             	mov    %al,-0x74(%rbp)
            numbuf[1] = '\0';
  100b75:	c6 45 8d 00          	movb   $0x0,-0x73(%rbp)
            break;
  100b79:	eb 45                	jmp    100bc0 <printer_vprintf+0x79b>
        default:
            data = numbuf;
  100b7b:	48 8d 45 8c          	lea    -0x74(%rbp),%rax
  100b7f:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
            numbuf[0] = (*format ? *format : '%');
  100b83:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  100b8a:	0f b6 00             	movzbl (%rax),%eax
  100b8d:	84 c0                	test   %al,%al
  100b8f:	74 0c                	je     100b9d <printer_vprintf+0x778>
  100b91:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  100b98:	0f b6 00             	movzbl (%rax),%eax
  100b9b:	eb 05                	jmp    100ba2 <printer_vprintf+0x77d>
  100b9d:	b8 25 00 00 00       	mov    $0x25,%eax
  100ba2:	88 45 8c             	mov    %al,-0x74(%rbp)
            numbuf[1] = '\0';
  100ba5:	c6 45 8d 00          	movb   $0x0,-0x73(%rbp)
            if (!*format) {
  100ba9:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  100bb0:	0f b6 00             	movzbl (%rax),%eax
  100bb3:	84 c0                	test   %al,%al
  100bb5:	75 08                	jne    100bbf <printer_vprintf+0x79a>
                format--;
  100bb7:	48 83 ad 68 ff ff ff 	subq   $0x1,-0x98(%rbp)
  100bbe:	01 
            }
            break;
  100bbf:	90                   	nop
        }

        if (flags & FLAG_NUMERIC) {
  100bc0:	8b 45 ec             	mov    -0x14(%rbp),%eax
  100bc3:	83 e0 20             	and    $0x20,%eax
  100bc6:	85 c0                	test   %eax,%eax
  100bc8:	74 1e                	je     100be8 <printer_vprintf+0x7c3>
            data = fill_numbuf(numbuf + NUMBUFSIZ, num, base);
  100bca:	48 8d 45 8c          	lea    -0x74(%rbp),%rax
  100bce:	48 83 c0 18          	add    $0x18,%rax
  100bd2:	8b 55 e0             	mov    -0x20(%rbp),%edx
  100bd5:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
  100bd9:	48 89 ce             	mov    %rcx,%rsi
  100bdc:	48 89 c7             	mov    %rax,%rdi
  100bdf:	e8 bf f7 ff ff       	call   1003a3 <fill_numbuf>
  100be4:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
        }

        const char* prefix = "";
  100be8:	48 c7 45 b8 96 11 10 	movq   $0x101196,-0x48(%rbp)
  100bef:	00 
        if ((flags & FLAG_NUMERIC) && (flags & FLAG_SIGNED)) {
  100bf0:	8b 45 ec             	mov    -0x14(%rbp),%eax
  100bf3:	83 e0 20             	and    $0x20,%eax
  100bf6:	85 c0                	test   %eax,%eax
  100bf8:	74 48                	je     100c42 <printer_vprintf+0x81d>
  100bfa:	8b 45 ec             	mov    -0x14(%rbp),%eax
  100bfd:	83 e0 40             	and    $0x40,%eax
  100c00:	85 c0                	test   %eax,%eax
  100c02:	74 3e                	je     100c42 <printer_vprintf+0x81d>
            if (flags & FLAG_NEGATIVE) {
  100c04:	8b 45 ec             	mov    -0x14(%rbp),%eax
  100c07:	25 80 00 00 00       	and    $0x80,%eax
  100c0c:	85 c0                	test   %eax,%eax
  100c0e:	74 0a                	je     100c1a <printer_vprintf+0x7f5>
                prefix = "-";
  100c10:	48 c7 45 b8 97 11 10 	movq   $0x101197,-0x48(%rbp)
  100c17:	00 
            if (flags & FLAG_NEGATIVE) {
  100c18:	eb 75                	jmp    100c8f <printer_vprintf+0x86a>
            } else if (flags & FLAG_PLUSPOSITIVE) {
  100c1a:	8b 45 ec             	mov    -0x14(%rbp),%eax
  100c1d:	83 e0 10             	and    $0x10,%eax
  100c20:	85 c0                	test   %eax,%eax
  100c22:	74 0a                	je     100c2e <printer_vprintf+0x809>
                prefix = "+";
  100c24:	48 c7 45 b8 99 11 10 	movq   $0x101199,-0x48(%rbp)
  100c2b:	00 
            if (flags & FLAG_NEGATIVE) {
  100c2c:	eb 61                	jmp    100c8f <printer_vprintf+0x86a>
            } else if (flags & FLAG_SPACEPOSITIVE) {
  100c2e:	8b 45 ec             	mov    -0x14(%rbp),%eax
  100c31:	83 e0 08             	and    $0x8,%eax
  100c34:	85 c0                	test   %eax,%eax
  100c36:	74 57                	je     100c8f <printer_vprintf+0x86a>
                prefix = " ";
  100c38:	48 c7 45 b8 9b 11 10 	movq   $0x10119b,-0x48(%rbp)
  100c3f:	00 
            if (flags & FLAG_NEGATIVE) {
  100c40:	eb 4d                	jmp    100c8f <printer_vprintf+0x86a>
            }
        } else if ((flags & FLAG_NUMERIC) && (flags & FLAG_ALT)
  100c42:	8b 45 ec             	mov    -0x14(%rbp),%eax
  100c45:	83 e0 20             	and    $0x20,%eax
  100c48:	85 c0                	test   %eax,%eax
  100c4a:	74 44                	je     100c90 <printer_vprintf+0x86b>
  100c4c:	8b 45 ec             	mov    -0x14(%rbp),%eax
  100c4f:	83 e0 01             	and    $0x1,%eax
  100c52:	85 c0                	test   %eax,%eax
  100c54:	74 3a                	je     100c90 <printer_vprintf+0x86b>
                   && (base == 16 || base == -16)
  100c56:	83 7d e0 10          	cmpl   $0x10,-0x20(%rbp)
  100c5a:	74 06                	je     100c62 <printer_vprintf+0x83d>
  100c5c:	83 7d e0 f0          	cmpl   $0xfffffff0,-0x20(%rbp)
  100c60:	75 2e                	jne    100c90 <printer_vprintf+0x86b>
                   && (num || (flags & FLAG_ALT2))) {
  100c62:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
  100c67:	75 0c                	jne    100c75 <printer_vprintf+0x850>
  100c69:	8b 45 ec             	mov    -0x14(%rbp),%eax
  100c6c:	25 00 01 00 00       	and    $0x100,%eax
  100c71:	85 c0                	test   %eax,%eax
  100c73:	74 1b                	je     100c90 <printer_vprintf+0x86b>
            prefix = (base == -16 ? "0x" : "0X");
  100c75:	83 7d e0 f0          	cmpl   $0xfffffff0,-0x20(%rbp)
  100c79:	75 0a                	jne    100c85 <printer_vprintf+0x860>
  100c7b:	48 c7 45 b8 9d 11 10 	movq   $0x10119d,-0x48(%rbp)
  100c82:	00 
  100c83:	eb 0b                	jmp    100c90 <printer_vprintf+0x86b>
  100c85:	48 c7 45 b8 a0 11 10 	movq   $0x1011a0,-0x48(%rbp)
  100c8c:	00 
  100c8d:	eb 01                	jmp    100c90 <printer_vprintf+0x86b>
            if (flags & FLAG_NEGATIVE) {
  100c8f:	90                   	nop
        }

        int len;
        if (precision >= 0 && !(flags & FLAG_NUMERIC)) {
  100c90:	83 7d e4 00          	cmpl   $0x0,-0x1c(%rbp)
  100c94:	78 24                	js     100cba <printer_vprintf+0x895>
  100c96:	8b 45 ec             	mov    -0x14(%rbp),%eax
  100c99:	83 e0 20             	and    $0x20,%eax
  100c9c:	85 c0                	test   %eax,%eax
  100c9e:	75 1a                	jne    100cba <printer_vprintf+0x895>
            len = strnlen(data, precision);
  100ca0:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  100ca3:	48 63 d0             	movslq %eax,%rdx
  100ca6:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  100caa:	48 89 d6             	mov    %rdx,%rsi
  100cad:	48 89 c7             	mov    %rax,%rdi
  100cb0:	e8 44 f5 ff ff       	call   1001f9 <strnlen>
  100cb5:	89 45 b4             	mov    %eax,-0x4c(%rbp)
  100cb8:	eb 0f                	jmp    100cc9 <printer_vprintf+0x8a4>
        } else {
            len = strlen(data);
  100cba:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  100cbe:	48 89 c7             	mov    %rax,%rdi
  100cc1:	e8 02 f5 ff ff       	call   1001c8 <strlen>
  100cc6:	89 45 b4             	mov    %eax,-0x4c(%rbp)
        }
        int zeros;
        if ((flags & FLAG_NUMERIC) && precision >= 0) {
  100cc9:	8b 45 ec             	mov    -0x14(%rbp),%eax
  100ccc:	83 e0 20             	and    $0x20,%eax
  100ccf:	85 c0                	test   %eax,%eax
  100cd1:	74 22                	je     100cf5 <printer_vprintf+0x8d0>
  100cd3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%rbp)
  100cd7:	78 1c                	js     100cf5 <printer_vprintf+0x8d0>
            zeros = precision > len ? precision - len : 0;
  100cd9:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  100cdc:	3b 45 b4             	cmp    -0x4c(%rbp),%eax
  100cdf:	7e 0b                	jle    100cec <printer_vprintf+0x8c7>
  100ce1:	8b 45 e4             	mov    -0x1c(%rbp),%eax
  100ce4:	2b 45 b4             	sub    -0x4c(%rbp),%eax
  100ce7:	89 45 b0             	mov    %eax,-0x50(%rbp)
  100cea:	eb 65                	jmp    100d51 <printer_vprintf+0x92c>
  100cec:	c7 45 b0 00 00 00 00 	movl   $0x0,-0x50(%rbp)
  100cf3:	eb 5c                	jmp    100d51 <printer_vprintf+0x92c>
        } else if ((flags & FLAG_NUMERIC) && (flags & FLAG_ZERO)
  100cf5:	8b 45 ec             	mov    -0x14(%rbp),%eax
  100cf8:	83 e0 20             	and    $0x20,%eax
  100cfb:	85 c0                	test   %eax,%eax
  100cfd:	74 4b                	je     100d4a <printer_vprintf+0x925>
  100cff:	8b 45 ec             	mov    -0x14(%rbp),%eax
  100d02:	83 e0 02             	and    $0x2,%eax
  100d05:	85 c0                	test   %eax,%eax
  100d07:	74 41                	je     100d4a <printer_vprintf+0x925>
                   && !(flags & FLAG_LEFTJUSTIFY)
  100d09:	8b 45 ec             	mov    -0x14(%rbp),%eax
  100d0c:	83 e0 04             	and    $0x4,%eax
  100d0f:	85 c0                	test   %eax,%eax
  100d11:	75 37                	jne    100d4a <printer_vprintf+0x925>
                   && len + (int) strlen(prefix) < width) {
  100d13:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  100d17:	48 89 c7             	mov    %rax,%rdi
  100d1a:	e8 a9 f4 ff ff       	call   1001c8 <strlen>
  100d1f:	89 c2                	mov    %eax,%edx
  100d21:	8b 45 b4             	mov    -0x4c(%rbp),%eax
  100d24:	01 d0                	add    %edx,%eax
  100d26:	39 45 e8             	cmp    %eax,-0x18(%rbp)
  100d29:	7e 1f                	jle    100d4a <printer_vprintf+0x925>
            zeros = width - len - strlen(prefix);
  100d2b:	8b 45 e8             	mov    -0x18(%rbp),%eax
  100d2e:	2b 45 b4             	sub    -0x4c(%rbp),%eax
  100d31:	89 c3                	mov    %eax,%ebx
  100d33:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  100d37:	48 89 c7             	mov    %rax,%rdi
  100d3a:	e8 89 f4 ff ff       	call   1001c8 <strlen>
  100d3f:	89 c2                	mov    %eax,%edx
  100d41:	89 d8                	mov    %ebx,%eax
  100d43:	29 d0                	sub    %edx,%eax
  100d45:	89 45 b0             	mov    %eax,-0x50(%rbp)
  100d48:	eb 07                	jmp    100d51 <printer_vprintf+0x92c>
        } else {
            zeros = 0;
  100d4a:	c7 45 b0 00 00 00 00 	movl   $0x0,-0x50(%rbp)
        }
        width -= len + zeros + strlen(prefix);
  100d51:	8b 55 b4             	mov    -0x4c(%rbp),%edx
  100d54:	8b 45 b0             	mov    -0x50(%rbp),%eax
  100d57:	01 d0                	add    %edx,%eax
  100d59:	48 63 d8             	movslq %eax,%rbx
  100d5c:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  100d60:	48 89 c7             	mov    %rax,%rdi
  100d63:	e8 60 f4 ff ff       	call   1001c8 <strlen>
  100d68:	48 8d 14 03          	lea    (%rbx,%rax,1),%rdx
  100d6c:	8b 45 e8             	mov    -0x18(%rbp),%eax
  100d6f:	29 d0                	sub    %edx,%eax
  100d71:	89 45 e8             	mov    %eax,-0x18(%rbp)
        for (; !(flags & FLAG_LEFTJUSTIFY) && width > 0; --width) {
  100d74:	eb 25                	jmp    100d9b <printer_vprintf+0x976>
            p->putc(p, ' ', color);
  100d76:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  100d7d:	48 8b 08             	mov    (%rax),%rcx
  100d80:	8b 95 74 ff ff ff    	mov    -0x8c(%rbp),%edx
  100d86:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  100d8d:	be 20 00 00 00       	mov    $0x20,%esi
  100d92:	48 89 c7             	mov    %rax,%rdi
  100d95:	ff d1                	call   *%rcx
        for (; !(flags & FLAG_LEFTJUSTIFY) && width > 0; --width) {
  100d97:	83 6d e8 01          	subl   $0x1,-0x18(%rbp)
  100d9b:	8b 45 ec             	mov    -0x14(%rbp),%eax
  100d9e:	83 e0 04             	and    $0x4,%eax
  100da1:	85 c0                	test   %eax,%eax
  100da3:	75 36                	jne    100ddb <printer_vprintf+0x9b6>
  100da5:	83 7d e8 00          	cmpl   $0x0,-0x18(%rbp)
  100da9:	7f cb                	jg     100d76 <printer_vprintf+0x951>
        }
        for (; *prefix; ++prefix) {
  100dab:	eb 2e                	jmp    100ddb <printer_vprintf+0x9b6>
            p->putc(p, *prefix, color);
  100dad:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  100db4:	4c 8b 00             	mov    (%rax),%r8
  100db7:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  100dbb:	0f b6 00             	movzbl (%rax),%eax
  100dbe:	8b 95 74 ff ff ff    	mov    -0x8c(%rbp),%edx
  100dc4:	0f b6 c8             	movzbl %al,%ecx
  100dc7:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  100dce:	89 ce                	mov    %ecx,%esi
  100dd0:	48 89 c7             	mov    %rax,%rdi
  100dd3:	41 ff d0             	call   *%r8
        for (; *prefix; ++prefix) {
  100dd6:	48 83 45 b8 01       	addq   $0x1,-0x48(%rbp)
  100ddb:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
  100ddf:	0f b6 00             	movzbl (%rax),%eax
  100de2:	84 c0                	test   %al,%al
  100de4:	75 c7                	jne    100dad <printer_vprintf+0x988>
        }
        for (; zeros > 0; --zeros) {
  100de6:	eb 25                	jmp    100e0d <printer_vprintf+0x9e8>
            p->putc(p, '0', color);
  100de8:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  100def:	48 8b 08             	mov    (%rax),%rcx
  100df2:	8b 95 74 ff ff ff    	mov    -0x8c(%rbp),%edx
  100df8:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  100dff:	be 30 00 00 00       	mov    $0x30,%esi
  100e04:	48 89 c7             	mov    %rax,%rdi
  100e07:	ff d1                	call   *%rcx
        for (; zeros > 0; --zeros) {
  100e09:	83 6d b0 01          	subl   $0x1,-0x50(%rbp)
  100e0d:	83 7d b0 00          	cmpl   $0x0,-0x50(%rbp)
  100e11:	7f d5                	jg     100de8 <printer_vprintf+0x9c3>
        }
        for (; len > 0; ++data, --len) {
  100e13:	eb 32                	jmp    100e47 <printer_vprintf+0xa22>
            p->putc(p, *data, color);
  100e15:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  100e1c:	4c 8b 00             	mov    (%rax),%r8
  100e1f:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  100e23:	0f b6 00             	movzbl (%rax),%eax
  100e26:	8b 95 74 ff ff ff    	mov    -0x8c(%rbp),%edx
  100e2c:	0f b6 c8             	movzbl %al,%ecx
  100e2f:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  100e36:	89 ce                	mov    %ecx,%esi
  100e38:	48 89 c7             	mov    %rax,%rdi
  100e3b:	41 ff d0             	call   *%r8
        for (; len > 0; ++data, --len) {
  100e3e:	48 83 45 c8 01       	addq   $0x1,-0x38(%rbp)
  100e43:	83 6d b4 01          	subl   $0x1,-0x4c(%rbp)
  100e47:	83 7d b4 00          	cmpl   $0x0,-0x4c(%rbp)
  100e4b:	7f c8                	jg     100e15 <printer_vprintf+0x9f0>
        }
        for (; width > 0; --width) {
  100e4d:	eb 25                	jmp    100e74 <printer_vprintf+0xa4f>
            p->putc(p, ' ', color);
  100e4f:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  100e56:	48 8b 08             	mov    (%rax),%rcx
  100e59:	8b 95 74 ff ff ff    	mov    -0x8c(%rbp),%edx
  100e5f:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
  100e66:	be 20 00 00 00       	mov    $0x20,%esi
  100e6b:	48 89 c7             	mov    %rax,%rdi
  100e6e:	ff d1                	call   *%rcx
        for (; width > 0; --width) {
  100e70:	83 6d e8 01          	subl   $0x1,-0x18(%rbp)
  100e74:	83 7d e8 00          	cmpl   $0x0,-0x18(%rbp)
  100e78:	7f d5                	jg     100e4f <printer_vprintf+0xa2a>
        }
    done: ;
  100e7a:	90                   	nop
    for (; *format; ++format) {
  100e7b:	48 83 85 68 ff ff ff 	addq   $0x1,-0x98(%rbp)
  100e82:	01 
  100e83:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
  100e8a:	0f b6 00             	movzbl (%rax),%eax
  100e8d:	84 c0                	test   %al,%al
  100e8f:	0f 85 bc f5 ff ff    	jne    100451 <printer_vprintf+0x2c>
    }
}
  100e95:	90                   	nop
  100e96:	90                   	nop
  100e97:	48 8b 5d f8          	mov    -0x8(%rbp),%rbx
  100e9b:	c9                   	leave
  100e9c:	c3                   	ret

0000000000100e9d <console_putc>:
typedef struct console_printer {
    printer p;
    uint16_t* cursor;
} console_printer;

static void console_putc(printer* p, unsigned char c, int color) {
  100e9d:	55                   	push   %rbp
  100e9e:	48 89 e5             	mov    %rsp,%rbp
  100ea1:	48 83 ec 20          	sub    $0x20,%rsp
  100ea5:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  100ea9:	40 88 75 e7          	mov    %sil,-0x19(%rbp)
  100ead:	89 55 e0             	mov    %edx,-0x20(%rbp)
    console_printer* cp = (console_printer*) p;
  100eb0:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  100eb4:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
    if (cp->cursor >= console + CONSOLE_ROWS * CONSOLE_COLUMNS) {
  100eb8:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  100ebc:	48 8b 40 08          	mov    0x8(%rax),%rax
  100ec0:	ba a0 8f 0b 00       	mov    $0xb8fa0,%edx
  100ec5:	48 39 d0             	cmp    %rdx,%rax
  100ec8:	72 0c                	jb     100ed6 <console_putc+0x39>
        cp->cursor = console;
  100eca:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  100ece:	48 c7 40 08 00 80 0b 	movq   $0xb8000,0x8(%rax)
  100ed5:	00 
    }
    if (c == '\n') {
  100ed6:	80 7d e7 0a          	cmpb   $0xa,-0x19(%rbp)
  100eda:	75 78                	jne    100f54 <console_putc+0xb7>
        int pos = (cp->cursor - console) % 80;
  100edc:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  100ee0:	48 8b 40 08          	mov    0x8(%rax),%rax
  100ee4:	48 2d 00 80 0b 00    	sub    $0xb8000,%rax
  100eea:	48 d1 f8             	sar    $1,%rax
  100eed:	48 89 c1             	mov    %rax,%rcx
  100ef0:	48 ba 67 66 66 66 66 	movabs $0x6666666666666667,%rdx
  100ef7:	66 66 66 
  100efa:	48 89 c8             	mov    %rcx,%rax
  100efd:	48 f7 ea             	imul   %rdx
  100f00:	48 c1 fa 05          	sar    $0x5,%rdx
  100f04:	48 89 c8             	mov    %rcx,%rax
  100f07:	48 c1 f8 3f          	sar    $0x3f,%rax
  100f0b:	48 29 c2             	sub    %rax,%rdx
  100f0e:	48 89 d0             	mov    %rdx,%rax
  100f11:	48 c1 e0 02          	shl    $0x2,%rax
  100f15:	48 01 d0             	add    %rdx,%rax
  100f18:	48 c1 e0 04          	shl    $0x4,%rax
  100f1c:	48 29 c1             	sub    %rax,%rcx
  100f1f:	48 89 ca             	mov    %rcx,%rdx
  100f22:	89 55 fc             	mov    %edx,-0x4(%rbp)
        for (; pos != 80; pos++) {
  100f25:	eb 25                	jmp    100f4c <console_putc+0xaf>
            *cp->cursor++ = ' ' | color;
  100f27:	8b 45 e0             	mov    -0x20(%rbp),%eax
  100f2a:	83 c8 20             	or     $0x20,%eax
  100f2d:	89 c6                	mov    %eax,%esi
  100f2f:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  100f33:	48 8b 40 08          	mov    0x8(%rax),%rax
  100f37:	48 8d 48 02          	lea    0x2(%rax),%rcx
  100f3b:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  100f3f:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  100f43:	89 f2                	mov    %esi,%edx
  100f45:	66 89 10             	mov    %dx,(%rax)
        for (; pos != 80; pos++) {
  100f48:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  100f4c:	83 7d fc 50          	cmpl   $0x50,-0x4(%rbp)
  100f50:	75 d5                	jne    100f27 <console_putc+0x8a>
        }
    } else {
        *cp->cursor++ = c | color;
    }
}
  100f52:	eb 24                	jmp    100f78 <console_putc+0xdb>
        *cp->cursor++ = c | color;
  100f54:	0f b6 45 e7          	movzbl -0x19(%rbp),%eax
  100f58:	8b 55 e0             	mov    -0x20(%rbp),%edx
  100f5b:	09 d0                	or     %edx,%eax
  100f5d:	89 c6                	mov    %eax,%esi
  100f5f:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  100f63:	48 8b 40 08          	mov    0x8(%rax),%rax
  100f67:	48 8d 48 02          	lea    0x2(%rax),%rcx
  100f6b:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
  100f6f:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  100f73:	89 f2                	mov    %esi,%edx
  100f75:	66 89 10             	mov    %dx,(%rax)
}
  100f78:	90                   	nop
  100f79:	c9                   	leave
  100f7a:	c3                   	ret

0000000000100f7b <console_vprintf>:

int console_vprintf(int cpos, int color, const char* format, va_list val) {
  100f7b:	55                   	push   %rbp
  100f7c:	48 89 e5             	mov    %rsp,%rbp
  100f7f:	48 83 ec 30          	sub    $0x30,%rsp
  100f83:	89 7d ec             	mov    %edi,-0x14(%rbp)
  100f86:	89 75 e8             	mov    %esi,-0x18(%rbp)
  100f89:	48 89 55 e0          	mov    %rdx,-0x20(%rbp)
  100f8d:	48 89 4d d8          	mov    %rcx,-0x28(%rbp)
    struct console_printer cp;
    cp.p.putc = console_putc;
  100f91:	48 c7 45 f0 9d 0e 10 	movq   $0x100e9d,-0x10(%rbp)
  100f98:	00 
    if (cpos < 0 || cpos >= CONSOLE_ROWS * CONSOLE_COLUMNS) {
  100f99:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
  100f9d:	78 09                	js     100fa8 <console_vprintf+0x2d>
  100f9f:	81 7d ec cf 07 00 00 	cmpl   $0x7cf,-0x14(%rbp)
  100fa6:	7e 07                	jle    100faf <console_vprintf+0x34>
        cpos = 0;
  100fa8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%rbp)
    }
    cp.cursor = console + cpos;
  100faf:	8b 45 ec             	mov    -0x14(%rbp),%eax
  100fb2:	48 98                	cltq
  100fb4:	48 01 c0             	add    %rax,%rax
  100fb7:	48 05 00 80 0b 00    	add    $0xb8000,%rax
  100fbd:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    printer_vprintf(&cp.p, color, format, val);
  100fc1:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
  100fc5:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
  100fc9:	8b 75 e8             	mov    -0x18(%rbp),%esi
  100fcc:	48 8d 45 f0          	lea    -0x10(%rbp),%rax
  100fd0:	48 89 c7             	mov    %rax,%rdi
  100fd3:	e8 4d f4 ff ff       	call   100425 <printer_vprintf>
    return cp.cursor - console;
  100fd8:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  100fdc:	48 2d 00 80 0b 00    	sub    $0xb8000,%rax
  100fe2:	48 d1 f8             	sar    $1,%rax
}
  100fe5:	c9                   	leave
  100fe6:	c3                   	ret

0000000000100fe7 <console_printf>:

int console_printf(int cpos, int color, const char* format, ...) {
  100fe7:	55                   	push   %rbp
  100fe8:	48 89 e5             	mov    %rsp,%rbp
  100feb:	48 83 ec 60          	sub    $0x60,%rsp
  100fef:	89 7d ac             	mov    %edi,-0x54(%rbp)
  100ff2:	89 75 a8             	mov    %esi,-0x58(%rbp)
  100ff5:	48 89 55 a0          	mov    %rdx,-0x60(%rbp)
  100ff9:	48 89 4d e8          	mov    %rcx,-0x18(%rbp)
  100ffd:	4c 89 45 f0          	mov    %r8,-0x10(%rbp)
  101001:	4c 89 4d f8          	mov    %r9,-0x8(%rbp)
    va_list val;
    va_start(val, format);
  101005:	c7 45 b8 18 00 00 00 	movl   $0x18,-0x48(%rbp)
  10100c:	48 8d 45 10          	lea    0x10(%rbp),%rax
  101010:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  101014:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
  101018:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    cpos = console_vprintf(cpos, color, format, val);
  10101c:	48 8d 4d b8          	lea    -0x48(%rbp),%rcx
  101020:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
  101024:	8b 75 a8             	mov    -0x58(%rbp),%esi
  101027:	8b 45 ac             	mov    -0x54(%rbp),%eax
  10102a:	89 c7                	mov    %eax,%edi
  10102c:	e8 4a ff ff ff       	call   100f7b <console_vprintf>
  101031:	89 45 ac             	mov    %eax,-0x54(%rbp)
    va_end(val);
    return cpos;
  101034:	8b 45 ac             	mov    -0x54(%rbp),%eax
}
  101037:	c9                   	leave
  101038:	c3                   	ret

0000000000101039 <string_putc>:
    printer p;
    char* s;
    char* end;
} string_printer;

static void string_putc(printer* p, unsigned char c, int color) {
  101039:	55                   	push   %rbp
  10103a:	48 89 e5             	mov    %rsp,%rbp
  10103d:	48 83 ec 20          	sub    $0x20,%rsp
  101041:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
  101045:	40 88 75 e7          	mov    %sil,-0x19(%rbp)
  101049:	89 55 e0             	mov    %edx,-0x20(%rbp)
    string_printer* sp = (string_printer*) p;
  10104c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
  101050:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    if (sp->s < sp->end) {
  101054:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  101058:	48 8b 50 08          	mov    0x8(%rax),%rdx
  10105c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  101060:	48 8b 40 10          	mov    0x10(%rax),%rax
  101064:	48 39 c2             	cmp    %rax,%rdx
  101067:	73 1a                	jae    101083 <string_putc+0x4a>
        *sp->s++ = c;
  101069:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  10106d:	48 8b 40 08          	mov    0x8(%rax),%rax
  101071:	48 8d 48 01          	lea    0x1(%rax),%rcx
  101075:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  101079:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
  10107d:	0f b6 55 e7          	movzbl -0x19(%rbp),%edx
  101081:	88 10                	mov    %dl,(%rax)
    }
    (void) color;
}
  101083:	90                   	nop
  101084:	c9                   	leave
  101085:	c3                   	ret

0000000000101086 <vsnprintf>:

int vsnprintf(char* s, size_t size, const char* format, va_list val) {
  101086:	55                   	push   %rbp
  101087:	48 89 e5             	mov    %rsp,%rbp
  10108a:	48 83 ec 40          	sub    $0x40,%rsp
  10108e:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
  101092:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
  101096:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  10109a:	48 89 4d c0          	mov    %rcx,-0x40(%rbp)
    string_printer sp;
    sp.p.putc = string_putc;
  10109e:	48 c7 45 e8 39 10 10 	movq   $0x101039,-0x18(%rbp)
  1010a5:	00 
    sp.s = s;
  1010a6:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  1010aa:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
    if (size) {
  1010ae:	48 83 7d d0 00       	cmpq   $0x0,-0x30(%rbp)
  1010b3:	74 33                	je     1010e8 <vsnprintf+0x62>
        sp.end = s + size - 1;
  1010b5:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  1010b9:	48 8d 50 ff          	lea    -0x1(%rax),%rdx
  1010bd:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
  1010c1:	48 01 d0             	add    %rdx,%rax
  1010c4:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
        printer_vprintf(&sp.p, 0, format, val);
  1010c8:	48 8b 4d c0          	mov    -0x40(%rbp),%rcx
  1010cc:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
  1010d0:	48 8d 45 e8          	lea    -0x18(%rbp),%rax
  1010d4:	be 00 00 00 00       	mov    $0x0,%esi
  1010d9:	48 89 c7             	mov    %rax,%rdi
  1010dc:	e8 44 f3 ff ff       	call   100425 <printer_vprintf>
        *sp.s = 0;
  1010e1:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  1010e5:	c6 00 00             	movb   $0x0,(%rax)
    }
    return sp.s - s;
  1010e8:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  1010ec:	48 2b 45 d8          	sub    -0x28(%rbp),%rax
}
  1010f0:	c9                   	leave
  1010f1:	c3                   	ret

00000000001010f2 <snprintf>:

int snprintf(char* s, size_t size, const char* format, ...) {
  1010f2:	55                   	push   %rbp
  1010f3:	48 89 e5             	mov    %rsp,%rbp
  1010f6:	48 83 ec 70          	sub    $0x70,%rsp
  1010fa:	48 89 7d a8          	mov    %rdi,-0x58(%rbp)
  1010fe:	48 89 75 a0          	mov    %rsi,-0x60(%rbp)
  101102:	48 89 55 98          	mov    %rdx,-0x68(%rbp)
  101106:	48 89 4d e8          	mov    %rcx,-0x18(%rbp)
  10110a:	4c 89 45 f0          	mov    %r8,-0x10(%rbp)
  10110e:	4c 89 4d f8          	mov    %r9,-0x8(%rbp)
    va_list val;
    va_start(val, format);
  101112:	c7 45 b0 18 00 00 00 	movl   $0x18,-0x50(%rbp)
  101119:	48 8d 45 10          	lea    0x10(%rbp),%rax
  10111d:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  101121:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
  101125:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
    int n = vsnprintf(s, size, format, val);
  101129:	48 8d 4d b0          	lea    -0x50(%rbp),%rcx
  10112d:	48 8b 55 98          	mov    -0x68(%rbp),%rdx
  101131:	48 8b 75 a0          	mov    -0x60(%rbp),%rsi
  101135:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
  101139:	48 89 c7             	mov    %rax,%rdi
  10113c:	e8 45 ff ff ff       	call   101086 <vsnprintf>
  101141:	89 45 cc             	mov    %eax,-0x34(%rbp)
    va_end(val);
    return n;
  101144:	8b 45 cc             	mov    -0x34(%rbp),%eax
}
  101147:	c9                   	leave
  101148:	c3                   	ret

0000000000101149 <console_clear>:


// console_clear
//    Erases the console and moves the cursor to the upper left (CPOS(0, 0)).

void console_clear(void) {
  101149:	55                   	push   %rbp
  10114a:	48 89 e5             	mov    %rsp,%rbp
  10114d:	48 83 ec 10          	sub    $0x10,%rsp
    for (int i = 0; i < CONSOLE_ROWS * CONSOLE_COLUMNS; ++i) {
  101151:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
  101158:	eb 13                	jmp    10116d <console_clear+0x24>
        console[i] = ' ' | 0x0700;
  10115a:	8b 45 fc             	mov    -0x4(%rbp),%eax
  10115d:	48 98                	cltq
  10115f:	66 c7 84 00 00 80 0b 	movw   $0x720,0xb8000(%rax,%rax,1)
  101166:	00 20 07 
    for (int i = 0; i < CONSOLE_ROWS * CONSOLE_COLUMNS; ++i) {
  101169:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
  10116d:	81 7d fc cf 07 00 00 	cmpl   $0x7cf,-0x4(%rbp)
  101174:	7e e4                	jle    10115a <console_clear+0x11>
    }
    cursorpos = 0;
  101176:	c7 05 7c 7e fb ff 00 	movl   $0x0,-0x48184(%rip)        # b8ffc <cursorpos>
  10117d:	00 00 00 
}
  101180:	90                   	nop
  101181:	c9                   	leave
  101182:	c3                   	ret
