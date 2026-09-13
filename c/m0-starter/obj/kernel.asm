
obj/kernel.full:     file format elf64-x86-64


Disassembly of section .text:

0000000000040000 <entry_from_boot>:
# The entry_from_boot routine sets the stack pointer to the top of the
# OS kernel stack, then jumps to the `kernel` routine.

.globl entry_from_boot
entry_from_boot:
        movq $0x80000, %rsp
   40000:	48 c7 c4 00 00 08 00 	mov    $0x80000,%rsp
        movq %rsp, %rbp
   40007:	48 89 e5             	mov    %rsp,%rbp
        pushq $0
   4000a:	6a 00                	push   $0x0
        popfq
   4000c:	9d                   	popf
        // Check for multiboot command line; if found pass it along.
        cmpl $0x2BADB002, %eax
   4000d:	3d 02 b0 ad 2b       	cmp    $0x2badb002,%eax
        jne 1f
   40012:	75 0d                	jne    40021 <entry_from_boot+0x21>
        testl $4, (%rbx)
   40014:	f7 03 04 00 00 00    	testl  $0x4,(%rbx)
        je 1f
   4001a:	74 05                	je     40021 <entry_from_boot+0x21>
        movl 16(%rbx), %edi
   4001c:	8b 7b 10             	mov    0x10(%rbx),%edi
        jmp 2f
   4001f:	eb 07                	jmp    40028 <entry_from_boot+0x28>
1:      movq $0, %rdi
   40021:	48 c7 c7 00 00 00 00 	mov    $0x0,%rdi
2:      jmp kernel
   40028:	e9 3a 01 00 00       	jmp    40167 <kernel>
   4002d:	90                   	nop

000000000004002e <gpf_int_handler>:
# Interrupt handlers
.align 2

        .globl gpf_int_handler
gpf_int_handler:
        pushq $13               // trap number
   4002e:	6a 0d                	push   $0xd
        jmp generic_exception_handler
   40030:	eb 6e                	jmp    400a0 <generic_exception_handler>

0000000000040032 <pagefault_int_handler>:

        .globl pagefault_int_handler
pagefault_int_handler:
        pushq $14
   40032:	6a 0e                	push   $0xe
        jmp generic_exception_handler
   40034:	eb 6a                	jmp    400a0 <generic_exception_handler>

0000000000040036 <timer_int_handler>:

        .globl timer_int_handler
timer_int_handler:
        pushq $0                // error code
   40036:	6a 00                	push   $0x0
        pushq $32
   40038:	6a 20                	push   $0x20
        jmp generic_exception_handler
   4003a:	eb 64                	jmp    400a0 <generic_exception_handler>

000000000004003c <sys48_int_handler>:

sys48_int_handler:
        pushq $0
   4003c:	6a 00                	push   $0x0
        pushq $48
   4003e:	6a 30                	push   $0x30
        jmp generic_exception_handler
   40040:	eb 5e                	jmp    400a0 <generic_exception_handler>

0000000000040042 <sys49_int_handler>:

sys49_int_handler:
        pushq $0
   40042:	6a 00                	push   $0x0
        pushq $49
   40044:	6a 31                	push   $0x31
        jmp generic_exception_handler
   40046:	eb 58                	jmp    400a0 <generic_exception_handler>

0000000000040048 <sys50_int_handler>:

sys50_int_handler:
        pushq $0
   40048:	6a 00                	push   $0x0
        pushq $50
   4004a:	6a 32                	push   $0x32
        jmp generic_exception_handler
   4004c:	eb 52                	jmp    400a0 <generic_exception_handler>

000000000004004e <sys51_int_handler>:

sys51_int_handler:
        pushq $0
   4004e:	6a 00                	push   $0x0
        pushq $51
   40050:	6a 33                	push   $0x33
        jmp generic_exception_handler
   40052:	eb 4c                	jmp    400a0 <generic_exception_handler>

0000000000040054 <sys52_int_handler>:

sys52_int_handler:
        pushq $0
   40054:	6a 00                	push   $0x0
        pushq $52
   40056:	6a 34                	push   $0x34
        jmp generic_exception_handler
   40058:	eb 46                	jmp    400a0 <generic_exception_handler>

000000000004005a <sys53_int_handler>:

sys53_int_handler:
        pushq $0
   4005a:	6a 00                	push   $0x0
        pushq $53
   4005c:	6a 35                	push   $0x35
        jmp generic_exception_handler
   4005e:	eb 40                	jmp    400a0 <generic_exception_handler>

0000000000040060 <sys54_int_handler>:

sys54_int_handler:
        pushq $0
   40060:	6a 00                	push   $0x0
        pushq $54
   40062:	6a 36                	push   $0x36
        jmp generic_exception_handler
   40064:	eb 3a                	jmp    400a0 <generic_exception_handler>

0000000000040066 <sys55_int_handler>:

sys55_int_handler:
        pushq $0
   40066:	6a 00                	push   $0x0
        pushq $55
   40068:	6a 37                	push   $0x37
        jmp generic_exception_handler
   4006a:	eb 34                	jmp    400a0 <generic_exception_handler>

000000000004006c <sys56_int_handler>:

sys56_int_handler:
        pushq $0
   4006c:	6a 00                	push   $0x0
        pushq $56
   4006e:	6a 38                	push   $0x38
        jmp generic_exception_handler
   40070:	eb 2e                	jmp    400a0 <generic_exception_handler>

0000000000040072 <sys57_int_handler>:

sys57_int_handler:
        pushq $0
   40072:	6a 00                	push   $0x0
        pushq $57
   40074:	6a 39                	push   $0x39
        jmp generic_exception_handler
   40076:	eb 28                	jmp    400a0 <generic_exception_handler>

0000000000040078 <sys58_int_handler>:

sys58_int_handler:
        pushq $0
   40078:	6a 00                	push   $0x0
        pushq $58
   4007a:	6a 3a                	push   $0x3a
        jmp generic_exception_handler
   4007c:	eb 22                	jmp    400a0 <generic_exception_handler>

000000000004007e <sys59_int_handler>:

sys59_int_handler:
        pushq $0
   4007e:	6a 00                	push   $0x0
        pushq $59
   40080:	6a 3b                	push   $0x3b
        jmp generic_exception_handler
   40082:	eb 1c                	jmp    400a0 <generic_exception_handler>

0000000000040084 <sys60_int_handler>:

sys60_int_handler:
        pushq $0
   40084:	6a 00                	push   $0x0
        pushq $60
   40086:	6a 3c                	push   $0x3c
        jmp generic_exception_handler
   40088:	eb 16                	jmp    400a0 <generic_exception_handler>

000000000004008a <sys61_int_handler>:

sys61_int_handler:
        pushq $0
   4008a:	6a 00                	push   $0x0
        pushq $61
   4008c:	6a 3d                	push   $0x3d
        jmp generic_exception_handler
   4008e:	eb 10                	jmp    400a0 <generic_exception_handler>

0000000000040090 <sys62_int_handler>:

sys62_int_handler:
        pushq $0
   40090:	6a 00                	push   $0x0
        pushq $62
   40092:	6a 3e                	push   $0x3e
        jmp generic_exception_handler
   40094:	eb 0a                	jmp    400a0 <generic_exception_handler>

0000000000040096 <sys63_int_handler>:

sys63_int_handler:
        pushq $0
   40096:	6a 00                	push   $0x0
        pushq $63
   40098:	6a 3f                	push   $0x3f
        jmp generic_exception_handler
   4009a:	eb 04                	jmp    400a0 <generic_exception_handler>

000000000004009c <default_int_handler>:

        .globl default_int_handler
default_int_handler:
        pushq $0
   4009c:	6a 00                	push   $0x0
        jmp generic_exception_handler
   4009e:	eb 00                	jmp    400a0 <generic_exception_handler>

00000000000400a0 <generic_exception_handler>:


generic_exception_handler:
        pushq %gs
   400a0:	0f a8                	push   %gs
        pushq %fs
   400a2:	0f a0                	push   %fs
        pushq %r15
   400a4:	41 57                	push   %r15
        pushq %r14
   400a6:	41 56                	push   %r14
        pushq %r13
   400a8:	41 55                	push   %r13
        pushq %r12
   400aa:	41 54                	push   %r12
        pushq %r11
   400ac:	41 53                	push   %r11
        pushq %r10
   400ae:	41 52                	push   %r10
        pushq %r9
   400b0:	41 51                	push   %r9
        pushq %r8
   400b2:	41 50                	push   %r8
        pushq %rdi
   400b4:	57                   	push   %rdi
        pushq %rsi
   400b5:	56                   	push   %rsi
        pushq %rbp
   400b6:	55                   	push   %rbp
        pushq %rbx
   400b7:	53                   	push   %rbx
        pushq %rdx
   400b8:	52                   	push   %rdx
        pushq %rcx
   400b9:	51                   	push   %rcx
        pushq %rax
   400ba:	50                   	push   %rax
        movq %rsp, %rdi
   400bb:	48 89 e7             	mov    %rsp,%rdi
        call exception
   400be:	e8 e5 04 00 00       	call   405a8 <exception>

00000000000400c3 <exception_return>:
        # `exception` should never return.


        .globl exception_return
exception_return:
        movq %rdi, %rsp
   400c3:	48 89 fc             	mov    %rdi,%rsp
        popq %rax
   400c6:	58                   	pop    %rax
        popq %rcx
   400c7:	59                   	pop    %rcx
        popq %rdx
   400c8:	5a                   	pop    %rdx
        popq %rbx
   400c9:	5b                   	pop    %rbx
        popq %rbp
   400ca:	5d                   	pop    %rbp
        popq %rsi
   400cb:	5e                   	pop    %rsi
        popq %rdi
   400cc:	5f                   	pop    %rdi
        popq %r8
   400cd:	41 58                	pop    %r8
        popq %r9
   400cf:	41 59                	pop    %r9
        popq %r10
   400d1:	41 5a                	pop    %r10
        popq %r11
   400d3:	41 5b                	pop    %r11
        popq %r12
   400d5:	41 5c                	pop    %r12
        popq %r13
   400d7:	41 5d                	pop    %r13
        popq %r14
   400d9:	41 5e                	pop    %r14
        popq %r15
   400db:	41 5f                	pop    %r15
        popq %fs
   400dd:	0f a1                	pop    %fs
        popq %gs
   400df:	0f a9                	pop    %gs
        addq $16, %rsp
   400e1:	48 83 c4 10          	add    $0x10,%rsp
        iretq
   400e5:	48 cf                	iretq

00000000000400e7 <sys_int_handlers>:
   400e7:	3c 00                	cmp    $0x0,%al
   400e9:	04 00                	add    $0x0,%al
   400eb:	00 00                	add    %al,(%rax)
   400ed:	00 00                	add    %al,(%rax)
   400ef:	42 00 04 00          	add    %al,(%rax,%r8,1)
   400f3:	00 00                	add    %al,(%rax)
   400f5:	00 00                	add    %al,(%rax)
   400f7:	48 00 04 00          	rex.W add %al,(%rax,%rax,1)
   400fb:	00 00                	add    %al,(%rax)
   400fd:	00 00                	add    %al,(%rax)
   400ff:	4e 00 04 00          	rex.WRX add %r8b,(%rax,%r8,1)
   40103:	00 00                	add    %al,(%rax)
   40105:	00 00                	add    %al,(%rax)
   40107:	54                   	push   %rsp
   40108:	00 04 00             	add    %al,(%rax,%rax,1)
   4010b:	00 00                	add    %al,(%rax)
   4010d:	00 00                	add    %al,(%rax)
   4010f:	5a                   	pop    %rdx
   40110:	00 04 00             	add    %al,(%rax,%rax,1)
   40113:	00 00                	add    %al,(%rax)
   40115:	00 00                	add    %al,(%rax)
   40117:	60                   	(bad)
   40118:	00 04 00             	add    %al,(%rax,%rax,1)
   4011b:	00 00                	add    %al,(%rax)
   4011d:	00 00                	add    %al,(%rax)
   4011f:	66 00 04 00          	data16 add %al,(%rax,%rax,1)
   40123:	00 00                	add    %al,(%rax)
   40125:	00 00                	add    %al,(%rax)
   40127:	6c                   	insb   (%dx),(%rdi)
   40128:	00 04 00             	add    %al,(%rax,%rax,1)
   4012b:	00 00                	add    %al,(%rax)
   4012d:	00 00                	add    %al,(%rax)
   4012f:	72 00                	jb     40131 <sys_int_handlers+0x4a>
   40131:	04 00                	add    $0x0,%al
   40133:	00 00                	add    %al,(%rax)
   40135:	00 00                	add    %al,(%rax)
   40137:	78 00                	js     40139 <sys_int_handlers+0x52>
   40139:	04 00                	add    $0x0,%al
   4013b:	00 00                	add    %al,(%rax)
   4013d:	00 00                	add    %al,(%rax)
   4013f:	7e 00                	jle    40141 <sys_int_handlers+0x5a>
   40141:	04 00                	add    $0x0,%al
   40143:	00 00                	add    %al,(%rax)
   40145:	00 00                	add    %al,(%rax)
   40147:	84 00                	test   %al,(%rax)
   40149:	04 00                	add    $0x0,%al
   4014b:	00 00                	add    %al,(%rax)
   4014d:	00 00                	add    %al,(%rax)
   4014f:	8a 00                	mov    (%rax),%al
   40151:	04 00                	add    $0x0,%al
   40153:	00 00                	add    %al,(%rax)
   40155:	00 00                	add    %al,(%rax)
   40157:	90                   	nop
   40158:	00 04 00             	add    %al,(%rax,%rax,1)
   4015b:	00 00                	add    %al,(%rax)
   4015d:	00 00                	add    %al,(%rax)
   4015f:	96                   	xchg   %eax,%esi
   40160:	00 04 00             	add    %al,(%rax,%rax,1)
   40163:	00 00                	add    %al,(%rax)
	...

0000000000040167 <kernel>:

// kernel(command)
//    Initialize the hardware and processes and start running. The `command`
//    string is an optional string passed from the boot loader.

void kernel(const char* command) {
   40167:	55                   	push   %rbp
   40168:	48 89 e5             	mov    %rsp,%rbp
   4016b:	48 83 ec 20          	sub    $0x20,%rsp
   4016f:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
    hardware_init();
   40173:	e8 81 12 00 00       	call   413f9 <hardware_init>
    pageinfo_init();
   40178:	e8 60 09 00 00       	call   40add <pageinfo_init>
    console_clear();
   4017d:	e8 3f 48 00 00       	call   449c1 <console_clear>
    timer_init(HZ);
   40182:	bf 64 00 00 00       	mov    $0x64,%edi
   40187:	e8 53 17 00 00       	call   418df <timer_init>

    // Set up process descriptors
    memset(processes, 0, sizeof(processes));
   4018c:	ba 00 0f 00 00       	mov    $0xf00,%edx
   40191:	be 00 00 00 00       	mov    $0x0,%esi
   40196:	bf 00 d0 04 00       	mov    $0x4d000,%edi
   4019b:	e8 61 38 00 00       	call   43a01 <memset>
    for (pid_t i = 0; i < NPROC; i++) {
   401a0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
   401a7:	eb 34                	jmp    401dd <kernel+0x76>
        processes[i].p_pid = i;
   401a9:	8b 45 fc             	mov    -0x4(%rbp),%eax
   401ac:	48 98                	cltq
   401ae:	48 69 c0 f0 00 00 00 	imul   $0xf0,%rax,%rax
   401b5:	48 8d 90 00 d0 04 00 	lea    0x4d000(%rax),%rdx
   401bc:	8b 45 fc             	mov    -0x4(%rbp),%eax
   401bf:	89 02                	mov    %eax,(%rdx)
        processes[i].p_state = P_FREE;
   401c1:	8b 45 fc             	mov    -0x4(%rbp),%eax
   401c4:	48 98                	cltq
   401c6:	48 69 c0 f0 00 00 00 	imul   $0xf0,%rax,%rax
   401cd:	48 05 d8 d0 04 00    	add    $0x4d0d8,%rax
   401d3:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
    for (pid_t i = 0; i < NPROC; i++) {
   401d9:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
   401dd:	83 7d fc 0f          	cmpl   $0xf,-0x4(%rbp)
   401e1:	7e c6                	jle    401a9 <kernel+0x42>
    }

    if (command && strcmp(command, "malloc") == 0) {
   401e3:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
   401e8:	74 29                	je     40213 <kernel+0xac>
   401ea:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   401ee:	be 26 4a 04 00       	mov    $0x44a26,%esi
   401f3:	48 89 c7             	mov    %rax,%rdi
   401f6:	e8 ff 38 00 00       	call   43afa <strcmp>
   401fb:	85 c0                	test   %eax,%eax
   401fd:	75 14                	jne    40213 <kernel+0xac>
        process_setup(1, 1);
   401ff:	be 01 00 00 00       	mov    $0x1,%esi
   40204:	bf 01 00 00 00       	mov    $0x1,%edi
   40209:	e8 b8 00 00 00       	call   402c6 <process_setup>
   4020e:	e9 a9 00 00 00       	jmp    402bc <kernel+0x155>
    } else if (command && strcmp(command, "alloctests") == 0) {
   40213:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
   40218:	74 26                	je     40240 <kernel+0xd9>
   4021a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   4021e:	be 2d 4a 04 00       	mov    $0x44a2d,%esi
   40223:	48 89 c7             	mov    %rax,%rdi
   40226:	e8 cf 38 00 00       	call   43afa <strcmp>
   4022b:	85 c0                	test   %eax,%eax
   4022d:	75 11                	jne    40240 <kernel+0xd9>
        process_setup(1, 2);
   4022f:	be 02 00 00 00       	mov    $0x2,%esi
   40234:	bf 01 00 00 00       	mov    $0x1,%edi
   40239:	e8 88 00 00 00       	call   402c6 <process_setup>
   4023e:	eb 7c                	jmp    402bc <kernel+0x155>
    } else if (command && strcmp(command, "test") == 0){
   40240:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
   40245:	74 26                	je     4026d <kernel+0x106>
   40247:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   4024b:	be 38 4a 04 00       	mov    $0x44a38,%esi
   40250:	48 89 c7             	mov    %rax,%rdi
   40253:	e8 a2 38 00 00       	call   43afa <strcmp>
   40258:	85 c0                	test   %eax,%eax
   4025a:	75 11                	jne    4026d <kernel+0x106>
        process_setup(1, 3);
   4025c:	be 03 00 00 00       	mov    $0x3,%esi
   40261:	bf 01 00 00 00       	mov    $0x1,%edi
   40266:	e8 5b 00 00 00       	call   402c6 <process_setup>
   4026b:	eb 4f                	jmp    402bc <kernel+0x155>
    } else if (command && strcmp(command, "test2") == 0) {
   4026d:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
   40272:	74 39                	je     402ad <kernel+0x146>
   40274:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   40278:	be 3d 4a 04 00       	mov    $0x44a3d,%esi
   4027d:	48 89 c7             	mov    %rax,%rdi
   40280:	e8 75 38 00 00       	call   43afa <strcmp>
   40285:	85 c0                	test   %eax,%eax
   40287:	75 24                	jne    402ad <kernel+0x146>
        for (pid_t i = 1; i <= 2; ++i) {
   40289:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%rbp)
   40290:	eb 13                	jmp    402a5 <kernel+0x13e>
            process_setup(i, 3);
   40292:	8b 45 f8             	mov    -0x8(%rbp),%eax
   40295:	be 03 00 00 00       	mov    $0x3,%esi
   4029a:	89 c7                	mov    %eax,%edi
   4029c:	e8 25 00 00 00       	call   402c6 <process_setup>
        for (pid_t i = 1; i <= 2; ++i) {
   402a1:	83 45 f8 01          	addl   $0x1,-0x8(%rbp)
   402a5:	83 7d f8 02          	cmpl   $0x2,-0x8(%rbp)
   402a9:	7e e7                	jle    40292 <kernel+0x12b>
   402ab:	eb 0f                	jmp    402bc <kernel+0x155>
        }
    } else {
        process_setup(1, 0);
   402ad:	be 00 00 00 00       	mov    $0x0,%esi
   402b2:	bf 01 00 00 00       	mov    $0x1,%edi
   402b7:	e8 0a 00 00 00       	call   402c6 <process_setup>
    }

    // Switch to the first process using run()
    run(&processes[1]);
   402bc:	bf f0 d0 04 00       	mov    $0x4d0f0,%edi
   402c1:	e8 86 07 00 00       	call   40a4c <run>

00000000000402c6 <process_setup>:
// process_setup(pid, program_number)
//    Load application program `program_number` as process number `pid`.
//    This loads the application's code and data into memory, sets its
//    %rip and %rsp, gives it a stack page, and marks it as runnable.

void process_setup(pid_t pid, int program_number) {
   402c6:	55                   	push   %rbp
   402c7:	48 89 e5             	mov    %rsp,%rbp
   402ca:	48 83 ec 10          	sub    $0x10,%rsp
   402ce:	89 7d fc             	mov    %edi,-0x4(%rbp)
   402d1:	89 75 f8             	mov    %esi,-0x8(%rbp)
    process_init(&processes[pid], 0);
   402d4:	8b 45 fc             	mov    -0x4(%rbp),%eax
   402d7:	48 98                	cltq
   402d9:	48 69 c0 f0 00 00 00 	imul   $0xf0,%rax,%rax
   402e0:	48 05 00 d0 04 00    	add    $0x4d000,%rax
   402e6:	be 00 00 00 00       	mov    $0x0,%esi
   402eb:	48 89 c7             	mov    %rax,%rdi
   402ee:	e8 77 18 00 00       	call   41b6a <process_init>
    assert(process_config_tables(pid) == 0);
   402f3:	8b 45 fc             	mov    -0x4(%rbp),%eax
   402f6:	89 c7                	mov    %eax,%edi
   402f8:	e8 cd 2e 00 00       	call   431ca <process_config_tables>
   402fd:	85 c0                	test   %eax,%eax
   402ff:	74 14                	je     40315 <process_setup+0x4f>
   40301:	ba 48 4a 04 00       	mov    $0x44a48,%edx
   40306:	be 77 00 00 00       	mov    $0x77,%esi
   4030b:	bf 68 4a 04 00       	mov    $0x44a68,%edi
   40310:	e8 27 20 00 00       	call   4233c <assert_fail>

    /* Calls program_load in k-loader */
    assert(process_load(&processes[pid], program_number) >= 0);
   40315:	8b 45 fc             	mov    -0x4(%rbp),%eax
   40318:	48 98                	cltq
   4031a:	48 69 c0 f0 00 00 00 	imul   $0xf0,%rax,%rax
   40321:	48 8d 90 00 d0 04 00 	lea    0x4d000(%rax),%rdx
   40328:	8b 45 f8             	mov    -0x8(%rbp),%eax
   4032b:	89 c6                	mov    %eax,%esi
   4032d:	48 89 d7             	mov    %rdx,%rdi
   40330:	e8 e3 31 00 00       	call   43518 <process_load>
   40335:	85 c0                	test   %eax,%eax
   40337:	79 14                	jns    4034d <process_setup+0x87>
   40339:	ba 78 4a 04 00       	mov    $0x44a78,%edx
   4033e:	be 7a 00 00 00       	mov    $0x7a,%esi
   40343:	bf 68 4a 04 00       	mov    $0x44a68,%edi
   40348:	e8 ef 1f 00 00       	call   4233c <assert_fail>

    process_setup_stack(&processes[pid]);
   4034d:	8b 45 fc             	mov    -0x4(%rbp),%eax
   40350:	48 98                	cltq
   40352:	48 69 c0 f0 00 00 00 	imul   $0xf0,%rax,%rax
   40359:	48 05 00 d0 04 00    	add    $0x4d000,%rax
   4035f:	48 89 c7             	mov    %rax,%rdi
   40362:	e8 e9 31 00 00       	call   43550 <process_setup_stack>

    processes[pid].p_state = P_RUNNABLE;
   40367:	8b 45 fc             	mov    -0x4(%rbp),%eax
   4036a:	48 98                	cltq
   4036c:	48 69 c0 f0 00 00 00 	imul   $0xf0,%rax,%rax
   40373:	48 05 d8 d0 04 00    	add    $0x4d0d8,%rax
   40379:	c7 00 01 00 00 00    	movl   $0x1,(%rax)
}
   4037f:	90                   	nop
   40380:	c9                   	leave
   40381:	c3                   	ret

0000000000040382 <assign_physical_page>:
// assign_physical_page(addr, owner)
//    Allocates the page with physical address `addr` to the given owner.
//    Fails if physical page `addr` was already allocated. Returns 0 on
//    success and -1 on failure. Used by the program loader.

int assign_physical_page(uintptr_t addr, int8_t owner) {
   40382:	55                   	push   %rbp
   40383:	48 89 e5             	mov    %rsp,%rbp
   40386:	48 83 ec 10          	sub    $0x10,%rsp
   4038a:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
   4038e:	40 88 75 f7          	mov    %sil,-0x9(%rbp)
    if ((addr & 0xFFF) != 0
   40392:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   40396:	25 ff 0f 00 00       	and    $0xfff,%eax
   4039b:	48 85 c0             	test   %rax,%rax
   4039e:	75 20                	jne    403c0 <assign_physical_page+0x3e>
        || addr >= MEMSIZE_PHYSICAL
   403a0:	48 81 7d f8 ff ff 1f 	cmpq   $0x1fffff,-0x8(%rbp)
   403a7:	00 
   403a8:	77 16                	ja     403c0 <assign_physical_page+0x3e>
        || pageinfo[PAGENUMBER(addr)].refcount != 0) {
   403aa:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   403ae:	48 c1 e8 0c          	shr    $0xc,%rax
   403b2:	48 98                	cltq
   403b4:	0f b6 84 00 21 df 04 	movzbl 0x4df21(%rax,%rax,1),%eax
   403bb:	00 
   403bc:	84 c0                	test   %al,%al
   403be:	74 07                	je     403c7 <assign_physical_page+0x45>
        return -1;
   403c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
   403c5:	eb 2c                	jmp    403f3 <assign_physical_page+0x71>
    } else {
        pageinfo[PAGENUMBER(addr)].refcount = 1;
   403c7:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   403cb:	48 c1 e8 0c          	shr    $0xc,%rax
   403cf:	48 98                	cltq
   403d1:	c6 84 00 21 df 04 00 	movb   $0x1,0x4df21(%rax,%rax,1)
   403d8:	01 
        pageinfo[PAGENUMBER(addr)].owner = owner;
   403d9:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   403dd:	48 c1 e8 0c          	shr    $0xc,%rax
   403e1:	48 98                	cltq
   403e3:	0f b6 55 f7          	movzbl -0x9(%rbp),%edx
   403e7:	88 94 00 20 df 04 00 	mov    %dl,0x4df20(%rax,%rax,1)
        return 0;
   403ee:	b8 00 00 00 00       	mov    $0x0,%eax
    }
}
   403f3:	c9                   	leave
   403f4:	c3                   	ret

00000000000403f5 <syscall_fork>:

pid_t syscall_fork() {
   403f5:	55                   	push   %rbp
   403f6:	48 89 e5             	mov    %rsp,%rbp
    return process_fork(current);
   403f9:	48 8b 05 00 db 00 00 	mov    0xdb00(%rip),%rax        # 4df00 <current>
   40400:	48 89 c7             	mov    %rax,%rdi
   40403:	e8 fb 31 00 00       	call   43603 <process_fork>
}
   40408:	5d                   	pop    %rbp
   40409:	c3                   	ret

000000000004040a <syscall_exit>:


void syscall_exit() {
   4040a:	55                   	push   %rbp
   4040b:	48 89 e5             	mov    %rsp,%rbp
    process_free(current->p_pid);
   4040e:	48 8b 05 eb da 00 00 	mov    0xdaeb(%rip),%rax        # 4df00 <current>
   40415:	8b 00                	mov    (%rax),%eax
   40417:	89 c7                	mov    %eax,%edi
   40419:	e8 ca 2a 00 00       	call   42ee8 <process_free>
}
   4041e:	90                   	nop
   4041f:	5d                   	pop    %rbp
   40420:	c3                   	ret

0000000000040421 <syscall_page_alloc>:

int syscall_page_alloc(uintptr_t addr) {
   40421:	55                   	push   %rbp
   40422:	48 89 e5             	mov    %rsp,%rbp
   40425:	48 83 ec 10          	sub    $0x10,%rsp
   40429:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
    return process_page_alloc(current, addr);
   4042d:	48 8b 05 cc da 00 00 	mov    0xdacc(%rip),%rax        # 4df00 <current>
   40434:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
   40438:	48 89 d6             	mov    %rdx,%rsi
   4043b:	48 89 c7             	mov    %rax,%rdi
   4043e:	e8 52 34 00 00       	call   43895 <process_page_alloc>
}
   40443:	c9                   	leave
   40444:	c3                   	ret

0000000000040445 <sbrk>:


int sbrk(proc * p, intptr_t difference) {
   40445:	55                   	push   %rbp
   40446:	48 89 e5             	mov    %rsp,%rbp
   40449:	48 83 ec 10          	sub    $0x10,%rsp
   4044d:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
   40451:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
    // TODO : Your code here
    return 0;
   40455:	b8 00 00 00 00       	mov    $0x0,%eax
}
   4045a:	c9                   	leave
   4045b:	c3                   	ret

000000000004045c <syscall_mapping>:


void syscall_mapping(proc* p){
   4045c:	55                   	push   %rbp
   4045d:	48 89 e5             	mov    %rsp,%rbp
   40460:	48 83 ec 70          	sub    $0x70,%rsp
   40464:	48 89 7d 98          	mov    %rdi,-0x68(%rbp)
    uintptr_t mapping_ptr = p->p_registers.reg_rdi;
   40468:	48 8b 45 98          	mov    -0x68(%rbp),%rax
   4046c:	48 8b 40 48          	mov    0x48(%rax),%rax
   40470:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    uintptr_t ptr = p->p_registers.reg_rsi;
   40474:	48 8b 45 98          	mov    -0x68(%rbp),%rax
   40478:	48 8b 40 40          	mov    0x40(%rax),%rax
   4047c:	48 89 45 f0          	mov    %rax,-0x10(%rbp)

    //convert to physical address so kernel can write to it
    vamapping map = virtual_memory_lookup(p->p_pagetable, mapping_ptr);
   40480:	48 8b 45 98          	mov    -0x68(%rbp),%rax
   40484:	48 8b 88 e0 00 00 00 	mov    0xe0(%rax),%rcx
   4048b:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
   4048f:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
   40493:	48 89 ce             	mov    %rcx,%rsi
   40496:	48 89 c7             	mov    %rax,%rdi
   40499:	e8 60 25 00 00       	call   429fe <virtual_memory_lookup>

    // check for write access
    if((map.perm & (PTE_W|PTE_U)) != (PTE_W|PTE_U))
   4049e:	8b 45 e0             	mov    -0x20(%rbp),%eax
   404a1:	48 98                	cltq
   404a3:	83 e0 06             	and    $0x6,%eax
   404a6:	48 83 f8 06          	cmp    $0x6,%rax
   404aa:	0f 85 89 00 00 00    	jne    40539 <syscall_mapping+0xdd>
        return;
    uintptr_t endaddr = mapping_ptr + sizeof(vamapping) - 1;
   404b0:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   404b4:	48 83 c0 17          	add    $0x17,%rax
   404b8:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
    if (PAGENUMBER(endaddr) != PAGENUMBER(ptr)){
   404bc:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   404c0:	48 c1 e8 0c          	shr    $0xc,%rax
   404c4:	89 c2                	mov    %eax,%edx
   404c6:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   404ca:	48 c1 e8 0c          	shr    $0xc,%rax
   404ce:	39 c2                	cmp    %eax,%edx
   404d0:	74 2c                	je     404fe <syscall_mapping+0xa2>
        vamapping end_map = virtual_memory_lookup(p->p_pagetable, endaddr);
   404d2:	48 8b 45 98          	mov    -0x68(%rbp),%rax
   404d6:	48 8b 88 e0 00 00 00 	mov    0xe0(%rax),%rcx
   404dd:	48 8d 45 a0          	lea    -0x60(%rbp),%rax
   404e1:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
   404e5:	48 89 ce             	mov    %rcx,%rsi
   404e8:	48 89 c7             	mov    %rax,%rdi
   404eb:	e8 0e 25 00 00       	call   429fe <virtual_memory_lookup>
        // check for write access for end address
        if((end_map.perm & (PTE_W|PTE_P)) != (PTE_W|PTE_P))
   404f0:	8b 45 b0             	mov    -0x50(%rbp),%eax
   404f3:	48 98                	cltq
   404f5:	83 e0 03             	and    $0x3,%eax
   404f8:	48 83 f8 03          	cmp    $0x3,%rax
   404fc:	75 3e                	jne    4053c <syscall_mapping+0xe0>
            return; 
    }
    // find the actual mapping now
    vamapping ptr_lookup = virtual_memory_lookup(p->p_pagetable, ptr);
   404fe:	48 8b 45 98          	mov    -0x68(%rbp),%rax
   40502:	48 8b 88 e0 00 00 00 	mov    0xe0(%rax),%rcx
   40509:	48 8d 45 b8          	lea    -0x48(%rbp),%rax
   4050d:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
   40511:	48 89 ce             	mov    %rcx,%rsi
   40514:	48 89 c7             	mov    %rax,%rdi
   40517:	e8 e2 24 00 00       	call   429fe <virtual_memory_lookup>
    memcpy((void *)map.pa, &ptr_lookup, sizeof(vamapping));
   4051c:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
   40520:	48 89 c1             	mov    %rax,%rcx
   40523:	48 8d 45 b8          	lea    -0x48(%rbp),%rax
   40527:	ba 18 00 00 00       	mov    $0x18,%edx
   4052c:	48 89 c6             	mov    %rax,%rsi
   4052f:	48 89 cf             	mov    %rcx,%rdi
   40532:	e8 cc 33 00 00       	call   43903 <memcpy>
   40537:	eb 04                	jmp    4053d <syscall_mapping+0xe1>
        return;
   40539:	90                   	nop
   4053a:	eb 01                	jmp    4053d <syscall_mapping+0xe1>
            return; 
   4053c:	90                   	nop
}
   4053d:	c9                   	leave
   4053e:	c3                   	ret

000000000004053f <syscall_mem_tog>:

void syscall_mem_tog(proc* process){
   4053f:	55                   	push   %rbp
   40540:	48 89 e5             	mov    %rsp,%rbp
   40543:	48 83 ec 18          	sub    $0x18,%rsp
   40547:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)

    pid_t p = process->p_registers.reg_rdi;
   4054b:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   4054f:	48 8b 40 48          	mov    0x48(%rax),%rax
   40553:	89 45 fc             	mov    %eax,-0x4(%rbp)
    if(p == 0) {
   40556:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
   4055a:	75 14                	jne    40570 <syscall_mem_tog+0x31>
        disp_global = !disp_global;
   4055c:	0f b6 05 9d 5a 00 00 	movzbl 0x5a9d(%rip),%eax        # 46000 <disp_global>
   40563:	84 c0                	test   %al,%al
   40565:	0f 94 c0             	sete   %al
   40568:	88 05 92 5a 00 00    	mov    %al,0x5a92(%rip)        # 46000 <disp_global>
   4056e:	eb 36                	jmp    405a6 <syscall_mem_tog+0x67>
    }
    else {
        if(p < 0 || p > NPROC || p != process->p_pid)
   40570:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
   40574:	78 2f                	js     405a5 <syscall_mem_tog+0x66>
   40576:	83 7d fc 10          	cmpl   $0x10,-0x4(%rbp)
   4057a:	7f 29                	jg     405a5 <syscall_mem_tog+0x66>
   4057c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   40580:	8b 00                	mov    (%rax),%eax
   40582:	39 45 fc             	cmp    %eax,-0x4(%rbp)
   40585:	75 1e                	jne    405a5 <syscall_mem_tog+0x66>
            return;
        process->display_status = !(process->display_status);
   40587:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   4058b:	0f b6 80 e8 00 00 00 	movzbl 0xe8(%rax),%eax
   40592:	84 c0                	test   %al,%al
   40594:	0f 94 c0             	sete   %al
   40597:	89 c2                	mov    %eax,%edx
   40599:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   4059d:	88 90 e8 00 00 00    	mov    %dl,0xe8(%rax)
   405a3:	eb 01                	jmp    405a6 <syscall_mem_tog+0x67>
            return;
   405a5:	90                   	nop
    }
}
   405a6:	c9                   	leave
   405a7:	c3                   	ret

00000000000405a8 <exception>:
//    k-exception.S). That code saves more registers on the kernel's stack,
//    then calls exception().
//
//    Note that hardware interrupts are disabled whenever the kernel is running.

void exception(x86_64_registers* reg) {
   405a8:	55                   	push   %rbp
   405a9:	48 89 e5             	mov    %rsp,%rbp
   405ac:	48 81 ec 00 01 00 00 	sub    $0x100,%rsp
   405b3:	48 89 bd 08 ff ff ff 	mov    %rdi,-0xf8(%rbp)
    // Copy the saved registers into the `current` process descriptor
    // and always use the kernel's page table.
    current->p_registers = *reg;
   405ba:	48 8b 15 3f d9 00 00 	mov    0xd93f(%rip),%rdx        # 4df00 <current>
   405c1:	48 8b 8d 08 ff ff ff 	mov    -0xf8(%rbp),%rcx
   405c8:	b8 c0 00 00 00       	mov    $0xc0,%eax
   405cd:	83 e0 e0             	and    $0xffffffe0,%eax
   405d0:	41 89 c3             	mov    %eax,%r11d
   405d3:	be 00 00 00 00       	mov    $0x0,%esi
   405d8:	89 f0                	mov    %esi,%eax
   405da:	4c 8b 14 01          	mov    (%rcx,%rax,1),%r10
   405de:	4c 8b 4c 01 08       	mov    0x8(%rcx,%rax,1),%r9
   405e3:	4c 8b 44 01 10       	mov    0x10(%rcx,%rax,1),%r8
   405e8:	48 8b 7c 01 18       	mov    0x18(%rcx,%rax,1),%rdi
   405ed:	4c 89 54 02 18       	mov    %r10,0x18(%rdx,%rax,1)
   405f2:	4c 89 4c 02 20       	mov    %r9,0x20(%rdx,%rax,1)
   405f7:	4c 89 44 02 28       	mov    %r8,0x28(%rdx,%rax,1)
   405fc:	48 89 7c 02 30       	mov    %rdi,0x30(%rdx,%rax,1)
   40601:	83 c6 20             	add    $0x20,%esi
   40604:	44 39 de             	cmp    %r11d,%esi
   40607:	72 cf                	jb     405d8 <exception+0x30>
    set_pagetable(kernel_pagetable);
   40609:	48 8b 05 f0 f9 00 00 	mov    0xf9f0(%rip),%rax        # 50000 <kernel_pagetable>
   40610:	48 89 c7             	mov    %rax,%rdi
   40613:	e8 f2 1e 00 00       	call   4250a <set_pagetable>
    // Events logged this way are stored in the host's `log.txt` file.
    /*log_printf("proc %d: exception %d\n", current->p_pid, reg->reg_intno);*/

    // Show the current cursor location and memory state
    // (unless this is a kernel fault).
    console_show_cursor(cursorpos);
   40618:	8b 05 de 89 07 00    	mov    0x789de(%rip),%eax        # b8ffc <cursorpos>
   4061e:	89 c7                	mov    %eax,%edi
   40620:	e8 0f 16 00 00       	call   41c34 <console_show_cursor>
    if ((reg->reg_intno != INT_PAGEFAULT
   40625:	48 8b 85 08 ff ff ff 	mov    -0xf8(%rbp),%rax
   4062c:	48 8b 80 88 00 00 00 	mov    0x88(%rax),%rax
   40633:	48 83 f8 0e          	cmp    $0xe,%rax
   40637:	74 14                	je     4064d <exception+0xa5>
	    && reg->reg_intno != INT_GPF)
   40639:	48 8b 85 08 ff ff ff 	mov    -0xf8(%rbp),%rax
   40640:	48 8b 80 88 00 00 00 	mov    0x88(%rax),%rax
   40647:	48 83 f8 0d          	cmp    $0xd,%rax
   4064b:	75 16                	jne    40663 <exception+0xbb>
            || (reg->reg_err & PFERR_USER)) {
   4064d:	48 8b 85 08 ff ff ff 	mov    -0xf8(%rbp),%rax
   40654:	48 8b 80 90 00 00 00 	mov    0x90(%rax),%rax
   4065b:	83 e0 04             	and    $0x4,%eax
   4065e:	48 85 c0             	test   %rax,%rax
   40661:	74 1a                	je     4067d <exception+0xd5>
        check_virtual_memory();
   40663:	e8 f4 07 00 00       	call   40e5c <check_virtual_memory>
        if(disp_global){
   40668:	0f b6 05 91 59 00 00 	movzbl 0x5991(%rip),%eax        # 46000 <disp_global>
   4066f:	84 c0                	test   %al,%al
   40671:	74 0a                	je     4067d <exception+0xd5>
            memshow_physical();
   40673:	e8 31 09 00 00       	call   40fa9 <memshow_physical>
            memshow_virtual_animate();
   40678:	e8 53 0c 00 00       	call   412d0 <memshow_virtual_animate>
        }
    }

    // If Control-C was typed, exit the virtual machine.
    check_keyboard();
   4067d:	e8 99 1a 00 00       	call   4211b <check_keyboard>


    // Actually handle the exception.
    switch (reg->reg_intno) {
   40682:	48 8b 85 08 ff ff ff 	mov    -0xf8(%rbp),%rax
   40689:	48 8b 80 88 00 00 00 	mov    0x88(%rax),%rax
   40690:	48 83 f8 3a          	cmp    $0x3a,%rax
   40694:	0f 84 1f 03 00 00    	je     409b9 <exception+0x411>
   4069a:	48 83 f8 3a          	cmp    $0x3a,%rax
   4069e:	0f 87 04 03 00 00    	ja     409a8 <exception+0x400>
   406a4:	48 83 f8 39          	cmp    $0x39,%rax
   406a8:	0f 84 0e 03 00 00    	je     409bc <exception+0x414>
   406ae:	48 83 f8 39          	cmp    $0x39,%rax
   406b2:	0f 87 f0 02 00 00    	ja     409a8 <exception+0x400>
   406b8:	48 83 f8 38          	cmp    $0x38,%rax
   406bc:	0f 84 b0 01 00 00    	je     40872 <exception+0x2ca>
   406c2:	48 83 f8 38          	cmp    $0x38,%rax
   406c6:	0f 87 dc 02 00 00    	ja     409a8 <exception+0x400>
   406cc:	48 83 f8 36          	cmp    $0x36,%rax
   406d0:	0f 84 4a 01 00 00    	je     40820 <exception+0x278>
   406d6:	48 83 f8 36          	cmp    $0x36,%rax
   406da:	0f 87 c8 02 00 00    	ja     409a8 <exception+0x400>
   406e0:	48 83 f8 35          	cmp    $0x35,%rax
   406e4:	0f 84 4a 01 00 00    	je     40834 <exception+0x28c>
   406ea:	48 83 f8 35          	cmp    $0x35,%rax
   406ee:	0f 87 b4 02 00 00    	ja     409a8 <exception+0x400>
   406f4:	48 83 f8 34          	cmp    $0x34,%rax
   406f8:	0f 84 03 01 00 00    	je     40801 <exception+0x259>
   406fe:	48 83 f8 34          	cmp    $0x34,%rax
   40702:	0f 87 a0 02 00 00    	ja     409a8 <exception+0x400>
   40708:	48 83 f8 33          	cmp    $0x33,%rax
   4070c:	0f 84 40 01 00 00    	je     40852 <exception+0x2aa>
   40712:	48 83 f8 33          	cmp    $0x33,%rax
   40716:	0f 87 8c 02 00 00    	ja     409a8 <exception+0x400>
   4071c:	48 83 f8 32          	cmp    $0x32,%rax
   40720:	0f 84 22 01 00 00    	je     40848 <exception+0x2a0>
   40726:	48 83 f8 32          	cmp    $0x32,%rax
   4072a:	0f 87 78 02 00 00    	ja     409a8 <exception+0x400>
   40730:	48 83 f8 31          	cmp    $0x31,%rax
   40734:	0f 84 ab 00 00 00    	je     407e5 <exception+0x23d>
   4073a:	48 83 f8 31          	cmp    $0x31,%rax
   4073e:	0f 87 64 02 00 00    	ja     409a8 <exception+0x400>
   40744:	48 83 f8 30          	cmp    $0x30,%rax
   40748:	74 23                	je     4076d <exception+0x1c5>
   4074a:	48 83 f8 30          	cmp    $0x30,%rax
   4074e:	0f 87 54 02 00 00    	ja     409a8 <exception+0x400>
   40754:	48 83 f8 0e          	cmp    $0xe,%rax
   40758:	0f 84 41 01 00 00    	je     4089f <exception+0x2f7>
   4075e:	48 83 f8 20          	cmp    $0x20,%rax
   40762:	0f 84 1e 01 00 00    	je     40886 <exception+0x2de>
   40768:	e9 3b 02 00 00       	jmp    409a8 <exception+0x400>
        case INT_SYS_PANIC:
            {
                // rdi stores pointer for msg string
                {
                    char msg[160];
                    uintptr_t addr = current->p_registers.reg_rdi;
   4076d:	48 8b 05 8c d7 00 00 	mov    0xd78c(%rip),%rax        # 4df00 <current>
   40774:	48 8b 40 48          	mov    0x48(%rax),%rax
   40778:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
                    if((void *)addr == NULL)
   4077c:	48 83 7d e0 00       	cmpq   $0x0,-0x20(%rbp)
   40781:	75 0f                	jne    40792 <exception+0x1ea>
                        kernel_panic(NULL);
   40783:	bf 00 00 00 00       	mov    $0x0,%edi
   40788:	b8 00 00 00 00       	mov    $0x0,%eax
   4078d:	e8 ca 1a 00 00       	call   4225c <kernel_panic>
                    vamapping map = virtual_memory_lookup(current->p_pagetable, addr);
   40792:	48 8b 05 67 d7 00 00 	mov    0xd767(%rip),%rax        # 4df00 <current>
   40799:	48 8b 88 e0 00 00 00 	mov    0xe0(%rax),%rcx
   407a0:	48 8d 45 b8          	lea    -0x48(%rbp),%rax
   407a4:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
   407a8:	48 89 ce             	mov    %rcx,%rsi
   407ab:	48 89 c7             	mov    %rax,%rdi
   407ae:	e8 4b 22 00 00       	call   429fe <virtual_memory_lookup>
                    memcpy(msg, (void *)map.pa, 160);
   407b3:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
   407b7:	48 89 c1             	mov    %rax,%rcx
   407ba:	48 8d 85 18 ff ff ff 	lea    -0xe8(%rbp),%rax
   407c1:	ba a0 00 00 00       	mov    $0xa0,%edx
   407c6:	48 89 ce             	mov    %rcx,%rsi
   407c9:	48 89 c7             	mov    %rax,%rdi
   407cc:	e8 32 31 00 00       	call   43903 <memcpy>
                    kernel_panic(msg);
   407d1:	48 8d 85 18 ff ff ff 	lea    -0xe8(%rbp),%rax
   407d8:	48 89 c7             	mov    %rax,%rdi
   407db:	b8 00 00 00 00       	mov    $0x0,%eax
   407e0:	e8 77 1a 00 00       	call   4225c <kernel_panic>
                kernel_panic(NULL);
                break;                  // will not be reached
            }
        case INT_SYS_GETPID:
            {
                current->p_registers.reg_rax = current->p_pid;
   407e5:	48 8b 05 14 d7 00 00 	mov    0xd714(%rip),%rax        # 4df00 <current>
   407ec:	8b 10                	mov    (%rax),%edx
   407ee:	48 8b 05 0b d7 00 00 	mov    0xd70b(%rip),%rax        # 4df00 <current>
   407f5:	48 63 d2             	movslq %edx,%rdx
   407f8:	48 89 50 18          	mov    %rdx,0x18(%rax)
                break;
   407fc:	e9 bc 01 00 00       	jmp    409bd <exception+0x415>
            }
        case INT_SYS_FORK:
            {
                current->p_registers.reg_rax = syscall_fork();
   40801:	b8 00 00 00 00       	mov    $0x0,%eax
   40806:	e8 ea fb ff ff       	call   403f5 <syscall_fork>
   4080b:	89 c2                	mov    %eax,%edx
   4080d:	48 8b 05 ec d6 00 00 	mov    0xd6ec(%rip),%rax        # 4df00 <current>
   40814:	48 63 d2             	movslq %edx,%rdx
   40817:	48 89 50 18          	mov    %rdx,0x18(%rax)
                break;
   4081b:	e9 9d 01 00 00       	jmp    409bd <exception+0x415>
            }
        case INT_SYS_MAPPING:
            {
                syscall_mapping(current);
   40820:	48 8b 05 d9 d6 00 00 	mov    0xd6d9(%rip),%rax        # 4df00 <current>
   40827:	48 89 c7             	mov    %rax,%rdi
   4082a:	e8 2d fc ff ff       	call   4045c <syscall_mapping>
                break;
   4082f:	e9 89 01 00 00       	jmp    409bd <exception+0x415>
            }

        case INT_SYS_EXIT:
            {
                syscall_exit();
   40834:	b8 00 00 00 00       	mov    $0x0,%eax
   40839:	e8 cc fb ff ff       	call   4040a <syscall_exit>
                schedule();
   4083e:	e8 a3 01 00 00       	call   409e6 <schedule>
                break;
   40843:	e9 75 01 00 00       	jmp    409bd <exception+0x415>
            }

        case INT_SYS_YIELD:
            {
                schedule();
   40848:	e8 99 01 00 00       	call   409e6 <schedule>
                break;                  /* will not be reached */
   4084d:	e9 6b 01 00 00       	jmp    409bd <exception+0x415>
                // TODO : Your code here
                break;
            }
	case INT_SYS_PAGE_ALLOC:
	    {
		intptr_t addr = reg->reg_rdi;
   40852:	48 8b 85 08 ff ff ff 	mov    -0xf8(%rbp),%rax
   40859:	48 8b 40 30          	mov    0x30(%rax),%rax
   4085d:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
		syscall_page_alloc(addr);
   40861:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   40865:	48 89 c7             	mov    %rax,%rdi
   40868:	e8 b4 fb ff ff       	call   40421 <syscall_page_alloc>
		break;
   4086d:	e9 4b 01 00 00       	jmp    409bd <exception+0x415>
	    }
        case INT_SYS_MEM_TOG:
            {
                syscall_mem_tog(current);
   40872:	48 8b 05 87 d6 00 00 	mov    0xd687(%rip),%rax        # 4df00 <current>
   40879:	48 89 c7             	mov    %rax,%rdi
   4087c:	e8 be fc ff ff       	call   4053f <syscall_mem_tog>
                break;
   40881:	e9 37 01 00 00       	jmp    409bd <exception+0x415>
            }

        case INT_TIMER:
            {
                ++ticks;
   40886:	8b 05 94 da 00 00    	mov    0xda94(%rip),%eax        # 4e320 <ticks>
   4088c:	83 c0 01             	add    $0x1,%eax
   4088f:	89 05 8b da 00 00    	mov    %eax,0xda8b(%rip)        # 4e320 <ticks>
                schedule();
   40895:	e8 4c 01 00 00       	call   409e6 <schedule>
                break;                  /* will not be reached */
   4089a:	e9 1e 01 00 00       	jmp    409bd <exception+0x415>
    return val;
}

static inline uintptr_t rcr2(void) {
    uintptr_t val;
    asm volatile("movq %%cr2,%0" : "=r" (val));
   4089f:	0f 20 d0             	mov    %cr2,%rax
   408a2:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
    return val;
   408a6:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
            }

        case INT_PAGEFAULT: 
            {
                // Analyze faulting address and access type.
                uintptr_t addr = rcr2();
   408aa:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
                const char* operation = reg->reg_err & PFERR_WRITE
   408ae:	48 8b 85 08 ff ff ff 	mov    -0xf8(%rbp),%rax
   408b5:	48 8b 80 90 00 00 00 	mov    0x90(%rax),%rax
   408bc:	83 e0 02             	and    $0x2,%eax
                    ? "write" : "read";
   408bf:	48 85 c0             	test   %rax,%rax
   408c2:	74 0a                	je     408ce <exception+0x326>
                const char* operation = reg->reg_err & PFERR_WRITE
   408c4:	48 c7 45 f8 ab 4a 04 	movq   $0x44aab,-0x8(%rbp)
   408cb:	00 
   408cc:	eb 08                	jmp    408d6 <exception+0x32e>
   408ce:	48 c7 45 f8 b1 4a 04 	movq   $0x44ab1,-0x8(%rbp)
   408d5:	00 
                const char* problem = reg->reg_err & PFERR_PRESENT
   408d6:	48 8b 85 08 ff ff ff 	mov    -0xf8(%rbp),%rax
   408dd:	48 8b 80 90 00 00 00 	mov    0x90(%rax),%rax
   408e4:	83 e0 01             	and    $0x1,%eax
                    ? "protection problem" : "missing page";
   408e7:	48 85 c0             	test   %rax,%rax
   408ea:	74 0a                	je     408f6 <exception+0x34e>
                const char* problem = reg->reg_err & PFERR_PRESENT
   408ec:	48 c7 45 f0 b6 4a 04 	movq   $0x44ab6,-0x10(%rbp)
   408f3:	00 
   408f4:	eb 08                	jmp    408fe <exception+0x356>
   408f6:	48 c7 45 f0 c9 4a 04 	movq   $0x44ac9,-0x10(%rbp)
   408fd:	00 

                if (!(reg->reg_err & PFERR_USER)) {
   408fe:	48 8b 85 08 ff ff ff 	mov    -0xf8(%rbp),%rax
   40905:	48 8b 80 90 00 00 00 	mov    0x90(%rax),%rax
   4090c:	83 e0 04             	and    $0x4,%eax
   4090f:	48 85 c0             	test   %rax,%rax
   40912:	75 2f                	jne    40943 <exception+0x39b>
                    kernel_panic("Kernel page fault for %p (%s %s, rip=%p)!\n",
   40914:	48 8b 85 08 ff ff ff 	mov    -0xf8(%rbp),%rax
   4091b:	48 8b b0 98 00 00 00 	mov    0x98(%rax),%rsi
   40922:	48 8b 4d f0          	mov    -0x10(%rbp),%rcx
   40926:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
   4092a:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
   4092e:	49 89 f0             	mov    %rsi,%r8
   40931:	48 89 c6             	mov    %rax,%rsi
   40934:	bf d8 4a 04 00       	mov    $0x44ad8,%edi
   40939:	b8 00 00 00 00       	mov    $0x0,%eax
   4093e:	e8 19 19 00 00       	call   4225c <kernel_panic>
                            addr, operation, problem, reg->reg_rip);
                }
                console_printf(CPOS(24, 0), 0x0C00,
   40943:	48 8b 85 08 ff ff ff 	mov    -0xf8(%rbp),%rax
   4094a:	48 8b 90 98 00 00 00 	mov    0x98(%rax),%rdx
                        "Process %d page fault for %p (%s %s, rip=%p)!\n",
                        current->p_pid, addr, operation, problem, reg->reg_rip);
   40951:	48 8b 05 a8 d5 00 00 	mov    0xd5a8(%rip),%rax        # 4df00 <current>
                console_printf(CPOS(24, 0), 0x0C00,
   40958:	8b 00                	mov    (%rax),%eax
   4095a:	48 8b 75 f8          	mov    -0x8(%rbp),%rsi
   4095e:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
   40962:	52                   	push   %rdx
   40963:	ff 75 f0             	push   -0x10(%rbp)
   40966:	49 89 f1             	mov    %rsi,%r9
   40969:	49 89 c8             	mov    %rcx,%r8
   4096c:	89 c1                	mov    %eax,%ecx
   4096e:	ba 08 4b 04 00       	mov    $0x44b08,%edx
   40973:	be 00 0c 00 00       	mov    $0xc00,%esi
   40978:	bf 80 07 00 00       	mov    $0x780,%edi
   4097d:	b8 00 00 00 00       	mov    $0x0,%eax
   40982:	e8 d8 3e 00 00       	call   4485f <console_printf>
   40987:	48 83 c4 10          	add    $0x10,%rsp
                current->p_state = P_BROKEN;
   4098b:	48 8b 05 6e d5 00 00 	mov    0xd56e(%rip),%rax        # 4df00 <current>
   40992:	c7 80 d8 00 00 00 03 	movl   $0x3,0xd8(%rax)
   40999:	00 00 00 
                syscall_exit();
   4099c:	b8 00 00 00 00       	mov    $0x0,%eax
   409a1:	e8 64 fa ff ff       	call   4040a <syscall_exit>
                break;
   409a6:	eb 15                	jmp    409bd <exception+0x415>
            }

        default:
            default_exception(current);
   409a8:	48 8b 05 51 d5 00 00 	mov    0xd551(%rip),%rax        # 4df00 <current>
   409af:	48 89 c7             	mov    %rax,%rdi
   409b2:	e8 b5 19 00 00       	call   4236c <default_exception>
            break;                  /* will not be reached */
   409b7:	eb 04                	jmp    409bd <exception+0x415>
                break;
   409b9:	90                   	nop
   409ba:	eb 01                	jmp    409bd <exception+0x415>
		break;
   409bc:	90                   	nop

    }

    // Return to the current process (or run something else).
    if (current->p_state == P_RUNNABLE) {
   409bd:	48 8b 05 3c d5 00 00 	mov    0xd53c(%rip),%rax        # 4df00 <current>
   409c4:	8b 80 d8 00 00 00    	mov    0xd8(%rax),%eax
   409ca:	83 f8 01             	cmp    $0x1,%eax
   409cd:	75 0f                	jne    409de <exception+0x436>
        run(current);
   409cf:	48 8b 05 2a d5 00 00 	mov    0xd52a(%rip),%rax        # 4df00 <current>
   409d6:	48 89 c7             	mov    %rax,%rdi
   409d9:	e8 6e 00 00 00       	call   40a4c <run>
    } else {
        schedule();
   409de:	e8 03 00 00 00       	call   409e6 <schedule>
    }
}
   409e3:	90                   	nop
   409e4:	c9                   	leave
   409e5:	c3                   	ret

00000000000409e6 <schedule>:

// schedule
//    Pick the next process to run and then run it.
//    If there are no runnable processes, spins forever.

void schedule(void) {
   409e6:	55                   	push   %rbp
   409e7:	48 89 e5             	mov    %rsp,%rbp
   409ea:	48 83 ec 10          	sub    $0x10,%rsp
    pid_t pid = current->p_pid;
   409ee:	48 8b 05 0b d5 00 00 	mov    0xd50b(%rip),%rax        # 4df00 <current>
   409f5:	8b 00                	mov    (%rax),%eax
   409f7:	89 45 fc             	mov    %eax,-0x4(%rbp)
    while (1) {
        pid = (pid + 1) % NPROC;
   409fa:	8b 45 fc             	mov    -0x4(%rbp),%eax
   409fd:	8d 50 01             	lea    0x1(%rax),%edx
   40a00:	89 d0                	mov    %edx,%eax
   40a02:	c1 f8 1f             	sar    $0x1f,%eax
   40a05:	c1 e8 1c             	shr    $0x1c,%eax
   40a08:	01 c2                	add    %eax,%edx
   40a0a:	83 e2 0f             	and    $0xf,%edx
   40a0d:	29 c2                	sub    %eax,%edx
   40a0f:	89 55 fc             	mov    %edx,-0x4(%rbp)
        if (processes[pid].p_state == P_RUNNABLE) {
   40a12:	8b 45 fc             	mov    -0x4(%rbp),%eax
   40a15:	48 98                	cltq
   40a17:	48 69 c0 f0 00 00 00 	imul   $0xf0,%rax,%rax
   40a1e:	48 05 d8 d0 04 00    	add    $0x4d0d8,%rax
   40a24:	8b 00                	mov    (%rax),%eax
   40a26:	83 f8 01             	cmp    $0x1,%eax
   40a29:	75 1a                	jne    40a45 <schedule+0x5f>
            run(&processes[pid]);
   40a2b:	8b 45 fc             	mov    -0x4(%rbp),%eax
   40a2e:	48 98                	cltq
   40a30:	48 69 c0 f0 00 00 00 	imul   $0xf0,%rax,%rax
   40a37:	48 05 00 d0 04 00    	add    $0x4d000,%rax
   40a3d:	48 89 c7             	mov    %rax,%rdi
   40a40:	e8 07 00 00 00       	call   40a4c <run>
        }
        // If Control-C was typed, exit the virtual machine.
        check_keyboard();
   40a45:	e8 d1 16 00 00       	call   4211b <check_keyboard>
        pid = (pid + 1) % NPROC;
   40a4a:	eb ae                	jmp    409fa <schedule+0x14>

0000000000040a4c <run>:
//    Run process `p`. This means reloading all the registers from
//    `p->p_registers` using the `popal`, `popl`, and `iret` instructions.
//
//    As a side effect, sets `current = p`.

void run(proc* p) {
   40a4c:	55                   	push   %rbp
   40a4d:	48 89 e5             	mov    %rsp,%rbp
   40a50:	48 83 ec 10          	sub    $0x10,%rsp
   40a54:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
    assert(p->p_state == P_RUNNABLE);
   40a58:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   40a5c:	8b 80 d8 00 00 00    	mov    0xd8(%rax),%eax
   40a62:	83 f8 01             	cmp    $0x1,%eax
   40a65:	74 14                	je     40a7b <run+0x2f>
   40a67:	ba 37 4b 04 00       	mov    $0x44b37,%edx
   40a6c:	be 7a 01 00 00       	mov    $0x17a,%esi
   40a71:	bf 68 4a 04 00       	mov    $0x44a68,%edi
   40a76:	e8 c1 18 00 00       	call   4233c <assert_fail>
    current = p;
   40a7b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   40a7f:	48 89 05 7a d4 00 00 	mov    %rax,0xd47a(%rip)        # 4df00 <current>

    // display running process in CONSOLE last value
    console_printf(CPOS(24, 79),
   40a86:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   40a8a:	8b 10                	mov    (%rax),%edx
            memstate_colors[p->p_pid - PO_KERNEL], "%d", p->p_pid);
   40a8c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   40a90:	8b 00                	mov    (%rax),%eax
   40a92:	83 c0 02             	add    $0x2,%eax
   40a95:	48 98                	cltq
   40a97:	0f b7 84 00 00 4a 04 	movzwl 0x44a00(%rax,%rax,1),%eax
   40a9e:	00 
    console_printf(CPOS(24, 79),
   40a9f:	0f b7 c0             	movzwl %ax,%eax
   40aa2:	89 d1                	mov    %edx,%ecx
   40aa4:	ba 50 4b 04 00       	mov    $0x44b50,%edx
   40aa9:	89 c6                	mov    %eax,%esi
   40aab:	bf cf 07 00 00       	mov    $0x7cf,%edi
   40ab0:	b8 00 00 00 00       	mov    $0x0,%eax
   40ab5:	e8 a5 3d 00 00       	call   4485f <console_printf>

    // Load the process's current pagetable.
    set_pagetable(p->p_pagetable);
   40aba:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   40abe:	48 8b 80 e0 00 00 00 	mov    0xe0(%rax),%rax
   40ac5:	48 89 c7             	mov    %rax,%rdi
   40ac8:	e8 3d 1a 00 00       	call   4250a <set_pagetable>

    // This function is defined in k-exception.S. It restores the process's
    // registers then jumps back to user mode.
    exception_return(&p->p_registers);
   40acd:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   40ad1:	48 83 c0 18          	add    $0x18,%rax
   40ad5:	48 89 c7             	mov    %rax,%rdi
   40ad8:	e8 e6 f5 ff ff       	call   400c3 <exception_return>

0000000000040add <pageinfo_init>:


// pageinfo_init
//    Initialize the `pageinfo[]` array.

void pageinfo_init(void) {
   40add:	55                   	push   %rbp
   40ade:	48 89 e5             	mov    %rsp,%rbp
   40ae1:	48 83 ec 10          	sub    $0x10,%rsp
    extern char end[];

    for (uintptr_t addr = 0; addr < MEMSIZE_PHYSICAL; addr += PAGESIZE) {
   40ae5:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
   40aec:	00 
   40aed:	e9 81 00 00 00       	jmp    40b73 <pageinfo_init+0x96>
        int owner;
        if (physical_memory_isreserved(addr)) {
   40af2:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   40af6:	48 89 c7             	mov    %rax,%rdi
   40af9:	e8 a7 0e 00 00       	call   419a5 <physical_memory_isreserved>
   40afe:	85 c0                	test   %eax,%eax
   40b00:	74 09                	je     40b0b <pageinfo_init+0x2e>
            owner = PO_RESERVED;
   40b02:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%rbp)
   40b09:	eb 2f                	jmp    40b3a <pageinfo_init+0x5d>
        } else if ((addr >= KERNEL_START_ADDR && addr < (uintptr_t) end)
   40b0b:	48 81 7d f8 ff ff 03 	cmpq   $0x3ffff,-0x8(%rbp)
   40b12:	00 
   40b13:	76 0b                	jbe    40b20 <pageinfo_init+0x43>
   40b15:	b8 10 60 05 00       	mov    $0x56010,%eax
   40b1a:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
   40b1e:	72 0a                	jb     40b2a <pageinfo_init+0x4d>
                   || addr == KERNEL_STACK_TOP - PAGESIZE) {
   40b20:	48 81 7d f8 00 f0 07 	cmpq   $0x7f000,-0x8(%rbp)
   40b27:	00 
   40b28:	75 09                	jne    40b33 <pageinfo_init+0x56>
            owner = PO_KERNEL;
   40b2a:	c7 45 f4 fe ff ff ff 	movl   $0xfffffffe,-0xc(%rbp)
   40b31:	eb 07                	jmp    40b3a <pageinfo_init+0x5d>
        } else {
            owner = PO_FREE;
   40b33:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%rbp)
        }
        pageinfo[PAGENUMBER(addr)].owner = owner;
   40b3a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   40b3e:	48 c1 e8 0c          	shr    $0xc,%rax
   40b42:	89 c1                	mov    %eax,%ecx
   40b44:	8b 45 f4             	mov    -0xc(%rbp),%eax
   40b47:	89 c2                	mov    %eax,%edx
   40b49:	48 63 c1             	movslq %ecx,%rax
   40b4c:	88 94 00 20 df 04 00 	mov    %dl,0x4df20(%rax,%rax,1)
        pageinfo[PAGENUMBER(addr)].refcount = (owner != PO_FREE);
   40b53:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
   40b57:	0f 95 c2             	setne  %dl
   40b5a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   40b5e:	48 c1 e8 0c          	shr    $0xc,%rax
   40b62:	48 98                	cltq
   40b64:	88 94 00 21 df 04 00 	mov    %dl,0x4df21(%rax,%rax,1)
    for (uintptr_t addr = 0; addr < MEMSIZE_PHYSICAL; addr += PAGESIZE) {
   40b6b:	48 81 45 f8 00 10 00 	addq   $0x1000,-0x8(%rbp)
   40b72:	00 
   40b73:	48 81 7d f8 ff ff 1f 	cmpq   $0x1fffff,-0x8(%rbp)
   40b7a:	00 
   40b7b:	0f 86 71 ff ff ff    	jbe    40af2 <pageinfo_init+0x15>
    }
}
   40b81:	90                   	nop
   40b82:	90                   	nop
   40b83:	c9                   	leave
   40b84:	c3                   	ret

0000000000040b85 <check_page_table_mappings>:

// check_page_table_mappings
//    Check operating system invariants about kernel mappings for page
//    table `pt`. Panic if any of the invariants are false.

void check_page_table_mappings(x86_64_pagetable* pt) {
   40b85:	55                   	push   %rbp
   40b86:	48 89 e5             	mov    %rsp,%rbp
   40b89:	48 83 ec 50          	sub    $0x50,%rsp
   40b8d:	48 89 7d b8          	mov    %rdi,-0x48(%rbp)
    extern char start_data[], end[];
    assert(PTE_ADDR(pt) == (uintptr_t) pt);
   40b91:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
   40b95:	25 ff 0f 00 00       	and    $0xfff,%eax
   40b9a:	48 85 c0             	test   %rax,%rax
   40b9d:	74 14                	je     40bb3 <check_page_table_mappings+0x2e>
   40b9f:	ba 58 4b 04 00       	mov    $0x44b58,%edx
   40ba4:	be a8 01 00 00       	mov    $0x1a8,%esi
   40ba9:	bf 68 4a 04 00       	mov    $0x44a68,%edi
   40bae:	e8 89 17 00 00       	call   4233c <assert_fail>

    // kernel memory is identity mapped; data is writable
    for (uintptr_t va = KERNEL_START_ADDR; va < (uintptr_t) end;
   40bb3:	48 c7 45 f8 00 00 04 	movq   $0x40000,-0x8(%rbp)
   40bba:	00 
   40bbb:	e9 9a 00 00 00       	jmp    40c5a <check_page_table_mappings+0xd5>
         va += PAGESIZE) {
        vamapping vam = virtual_memory_lookup(pt, va);
   40bc0:	48 8d 45 c0          	lea    -0x40(%rbp),%rax
   40bc4:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
   40bc8:	48 8b 4d b8          	mov    -0x48(%rbp),%rcx
   40bcc:	48 89 ce             	mov    %rcx,%rsi
   40bcf:	48 89 c7             	mov    %rax,%rdi
   40bd2:	e8 27 1e 00 00       	call   429fe <virtual_memory_lookup>
        if (vam.pa != va) {
   40bd7:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
   40bdb:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
   40bdf:	74 27                	je     40c08 <check_page_table_mappings+0x83>
            console_printf(CPOS(22, 0), 0xC000, "%p vs %p\n", va, vam.pa);
   40be1:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
   40be5:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   40be9:	49 89 d0             	mov    %rdx,%r8
   40bec:	48 89 c1             	mov    %rax,%rcx
   40bef:	ba 77 4b 04 00       	mov    $0x44b77,%edx
   40bf4:	be 00 c0 00 00       	mov    $0xc000,%esi
   40bf9:	bf e0 06 00 00       	mov    $0x6e0,%edi
   40bfe:	b8 00 00 00 00       	mov    $0x0,%eax
   40c03:	e8 57 3c 00 00       	call   4485f <console_printf>
        }
        assert(vam.pa == va);
   40c08:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
   40c0c:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
   40c10:	74 14                	je     40c26 <check_page_table_mappings+0xa1>
   40c12:	ba 81 4b 04 00       	mov    $0x44b81,%edx
   40c17:	be b1 01 00 00       	mov    $0x1b1,%esi
   40c1c:	bf 68 4a 04 00       	mov    $0x44a68,%edi
   40c21:	e8 16 17 00 00       	call   4233c <assert_fail>
        if (va >= (uintptr_t) start_data) {
   40c26:	b8 00 60 04 00       	mov    $0x46000,%eax
   40c2b:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
   40c2f:	72 21                	jb     40c52 <check_page_table_mappings+0xcd>
            assert(vam.perm & PTE_W);
   40c31:	8b 45 d0             	mov    -0x30(%rbp),%eax
   40c34:	48 98                	cltq
   40c36:	83 e0 02             	and    $0x2,%eax
   40c39:	48 85 c0             	test   %rax,%rax
   40c3c:	75 14                	jne    40c52 <check_page_table_mappings+0xcd>
   40c3e:	ba 8e 4b 04 00       	mov    $0x44b8e,%edx
   40c43:	be b3 01 00 00       	mov    $0x1b3,%esi
   40c48:	bf 68 4a 04 00       	mov    $0x44a68,%edi
   40c4d:	e8 ea 16 00 00       	call   4233c <assert_fail>
         va += PAGESIZE) {
   40c52:	48 81 45 f8 00 10 00 	addq   $0x1000,-0x8(%rbp)
   40c59:	00 
    for (uintptr_t va = KERNEL_START_ADDR; va < (uintptr_t) end;
   40c5a:	b8 10 60 05 00       	mov    $0x56010,%eax
   40c5f:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
   40c63:	0f 82 57 ff ff ff    	jb     40bc0 <check_page_table_mappings+0x3b>
        }
    }

    // kernel stack is identity mapped and writable
    uintptr_t kstack = KERNEL_STACK_TOP - PAGESIZE;
   40c69:	48 c7 45 f0 00 f0 07 	movq   $0x7f000,-0x10(%rbp)
   40c70:	00 
    vamapping vam = virtual_memory_lookup(pt, kstack);
   40c71:	48 8d 45 d8          	lea    -0x28(%rbp),%rax
   40c75:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
   40c79:	48 8b 4d b8          	mov    -0x48(%rbp),%rcx
   40c7d:	48 89 ce             	mov    %rcx,%rsi
   40c80:	48 89 c7             	mov    %rax,%rdi
   40c83:	e8 76 1d 00 00       	call   429fe <virtual_memory_lookup>
    assert(vam.pa == kstack);
   40c88:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
   40c8c:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
   40c90:	74 14                	je     40ca6 <check_page_table_mappings+0x121>
   40c92:	ba 9f 4b 04 00       	mov    $0x44b9f,%edx
   40c97:	be ba 01 00 00       	mov    $0x1ba,%esi
   40c9c:	bf 68 4a 04 00       	mov    $0x44a68,%edi
   40ca1:	e8 96 16 00 00       	call   4233c <assert_fail>
    assert(vam.perm & PTE_W);
   40ca6:	8b 45 e8             	mov    -0x18(%rbp),%eax
   40ca9:	48 98                	cltq
   40cab:	83 e0 02             	and    $0x2,%eax
   40cae:	48 85 c0             	test   %rax,%rax
   40cb1:	75 14                	jne    40cc7 <check_page_table_mappings+0x142>
   40cb3:	ba 8e 4b 04 00       	mov    $0x44b8e,%edx
   40cb8:	be bb 01 00 00       	mov    $0x1bb,%esi
   40cbd:	bf 68 4a 04 00       	mov    $0x44a68,%edi
   40cc2:	e8 75 16 00 00       	call   4233c <assert_fail>
}
   40cc7:	90                   	nop
   40cc8:	c9                   	leave
   40cc9:	c3                   	ret

0000000000040cca <check_page_table_ownership>:
//    counts for page table `pt`. Panic if any of the invariants are false.

static void check_page_table_ownership_level(x86_64_pagetable* pt, int level,
                                             int owner, int refcount);

void check_page_table_ownership(x86_64_pagetable* pt, pid_t pid) {
   40cca:	55                   	push   %rbp
   40ccb:	48 89 e5             	mov    %rsp,%rbp
   40cce:	48 83 ec 20          	sub    $0x20,%rsp
   40cd2:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
   40cd6:	89 75 e4             	mov    %esi,-0x1c(%rbp)
    // calculate expected reference count for page tables
    int owner = pid;
   40cd9:	8b 45 e4             	mov    -0x1c(%rbp),%eax
   40cdc:	89 45 fc             	mov    %eax,-0x4(%rbp)
    int expected_refcount = 1;
   40cdf:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%rbp)
    if (pt == kernel_pagetable) {
   40ce6:	48 8b 05 13 f3 00 00 	mov    0xf313(%rip),%rax        # 50000 <kernel_pagetable>
   40ced:	48 39 45 e8          	cmp    %rax,-0x18(%rbp)
   40cf1:	75 57                	jne    40d4a <check_page_table_ownership+0x80>
        owner = PO_KERNEL;
   40cf3:	c7 45 fc fe ff ff ff 	movl   $0xfffffffe,-0x4(%rbp)
        for (int xpid = 0; xpid < NPROC; ++xpid) {
   40cfa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%rbp)
   40d01:	eb 41                	jmp    40d44 <check_page_table_ownership+0x7a>
            if (processes[xpid].p_state != P_FREE
   40d03:	8b 45 f4             	mov    -0xc(%rbp),%eax
   40d06:	48 98                	cltq
   40d08:	48 69 c0 f0 00 00 00 	imul   $0xf0,%rax,%rax
   40d0f:	48 05 d8 d0 04 00    	add    $0x4d0d8,%rax
   40d15:	8b 00                	mov    (%rax),%eax
   40d17:	85 c0                	test   %eax,%eax
   40d19:	74 25                	je     40d40 <check_page_table_ownership+0x76>
                && processes[xpid].p_pagetable == kernel_pagetable) {
   40d1b:	8b 45 f4             	mov    -0xc(%rbp),%eax
   40d1e:	48 98                	cltq
   40d20:	48 69 c0 f0 00 00 00 	imul   $0xf0,%rax,%rax
   40d27:	48 05 e0 d0 04 00    	add    $0x4d0e0,%rax
   40d2d:	48 8b 10             	mov    (%rax),%rdx
   40d30:	48 8b 05 c9 f2 00 00 	mov    0xf2c9(%rip),%rax        # 50000 <kernel_pagetable>
   40d37:	48 39 c2             	cmp    %rax,%rdx
   40d3a:	75 04                	jne    40d40 <check_page_table_ownership+0x76>
                ++expected_refcount;
   40d3c:	83 45 f8 01          	addl   $0x1,-0x8(%rbp)
        for (int xpid = 0; xpid < NPROC; ++xpid) {
   40d40:	83 45 f4 01          	addl   $0x1,-0xc(%rbp)
   40d44:	83 7d f4 0f          	cmpl   $0xf,-0xc(%rbp)
   40d48:	7e b9                	jle    40d03 <check_page_table_ownership+0x39>
            }
        }
    }
    check_page_table_ownership_level(pt, 0, owner, expected_refcount);
   40d4a:	8b 4d f8             	mov    -0x8(%rbp),%ecx
   40d4d:	8b 55 fc             	mov    -0x4(%rbp),%edx
   40d50:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   40d54:	be 00 00 00 00       	mov    $0x0,%esi
   40d59:	48 89 c7             	mov    %rax,%rdi
   40d5c:	e8 03 00 00 00       	call   40d64 <check_page_table_ownership_level>
}
   40d61:	90                   	nop
   40d62:	c9                   	leave
   40d63:	c3                   	ret

0000000000040d64 <check_page_table_ownership_level>:

static void check_page_table_ownership_level(x86_64_pagetable* pt, int level,
                                             int owner, int refcount) {
   40d64:	55                   	push   %rbp
   40d65:	48 89 e5             	mov    %rsp,%rbp
   40d68:	48 83 ec 30          	sub    $0x30,%rsp
   40d6c:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
   40d70:	89 75 e4             	mov    %esi,-0x1c(%rbp)
   40d73:	89 55 e0             	mov    %edx,-0x20(%rbp)
   40d76:	89 4d dc             	mov    %ecx,-0x24(%rbp)
    assert(PAGENUMBER(pt) < NPAGES);
   40d79:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   40d7d:	48 c1 e8 0c          	shr    $0xc,%rax
   40d81:	3d ff 01 00 00       	cmp    $0x1ff,%eax
   40d86:	7e 14                	jle    40d9c <check_page_table_ownership_level+0x38>
   40d88:	ba b0 4b 04 00       	mov    $0x44bb0,%edx
   40d8d:	be d8 01 00 00       	mov    $0x1d8,%esi
   40d92:	bf 68 4a 04 00       	mov    $0x44a68,%edi
   40d97:	e8 a0 15 00 00       	call   4233c <assert_fail>
    assert(pageinfo[PAGENUMBER(pt)].owner == owner);
   40d9c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   40da0:	48 c1 e8 0c          	shr    $0xc,%rax
   40da4:	48 98                	cltq
   40da6:	0f b6 84 00 20 df 04 	movzbl 0x4df20(%rax,%rax,1),%eax
   40dad:	00 
   40dae:	0f be c0             	movsbl %al,%eax
   40db1:	39 45 e0             	cmp    %eax,-0x20(%rbp)
   40db4:	74 14                	je     40dca <check_page_table_ownership_level+0x66>
   40db6:	ba c8 4b 04 00       	mov    $0x44bc8,%edx
   40dbb:	be d9 01 00 00       	mov    $0x1d9,%esi
   40dc0:	bf 68 4a 04 00       	mov    $0x44a68,%edi
   40dc5:	e8 72 15 00 00       	call   4233c <assert_fail>
    assert(pageinfo[PAGENUMBER(pt)].refcount == refcount);
   40dca:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   40dce:	48 c1 e8 0c          	shr    $0xc,%rax
   40dd2:	48 98                	cltq
   40dd4:	0f b6 84 00 21 df 04 	movzbl 0x4df21(%rax,%rax,1),%eax
   40ddb:	00 
   40ddc:	0f be c0             	movsbl %al,%eax
   40ddf:	39 45 dc             	cmp    %eax,-0x24(%rbp)
   40de2:	74 14                	je     40df8 <check_page_table_ownership_level+0x94>
   40de4:	ba f0 4b 04 00       	mov    $0x44bf0,%edx
   40de9:	be da 01 00 00       	mov    $0x1da,%esi
   40dee:	bf 68 4a 04 00       	mov    $0x44a68,%edi
   40df3:	e8 44 15 00 00       	call   4233c <assert_fail>
    if (level < 3) {
   40df8:	83 7d e4 02          	cmpl   $0x2,-0x1c(%rbp)
   40dfc:	7f 5b                	jg     40e59 <check_page_table_ownership_level+0xf5>
        for (int index = 0; index < NPAGETABLEENTRIES; ++index) {
   40dfe:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
   40e05:	eb 49                	jmp    40e50 <check_page_table_ownership_level+0xec>
            if (pt->entry[index]) {
   40e07:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   40e0b:	8b 55 fc             	mov    -0x4(%rbp),%edx
   40e0e:	48 63 d2             	movslq %edx,%rdx
   40e11:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
   40e15:	48 85 c0             	test   %rax,%rax
   40e18:	74 32                	je     40e4c <check_page_table_ownership_level+0xe8>
                x86_64_pagetable* nextpt =
                    (x86_64_pagetable*) PTE_ADDR(pt->entry[index]);
   40e1a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   40e1e:	8b 55 fc             	mov    -0x4(%rbp),%edx
   40e21:	48 63 d2             	movslq %edx,%rdx
   40e24:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
   40e28:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
                x86_64_pagetable* nextpt =
   40e2e:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
                check_page_table_ownership_level(nextpt, level + 1, owner, 1);
   40e32:	8b 45 e4             	mov    -0x1c(%rbp),%eax
   40e35:	8d 70 01             	lea    0x1(%rax),%esi
   40e38:	8b 55 e0             	mov    -0x20(%rbp),%edx
   40e3b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   40e3f:	b9 01 00 00 00       	mov    $0x1,%ecx
   40e44:	48 89 c7             	mov    %rax,%rdi
   40e47:	e8 18 ff ff ff       	call   40d64 <check_page_table_ownership_level>
        for (int index = 0; index < NPAGETABLEENTRIES; ++index) {
   40e4c:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
   40e50:	81 7d fc ff 01 00 00 	cmpl   $0x1ff,-0x4(%rbp)
   40e57:	7e ae                	jle    40e07 <check_page_table_ownership_level+0xa3>
            }
        }
    }
}
   40e59:	90                   	nop
   40e5a:	c9                   	leave
   40e5b:	c3                   	ret

0000000000040e5c <check_virtual_memory>:

// check_virtual_memory
//    Check operating system invariants about virtual memory. Panic if any
//    of the invariants are false.

void check_virtual_memory(void) {
   40e5c:	55                   	push   %rbp
   40e5d:	48 89 e5             	mov    %rsp,%rbp
   40e60:	48 83 ec 10          	sub    $0x10,%rsp
    // Process 0 must never be used.
    assert(processes[0].p_state == P_FREE);
   40e64:	8b 05 6e c2 00 00    	mov    0xc26e(%rip),%eax        # 4d0d8 <processes+0xd8>
   40e6a:	85 c0                	test   %eax,%eax
   40e6c:	74 14                	je     40e82 <check_virtual_memory+0x26>
   40e6e:	ba 20 4c 04 00       	mov    $0x44c20,%edx
   40e73:	be ed 01 00 00       	mov    $0x1ed,%esi
   40e78:	bf 68 4a 04 00       	mov    $0x44a68,%edi
   40e7d:	e8 ba 14 00 00       	call   4233c <assert_fail>
    // that don't have their own page tables.
    // Active processes have their own page tables. A process page table
    // should be owned by that process and have reference count 1.
    // All level-2-4 page tables must have reference count 1.

    check_page_table_mappings(kernel_pagetable);
   40e82:	48 8b 05 77 f1 00 00 	mov    0xf177(%rip),%rax        # 50000 <kernel_pagetable>
   40e89:	48 89 c7             	mov    %rax,%rdi
   40e8c:	e8 f4 fc ff ff       	call   40b85 <check_page_table_mappings>
    check_page_table_ownership(kernel_pagetable, -1);
   40e91:	48 8b 05 68 f1 00 00 	mov    0xf168(%rip),%rax        # 50000 <kernel_pagetable>
   40e98:	be ff ff ff ff       	mov    $0xffffffff,%esi
   40e9d:	48 89 c7             	mov    %rax,%rdi
   40ea0:	e8 25 fe ff ff       	call   40cca <check_page_table_ownership>

    for (int pid = 0; pid < NPROC; ++pid) {
   40ea5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
   40eac:	eb 7c                	jmp    40f2a <check_virtual_memory+0xce>
        if (processes[pid].p_state != P_FREE
   40eae:	8b 45 fc             	mov    -0x4(%rbp),%eax
   40eb1:	48 98                	cltq
   40eb3:	48 69 c0 f0 00 00 00 	imul   $0xf0,%rax,%rax
   40eba:	48 05 d8 d0 04 00    	add    $0x4d0d8,%rax
   40ec0:	8b 00                	mov    (%rax),%eax
   40ec2:	85 c0                	test   %eax,%eax
   40ec4:	74 60                	je     40f26 <check_virtual_memory+0xca>
            && processes[pid].p_pagetable != kernel_pagetable) {
   40ec6:	8b 45 fc             	mov    -0x4(%rbp),%eax
   40ec9:	48 98                	cltq
   40ecb:	48 69 c0 f0 00 00 00 	imul   $0xf0,%rax,%rax
   40ed2:	48 05 e0 d0 04 00    	add    $0x4d0e0,%rax
   40ed8:	48 8b 10             	mov    (%rax),%rdx
   40edb:	48 8b 05 1e f1 00 00 	mov    0xf11e(%rip),%rax        # 50000 <kernel_pagetable>
   40ee2:	48 39 c2             	cmp    %rax,%rdx
   40ee5:	74 3f                	je     40f26 <check_virtual_memory+0xca>
            check_page_table_mappings(processes[pid].p_pagetable);
   40ee7:	8b 45 fc             	mov    -0x4(%rbp),%eax
   40eea:	48 98                	cltq
   40eec:	48 69 c0 f0 00 00 00 	imul   $0xf0,%rax,%rax
   40ef3:	48 05 e0 d0 04 00    	add    $0x4d0e0,%rax
   40ef9:	48 8b 00             	mov    (%rax),%rax
   40efc:	48 89 c7             	mov    %rax,%rdi
   40eff:	e8 81 fc ff ff       	call   40b85 <check_page_table_mappings>
            check_page_table_ownership(processes[pid].p_pagetable, pid);
   40f04:	8b 45 fc             	mov    -0x4(%rbp),%eax
   40f07:	48 98                	cltq
   40f09:	48 69 c0 f0 00 00 00 	imul   $0xf0,%rax,%rax
   40f10:	48 05 e0 d0 04 00    	add    $0x4d0e0,%rax
   40f16:	48 8b 00             	mov    (%rax),%rax
   40f19:	8b 55 fc             	mov    -0x4(%rbp),%edx
   40f1c:	89 d6                	mov    %edx,%esi
   40f1e:	48 89 c7             	mov    %rax,%rdi
   40f21:	e8 a4 fd ff ff       	call   40cca <check_page_table_ownership>
    for (int pid = 0; pid < NPROC; ++pid) {
   40f26:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
   40f2a:	83 7d fc 0f          	cmpl   $0xf,-0x4(%rbp)
   40f2e:	0f 8e 7a ff ff ff    	jle    40eae <check_virtual_memory+0x52>
        }
    }

    // Check that all referenced pages refer to active processes
    for (int pn = 0; pn < PAGENUMBER(MEMSIZE_PHYSICAL); ++pn) {
   40f34:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%rbp)
   40f3b:	eb 5f                	jmp    40f9c <check_virtual_memory+0x140>
        if (pageinfo[pn].refcount > 0 && pageinfo[pn].owner >= 0) {
   40f3d:	8b 45 f8             	mov    -0x8(%rbp),%eax
   40f40:	48 98                	cltq
   40f42:	0f b6 84 00 21 df 04 	movzbl 0x4df21(%rax,%rax,1),%eax
   40f49:	00 
   40f4a:	84 c0                	test   %al,%al
   40f4c:	7e 4a                	jle    40f98 <check_virtual_memory+0x13c>
   40f4e:	8b 45 f8             	mov    -0x8(%rbp),%eax
   40f51:	48 98                	cltq
   40f53:	0f b6 84 00 20 df 04 	movzbl 0x4df20(%rax,%rax,1),%eax
   40f5a:	00 
   40f5b:	84 c0                	test   %al,%al
   40f5d:	78 39                	js     40f98 <check_virtual_memory+0x13c>
            assert(processes[pageinfo[pn].owner].p_state != P_FREE);
   40f5f:	8b 45 f8             	mov    -0x8(%rbp),%eax
   40f62:	48 98                	cltq
   40f64:	0f b6 84 00 20 df 04 	movzbl 0x4df20(%rax,%rax,1),%eax
   40f6b:	00 
   40f6c:	0f be c0             	movsbl %al,%eax
   40f6f:	48 98                	cltq
   40f71:	48 69 c0 f0 00 00 00 	imul   $0xf0,%rax,%rax
   40f78:	48 05 d8 d0 04 00    	add    $0x4d0d8,%rax
   40f7e:	8b 00                	mov    (%rax),%eax
   40f80:	85 c0                	test   %eax,%eax
   40f82:	75 14                	jne    40f98 <check_virtual_memory+0x13c>
   40f84:	ba 40 4c 04 00       	mov    $0x44c40,%edx
   40f89:	be 04 02 00 00       	mov    $0x204,%esi
   40f8e:	bf 68 4a 04 00       	mov    $0x44a68,%edi
   40f93:	e8 a4 13 00 00       	call   4233c <assert_fail>
    for (int pn = 0; pn < PAGENUMBER(MEMSIZE_PHYSICAL); ++pn) {
   40f98:	83 45 f8 01          	addl   $0x1,-0x8(%rbp)
   40f9c:	81 7d f8 ff 01 00 00 	cmpl   $0x1ff,-0x8(%rbp)
   40fa3:	7e 98                	jle    40f3d <check_virtual_memory+0xe1>
        }
    }
}
   40fa5:	90                   	nop
   40fa6:	90                   	nop
   40fa7:	c9                   	leave
   40fa8:	c3                   	ret

0000000000040fa9 <memshow_physical>:
    'E' | 0x0E00, 'F' | 0x0F00, 'S'
};
#define SHARED_COLOR memstate_colors[18]
#define SHARED

void memshow_physical(void) {
   40fa9:	55                   	push   %rbp
   40faa:	48 89 e5             	mov    %rsp,%rbp
   40fad:	48 83 ec 10          	sub    $0x10,%rsp
    console_printf(CPOS(0, 32), 0x0F00, "PHYSICAL MEMORY");
   40fb1:	ba 70 4c 04 00       	mov    $0x44c70,%edx
   40fb6:	be 00 0f 00 00       	mov    $0xf00,%esi
   40fbb:	bf 20 00 00 00       	mov    $0x20,%edi
   40fc0:	b8 00 00 00 00       	mov    $0x0,%eax
   40fc5:	e8 95 38 00 00       	call   4485f <console_printf>
    for (int pn = 0; pn < PAGENUMBER(MEMSIZE_PHYSICAL); ++pn) {
   40fca:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
   40fd1:	e9 f8 00 00 00       	jmp    410ce <memshow_physical+0x125>
        if (pn % 64 == 0) {
   40fd6:	8b 45 fc             	mov    -0x4(%rbp),%eax
   40fd9:	83 e0 3f             	and    $0x3f,%eax
   40fdc:	85 c0                	test   %eax,%eax
   40fde:	75 3c                	jne    4101c <memshow_physical+0x73>
            console_printf(CPOS(1 + pn / 64, 3), 0x0F00, "0x%06X ", pn << 12);
   40fe0:	8b 45 fc             	mov    -0x4(%rbp),%eax
   40fe3:	c1 e0 0c             	shl    $0xc,%eax
   40fe6:	89 c1                	mov    %eax,%ecx
   40fe8:	8b 45 fc             	mov    -0x4(%rbp),%eax
   40feb:	8d 50 3f             	lea    0x3f(%rax),%edx
   40fee:	85 c0                	test   %eax,%eax
   40ff0:	0f 48 c2             	cmovs  %edx,%eax
   40ff3:	c1 f8 06             	sar    $0x6,%eax
   40ff6:	8d 50 01             	lea    0x1(%rax),%edx
   40ff9:	89 d0                	mov    %edx,%eax
   40ffb:	c1 e0 02             	shl    $0x2,%eax
   40ffe:	01 d0                	add    %edx,%eax
   41000:	c1 e0 04             	shl    $0x4,%eax
   41003:	83 c0 03             	add    $0x3,%eax
   41006:	ba 80 4c 04 00       	mov    $0x44c80,%edx
   4100b:	be 00 0f 00 00       	mov    $0xf00,%esi
   41010:	89 c7                	mov    %eax,%edi
   41012:	b8 00 00 00 00       	mov    $0x0,%eax
   41017:	e8 43 38 00 00       	call   4485f <console_printf>
        }

        int owner = pageinfo[pn].owner;
   4101c:	8b 45 fc             	mov    -0x4(%rbp),%eax
   4101f:	48 98                	cltq
   41021:	0f b6 84 00 20 df 04 	movzbl 0x4df20(%rax,%rax,1),%eax
   41028:	00 
   41029:	0f be c0             	movsbl %al,%eax
   4102c:	89 45 f8             	mov    %eax,-0x8(%rbp)
        if (pageinfo[pn].refcount == 0) {
   4102f:	8b 45 fc             	mov    -0x4(%rbp),%eax
   41032:	48 98                	cltq
   41034:	0f b6 84 00 21 df 04 	movzbl 0x4df21(%rax,%rax,1),%eax
   4103b:	00 
   4103c:	84 c0                	test   %al,%al
   4103e:	75 07                	jne    41047 <memshow_physical+0x9e>
            owner = PO_FREE;
   41040:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%rbp)
        }
        uint16_t color = memstate_colors[owner - PO_KERNEL];
   41047:	8b 45 f8             	mov    -0x8(%rbp),%eax
   4104a:	83 c0 02             	add    $0x2,%eax
   4104d:	48 98                	cltq
   4104f:	0f b7 84 00 00 4a 04 	movzwl 0x44a00(%rax,%rax,1),%eax
   41056:	00 
   41057:	66 89 45 f6          	mov    %ax,-0xa(%rbp)
        // darker color for shared pages
        if (pageinfo[pn].refcount > 1 && pn != PAGENUMBER(CONSOLE_ADDR)){
   4105b:	8b 45 fc             	mov    -0x4(%rbp),%eax
   4105e:	48 98                	cltq
   41060:	0f b6 84 00 21 df 04 	movzbl 0x4df21(%rax,%rax,1),%eax
   41067:	00 
   41068:	3c 01                	cmp    $0x1,%al
   4106a:	7e 1a                	jle    41086 <memshow_physical+0xdd>
   4106c:	b8 00 80 0b 00       	mov    $0xb8000,%eax
   41071:	48 c1 e8 0c          	shr    $0xc,%rax
   41075:	39 45 fc             	cmp    %eax,-0x4(%rbp)
   41078:	74 0c                	je     41086 <memshow_physical+0xdd>
#ifdef SHARED
            color = SHARED_COLOR | 0x0F00;
   4107a:	b8 53 00 00 00       	mov    $0x53,%eax
   4107f:	80 cc 0f             	or     $0xf,%ah
   41082:	66 89 45 f6          	mov    %ax,-0xa(%rbp)
#else
	    color &= 0x77FF;
#endif
        }

        console[CPOS(1 + pn / 64, 12 + pn % 64)] = color;
   41086:	8b 45 fc             	mov    -0x4(%rbp),%eax
   41089:	8d 50 3f             	lea    0x3f(%rax),%edx
   4108c:	85 c0                	test   %eax,%eax
   4108e:	0f 48 c2             	cmovs  %edx,%eax
   41091:	c1 f8 06             	sar    $0x6,%eax
   41094:	8d 50 01             	lea    0x1(%rax),%edx
   41097:	89 d0                	mov    %edx,%eax
   41099:	c1 e0 02             	shl    $0x2,%eax
   4109c:	01 d0                	add    %edx,%eax
   4109e:	c1 e0 04             	shl    $0x4,%eax
   410a1:	89 c1                	mov    %eax,%ecx
   410a3:	8b 55 fc             	mov    -0x4(%rbp),%edx
   410a6:	89 d0                	mov    %edx,%eax
   410a8:	c1 f8 1f             	sar    $0x1f,%eax
   410ab:	c1 e8 1a             	shr    $0x1a,%eax
   410ae:	01 c2                	add    %eax,%edx
   410b0:	83 e2 3f             	and    $0x3f,%edx
   410b3:	29 c2                	sub    %eax,%edx
   410b5:	89 d0                	mov    %edx,%eax
   410b7:	83 c0 0c             	add    $0xc,%eax
   410ba:	01 c8                	add    %ecx,%eax
   410bc:	48 98                	cltq
   410be:	0f b7 55 f6          	movzwl -0xa(%rbp),%edx
   410c2:	66 89 94 00 00 80 0b 	mov    %dx,0xb8000(%rax,%rax,1)
   410c9:	00 
    for (int pn = 0; pn < PAGENUMBER(MEMSIZE_PHYSICAL); ++pn) {
   410ca:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
   410ce:	81 7d fc ff 01 00 00 	cmpl   $0x1ff,-0x4(%rbp)
   410d5:	0f 8e fb fe ff ff    	jle    40fd6 <memshow_physical+0x2d>
    }
}
   410db:	90                   	nop
   410dc:	90                   	nop
   410dd:	c9                   	leave
   410de:	c3                   	ret

00000000000410df <memshow_virtual>:

// memshow_virtual(pagetable, name)
//    Draw a picture of the virtual memory map `pagetable` (named `name`) on
//    the CGA console.

void memshow_virtual(x86_64_pagetable* pagetable, const char* name) {
   410df:	55                   	push   %rbp
   410e0:	48 89 e5             	mov    %rsp,%rbp
   410e3:	48 83 ec 40          	sub    $0x40,%rsp
   410e7:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
   410eb:	48 89 75 c0          	mov    %rsi,-0x40(%rbp)
    assert((uintptr_t) pagetable == PTE_ADDR(pagetable));
   410ef:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
   410f3:	25 ff 0f 00 00       	and    $0xfff,%eax
   410f8:	48 85 c0             	test   %rax,%rax
   410fb:	74 14                	je     41111 <memshow_virtual+0x32>
   410fd:	ba 88 4c 04 00       	mov    $0x44c88,%edx
   41102:	be 35 02 00 00       	mov    $0x235,%esi
   41107:	bf 68 4a 04 00       	mov    $0x44a68,%edi
   4110c:	e8 2b 12 00 00       	call   4233c <assert_fail>

    console_printf(CPOS(10, 26), 0x0F00, "VIRTUAL ADDRESS SPACE FOR %s", name);
   41111:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
   41115:	48 89 c1             	mov    %rax,%rcx
   41118:	ba b5 4c 04 00       	mov    $0x44cb5,%edx
   4111d:	be 00 0f 00 00       	mov    $0xf00,%esi
   41122:	bf 3a 03 00 00       	mov    $0x33a,%edi
   41127:	b8 00 00 00 00       	mov    $0x0,%eax
   4112c:	e8 2e 37 00 00       	call   4485f <console_printf>
    for (uintptr_t va = 0; va < MEMSIZE_VIRTUAL; va += PAGESIZE) {
   41131:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
   41138:	00 
   41139:	e9 80 01 00 00       	jmp    412be <memshow_virtual+0x1df>
        vamapping vam = virtual_memory_lookup(pagetable, va);
   4113e:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
   41142:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
   41146:	48 8b 4d c8          	mov    -0x38(%rbp),%rcx
   4114a:	48 89 ce             	mov    %rcx,%rsi
   4114d:	48 89 c7             	mov    %rax,%rdi
   41150:	e8 a9 18 00 00       	call   429fe <virtual_memory_lookup>
        uint16_t color;
        if (vam.pn < 0) {
   41155:	8b 45 d0             	mov    -0x30(%rbp),%eax
   41158:	85 c0                	test   %eax,%eax
   4115a:	79 0b                	jns    41167 <memshow_virtual+0x88>
            color = ' ';
   4115c:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%rbp)
   41162:	e9 d7 00 00 00       	jmp    4123e <memshow_virtual+0x15f>
        } else {
            assert(vam.pa < MEMSIZE_PHYSICAL);
   41167:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
   4116b:	48 3d ff ff 1f 00    	cmp    $0x1fffff,%rax
   41171:	76 14                	jbe    41187 <memshow_virtual+0xa8>
   41173:	ba d2 4c 04 00       	mov    $0x44cd2,%edx
   41178:	be 3e 02 00 00       	mov    $0x23e,%esi
   4117d:	bf 68 4a 04 00       	mov    $0x44a68,%edi
   41182:	e8 b5 11 00 00       	call   4233c <assert_fail>
            int owner = pageinfo[vam.pn].owner;
   41187:	8b 45 d0             	mov    -0x30(%rbp),%eax
   4118a:	48 98                	cltq
   4118c:	0f b6 84 00 20 df 04 	movzbl 0x4df20(%rax,%rax,1),%eax
   41193:	00 
   41194:	0f be c0             	movsbl %al,%eax
   41197:	89 45 f0             	mov    %eax,-0x10(%rbp)
            if (pageinfo[vam.pn].refcount == 0) {
   4119a:	8b 45 d0             	mov    -0x30(%rbp),%eax
   4119d:	48 98                	cltq
   4119f:	0f b6 84 00 21 df 04 	movzbl 0x4df21(%rax,%rax,1),%eax
   411a6:	00 
   411a7:	84 c0                	test   %al,%al
   411a9:	75 07                	jne    411b2 <memshow_virtual+0xd3>
                owner = PO_FREE;
   411ab:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)
            }
            color = memstate_colors[owner - PO_KERNEL];
   411b2:	8b 45 f0             	mov    -0x10(%rbp),%eax
   411b5:	83 c0 02             	add    $0x2,%eax
   411b8:	48 98                	cltq
   411ba:	0f b7 84 00 00 4a 04 	movzwl 0x44a00(%rax,%rax,1),%eax
   411c1:	00 
   411c2:	66 89 45 f6          	mov    %ax,-0xa(%rbp)
            // reverse video for user-accessible pages
            if (vam.perm & PTE_U) {
   411c6:	8b 45 e0             	mov    -0x20(%rbp),%eax
   411c9:	48 98                	cltq
   411cb:	83 e0 04             	and    $0x4,%eax
   411ce:	48 85 c0             	test   %rax,%rax
   411d1:	74 27                	je     411fa <memshow_virtual+0x11b>
                color = ((color & 0x0F00) << 4) | ((color & 0xF000) >> 4)
   411d3:	0f b7 45 f6          	movzwl -0xa(%rbp),%eax
   411d7:	c1 e0 04             	shl    $0x4,%eax
   411da:	66 25 00 f0          	and    $0xf000,%ax
   411de:	89 c2                	mov    %eax,%edx
   411e0:	0f b7 45 f6          	movzwl -0xa(%rbp),%eax
   411e4:	c1 f8 04             	sar    $0x4,%eax
   411e7:	66 25 00 0f          	and    $0xf00,%ax
   411eb:	09 c2                	or     %eax,%edx
                    | (color & 0x00FF);
   411ed:	0f b7 45 f6          	movzwl -0xa(%rbp),%eax
   411f1:	0f b6 c0             	movzbl %al,%eax
   411f4:	09 d0                	or     %edx,%eax
                color = ((color & 0x0F00) << 4) | ((color & 0xF000) >> 4)
   411f6:	66 89 45 f6          	mov    %ax,-0xa(%rbp)
            }
            // darker color for shared pages
            if (pageinfo[vam.pn].refcount > 1 && va != CONSOLE_ADDR) {
   411fa:	8b 45 d0             	mov    -0x30(%rbp),%eax
   411fd:	48 98                	cltq
   411ff:	0f b6 84 00 21 df 04 	movzbl 0x4df21(%rax,%rax,1),%eax
   41206:	00 
   41207:	3c 01                	cmp    $0x1,%al
   41209:	7e 33                	jle    4123e <memshow_virtual+0x15f>
   4120b:	b8 00 80 0b 00       	mov    $0xb8000,%eax
   41210:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
   41214:	74 28                	je     4123e <memshow_virtual+0x15f>
#ifdef SHARED
                color = (SHARED_COLOR | (color & 0xF000));
   41216:	b8 53 00 00 00       	mov    $0x53,%eax
   4121b:	89 c2                	mov    %eax,%edx
   4121d:	0f b7 45 f6          	movzwl -0xa(%rbp),%eax
   41221:	66 25 00 f0          	and    $0xf000,%ax
   41225:	09 d0                	or     %edx,%eax
   41227:	66 89 45 f6          	mov    %ax,-0xa(%rbp)
                if(! (vam.perm & PTE_U))
   4122b:	8b 45 e0             	mov    -0x20(%rbp),%eax
   4122e:	48 98                	cltq
   41230:	83 e0 04             	and    $0x4,%eax
   41233:	48 85 c0             	test   %rax,%rax
   41236:	75 06                	jne    4123e <memshow_virtual+0x15f>
                    color = color | 0x0F00;
   41238:	66 81 4d f6 00 0f    	orw    $0xf00,-0xa(%rbp)
#else
		color &= 0x77FF;
#endif
            }
        }
        uint32_t pn = PAGENUMBER(va);
   4123e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   41242:	48 c1 e8 0c          	shr    $0xc,%rax
   41246:	89 45 ec             	mov    %eax,-0x14(%rbp)
        if (pn % 64 == 0) {
   41249:	8b 45 ec             	mov    -0x14(%rbp),%eax
   4124c:	83 e0 3f             	and    $0x3f,%eax
   4124f:	85 c0                	test   %eax,%eax
   41251:	75 34                	jne    41287 <memshow_virtual+0x1a8>
            console_printf(CPOS(11 + pn / 64, 3), 0x0F00, "0x%06X ", va);
   41253:	8b 45 ec             	mov    -0x14(%rbp),%eax
   41256:	c1 e8 06             	shr    $0x6,%eax
   41259:	89 c2                	mov    %eax,%edx
   4125b:	89 d0                	mov    %edx,%eax
   4125d:	c1 e0 02             	shl    $0x2,%eax
   41260:	01 d0                	add    %edx,%eax
   41262:	c1 e0 04             	shl    $0x4,%eax
   41265:	05 73 03 00 00       	add    $0x373,%eax
   4126a:	89 c7                	mov    %eax,%edi
   4126c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   41270:	48 89 c1             	mov    %rax,%rcx
   41273:	ba 80 4c 04 00       	mov    $0x44c80,%edx
   41278:	be 00 0f 00 00       	mov    $0xf00,%esi
   4127d:	b8 00 00 00 00       	mov    $0x0,%eax
   41282:	e8 d8 35 00 00       	call   4485f <console_printf>
        }
        console[CPOS(11 + pn / 64, 12 + pn % 64)] = color;
   41287:	8b 45 ec             	mov    -0x14(%rbp),%eax
   4128a:	c1 e8 06             	shr    $0x6,%eax
   4128d:	89 c2                	mov    %eax,%edx
   4128f:	89 d0                	mov    %edx,%eax
   41291:	c1 e0 02             	shl    $0x2,%eax
   41294:	01 d0                	add    %edx,%eax
   41296:	c1 e0 04             	shl    $0x4,%eax
   41299:	89 c2                	mov    %eax,%edx
   4129b:	8b 45 ec             	mov    -0x14(%rbp),%eax
   4129e:	83 e0 3f             	and    $0x3f,%eax
   412a1:	01 d0                	add    %edx,%eax
   412a3:	05 7c 03 00 00       	add    $0x37c,%eax
   412a8:	89 c2                	mov    %eax,%edx
   412aa:	0f b7 45 f6          	movzwl -0xa(%rbp),%eax
   412ae:	66 89 84 12 00 80 0b 	mov    %ax,0xb8000(%rdx,%rdx,1)
   412b5:	00 
    for (uintptr_t va = 0; va < MEMSIZE_VIRTUAL; va += PAGESIZE) {
   412b6:	48 81 45 f8 00 10 00 	addq   $0x1000,-0x8(%rbp)
   412bd:	00 
   412be:	48 81 7d f8 ff ff 2f 	cmpq   $0x2fffff,-0x8(%rbp)
   412c5:	00 
   412c6:	0f 86 72 fe ff ff    	jbe    4113e <memshow_virtual+0x5f>
    }
}
   412cc:	90                   	nop
   412cd:	90                   	nop
   412ce:	c9                   	leave
   412cf:	c3                   	ret

00000000000412d0 <memshow_virtual_animate>:

// memshow_virtual_animate
//    Draw a picture of process virtual memory maps on the CGA console.
//    Starts with process 1, then switches to a new process every 0.25 sec.

void memshow_virtual_animate(void) {
   412d0:	55                   	push   %rbp
   412d1:	48 89 e5             	mov    %rsp,%rbp
   412d4:	48 83 ec 10          	sub    $0x10,%rsp
    static unsigned last_ticks = 0;
    static int showing = 1;

    // switch to a new process every 0.25 sec
    if (last_ticks == 0 || ticks - last_ticks >= HZ / 2) {
   412d8:	8b 05 46 d0 00 00    	mov    0xd046(%rip),%eax        # 4e324 <last_ticks.1>
   412de:	85 c0                	test   %eax,%eax
   412e0:	74 13                	je     412f5 <memshow_virtual_animate+0x25>
   412e2:	8b 15 38 d0 00 00    	mov    0xd038(%rip),%edx        # 4e320 <ticks>
   412e8:	8b 05 36 d0 00 00    	mov    0xd036(%rip),%eax        # 4e324 <last_ticks.1>
   412ee:	29 c2                	sub    %eax,%edx
   412f0:	83 fa 31             	cmp    $0x31,%edx
   412f3:	76 2c                	jbe    41321 <memshow_virtual_animate+0x51>
        last_ticks = ticks;
   412f5:	8b 05 25 d0 00 00    	mov    0xd025(%rip),%eax        # 4e320 <ticks>
   412fb:	89 05 23 d0 00 00    	mov    %eax,0xd023(%rip)        # 4e324 <last_ticks.1>
        ++showing;
   41301:	8b 05 fd 4c 00 00    	mov    0x4cfd(%rip),%eax        # 46004 <showing.0>
   41307:	83 c0 01             	add    $0x1,%eax
   4130a:	89 05 f4 4c 00 00    	mov    %eax,0x4cf4(%rip)        # 46004 <showing.0>
    }

    // the current process may have died -- don't display it if so
    while (showing <= 2*NPROC
   41310:	eb 0f                	jmp    41321 <memshow_virtual_animate+0x51>
           && processes[showing % NPROC].p_state == P_FREE) {
        ++showing;
   41312:	8b 05 ec 4c 00 00    	mov    0x4cec(%rip),%eax        # 46004 <showing.0>
   41318:	83 c0 01             	add    $0x1,%eax
   4131b:	89 05 e3 4c 00 00    	mov    %eax,0x4ce3(%rip)        # 46004 <showing.0>
    while (showing <= 2*NPROC
   41321:	8b 05 dd 4c 00 00    	mov    0x4cdd(%rip),%eax        # 46004 <showing.0>
           && processes[showing % NPROC].p_state == P_FREE) {
   41327:	83 f8 20             	cmp    $0x20,%eax
   4132a:	7f 2c                	jg     41358 <memshow_virtual_animate+0x88>
   4132c:	8b 15 d2 4c 00 00    	mov    0x4cd2(%rip),%edx        # 46004 <showing.0>
   41332:	89 d0                	mov    %edx,%eax
   41334:	c1 f8 1f             	sar    $0x1f,%eax
   41337:	c1 e8 1c             	shr    $0x1c,%eax
   4133a:	01 c2                	add    %eax,%edx
   4133c:	83 e2 0f             	and    $0xf,%edx
   4133f:	29 c2                	sub    %eax,%edx
   41341:	89 d0                	mov    %edx,%eax
   41343:	48 98                	cltq
   41345:	48 69 c0 f0 00 00 00 	imul   $0xf0,%rax,%rax
   4134c:	48 05 d8 d0 04 00    	add    $0x4d0d8,%rax
   41352:	8b 00                	mov    (%rax),%eax
   41354:	85 c0                	test   %eax,%eax
   41356:	74 ba                	je     41312 <memshow_virtual_animate+0x42>
    }
    showing = showing % NPROC;
   41358:	8b 15 a6 4c 00 00    	mov    0x4ca6(%rip),%edx        # 46004 <showing.0>
   4135e:	89 d0                	mov    %edx,%eax
   41360:	c1 f8 1f             	sar    $0x1f,%eax
   41363:	c1 e8 1c             	shr    $0x1c,%eax
   41366:	01 c2                	add    %eax,%edx
   41368:	83 e2 0f             	and    $0xf,%edx
   4136b:	29 c2                	sub    %eax,%edx
   4136d:	89 d0                	mov    %edx,%eax
   4136f:	89 05 8f 4c 00 00    	mov    %eax,0x4c8f(%rip)        # 46004 <showing.0>

    if (processes[showing].p_state != P_FREE && processes[showing].display_status) {
   41375:	8b 05 89 4c 00 00    	mov    0x4c89(%rip),%eax        # 46004 <showing.0>
   4137b:	48 98                	cltq
   4137d:	48 69 c0 f0 00 00 00 	imul   $0xf0,%rax,%rax
   41384:	48 05 d8 d0 04 00    	add    $0x4d0d8,%rax
   4138a:	8b 00                	mov    (%rax),%eax
   4138c:	85 c0                	test   %eax,%eax
   4138e:	74 66                	je     413f6 <memshow_virtual_animate+0x126>
   41390:	8b 05 6e 4c 00 00    	mov    0x4c6e(%rip),%eax        # 46004 <showing.0>
   41396:	48 98                	cltq
   41398:	48 69 c0 f0 00 00 00 	imul   $0xf0,%rax,%rax
   4139f:	48 05 e8 d0 04 00    	add    $0x4d0e8,%rax
   413a5:	0f b6 00             	movzbl (%rax),%eax
   413a8:	84 c0                	test   %al,%al
   413aa:	74 4a                	je     413f6 <memshow_virtual_animate+0x126>
        char s[4];
        snprintf(s, 4, "%d ", showing);
   413ac:	8b 15 52 4c 00 00    	mov    0x4c52(%rip),%edx        # 46004 <showing.0>
   413b2:	48 8d 45 fc          	lea    -0x4(%rbp),%rax
   413b6:	89 d1                	mov    %edx,%ecx
   413b8:	ba ec 4c 04 00       	mov    $0x44cec,%edx
   413bd:	be 04 00 00 00       	mov    $0x4,%esi
   413c2:	48 89 c7             	mov    %rax,%rdi
   413c5:	b8 00 00 00 00       	mov    $0x0,%eax
   413ca:	e8 9b 35 00 00       	call   4496a <snprintf>
        memshow_virtual(processes[showing].p_pagetable, s);
   413cf:	8b 05 2f 4c 00 00    	mov    0x4c2f(%rip),%eax        # 46004 <showing.0>
   413d5:	48 98                	cltq
   413d7:	48 69 c0 f0 00 00 00 	imul   $0xf0,%rax,%rax
   413de:	48 05 e0 d0 04 00    	add    $0x4d0e0,%rax
   413e4:	48 8b 00             	mov    (%rax),%rax
   413e7:	48 8d 55 fc          	lea    -0x4(%rbp),%rdx
   413eb:	48 89 d6             	mov    %rdx,%rsi
   413ee:	48 89 c7             	mov    %rax,%rdi
   413f1:	e8 e9 fc ff ff       	call   410df <memshow_virtual>
    }
}
   413f6:	90                   	nop
   413f7:	c9                   	leave
   413f8:	c3                   	ret

00000000000413f9 <hardware_init>:

static void segments_init(void);
static void interrupt_init(void);
extern void virtual_memory_init(void);

void hardware_init(void) {
   413f9:	55                   	push   %rbp
   413fa:	48 89 e5             	mov    %rsp,%rbp
    segments_init();
   413fd:	e8 4f 01 00 00       	call   41551 <segments_init>
    interrupt_init();
   41402:	e8 ca 03 00 00       	call   417d1 <interrupt_init>
    virtual_memory_init();
   41407:	e8 eb 0f 00 00       	call   423f7 <virtual_memory_init>
}
   4140c:	90                   	nop
   4140d:	5d                   	pop    %rbp
   4140e:	c3                   	ret

000000000004140f <set_app_segment>:
#define SEGSEL_TASKSTATE        0x28            // task state segment

// Segments
static uint64_t segments[7];

static void set_app_segment(uint64_t* segment, uint64_t type, int dpl) {
   4140f:	55                   	push   %rbp
   41410:	48 89 e5             	mov    %rsp,%rbp
   41413:	48 83 ec 18          	sub    $0x18,%rsp
   41417:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
   4141b:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
   4141f:	89 55 ec             	mov    %edx,-0x14(%rbp)
    *segment = type
        | X86SEG_S                    // code/data segment
        | ((uint64_t) dpl << 45)
   41422:	8b 45 ec             	mov    -0x14(%rbp),%eax
   41425:	48 98                	cltq
   41427:	48 c1 e0 2d          	shl    $0x2d,%rax
   4142b:	48 0b 45 f0          	or     -0x10(%rbp),%rax
        | X86SEG_P;                   // segment present
   4142f:	48 ba 00 00 00 00 00 	movabs $0x900000000000,%rdx
   41436:	90 00 00 
   41439:	48 09 c2             	or     %rax,%rdx
    *segment = type
   4143c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   41440:	48 89 10             	mov    %rdx,(%rax)
}
   41443:	90                   	nop
   41444:	c9                   	leave
   41445:	c3                   	ret

0000000000041446 <set_sys_segment>:

static void set_sys_segment(uint64_t* segment, uint64_t type, int dpl,
                            uintptr_t addr, size_t size) {
   41446:	55                   	push   %rbp
   41447:	48 89 e5             	mov    %rsp,%rbp
   4144a:	48 83 ec 28          	sub    $0x28,%rsp
   4144e:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
   41452:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
   41456:	89 55 ec             	mov    %edx,-0x14(%rbp)
   41459:	48 89 4d e0          	mov    %rcx,-0x20(%rbp)
   4145d:	4c 89 45 d8          	mov    %r8,-0x28(%rbp)
    segment[0] = ((addr & 0x0000000000FFFFFFUL) << 16)
   41461:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
   41465:	48 c1 e0 10          	shl    $0x10,%rax
   41469:	48 89 c2             	mov    %rax,%rdx
   4146c:	48 b8 00 00 ff ff ff 	movabs $0xffffff0000,%rax
   41473:	00 00 00 
   41476:	48 21 c2             	and    %rax,%rdx
        | ((addr & 0x00000000FF000000UL) << 32)
   41479:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
   4147d:	48 c1 e0 20          	shl    $0x20,%rax
   41481:	48 89 c1             	mov    %rax,%rcx
   41484:	48 b8 00 00 00 00 00 	movabs $0xff00000000000000,%rax
   4148b:	00 00 ff 
   4148e:	48 21 c8             	and    %rcx,%rax
   41491:	48 09 c2             	or     %rax,%rdx
        | ((size - 1) & 0x0FFFFUL)
   41494:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
   41498:	48 83 e8 01          	sub    $0x1,%rax
   4149c:	0f b7 c0             	movzwl %ax,%eax
        | (((size - 1) & 0xF0000UL) << 48)
   4149f:	48 09 d0             	or     %rdx,%rax
        | type
   414a2:	48 0b 45 f0          	or     -0x10(%rbp),%rax
        | ((uint64_t) dpl << 45)
   414a6:	8b 55 ec             	mov    -0x14(%rbp),%edx
   414a9:	48 63 d2             	movslq %edx,%rdx
   414ac:	48 c1 e2 2d          	shl    $0x2d,%rdx
   414b0:	48 09 c2             	or     %rax,%rdx
        | X86SEG_P;                   // segment present
   414b3:	48 b8 00 00 00 00 00 	movabs $0x800000000000,%rax
   414ba:	80 00 00 
   414bd:	48 09 c2             	or     %rax,%rdx
    segment[0] = ((addr & 0x0000000000FFFFFFUL) << 16)
   414c0:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   414c4:	48 89 10             	mov    %rdx,(%rax)
    segment[1] = addr >> 32;
   414c7:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   414cb:	48 83 c0 08          	add    $0x8,%rax
   414cf:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
   414d3:	48 c1 ea 20          	shr    $0x20,%rdx
   414d7:	48 89 10             	mov    %rdx,(%rax)
}
   414da:	90                   	nop
   414db:	c9                   	leave
   414dc:	c3                   	ret

00000000000414dd <set_gate>:

// Processor state for taking an interrupt
static x86_64_taskstate kernel_task_descriptor;

static void set_gate(x86_64_gatedescriptor* gate, uint64_t type, int dpl,
                     uintptr_t function) {
   414dd:	55                   	push   %rbp
   414de:	48 89 e5             	mov    %rsp,%rbp
   414e1:	48 83 ec 20          	sub    $0x20,%rsp
   414e5:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
   414e9:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
   414ed:	89 55 ec             	mov    %edx,-0x14(%rbp)
   414f0:	48 89 4d e0          	mov    %rcx,-0x20(%rbp)
    gate->gd_low = (function & 0x000000000000FFFFUL)
   414f4:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
   414f8:	0f b7 c0             	movzwl %ax,%eax
        | (SEGSEL_KERN_CODE << 16)
        | type
   414fb:	48 0b 45 f0          	or     -0x10(%rbp),%rax
        | ((uint64_t) dpl << 45)
   414ff:	8b 55 ec             	mov    -0x14(%rbp),%edx
   41502:	48 63 d2             	movslq %edx,%rdx
   41505:	48 c1 e2 2d          	shl    $0x2d,%rdx
   41509:	48 09 c2             	or     %rax,%rdx
        | X86SEG_P
        | ((function & 0x00000000FFFF0000UL) << 32);
   4150c:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
   41510:	48 c1 e0 20          	shl    $0x20,%rax
   41514:	48 89 c1             	mov    %rax,%rcx
   41517:	48 b8 00 00 00 00 00 	movabs $0xffff000000000000,%rax
   4151e:	00 ff ff 
   41521:	48 21 c8             	and    %rcx,%rax
   41524:	48 09 c2             	or     %rax,%rdx
   41527:	48 b8 00 00 08 00 00 	movabs $0x800000080000,%rax
   4152e:	80 00 00 
   41531:	48 09 c2             	or     %rax,%rdx
    gate->gd_low = (function & 0x000000000000FFFFUL)
   41534:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   41538:	48 89 10             	mov    %rdx,(%rax)
    gate->gd_high = function >> 32;
   4153b:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
   4153f:	48 c1 e8 20          	shr    $0x20,%rax
   41543:	48 89 c2             	mov    %rax,%rdx
   41546:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   4154a:	48 89 50 08          	mov    %rdx,0x8(%rax)
}
   4154e:	90                   	nop
   4154f:	c9                   	leave
   41550:	c3                   	ret

0000000000041551 <segments_init>:
extern void default_int_handler(void);
extern void gpf_int_handler(void);
extern void pagefault_int_handler(void);
extern void timer_int_handler(void);

void segments_init(void) {
   41551:	55                   	push   %rbp
   41552:	48 89 e5             	mov    %rsp,%rbp
   41555:	48 83 ec 40          	sub    $0x40,%rsp
    // Segments for kernel & user code & data
    // The privilege level, which can be 0 or 3, differentiates between
    // kernel and user code. (Data segments are unused in WeensyOS.)
    segments[0] = 0;
   41559:	48 c7 05 dc cd 00 00 	movq   $0x0,0xcddc(%rip)        # 4e340 <segments>
   41560:	00 00 00 00 
    set_app_segment(&segments[SEGSEL_KERN_CODE >> 3], X86SEG_X | X86SEG_L, 0);
   41564:	48 b8 00 00 00 00 00 	movabs $0x20080000000000,%rax
   4156b:	08 20 00 
   4156e:	ba 00 00 00 00       	mov    $0x0,%edx
   41573:	48 89 c6             	mov    %rax,%rsi
   41576:	bf 48 e3 04 00       	mov    $0x4e348,%edi
   4157b:	e8 8f fe ff ff       	call   4140f <set_app_segment>
    set_app_segment(&segments[SEGSEL_APP_CODE >> 3], X86SEG_X | X86SEG_L, 3);
   41580:	48 b8 00 00 00 00 00 	movabs $0x20080000000000,%rax
   41587:	08 20 00 
   4158a:	ba 03 00 00 00       	mov    $0x3,%edx
   4158f:	48 89 c6             	mov    %rax,%rsi
   41592:	bf 50 e3 04 00       	mov    $0x4e350,%edi
   41597:	e8 73 fe ff ff       	call   4140f <set_app_segment>
    set_app_segment(&segments[SEGSEL_KERN_DATA >> 3], X86SEG_W, 0);
   4159c:	48 b8 00 00 00 00 00 	movabs $0x20000000000,%rax
   415a3:	02 00 00 
   415a6:	ba 00 00 00 00       	mov    $0x0,%edx
   415ab:	48 89 c6             	mov    %rax,%rsi
   415ae:	bf 58 e3 04 00       	mov    $0x4e358,%edi
   415b3:	e8 57 fe ff ff       	call   4140f <set_app_segment>
    set_app_segment(&segments[SEGSEL_APP_DATA >> 3], X86SEG_W, 3);
   415b8:	48 b8 00 00 00 00 00 	movabs $0x20000000000,%rax
   415bf:	02 00 00 
   415c2:	ba 03 00 00 00       	mov    $0x3,%edx
   415c7:	48 89 c6             	mov    %rax,%rsi
   415ca:	bf 60 e3 04 00       	mov    $0x4e360,%edi
   415cf:	e8 3b fe ff ff       	call   4140f <set_app_segment>
    set_sys_segment(&segments[SEGSEL_TASKSTATE >> 3], X86SEG_TSS, 0,
   415d4:	ba 80 f3 04 00       	mov    $0x4f380,%edx
   415d9:	48 b8 00 00 00 00 00 	movabs $0x90000000000,%rax
   415e0:	09 00 00 
   415e3:	41 b8 60 00 00 00    	mov    $0x60,%r8d
   415e9:	48 89 d1             	mov    %rdx,%rcx
   415ec:	ba 00 00 00 00       	mov    $0x0,%edx
   415f1:	48 89 c6             	mov    %rax,%rsi
   415f4:	bf 68 e3 04 00       	mov    $0x4e368,%edi
   415f9:	e8 48 fe ff ff       	call   41446 <set_sys_segment>
                    (uintptr_t) &kernel_task_descriptor,
                    sizeof(kernel_task_descriptor));

    x86_64_pseudodescriptor gdt;
    gdt.pseudod_limit = sizeof(segments) - 1;
   415fe:	66 c7 45 d6 37 00    	movw   $0x37,-0x2a(%rbp)
    gdt.pseudod_base = (uint64_t) segments;
   41604:	b8 40 e3 04 00       	mov    $0x4e340,%eax
   41609:	48 89 45 d8          	mov    %rax,-0x28(%rbp)

    // Kernel task descriptor lets us receive interrupts
    memset(&kernel_task_descriptor, 0, sizeof(kernel_task_descriptor));
   4160d:	ba 60 00 00 00       	mov    $0x60,%edx
   41612:	be 00 00 00 00       	mov    $0x0,%esi
   41617:	bf 80 f3 04 00       	mov    $0x4f380,%edi
   4161c:	e8 e0 23 00 00       	call   43a01 <memset>
    kernel_task_descriptor.ts_rsp[0] = KERNEL_STACK_TOP;
   41621:	48 c7 05 58 dd 00 00 	movq   $0x80000,0xdd58(%rip)        # 4f384 <kernel_task_descriptor+0x4>
   41628:	00 00 08 00 

    // Interrupt handler; most interrupts are effectively ignored
    memset(interrupt_descriptors, 0, sizeof(interrupt_descriptors));
   4162c:	ba 00 10 00 00       	mov    $0x1000,%edx
   41631:	be 00 00 00 00       	mov    $0x0,%esi
   41636:	bf 80 e3 04 00       	mov    $0x4e380,%edi
   4163b:	e8 c1 23 00 00       	call   43a01 <memset>
    for (unsigned i = 16; i < arraysize(interrupt_descriptors); ++i) {
   41640:	c7 45 fc 10 00 00 00 	movl   $0x10,-0x4(%rbp)
   41647:	eb 30                	jmp    41679 <segments_init+0x128>
        set_gate(&interrupt_descriptors[i], X86GATE_INTERRUPT, 0,
   41649:	ba 9c 00 04 00       	mov    $0x4009c,%edx
   4164e:	8b 45 fc             	mov    -0x4(%rbp),%eax
   41651:	48 c1 e0 04          	shl    $0x4,%rax
   41655:	48 05 80 e3 04 00    	add    $0x4e380,%rax
   4165b:	48 be 00 00 00 00 00 	movabs $0xe0000000000,%rsi
   41662:	0e 00 00 
   41665:	48 89 d1             	mov    %rdx,%rcx
   41668:	ba 00 00 00 00       	mov    $0x0,%edx
   4166d:	48 89 c7             	mov    %rax,%rdi
   41670:	e8 68 fe ff ff       	call   414dd <set_gate>
    for (unsigned i = 16; i < arraysize(interrupt_descriptors); ++i) {
   41675:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
   41679:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%rbp)
   41680:	76 c7                	jbe    41649 <segments_init+0xf8>
                 (uint64_t) default_int_handler);
    }

    // Timer interrupt
    set_gate(&interrupt_descriptors[INT_TIMER], X86GATE_INTERRUPT, 0,
   41682:	ba 36 00 04 00       	mov    $0x40036,%edx
   41687:	48 b8 00 00 00 00 00 	movabs $0xe0000000000,%rax
   4168e:	0e 00 00 
   41691:	48 89 d1             	mov    %rdx,%rcx
   41694:	ba 00 00 00 00       	mov    $0x0,%edx
   41699:	48 89 c6             	mov    %rax,%rsi
   4169c:	bf 80 e5 04 00       	mov    $0x4e580,%edi
   416a1:	e8 37 fe ff ff       	call   414dd <set_gate>
             (uint64_t) timer_int_handler);

    // GPF and page fault
    set_gate(&interrupt_descriptors[INT_GPF], X86GATE_INTERRUPT, 0,
   416a6:	ba 2e 00 04 00       	mov    $0x4002e,%edx
   416ab:	48 b8 00 00 00 00 00 	movabs $0xe0000000000,%rax
   416b2:	0e 00 00 
   416b5:	48 89 d1             	mov    %rdx,%rcx
   416b8:	ba 00 00 00 00       	mov    $0x0,%edx
   416bd:	48 89 c6             	mov    %rax,%rsi
   416c0:	bf 50 e4 04 00       	mov    $0x4e450,%edi
   416c5:	e8 13 fe ff ff       	call   414dd <set_gate>
             (uint64_t) gpf_int_handler);
    set_gate(&interrupt_descriptors[INT_PAGEFAULT], X86GATE_INTERRUPT, 0,
   416ca:	ba 32 00 04 00       	mov    $0x40032,%edx
   416cf:	48 b8 00 00 00 00 00 	movabs $0xe0000000000,%rax
   416d6:	0e 00 00 
   416d9:	48 89 d1             	mov    %rdx,%rcx
   416dc:	ba 00 00 00 00       	mov    $0x0,%edx
   416e1:	48 89 c6             	mov    %rax,%rsi
   416e4:	bf 60 e4 04 00       	mov    $0x4e460,%edi
   416e9:	e8 ef fd ff ff       	call   414dd <set_gate>
             (uint64_t) pagefault_int_handler);

    // System calls get special handling.
    // Note that the last argument is '3'.  This means that unprivileged
    // (level-3) applications may generate these interrupts.
    for (unsigned i = INT_SYS; i < INT_SYS + 16; ++i) {
   416ee:	c7 45 f8 30 00 00 00 	movl   $0x30,-0x8(%rbp)
   416f5:	eb 3e                	jmp    41735 <segments_init+0x1e4>
        set_gate(&interrupt_descriptors[i], X86GATE_INTERRUPT, 3,
                 (uint64_t) sys_int_handlers[i - INT_SYS]);
   416f7:	8b 45 f8             	mov    -0x8(%rbp),%eax
   416fa:	83 e8 30             	sub    $0x30,%eax
   416fd:	89 c0                	mov    %eax,%eax
   416ff:	48 8b 04 c5 e7 00 04 	mov    0x400e7(,%rax,8),%rax
   41706:	00 
        set_gate(&interrupt_descriptors[i], X86GATE_INTERRUPT, 3,
   41707:	48 89 c2             	mov    %rax,%rdx
   4170a:	8b 45 f8             	mov    -0x8(%rbp),%eax
   4170d:	48 c1 e0 04          	shl    $0x4,%rax
   41711:	48 05 80 e3 04 00    	add    $0x4e380,%rax
   41717:	48 be 00 00 00 00 00 	movabs $0xe0000000000,%rsi
   4171e:	0e 00 00 
   41721:	48 89 d1             	mov    %rdx,%rcx
   41724:	ba 03 00 00 00       	mov    $0x3,%edx
   41729:	48 89 c7             	mov    %rax,%rdi
   4172c:	e8 ac fd ff ff       	call   414dd <set_gate>
    for (unsigned i = INT_SYS; i < INT_SYS + 16; ++i) {
   41731:	83 45 f8 01          	addl   $0x1,-0x8(%rbp)
   41735:	83 7d f8 3f          	cmpl   $0x3f,-0x8(%rbp)
   41739:	76 bc                	jbe    416f7 <segments_init+0x1a6>
    }

    x86_64_pseudodescriptor idt;
    idt.pseudod_limit = sizeof(interrupt_descriptors) - 1;
   4173b:	66 c7 45 cc ff 0f    	movw   $0xfff,-0x34(%rbp)
    idt.pseudod_base = (uint64_t) interrupt_descriptors;
   41741:	b8 80 e3 04 00       	mov    $0x4e380,%eax
   41746:	48 89 45 ce          	mov    %rax,-0x32(%rbp)

    // Reload segment pointers
    asm volatile("lgdt %0\n\t"
   4174a:	b8 28 00 00 00       	mov    $0x28,%eax
   4174f:	0f 01 55 d6          	lgdt   -0x2a(%rbp)
   41753:	0f 00 d8             	ltr    %eax
   41756:	0f 01 5d cc          	lidt   -0x34(%rbp)
    asm volatile("movq %%cr0,%0" : "=r" (val));
   4175a:	0f 20 c0             	mov    %cr0,%rax
   4175d:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
    return val;
   41761:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
                     "r" ((uint16_t) SEGSEL_TASKSTATE),
                     "m" (idt)
                 : "memory");

    // Set up control registers: check alignment
    uint32_t cr0 = rcr0();
   41765:	89 45 f4             	mov    %eax,-0xc(%rbp)
    cr0 |= CR0_PE | CR0_PG | CR0_WP | CR0_AM | CR0_MP | CR0_NE;
   41768:	81 4d f4 23 00 05 80 	orl    $0x80050023,-0xc(%rbp)
   4176f:	8b 45 f4             	mov    -0xc(%rbp),%eax
   41772:	89 45 f0             	mov    %eax,-0x10(%rbp)
    uint64_t xval = val;
   41775:	8b 45 f0             	mov    -0x10(%rbp),%eax
   41778:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
    asm volatile("movq %0,%%cr0" : : "r" (xval));
   4177c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   41780:	0f 22 c0             	mov    %rax,%cr0
}
   41783:	90                   	nop
    lcr0(cr0);
}
   41784:	90                   	nop
   41785:	c9                   	leave
   41786:	c3                   	ret

0000000000041787 <interrupt_mask>:
#define TIMER_FREQ      1193182
#define TIMER_DIV(x)    ((TIMER_FREQ+(x)/2)/(x))

static uint16_t interrupts_enabled;

static void interrupt_mask(void) {
   41787:	55                   	push   %rbp
   41788:	48 89 e5             	mov    %rsp,%rbp
   4178b:	48 83 ec 20          	sub    $0x20,%rsp
    uint16_t masked = ~interrupts_enabled;
   4178f:	0f b7 05 4a dc 00 00 	movzwl 0xdc4a(%rip),%eax        # 4f3e0 <interrupts_enabled>
   41796:	f7 d0                	not    %eax
   41798:	66 89 45 fe          	mov    %ax,-0x2(%rbp)
    outb(IO_PIC1+1, masked & 0xFF);
   4179c:	0f b7 45 fe          	movzwl -0x2(%rbp),%eax
   417a0:	c7 45 f0 21 00 00 00 	movl   $0x21,-0x10(%rbp)
   417a7:	88 45 ef             	mov    %al,-0x11(%rbp)
    asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
   417aa:	0f b6 45 ef          	movzbl -0x11(%rbp),%eax
   417ae:	8b 55 f0             	mov    -0x10(%rbp),%edx
   417b1:	ee                   	out    %al,(%dx)
}
   417b2:	90                   	nop
    outb(IO_PIC2+1, (masked >> 8) & 0xFF);
   417b3:	0f b7 45 fe          	movzwl -0x2(%rbp),%eax
   417b7:	66 c1 e8 08          	shr    $0x8,%ax
   417bb:	c7 45 f8 a1 00 00 00 	movl   $0xa1,-0x8(%rbp)
   417c2:	88 45 f7             	mov    %al,-0x9(%rbp)
    asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
   417c5:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
   417c9:	8b 55 f8             	mov    -0x8(%rbp),%edx
   417cc:	ee                   	out    %al,(%dx)
}
   417cd:	90                   	nop
}
   417ce:	90                   	nop
   417cf:	c9                   	leave
   417d0:	c3                   	ret

00000000000417d1 <interrupt_init>:

void interrupt_init(void) {
   417d1:	55                   	push   %rbp
   417d2:	48 89 e5             	mov    %rsp,%rbp
   417d5:	48 83 ec 60          	sub    $0x60,%rsp
    // mask all interrupts
    interrupts_enabled = 0;
   417d9:	66 c7 05 fe db 00 00 	movw   $0x0,0xdbfe(%rip)        # 4f3e0 <interrupts_enabled>
   417e0:	00 00 
    interrupt_mask();
   417e2:	e8 a0 ff ff ff       	call   41787 <interrupt_mask>
   417e7:	c7 45 a4 20 00 00 00 	movl   $0x20,-0x5c(%rbp)
   417ee:	c6 45 a3 11          	movb   $0x11,-0x5d(%rbp)
    asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
   417f2:	0f b6 45 a3          	movzbl -0x5d(%rbp),%eax
   417f6:	8b 55 a4             	mov    -0x5c(%rbp),%edx
   417f9:	ee                   	out    %al,(%dx)
}
   417fa:	90                   	nop
   417fb:	c7 45 ac 21 00 00 00 	movl   $0x21,-0x54(%rbp)
   41802:	c6 45 ab 20          	movb   $0x20,-0x55(%rbp)
    asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
   41806:	0f b6 45 ab          	movzbl -0x55(%rbp),%eax
   4180a:	8b 55 ac             	mov    -0x54(%rbp),%edx
   4180d:	ee                   	out    %al,(%dx)
}
   4180e:	90                   	nop
   4180f:	c7 45 b4 21 00 00 00 	movl   $0x21,-0x4c(%rbp)
   41816:	c6 45 b3 04          	movb   $0x4,-0x4d(%rbp)
    asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
   4181a:	0f b6 45 b3          	movzbl -0x4d(%rbp),%eax
   4181e:	8b 55 b4             	mov    -0x4c(%rbp),%edx
   41821:	ee                   	out    %al,(%dx)
}
   41822:	90                   	nop
   41823:	c7 45 bc 21 00 00 00 	movl   $0x21,-0x44(%rbp)
   4182a:	c6 45 bb 03          	movb   $0x3,-0x45(%rbp)
    asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
   4182e:	0f b6 45 bb          	movzbl -0x45(%rbp),%eax
   41832:	8b 55 bc             	mov    -0x44(%rbp),%edx
   41835:	ee                   	out    %al,(%dx)
}
   41836:	90                   	nop
   41837:	c7 45 c4 a0 00 00 00 	movl   $0xa0,-0x3c(%rbp)
   4183e:	c6 45 c3 11          	movb   $0x11,-0x3d(%rbp)
    asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
   41842:	0f b6 45 c3          	movzbl -0x3d(%rbp),%eax
   41846:	8b 55 c4             	mov    -0x3c(%rbp),%edx
   41849:	ee                   	out    %al,(%dx)
}
   4184a:	90                   	nop
   4184b:	c7 45 cc a1 00 00 00 	movl   $0xa1,-0x34(%rbp)
   41852:	c6 45 cb 28          	movb   $0x28,-0x35(%rbp)
    asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
   41856:	0f b6 45 cb          	movzbl -0x35(%rbp),%eax
   4185a:	8b 55 cc             	mov    -0x34(%rbp),%edx
   4185d:	ee                   	out    %al,(%dx)
}
   4185e:	90                   	nop
   4185f:	c7 45 d4 a1 00 00 00 	movl   $0xa1,-0x2c(%rbp)
   41866:	c6 45 d3 02          	movb   $0x2,-0x2d(%rbp)
    asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
   4186a:	0f b6 45 d3          	movzbl -0x2d(%rbp),%eax
   4186e:	8b 55 d4             	mov    -0x2c(%rbp),%edx
   41871:	ee                   	out    %al,(%dx)
}
   41872:	90                   	nop
   41873:	c7 45 dc a1 00 00 00 	movl   $0xa1,-0x24(%rbp)
   4187a:	c6 45 db 01          	movb   $0x1,-0x25(%rbp)
    asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
   4187e:	0f b6 45 db          	movzbl -0x25(%rbp),%eax
   41882:	8b 55 dc             	mov    -0x24(%rbp),%edx
   41885:	ee                   	out    %al,(%dx)
}
   41886:	90                   	nop
   41887:	c7 45 e4 20 00 00 00 	movl   $0x20,-0x1c(%rbp)
   4188e:	c6 45 e3 68          	movb   $0x68,-0x1d(%rbp)
    asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
   41892:	0f b6 45 e3          	movzbl -0x1d(%rbp),%eax
   41896:	8b 55 e4             	mov    -0x1c(%rbp),%edx
   41899:	ee                   	out    %al,(%dx)
}
   4189a:	90                   	nop
   4189b:	c7 45 ec 20 00 00 00 	movl   $0x20,-0x14(%rbp)
   418a2:	c6 45 eb 0a          	movb   $0xa,-0x15(%rbp)
    asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
   418a6:	0f b6 45 eb          	movzbl -0x15(%rbp),%eax
   418aa:	8b 55 ec             	mov    -0x14(%rbp),%edx
   418ad:	ee                   	out    %al,(%dx)
}
   418ae:	90                   	nop
   418af:	c7 45 f4 a0 00 00 00 	movl   $0xa0,-0xc(%rbp)
   418b6:	c6 45 f3 68          	movb   $0x68,-0xd(%rbp)
    asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
   418ba:	0f b6 45 f3          	movzbl -0xd(%rbp),%eax
   418be:	8b 55 f4             	mov    -0xc(%rbp),%edx
   418c1:	ee                   	out    %al,(%dx)
}
   418c2:	90                   	nop
   418c3:	c7 45 fc a0 00 00 00 	movl   $0xa0,-0x4(%rbp)
   418ca:	c6 45 fb 0a          	movb   $0xa,-0x5(%rbp)
    asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
   418ce:	0f b6 45 fb          	movzbl -0x5(%rbp),%eax
   418d2:	8b 55 fc             	mov    -0x4(%rbp),%edx
   418d5:	ee                   	out    %al,(%dx)
}
   418d6:	90                   	nop

    outb(IO_PIC2, 0x68);               /* OCW3 */
    outb(IO_PIC2, 0x0a);               /* OCW3 */

    // re-disable interrupts
    interrupt_mask();
   418d7:	e8 ab fe ff ff       	call   41787 <interrupt_mask>
}
   418dc:	90                   	nop
   418dd:	c9                   	leave
   418de:	c3                   	ret

00000000000418df <timer_init>:

// timer_init(rate)
//    Set the timer interrupt to fire `rate` times a second. Disables the
//    timer interrupt if `rate <= 0`.

void timer_init(int rate) {
   418df:	55                   	push   %rbp
   418e0:	48 89 e5             	mov    %rsp,%rbp
   418e3:	48 83 ec 28          	sub    $0x28,%rsp
   418e7:	89 7d dc             	mov    %edi,-0x24(%rbp)
    if (rate > 0) {
   418ea:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
   418ee:	0f 8e 98 00 00 00    	jle    4198c <timer_init+0xad>
   418f4:	c7 45 ec 43 00 00 00 	movl   $0x43,-0x14(%rbp)
   418fb:	c6 45 eb 34          	movb   $0x34,-0x15(%rbp)
    asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
   418ff:	0f b6 45 eb          	movzbl -0x15(%rbp),%eax
   41903:	8b 55 ec             	mov    -0x14(%rbp),%edx
   41906:	ee                   	out    %al,(%dx)
}
   41907:	90                   	nop
        outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
        outb(IO_TIMER1, TIMER_DIV(rate) % 256);
   41908:	8b 45 dc             	mov    -0x24(%rbp),%eax
   4190b:	89 c2                	mov    %eax,%edx
   4190d:	c1 ea 1f             	shr    $0x1f,%edx
   41910:	01 d0                	add    %edx,%eax
   41912:	d1 f8                	sar    $1,%eax
   41914:	05 de 34 12 00       	add    $0x1234de,%eax
   41919:	99                   	cltd
   4191a:	f7 7d dc             	idivl  -0x24(%rbp)
   4191d:	89 c2                	mov    %eax,%edx
   4191f:	89 d0                	mov    %edx,%eax
   41921:	c1 f8 1f             	sar    $0x1f,%eax
   41924:	c1 e8 18             	shr    $0x18,%eax
   41927:	01 c2                	add    %eax,%edx
   41929:	0f b6 d2             	movzbl %dl,%edx
   4192c:	29 c2                	sub    %eax,%edx
   4192e:	89 d0                	mov    %edx,%eax
   41930:	c7 45 f4 40 00 00 00 	movl   $0x40,-0xc(%rbp)
   41937:	88 45 f3             	mov    %al,-0xd(%rbp)
    asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
   4193a:	0f b6 45 f3          	movzbl -0xd(%rbp),%eax
   4193e:	8b 55 f4             	mov    -0xc(%rbp),%edx
   41941:	ee                   	out    %al,(%dx)
}
   41942:	90                   	nop
        outb(IO_TIMER1, TIMER_DIV(rate) / 256);
   41943:	8b 45 dc             	mov    -0x24(%rbp),%eax
   41946:	89 c2                	mov    %eax,%edx
   41948:	c1 ea 1f             	shr    $0x1f,%edx
   4194b:	01 d0                	add    %edx,%eax
   4194d:	d1 f8                	sar    $1,%eax
   4194f:	05 de 34 12 00       	add    $0x1234de,%eax
   41954:	99                   	cltd
   41955:	f7 7d dc             	idivl  -0x24(%rbp)
   41958:	8d 90 ff 00 00 00    	lea    0xff(%rax),%edx
   4195e:	85 c0                	test   %eax,%eax
   41960:	0f 48 c2             	cmovs  %edx,%eax
   41963:	c1 f8 08             	sar    $0x8,%eax
   41966:	c7 45 fc 40 00 00 00 	movl   $0x40,-0x4(%rbp)
   4196d:	88 45 fb             	mov    %al,-0x5(%rbp)
    asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
   41970:	0f b6 45 fb          	movzbl -0x5(%rbp),%eax
   41974:	8b 55 fc             	mov    -0x4(%rbp),%edx
   41977:	ee                   	out    %al,(%dx)
}
   41978:	90                   	nop
        interrupts_enabled |= 1 << (INT_TIMER - INT_HARDWARE);
   41979:	0f b7 05 60 da 00 00 	movzwl 0xda60(%rip),%eax        # 4f3e0 <interrupts_enabled>
   41980:	83 c8 01             	or     $0x1,%eax
   41983:	66 89 05 56 da 00 00 	mov    %ax,0xda56(%rip)        # 4f3e0 <interrupts_enabled>
   4198a:	eb 11                	jmp    4199d <timer_init+0xbe>
    } else {
        interrupts_enabled &= ~(1 << (INT_TIMER - INT_HARDWARE));
   4198c:	0f b7 05 4d da 00 00 	movzwl 0xda4d(%rip),%eax        # 4f3e0 <interrupts_enabled>
   41993:	83 e0 fe             	and    $0xfffffffe,%eax
   41996:	66 89 05 43 da 00 00 	mov    %ax,0xda43(%rip)        # 4f3e0 <interrupts_enabled>
    }
    interrupt_mask();
   4199d:	e8 e5 fd ff ff       	call   41787 <interrupt_mask>
}
   419a2:	90                   	nop
   419a3:	c9                   	leave
   419a4:	c3                   	ret

00000000000419a5 <physical_memory_isreserved>:
//    Returns non-zero iff `pa` is a reserved physical address.

#define IOPHYSMEM       0x000A0000
#define EXTPHYSMEM      0x00100000

int physical_memory_isreserved(uintptr_t pa) {
   419a5:	55                   	push   %rbp
   419a6:	48 89 e5             	mov    %rsp,%rbp
   419a9:	48 83 ec 08          	sub    $0x8,%rsp
   419ad:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
    return pa == 0 || (pa >= IOPHYSMEM && pa < EXTPHYSMEM);
   419b1:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
   419b6:	74 14                	je     419cc <physical_memory_isreserved+0x27>
   419b8:	48 81 7d f8 ff ff 09 	cmpq   $0x9ffff,-0x8(%rbp)
   419bf:	00 
   419c0:	76 11                	jbe    419d3 <physical_memory_isreserved+0x2e>
   419c2:	48 81 7d f8 ff ff 0f 	cmpq   $0xfffff,-0x8(%rbp)
   419c9:	00 
   419ca:	77 07                	ja     419d3 <physical_memory_isreserved+0x2e>
   419cc:	b8 01 00 00 00       	mov    $0x1,%eax
   419d1:	eb 05                	jmp    419d8 <physical_memory_isreserved+0x33>
   419d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
   419d8:	c9                   	leave
   419d9:	c3                   	ret

00000000000419da <pci_make_configaddr>:


// pci_make_configaddr(bus, slot, func)
//    Construct a PCI configuration space address from parts.

static int pci_make_configaddr(int bus, int slot, int func) {
   419da:	55                   	push   %rbp
   419db:	48 89 e5             	mov    %rsp,%rbp
   419de:	48 83 ec 10          	sub    $0x10,%rsp
   419e2:	89 7d fc             	mov    %edi,-0x4(%rbp)
   419e5:	89 75 f8             	mov    %esi,-0x8(%rbp)
   419e8:	89 55 f4             	mov    %edx,-0xc(%rbp)
    return (bus << 16) | (slot << 11) | (func << 8);
   419eb:	8b 45 fc             	mov    -0x4(%rbp),%eax
   419ee:	c1 e0 10             	shl    $0x10,%eax
   419f1:	89 c2                	mov    %eax,%edx
   419f3:	8b 45 f8             	mov    -0x8(%rbp),%eax
   419f6:	c1 e0 0b             	shl    $0xb,%eax
   419f9:	09 c2                	or     %eax,%edx
   419fb:	8b 45 f4             	mov    -0xc(%rbp),%eax
   419fe:	c1 e0 08             	shl    $0x8,%eax
   41a01:	09 d0                	or     %edx,%eax
}
   41a03:	c9                   	leave
   41a04:	c3                   	ret

0000000000041a05 <pci_config_readl>:
//    Read a 32-bit word in PCI configuration space.

#define PCI_HOST_BRIDGE_CONFIG_ADDR 0xCF8
#define PCI_HOST_BRIDGE_CONFIG_DATA 0xCFC

static uint32_t pci_config_readl(int configaddr, int offset) {
   41a05:	55                   	push   %rbp
   41a06:	48 89 e5             	mov    %rsp,%rbp
   41a09:	48 83 ec 18          	sub    $0x18,%rsp
   41a0d:	89 7d ec             	mov    %edi,-0x14(%rbp)
   41a10:	89 75 e8             	mov    %esi,-0x18(%rbp)
    outl(PCI_HOST_BRIDGE_CONFIG_ADDR, 0x80000000 | configaddr | offset);
   41a13:	8b 55 ec             	mov    -0x14(%rbp),%edx
   41a16:	8b 45 e8             	mov    -0x18(%rbp),%eax
   41a19:	09 d0                	or     %edx,%eax
   41a1b:	0d 00 00 00 80       	or     $0x80000000,%eax
   41a20:	c7 45 f4 f8 0c 00 00 	movl   $0xcf8,-0xc(%rbp)
   41a27:	89 45 f0             	mov    %eax,-0x10(%rbp)
    asm volatile("outl %0,%w1" : : "a" (data), "d" (port));
   41a2a:	8b 45 f0             	mov    -0x10(%rbp),%eax
   41a2d:	8b 55 f4             	mov    -0xc(%rbp),%edx
   41a30:	ef                   	out    %eax,(%dx)
}
   41a31:	90                   	nop
   41a32:	c7 45 fc fc 0c 00 00 	movl   $0xcfc,-0x4(%rbp)
    asm volatile("inl %w1,%0" : "=a" (data) : "d" (port));
   41a39:	8b 45 fc             	mov    -0x4(%rbp),%eax
   41a3c:	89 c2                	mov    %eax,%edx
   41a3e:	ed                   	in     (%dx),%eax
   41a3f:	89 45 f8             	mov    %eax,-0x8(%rbp)
    return data;
   41a42:	8b 45 f8             	mov    -0x8(%rbp),%eax
    return inl(PCI_HOST_BRIDGE_CONFIG_DATA);
}
   41a45:	c9                   	leave
   41a46:	c3                   	ret

0000000000041a47 <pci_find_device>:

// pci_find_device
//    Search for a PCI device matching `vendor` and `device`. Return
//    the config base address or -1 if no device was found.

static int pci_find_device(int vendor, int device) {
   41a47:	55                   	push   %rbp
   41a48:	48 89 e5             	mov    %rsp,%rbp
   41a4b:	48 83 ec 28          	sub    $0x28,%rsp
   41a4f:	89 7d dc             	mov    %edi,-0x24(%rbp)
   41a52:	89 75 d8             	mov    %esi,-0x28(%rbp)
    for (int bus = 0; bus != 256; ++bus) {
   41a55:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
   41a5c:	eb 73                	jmp    41ad1 <pci_find_device+0x8a>
        for (int slot = 0; slot != 32; ++slot) {
   41a5e:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%rbp)
   41a65:	eb 60                	jmp    41ac7 <pci_find_device+0x80>
            for (int func = 0; func != 8; ++func) {
   41a67:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%rbp)
   41a6e:	eb 4a                	jmp    41aba <pci_find_device+0x73>
                int configaddr = pci_make_configaddr(bus, slot, func);
   41a70:	8b 55 f4             	mov    -0xc(%rbp),%edx
   41a73:	8b 4d f8             	mov    -0x8(%rbp),%ecx
   41a76:	8b 45 fc             	mov    -0x4(%rbp),%eax
   41a79:	89 ce                	mov    %ecx,%esi
   41a7b:	89 c7                	mov    %eax,%edi
   41a7d:	e8 58 ff ff ff       	call   419da <pci_make_configaddr>
   41a82:	89 45 f0             	mov    %eax,-0x10(%rbp)
                uint32_t vendor_device = pci_config_readl(configaddr, 0);
   41a85:	8b 45 f0             	mov    -0x10(%rbp),%eax
   41a88:	be 00 00 00 00       	mov    $0x0,%esi
   41a8d:	89 c7                	mov    %eax,%edi
   41a8f:	e8 71 ff ff ff       	call   41a05 <pci_config_readl>
   41a94:	89 45 ec             	mov    %eax,-0x14(%rbp)
                if (vendor_device == (uint32_t) (vendor | (device << 16))) {
   41a97:	8b 45 d8             	mov    -0x28(%rbp),%eax
   41a9a:	c1 e0 10             	shl    $0x10,%eax
   41a9d:	0b 45 dc             	or     -0x24(%rbp),%eax
   41aa0:	39 45 ec             	cmp    %eax,-0x14(%rbp)
   41aa3:	75 05                	jne    41aaa <pci_find_device+0x63>
                    return configaddr;
   41aa5:	8b 45 f0             	mov    -0x10(%rbp),%eax
   41aa8:	eb 35                	jmp    41adf <pci_find_device+0x98>
                } else if (vendor_device == (uint32_t) -1 && func == 0) {
   41aaa:	83 7d ec ff          	cmpl   $0xffffffff,-0x14(%rbp)
   41aae:	75 06                	jne    41ab6 <pci_find_device+0x6f>
   41ab0:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
   41ab4:	74 0c                	je     41ac2 <pci_find_device+0x7b>
            for (int func = 0; func != 8; ++func) {
   41ab6:	83 45 f4 01          	addl   $0x1,-0xc(%rbp)
   41aba:	83 7d f4 08          	cmpl   $0x8,-0xc(%rbp)
   41abe:	75 b0                	jne    41a70 <pci_find_device+0x29>
   41ac0:	eb 01                	jmp    41ac3 <pci_find_device+0x7c>
                    break;
   41ac2:	90                   	nop
        for (int slot = 0; slot != 32; ++slot) {
   41ac3:	83 45 f8 01          	addl   $0x1,-0x8(%rbp)
   41ac7:	83 7d f8 20          	cmpl   $0x20,-0x8(%rbp)
   41acb:	75 9a                	jne    41a67 <pci_find_device+0x20>
    for (int bus = 0; bus != 256; ++bus) {
   41acd:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
   41ad1:	81 7d fc 00 01 00 00 	cmpl   $0x100,-0x4(%rbp)
   41ad8:	75 84                	jne    41a5e <pci_find_device+0x17>
                }
            }
        }
    }
    return -1;
   41ada:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
   41adf:	c9                   	leave
   41ae0:	c3                   	ret

0000000000041ae1 <poweroff>:
//    that speaks ACPI; QEMU emulates a PIIX4 Power Management Controller.

#define PCI_VENDOR_ID_INTEL     0x8086
#define PCI_DEVICE_ID_PIIX4     0x7113

void poweroff(void) {
   41ae1:	55                   	push   %rbp
   41ae2:	48 89 e5             	mov    %rsp,%rbp
   41ae5:	48 83 ec 10          	sub    $0x10,%rsp
    int configaddr = pci_find_device(PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_PIIX4);
   41ae9:	be 13 71 00 00       	mov    $0x7113,%esi
   41aee:	bf 86 80 00 00       	mov    $0x8086,%edi
   41af3:	e8 4f ff ff ff       	call   41a47 <pci_find_device>
   41af8:	89 45 fc             	mov    %eax,-0x4(%rbp)
    if (configaddr >= 0) {
   41afb:	83 7d fc 00          	cmpl   $0x0,-0x4(%rbp)
   41aff:	78 30                	js     41b31 <poweroff+0x50>
        // Read I/O base register from controller's PCI configuration space.
        int pm_io_base = pci_config_readl(configaddr, 0x40) & 0xFFC0;
   41b01:	8b 45 fc             	mov    -0x4(%rbp),%eax
   41b04:	be 40 00 00 00       	mov    $0x40,%esi
   41b09:	89 c7                	mov    %eax,%edi
   41b0b:	e8 f5 fe ff ff       	call   41a05 <pci_config_readl>
   41b10:	25 c0 ff 00 00       	and    $0xffc0,%eax
   41b15:	89 45 f8             	mov    %eax,-0x8(%rbp)
        // Write `suspend enable` to the power management control register.
        outw(pm_io_base + 4, 0x2000);
   41b18:	8b 45 f8             	mov    -0x8(%rbp),%eax
   41b1b:	83 c0 04             	add    $0x4,%eax
   41b1e:	89 45 f4             	mov    %eax,-0xc(%rbp)
   41b21:	66 c7 45 f2 00 20    	movw   $0x2000,-0xe(%rbp)
    asm volatile("outw %0,%w1" : : "a" (data), "d" (port));
   41b27:	0f b7 45 f2          	movzwl -0xe(%rbp),%eax
   41b2b:	8b 55 f4             	mov    -0xc(%rbp),%edx
   41b2e:	66 ef                	out    %ax,(%dx)
}
   41b30:	90                   	nop
    }
    // No PIIX4; spin.
    console_printf(CPOS(24, 0), 0xC000, "Cannot power off!\n");
   41b31:	ba 00 4d 04 00       	mov    $0x44d00,%edx
   41b36:	be 00 c0 00 00       	mov    $0xc000,%esi
   41b3b:	bf 80 07 00 00       	mov    $0x780,%edi
   41b40:	b8 00 00 00 00       	mov    $0x0,%eax
   41b45:	e8 15 2d 00 00       	call   4485f <console_printf>
 spinloop: goto spinloop;
   41b4a:	eb fe                	jmp    41b4a <poweroff+0x69>

0000000000041b4c <reboot>:


// reboot
//    Reboot the virtual machine.

void reboot(void) {
   41b4c:	55                   	push   %rbp
   41b4d:	48 89 e5             	mov    %rsp,%rbp
   41b50:	48 83 ec 10          	sub    $0x10,%rsp
   41b54:	c7 45 fc 92 00 00 00 	movl   $0x92,-0x4(%rbp)
   41b5b:	c6 45 fb 03          	movb   $0x3,-0x5(%rbp)
    asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
   41b5f:	0f b6 45 fb          	movzbl -0x5(%rbp),%eax
   41b63:	8b 55 fc             	mov    -0x4(%rbp),%edx
   41b66:	ee                   	out    %al,(%dx)
}
   41b67:	90                   	nop
    outb(0x92, 3);
 spinloop: goto spinloop;
   41b68:	eb fe                	jmp    41b68 <reboot+0x1c>

0000000000041b6a <process_init>:


// process_init(p, flags)
//    Initialize special-purpose registers for process `p`.

void process_init(proc* p, int flags) {
   41b6a:	55                   	push   %rbp
   41b6b:	48 89 e5             	mov    %rsp,%rbp
   41b6e:	48 83 ec 10          	sub    $0x10,%rsp
   41b72:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
   41b76:	89 75 f4             	mov    %esi,-0xc(%rbp)
    memset(&p->p_registers, 0, sizeof(p->p_registers));
   41b79:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   41b7d:	48 83 c0 18          	add    $0x18,%rax
   41b81:	ba c0 00 00 00       	mov    $0xc0,%edx
   41b86:	be 00 00 00 00       	mov    $0x0,%esi
   41b8b:	48 89 c7             	mov    %rax,%rdi
   41b8e:	e8 6e 1e 00 00       	call   43a01 <memset>
    p->p_registers.reg_cs = SEGSEL_APP_CODE | 3;
   41b93:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   41b97:	66 c7 80 b8 00 00 00 	movw   $0x13,0xb8(%rax)
   41b9e:	13 00 
    p->p_registers.reg_fs = SEGSEL_APP_DATA | 3;
   41ba0:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   41ba4:	48 c7 80 90 00 00 00 	movq   $0x23,0x90(%rax)
   41bab:	23 00 00 00 
    p->p_registers.reg_gs = SEGSEL_APP_DATA | 3;
   41baf:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   41bb3:	48 c7 80 98 00 00 00 	movq   $0x23,0x98(%rax)
   41bba:	23 00 00 00 
    p->p_registers.reg_ss = SEGSEL_APP_DATA | 3;
   41bbe:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   41bc2:	66 c7 80 d0 00 00 00 	movw   $0x23,0xd0(%rax)
   41bc9:	23 00 
    p->p_registers.reg_rflags = EFLAGS_IF;
   41bcb:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   41bcf:	48 c7 80 c0 00 00 00 	movq   $0x200,0xc0(%rax)
   41bd6:	00 02 00 00 

    if (flags & PROCINIT_ALLOW_PROGRAMMED_IO) {
   41bda:	8b 45 f4             	mov    -0xc(%rbp),%eax
   41bdd:	83 e0 01             	and    $0x1,%eax
   41be0:	85 c0                	test   %eax,%eax
   41be2:	74 1c                	je     41c00 <process_init+0x96>
        p->p_registers.reg_rflags |= EFLAGS_IOPL_3;
   41be4:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   41be8:	48 8b 80 c0 00 00 00 	mov    0xc0(%rax),%rax
   41bef:	80 cc 30             	or     $0x30,%ah
   41bf2:	48 89 c2             	mov    %rax,%rdx
   41bf5:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   41bf9:	48 89 90 c0 00 00 00 	mov    %rdx,0xc0(%rax)
    }
    if (flags & PROCINIT_DISABLE_INTERRUPTS) {
   41c00:	8b 45 f4             	mov    -0xc(%rbp),%eax
   41c03:	83 e0 02             	and    $0x2,%eax
   41c06:	85 c0                	test   %eax,%eax
   41c08:	74 1c                	je     41c26 <process_init+0xbc>
        p->p_registers.reg_rflags &= ~EFLAGS_IF;
   41c0a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   41c0e:	48 8b 80 c0 00 00 00 	mov    0xc0(%rax),%rax
   41c15:	80 e4 fd             	and    $0xfd,%ah
   41c18:	48 89 c2             	mov    %rax,%rdx
   41c1b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   41c1f:	48 89 90 c0 00 00 00 	mov    %rdx,0xc0(%rax)
    }
    p->display_status = 1;
   41c26:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   41c2a:	c6 80 e8 00 00 00 01 	movb   $0x1,0xe8(%rax)
}
   41c31:	90                   	nop
   41c32:	c9                   	leave
   41c33:	c3                   	ret

0000000000041c34 <console_show_cursor>:

// console_show_cursor(cpos)
//    Move the console cursor to position `cpos`, which should be between 0
//    and 80 * 25.

void console_show_cursor(int cpos) {
   41c34:	55                   	push   %rbp
   41c35:	48 89 e5             	mov    %rsp,%rbp
   41c38:	48 83 ec 28          	sub    $0x28,%rsp
   41c3c:	89 7d dc             	mov    %edi,-0x24(%rbp)
    if (cpos < 0 || cpos > CONSOLE_ROWS * CONSOLE_COLUMNS) {
   41c3f:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
   41c43:	78 09                	js     41c4e <console_show_cursor+0x1a>
   41c45:	81 7d dc d0 07 00 00 	cmpl   $0x7d0,-0x24(%rbp)
   41c4c:	7e 07                	jle    41c55 <console_show_cursor+0x21>
        cpos = 0;
   41c4e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%rbp)
   41c55:	c7 45 e4 d4 03 00 00 	movl   $0x3d4,-0x1c(%rbp)
   41c5c:	c6 45 e3 0e          	movb   $0xe,-0x1d(%rbp)
    asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
   41c60:	0f b6 45 e3          	movzbl -0x1d(%rbp),%eax
   41c64:	8b 55 e4             	mov    -0x1c(%rbp),%edx
   41c67:	ee                   	out    %al,(%dx)
}
   41c68:	90                   	nop
    }
    outb(0x3D4, 14);
    outb(0x3D5, cpos / 256);
   41c69:	8b 45 dc             	mov    -0x24(%rbp),%eax
   41c6c:	8d 90 ff 00 00 00    	lea    0xff(%rax),%edx
   41c72:	85 c0                	test   %eax,%eax
   41c74:	0f 48 c2             	cmovs  %edx,%eax
   41c77:	c1 f8 08             	sar    $0x8,%eax
   41c7a:	c7 45 ec d5 03 00 00 	movl   $0x3d5,-0x14(%rbp)
   41c81:	88 45 eb             	mov    %al,-0x15(%rbp)
    asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
   41c84:	0f b6 45 eb          	movzbl -0x15(%rbp),%eax
   41c88:	8b 55 ec             	mov    -0x14(%rbp),%edx
   41c8b:	ee                   	out    %al,(%dx)
}
   41c8c:	90                   	nop
   41c8d:	c7 45 f4 d4 03 00 00 	movl   $0x3d4,-0xc(%rbp)
   41c94:	c6 45 f3 0f          	movb   $0xf,-0xd(%rbp)
    asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
   41c98:	0f b6 45 f3          	movzbl -0xd(%rbp),%eax
   41c9c:	8b 55 f4             	mov    -0xc(%rbp),%edx
   41c9f:	ee                   	out    %al,(%dx)
}
   41ca0:	90                   	nop
    outb(0x3D4, 15);
    outb(0x3D5, cpos % 256);
   41ca1:	8b 55 dc             	mov    -0x24(%rbp),%edx
   41ca4:	89 d0                	mov    %edx,%eax
   41ca6:	c1 f8 1f             	sar    $0x1f,%eax
   41ca9:	c1 e8 18             	shr    $0x18,%eax
   41cac:	01 c2                	add    %eax,%edx
   41cae:	0f b6 d2             	movzbl %dl,%edx
   41cb1:	29 c2                	sub    %eax,%edx
   41cb3:	89 d0                	mov    %edx,%eax
   41cb5:	c7 45 fc d5 03 00 00 	movl   $0x3d5,-0x4(%rbp)
   41cbc:	88 45 fb             	mov    %al,-0x5(%rbp)
    asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
   41cbf:	0f b6 45 fb          	movzbl -0x5(%rbp),%eax
   41cc3:	8b 55 fc             	mov    -0x4(%rbp),%edx
   41cc6:	ee                   	out    %al,(%dx)
}
   41cc7:	90                   	nop
}
   41cc8:	90                   	nop
   41cc9:	c9                   	leave
   41cca:	c3                   	ret

0000000000041ccb <keyboard_readc>:
    /*CKEY(16)*/ {{'\'', '"', 0, 0}},  /*CKEY(17)*/ {{'`', '~', 0, 0}},
    /*CKEY(18)*/ {{'\\', '|', 034, 0}},  /*CKEY(19)*/ {{',', '<', 0, 0}},
    /*CKEY(20)*/ {{'.', '>', 0, 0}},  /*CKEY(21)*/ {{'/', '?', 0, 0}}
};

int keyboard_readc(void) {
   41ccb:	55                   	push   %rbp
   41ccc:	48 89 e5             	mov    %rsp,%rbp
   41ccf:	48 83 ec 20          	sub    $0x20,%rsp
   41cd3:	c7 45 f0 64 00 00 00 	movl   $0x64,-0x10(%rbp)
    asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
   41cda:	8b 45 f0             	mov    -0x10(%rbp),%eax
   41cdd:	89 c2                	mov    %eax,%edx
   41cdf:	ec                   	in     (%dx),%al
   41ce0:	88 45 ef             	mov    %al,-0x11(%rbp)
    return data;
   41ce3:	0f b6 45 ef          	movzbl -0x11(%rbp),%eax
    static uint8_t modifiers;
    static uint8_t last_escape;

    if ((inb(KEYBOARD_STATUSREG) & KEYBOARD_STATUS_READY) == 0) {
   41ce7:	0f b6 c0             	movzbl %al,%eax
   41cea:	83 e0 01             	and    $0x1,%eax
   41ced:	85 c0                	test   %eax,%eax
   41cef:	75 0a                	jne    41cfb <keyboard_readc+0x30>
        return -1;
   41cf1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
   41cf6:	e9 f2 01 00 00       	jmp    41eed <keyboard_readc+0x222>
   41cfb:	c7 45 e8 60 00 00 00 	movl   $0x60,-0x18(%rbp)
    asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
   41d02:	8b 45 e8             	mov    -0x18(%rbp),%eax
   41d05:	89 c2                	mov    %eax,%edx
   41d07:	ec                   	in     (%dx),%al
   41d08:	88 45 e7             	mov    %al,-0x19(%rbp)
    return data;
   41d0b:	0f b6 45 e7          	movzbl -0x19(%rbp),%eax
    }

    uint8_t data = inb(KEYBOARD_DATAREG);
   41d0f:	88 45 fb             	mov    %al,-0x5(%rbp)
    uint8_t escape = last_escape;
   41d12:	0f b6 05 c9 d6 00 00 	movzbl 0xd6c9(%rip),%eax        # 4f3e2 <last_escape.2>
   41d19:	88 45 fa             	mov    %al,-0x6(%rbp)
    last_escape = 0;
   41d1c:	c6 05 bf d6 00 00 00 	movb   $0x0,0xd6bf(%rip)        # 4f3e2 <last_escape.2>

    if (data == 0xE0) {         // mode shift
   41d23:	80 7d fb e0          	cmpb   $0xe0,-0x5(%rbp)
   41d27:	75 11                	jne    41d3a <keyboard_readc+0x6f>
        last_escape = 0x80;
   41d29:	c6 05 b2 d6 00 00 80 	movb   $0x80,0xd6b2(%rip)        # 4f3e2 <last_escape.2>
        return 0;
   41d30:	b8 00 00 00 00       	mov    $0x0,%eax
   41d35:	e9 b3 01 00 00       	jmp    41eed <keyboard_readc+0x222>
    } else if (data & 0x80) {   // key release: matters only for modifier keys
   41d3a:	0f b6 45 fb          	movzbl -0x5(%rbp),%eax
   41d3e:	84 c0                	test   %al,%al
   41d40:	79 60                	jns    41da2 <keyboard_readc+0xd7>
        int ch = keymap[(data & 0x7F) | escape];
   41d42:	0f b6 45 fb          	movzbl -0x5(%rbp),%eax
   41d46:	83 e0 7f             	and    $0x7f,%eax
   41d49:	89 c2                	mov    %eax,%edx
   41d4b:	0f b6 45 fa          	movzbl -0x6(%rbp),%eax
   41d4f:	09 d0                	or     %edx,%eax
   41d51:	48 98                	cltq
   41d53:	0f b6 80 20 4d 04 00 	movzbl 0x44d20(%rax),%eax
   41d5a:	0f b6 c0             	movzbl %al,%eax
   41d5d:	89 45 f4             	mov    %eax,-0xc(%rbp)
        if (ch >= KEY_SHIFT && ch < KEY_CAPSLOCK) {
   41d60:	81 7d f4 f9 00 00 00 	cmpl   $0xf9,-0xc(%rbp)
   41d67:	7e 2f                	jle    41d98 <keyboard_readc+0xcd>
   41d69:	81 7d f4 fc 00 00 00 	cmpl   $0xfc,-0xc(%rbp)
   41d70:	7f 26                	jg     41d98 <keyboard_readc+0xcd>
            modifiers &= ~(1 << (ch - KEY_SHIFT));
   41d72:	8b 45 f4             	mov    -0xc(%rbp),%eax
   41d75:	2d fa 00 00 00       	sub    $0xfa,%eax
   41d7a:	ba 01 00 00 00       	mov    $0x1,%edx
   41d7f:	89 c1                	mov    %eax,%ecx
   41d81:	d3 e2                	shl    %cl,%edx
   41d83:	89 d0                	mov    %edx,%eax
   41d85:	f7 d0                	not    %eax
   41d87:	89 c2                	mov    %eax,%edx
   41d89:	0f b6 05 53 d6 00 00 	movzbl 0xd653(%rip),%eax        # 4f3e3 <modifiers.1>
   41d90:	21 d0                	and    %edx,%eax
   41d92:	88 05 4b d6 00 00    	mov    %al,0xd64b(%rip)        # 4f3e3 <modifiers.1>
        }
        return 0;
   41d98:	b8 00 00 00 00       	mov    $0x0,%eax
   41d9d:	e9 4b 01 00 00       	jmp    41eed <keyboard_readc+0x222>
    }

    int ch = (unsigned char) keymap[data | escape];
   41da2:	0f b6 45 fb          	movzbl -0x5(%rbp),%eax
   41da6:	0a 45 fa             	or     -0x6(%rbp),%al
   41da9:	0f b6 c0             	movzbl %al,%eax
   41dac:	48 98                	cltq
   41dae:	0f b6 80 20 4d 04 00 	movzbl 0x44d20(%rax),%eax
   41db5:	0f b6 c0             	movzbl %al,%eax
   41db8:	89 45 fc             	mov    %eax,-0x4(%rbp)

    if (ch >= 'a' && ch <= 'z') {
   41dbb:	83 7d fc 60          	cmpl   $0x60,-0x4(%rbp)
   41dbf:	7e 62                	jle    41e23 <keyboard_readc+0x158>
   41dc1:	83 7d fc 7a          	cmpl   $0x7a,-0x4(%rbp)
   41dc5:	7f 5c                	jg     41e23 <keyboard_readc+0x158>
        if (modifiers & MOD_CONTROL) {
   41dc7:	0f b6 05 15 d6 00 00 	movzbl 0xd615(%rip),%eax        # 4f3e3 <modifiers.1>
   41dce:	0f b6 c0             	movzbl %al,%eax
   41dd1:	83 e0 02             	and    $0x2,%eax
   41dd4:	85 c0                	test   %eax,%eax
   41dd6:	74 09                	je     41de1 <keyboard_readc+0x116>
            ch -= 0x60;
   41dd8:	83 6d fc 60          	subl   $0x60,-0x4(%rbp)
        if (modifiers & MOD_CONTROL) {
   41ddc:	e9 08 01 00 00       	jmp    41ee9 <keyboard_readc+0x21e>
        } else if (!(modifiers & MOD_SHIFT) != !(modifiers & MOD_CAPSLOCK)) {
   41de1:	0f b6 05 fb d5 00 00 	movzbl 0xd5fb(%rip),%eax        # 4f3e3 <modifiers.1>
   41de8:	0f b6 c0             	movzbl %al,%eax
   41deb:	83 e0 01             	and    $0x1,%eax
   41dee:	89 c2                	mov    %eax,%edx
   41df0:	83 e2 01             	and    $0x1,%edx
   41df3:	89 d0                	mov    %edx,%eax
   41df5:	83 f0 01             	xor    $0x1,%eax
   41df8:	89 c2                	mov    %eax,%edx
   41dfa:	0f b6 05 e2 d5 00 00 	movzbl 0xd5e2(%rip),%eax        # 4f3e3 <modifiers.1>
   41e01:	0f b6 c0             	movzbl %al,%eax
   41e04:	83 e0 08             	and    $0x8,%eax
   41e07:	c1 e8 03             	shr    $0x3,%eax
   41e0a:	83 e0 01             	and    $0x1,%eax
   41e0d:	83 f0 01             	xor    $0x1,%eax
   41e10:	31 d0                	xor    %edx,%eax
   41e12:	84 c0                	test   %al,%al
   41e14:	0f 84 cf 00 00 00    	je     41ee9 <keyboard_readc+0x21e>
            ch -= 0x20;
   41e1a:	83 6d fc 20          	subl   $0x20,-0x4(%rbp)
        if (modifiers & MOD_CONTROL) {
   41e1e:	e9 c6 00 00 00       	jmp    41ee9 <keyboard_readc+0x21e>
        }
    } else if (ch >= KEY_CAPSLOCK) {
   41e23:	81 7d fc fc 00 00 00 	cmpl   $0xfc,-0x4(%rbp)
   41e2a:	7e 30                	jle    41e5c <keyboard_readc+0x191>
        modifiers ^= 1 << (ch - KEY_SHIFT);
   41e2c:	8b 45 fc             	mov    -0x4(%rbp),%eax
   41e2f:	2d fa 00 00 00       	sub    $0xfa,%eax
   41e34:	ba 01 00 00 00       	mov    $0x1,%edx
   41e39:	89 c1                	mov    %eax,%ecx
   41e3b:	d3 e2                	shl    %cl,%edx
   41e3d:	89 d0                	mov    %edx,%eax
   41e3f:	89 c2                	mov    %eax,%edx
   41e41:	0f b6 05 9b d5 00 00 	movzbl 0xd59b(%rip),%eax        # 4f3e3 <modifiers.1>
   41e48:	31 d0                	xor    %edx,%eax
   41e4a:	88 05 93 d5 00 00    	mov    %al,0xd593(%rip)        # 4f3e3 <modifiers.1>
        ch = 0;
   41e50:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
   41e57:	e9 8e 00 00 00       	jmp    41eea <keyboard_readc+0x21f>
    } else if (ch >= KEY_SHIFT) {
   41e5c:	81 7d fc f9 00 00 00 	cmpl   $0xf9,-0x4(%rbp)
   41e63:	7e 2d                	jle    41e92 <keyboard_readc+0x1c7>
        modifiers |= 1 << (ch - KEY_SHIFT);
   41e65:	8b 45 fc             	mov    -0x4(%rbp),%eax
   41e68:	2d fa 00 00 00       	sub    $0xfa,%eax
   41e6d:	ba 01 00 00 00       	mov    $0x1,%edx
   41e72:	89 c1                	mov    %eax,%ecx
   41e74:	d3 e2                	shl    %cl,%edx
   41e76:	89 d0                	mov    %edx,%eax
   41e78:	89 c2                	mov    %eax,%edx
   41e7a:	0f b6 05 62 d5 00 00 	movzbl 0xd562(%rip),%eax        # 4f3e3 <modifiers.1>
   41e81:	09 d0                	or     %edx,%eax
   41e83:	88 05 5a d5 00 00    	mov    %al,0xd55a(%rip)        # 4f3e3 <modifiers.1>
        ch = 0;
   41e89:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
   41e90:	eb 58                	jmp    41eea <keyboard_readc+0x21f>
    } else if (ch >= CKEY(0) && ch <= CKEY(21)) {
   41e92:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%rbp)
   41e96:	7e 31                	jle    41ec9 <keyboard_readc+0x1fe>
   41e98:	81 7d fc 95 00 00 00 	cmpl   $0x95,-0x4(%rbp)
   41e9f:	7f 28                	jg     41ec9 <keyboard_readc+0x1fe>
        ch = complex_keymap[ch - CKEY(0)].map[modifiers & 3];
   41ea1:	8b 45 fc             	mov    -0x4(%rbp),%eax
   41ea4:	8d 50 80             	lea    -0x80(%rax),%edx
   41ea7:	0f b6 05 35 d5 00 00 	movzbl 0xd535(%rip),%eax        # 4f3e3 <modifiers.1>
   41eae:	0f b6 c0             	movzbl %al,%eax
   41eb1:	83 e0 03             	and    $0x3,%eax
   41eb4:	48 98                	cltq
   41eb6:	48 63 d2             	movslq %edx,%rdx
   41eb9:	0f b6 84 90 20 4e 04 	movzbl 0x44e20(%rax,%rdx,4),%eax
   41ec0:	00 
   41ec1:	0f b6 c0             	movzbl %al,%eax
   41ec4:	89 45 fc             	mov    %eax,-0x4(%rbp)
   41ec7:	eb 21                	jmp    41eea <keyboard_readc+0x21f>
    } else if (ch < 0x80 && (modifiers & MOD_CONTROL)) {
   41ec9:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%rbp)
   41ecd:	7f 1b                	jg     41eea <keyboard_readc+0x21f>
   41ecf:	0f b6 05 0d d5 00 00 	movzbl 0xd50d(%rip),%eax        # 4f3e3 <modifiers.1>
   41ed6:	0f b6 c0             	movzbl %al,%eax
   41ed9:	83 e0 02             	and    $0x2,%eax
   41edc:	85 c0                	test   %eax,%eax
   41ede:	74 0a                	je     41eea <keyboard_readc+0x21f>
        ch = 0;
   41ee0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
   41ee7:	eb 01                	jmp    41eea <keyboard_readc+0x21f>
        if (modifiers & MOD_CONTROL) {
   41ee9:	90                   	nop
    }

    return ch;
   41eea:	8b 45 fc             	mov    -0x4(%rbp),%eax
}
   41eed:	c9                   	leave
   41eee:	c3                   	ret

0000000000041eef <delay>:
#define IO_PARALLEL1_CONTROL    0x37A
# define IO_PARALLEL_CONTROL_SELECT     0x08
# define IO_PARALLEL_CONTROL_INIT       0x04
# define IO_PARALLEL_CONTROL_STROBE     0x01

static void delay(void) {
   41eef:	55                   	push   %rbp
   41ef0:	48 89 e5             	mov    %rsp,%rbp
   41ef3:	48 83 ec 20          	sub    $0x20,%rsp
   41ef7:	c7 45 e4 84 00 00 00 	movl   $0x84,-0x1c(%rbp)
    asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
   41efe:	8b 45 e4             	mov    -0x1c(%rbp),%eax
   41f01:	89 c2                	mov    %eax,%edx
   41f03:	ec                   	in     (%dx),%al
   41f04:	88 45 e3             	mov    %al,-0x1d(%rbp)
   41f07:	c7 45 ec 84 00 00 00 	movl   $0x84,-0x14(%rbp)
   41f0e:	8b 45 ec             	mov    -0x14(%rbp),%eax
   41f11:	89 c2                	mov    %eax,%edx
   41f13:	ec                   	in     (%dx),%al
   41f14:	88 45 eb             	mov    %al,-0x15(%rbp)
   41f17:	c7 45 f4 84 00 00 00 	movl   $0x84,-0xc(%rbp)
   41f1e:	8b 45 f4             	mov    -0xc(%rbp),%eax
   41f21:	89 c2                	mov    %eax,%edx
   41f23:	ec                   	in     (%dx),%al
   41f24:	88 45 f3             	mov    %al,-0xd(%rbp)
   41f27:	c7 45 fc 84 00 00 00 	movl   $0x84,-0x4(%rbp)
   41f2e:	8b 45 fc             	mov    -0x4(%rbp),%eax
   41f31:	89 c2                	mov    %eax,%edx
   41f33:	ec                   	in     (%dx),%al
   41f34:	88 45 fb             	mov    %al,-0x5(%rbp)
    (void) inb(0x84);
    (void) inb(0x84);
    (void) inb(0x84);
    (void) inb(0x84);
}
   41f37:	90                   	nop
   41f38:	c9                   	leave
   41f39:	c3                   	ret

0000000000041f3a <parallel_port_putc>:

static void parallel_port_putc(printer* p, unsigned char c, int color) {
   41f3a:	55                   	push   %rbp
   41f3b:	48 89 e5             	mov    %rsp,%rbp
   41f3e:	48 83 ec 40          	sub    $0x40,%rsp
   41f42:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
   41f46:	40 88 75 c7          	mov    %sil,-0x39(%rbp)
   41f4a:	89 55 c0             	mov    %edx,-0x40(%rbp)
    static int initialized;
    (void) p, (void) color;
    if (!initialized) {
   41f4d:	8b 05 91 d4 00 00    	mov    0xd491(%rip),%eax        # 4f3e4 <initialized.0>
   41f53:	85 c0                	test   %eax,%eax
   41f55:	75 1e                	jne    41f75 <parallel_port_putc+0x3b>
   41f57:	c7 45 f8 7a 03 00 00 	movl   $0x37a,-0x8(%rbp)
   41f5e:	c6 45 f7 00          	movb   $0x0,-0x9(%rbp)
    asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
   41f62:	0f b6 45 f7          	movzbl -0x9(%rbp),%eax
   41f66:	8b 55 f8             	mov    -0x8(%rbp),%edx
   41f69:	ee                   	out    %al,(%dx)
}
   41f6a:	90                   	nop
        outb(IO_PARALLEL1_CONTROL, 0);
        initialized = 1;
   41f6b:	c7 05 6f d4 00 00 01 	movl   $0x1,0xd46f(%rip)        # 4f3e4 <initialized.0>
   41f72:	00 00 00 
    }

    for (int i = 0;
   41f75:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
   41f7c:	eb 09                	jmp    41f87 <parallel_port_putc+0x4d>
         i < 12800 && (inb(IO_PARALLEL1_STATUS) & IO_PARALLEL_STATUS_BUSY) == 0;
         ++i) {
        delay();
   41f7e:	e8 6c ff ff ff       	call   41eef <delay>
         ++i) {
   41f83:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
         i < 12800 && (inb(IO_PARALLEL1_STATUS) & IO_PARALLEL_STATUS_BUSY) == 0;
   41f87:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%rbp)
   41f8e:	7f 18                	jg     41fa8 <parallel_port_putc+0x6e>
   41f90:	c7 45 f0 79 03 00 00 	movl   $0x379,-0x10(%rbp)
    asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
   41f97:	8b 45 f0             	mov    -0x10(%rbp),%eax
   41f9a:	89 c2                	mov    %eax,%edx
   41f9c:	ec                   	in     (%dx),%al
   41f9d:	88 45 ef             	mov    %al,-0x11(%rbp)
    return data;
   41fa0:	0f b6 45 ef          	movzbl -0x11(%rbp),%eax
   41fa4:	84 c0                	test   %al,%al
   41fa6:	79 d6                	jns    41f7e <parallel_port_putc+0x44>
   41fa8:	c7 45 d8 78 03 00 00 	movl   $0x378,-0x28(%rbp)
   41faf:	0f b6 45 c7          	movzbl -0x39(%rbp),%eax
   41fb3:	88 45 d7             	mov    %al,-0x29(%rbp)
    asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
   41fb6:	0f b6 45 d7          	movzbl -0x29(%rbp),%eax
   41fba:	8b 55 d8             	mov    -0x28(%rbp),%edx
   41fbd:	ee                   	out    %al,(%dx)
}
   41fbe:	90                   	nop
   41fbf:	c7 45 e0 7a 03 00 00 	movl   $0x37a,-0x20(%rbp)
   41fc6:	c6 45 df 0d          	movb   $0xd,-0x21(%rbp)
    asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
   41fca:	0f b6 45 df          	movzbl -0x21(%rbp),%eax
   41fce:	8b 55 e0             	mov    -0x20(%rbp),%edx
   41fd1:	ee                   	out    %al,(%dx)
}
   41fd2:	90                   	nop
   41fd3:	c7 45 e8 7a 03 00 00 	movl   $0x37a,-0x18(%rbp)
   41fda:	c6 45 e7 0c          	movb   $0xc,-0x19(%rbp)
    asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
   41fde:	0f b6 45 e7          	movzbl -0x19(%rbp),%eax
   41fe2:	8b 55 e8             	mov    -0x18(%rbp),%edx
   41fe5:	ee                   	out    %al,(%dx)
}
   41fe6:	90                   	nop
    outb(IO_PARALLEL1_DATA, c);
    outb(IO_PARALLEL1_CONTROL, IO_PARALLEL_CONTROL_SELECT
         | IO_PARALLEL_CONTROL_INIT | IO_PARALLEL_CONTROL_STROBE);
    outb(IO_PARALLEL1_CONTROL, IO_PARALLEL_CONTROL_SELECT
         | IO_PARALLEL_CONTROL_INIT);
}
   41fe7:	90                   	nop
   41fe8:	c9                   	leave
   41fe9:	c3                   	ret

0000000000041fea <log_vprintf>:

void log_vprintf(const char* format, va_list val) {
   41fea:	55                   	push   %rbp
   41feb:	48 89 e5             	mov    %rsp,%rbp
   41fee:	48 83 ec 20          	sub    $0x20,%rsp
   41ff2:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
   41ff6:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
    printer p;
    p.putc = parallel_port_putc;
   41ffa:	48 c7 45 f8 3a 1f 04 	movq   $0x41f3a,-0x8(%rbp)
   42001:	00 
    printer_vprintf(&p, 0, format, val);
   42002:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
   42006:	48 8b 55 e8          	mov    -0x18(%rbp),%rdx
   4200a:	48 8d 45 f8          	lea    -0x8(%rbp),%rax
   4200e:	be 00 00 00 00       	mov    $0x0,%esi
   42013:	48 89 c7             	mov    %rax,%rdi
   42016:	e8 82 1c 00 00       	call   43c9d <printer_vprintf>
}
   4201b:	90                   	nop
   4201c:	c9                   	leave
   4201d:	c3                   	ret

000000000004201e <log_printf>:

void log_printf(const char* format, ...) {
   4201e:	55                   	push   %rbp
   4201f:	48 89 e5             	mov    %rsp,%rbp
   42022:	48 83 ec 60          	sub    $0x60,%rsp
   42026:	48 89 7d a8          	mov    %rdi,-0x58(%rbp)
   4202a:	48 89 75 d8          	mov    %rsi,-0x28(%rbp)
   4202e:	48 89 55 e0          	mov    %rdx,-0x20(%rbp)
   42032:	48 89 4d e8          	mov    %rcx,-0x18(%rbp)
   42036:	4c 89 45 f0          	mov    %r8,-0x10(%rbp)
   4203a:	4c 89 4d f8          	mov    %r9,-0x8(%rbp)
    va_list val;
    va_start(val, format);
   4203e:	c7 45 b8 08 00 00 00 	movl   $0x8,-0x48(%rbp)
   42045:	48 8d 45 10          	lea    0x10(%rbp),%rax
   42049:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
   4204d:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
   42051:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    log_vprintf(format, val);
   42055:	48 8d 55 b8          	lea    -0x48(%rbp),%rdx
   42059:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
   4205d:	48 89 d6             	mov    %rdx,%rsi
   42060:	48 89 c7             	mov    %rax,%rdi
   42063:	e8 82 ff ff ff       	call   41fea <log_vprintf>
    va_end(val);
}
   42068:	90                   	nop
   42069:	c9                   	leave
   4206a:	c3                   	ret

000000000004206b <error_vprintf>:

// error_printf, error_vprintf
//    Print debugging messages to the console and to the host's
//    `log.txt` file via `log_printf`.

int error_vprintf(int cpos, int color, const char* format, va_list val) {
   4206b:	55                   	push   %rbp
   4206c:	48 89 e5             	mov    %rsp,%rbp
   4206f:	48 83 ec 40          	sub    $0x40,%rsp
   42073:	89 7d dc             	mov    %edi,-0x24(%rbp)
   42076:	89 75 d8             	mov    %esi,-0x28(%rbp)
   42079:	48 89 55 d0          	mov    %rdx,-0x30(%rbp)
   4207d:	48 89 4d c8          	mov    %rcx,-0x38(%rbp)
    va_list val2;
    __builtin_va_copy(val2, val);
   42081:	48 8d 45 e8          	lea    -0x18(%rbp),%rax
   42085:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
   42089:	48 8b 0a             	mov    (%rdx),%rcx
   4208c:	48 89 08             	mov    %rcx,(%rax)
   4208f:	48 8b 4a 08          	mov    0x8(%rdx),%rcx
   42093:	48 89 48 08          	mov    %rcx,0x8(%rax)
   42097:	48 8b 52 10          	mov    0x10(%rdx),%rdx
   4209b:	48 89 50 10          	mov    %rdx,0x10(%rax)
    log_vprintf(format, val2);
   4209f:	48 8d 55 e8          	lea    -0x18(%rbp),%rdx
   420a3:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
   420a7:	48 89 d6             	mov    %rdx,%rsi
   420aa:	48 89 c7             	mov    %rax,%rdi
   420ad:	e8 38 ff ff ff       	call   41fea <log_vprintf>
    va_end(val2);
    return console_vprintf(cpos, color, format, val);
   420b2:	48 8b 4d c8          	mov    -0x38(%rbp),%rcx
   420b6:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
   420ba:	8b 75 d8             	mov    -0x28(%rbp),%esi
   420bd:	8b 45 dc             	mov    -0x24(%rbp),%eax
   420c0:	89 c7                	mov    %eax,%edi
   420c2:	e8 2c 27 00 00       	call   447f3 <console_vprintf>
}
   420c7:	c9                   	leave
   420c8:	c3                   	ret

00000000000420c9 <error_printf>:

int error_printf(int cpos, int color, const char* format, ...) {
   420c9:	55                   	push   %rbp
   420ca:	48 89 e5             	mov    %rsp,%rbp
   420cd:	48 83 ec 60          	sub    $0x60,%rsp
   420d1:	89 7d ac             	mov    %edi,-0x54(%rbp)
   420d4:	89 75 a8             	mov    %esi,-0x58(%rbp)
   420d7:	48 89 55 a0          	mov    %rdx,-0x60(%rbp)
   420db:	48 89 4d e8          	mov    %rcx,-0x18(%rbp)
   420df:	4c 89 45 f0          	mov    %r8,-0x10(%rbp)
   420e3:	4c 89 4d f8          	mov    %r9,-0x8(%rbp)
    va_list val;
    va_start(val, format);
   420e7:	c7 45 b8 18 00 00 00 	movl   $0x18,-0x48(%rbp)
   420ee:	48 8d 45 10          	lea    0x10(%rbp),%rax
   420f2:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
   420f6:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
   420fa:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    cpos = error_vprintf(cpos, color, format, val);
   420fe:	48 8d 4d b8          	lea    -0x48(%rbp),%rcx
   42102:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
   42106:	8b 75 a8             	mov    -0x58(%rbp),%esi
   42109:	8b 45 ac             	mov    -0x54(%rbp),%eax
   4210c:	89 c7                	mov    %eax,%edi
   4210e:	e8 58 ff ff ff       	call   4206b <error_vprintf>
   42113:	89 45 ac             	mov    %eax,-0x54(%rbp)
    va_end(val);
    return cpos;
   42116:	8b 45 ac             	mov    -0x54(%rbp),%eax
}
   42119:	c9                   	leave
   4211a:	c3                   	ret

000000000004211b <check_keyboard>:
//    Check for the user typing a control key. 'a', 'm', and 'c' cause a soft
//    reboot where the kernel runs the allocator programs, "malloc", or
//    "alloctests", respectively. Control-C or 'q' exit the virtual machine.
//    Returns key typed or -1 for no key.

int check_keyboard(void) {
   4211b:	55                   	push   %rbp
   4211c:	48 89 e5             	mov    %rsp,%rbp
   4211f:	53                   	push   %rbx
   42120:	48 83 ec 48          	sub    $0x48,%rsp
    int c = keyboard_readc();
   42124:	e8 a2 fb ff ff       	call   41ccb <keyboard_readc>
   42129:	89 45 e4             	mov    %eax,-0x1c(%rbp)
    if (c == 'a' || c == 'm' || c == 'c' || c == 't'|| c =='2') {
   4212c:	83 7d e4 61          	cmpl   $0x61,-0x1c(%rbp)
   42130:	74 1c                	je     4214e <check_keyboard+0x33>
   42132:	83 7d e4 6d          	cmpl   $0x6d,-0x1c(%rbp)
   42136:	74 16                	je     4214e <check_keyboard+0x33>
   42138:	83 7d e4 63          	cmpl   $0x63,-0x1c(%rbp)
   4213c:	74 10                	je     4214e <check_keyboard+0x33>
   4213e:	83 7d e4 74          	cmpl   $0x74,-0x1c(%rbp)
   42142:	74 0a                	je     4214e <check_keyboard+0x33>
   42144:	83 7d e4 32          	cmpl   $0x32,-0x1c(%rbp)
   42148:	0f 85 e9 00 00 00    	jne    42237 <check_keyboard+0x11c>
        // Install a temporary page table to carry us through the
        // process of reinitializing memory. This replicates work the
        // bootloader does.
        x86_64_pagetable* pt = (x86_64_pagetable*) 0x8000;
   4214e:	48 c7 45 d8 00 80 00 	movq   $0x8000,-0x28(%rbp)
   42155:	00 
        memset(pt, 0, PAGESIZE * 3);
   42156:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
   4215a:	ba 00 30 00 00       	mov    $0x3000,%edx
   4215f:	be 00 00 00 00       	mov    $0x0,%esi
   42164:	48 89 c7             	mov    %rax,%rdi
   42167:	e8 95 18 00 00       	call   43a01 <memset>
        pt[0].entry[0] = 0x9000 | PTE_P | PTE_W | PTE_U;
   4216c:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
   42170:	48 c7 00 07 90 00 00 	movq   $0x9007,(%rax)
        pt[1].entry[0] = 0xA000 | PTE_P | PTE_W | PTE_U;
   42177:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
   4217b:	48 05 00 10 00 00    	add    $0x1000,%rax
   42181:	48 c7 00 07 a0 00 00 	movq   $0xa007,(%rax)
        pt[2].entry[0] = PTE_P | PTE_W | PTE_U | PTE_PS;
   42188:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
   4218c:	48 05 00 20 00 00    	add    $0x2000,%rax
   42192:	48 c7 00 87 00 00 00 	movq   $0x87,(%rax)
        lcr3((uintptr_t) pt);
   42199:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
   4219d:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
}

static inline void lcr3(uintptr_t val) {
    asm volatile("" : : : "memory");
    asm volatile("movq %0,%%cr3" : : "r" (val) : "memory");
   421a1:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
   421a5:	0f 22 d8             	mov    %rax,%cr3
}
   421a8:	90                   	nop
        // The soft reboot process doesn't modify memory, so it's
        // safe to pass `multiboot_info` on the kernel stack, even
        // though it will get overwritten as the kernel runs.
        uint32_t multiboot_info[5];
        multiboot_info[0] = 4;
   421a9:	c7 45 b4 04 00 00 00 	movl   $0x4,-0x4c(%rbp)
        const char* argument = "malloc";
   421b0:	48 c7 45 e8 78 4e 04 	movq   $0x44e78,-0x18(%rbp)
   421b7:	00 
        if (c == 'a') {
   421b8:	83 7d e4 61          	cmpl   $0x61,-0x1c(%rbp)
   421bc:	75 0a                	jne    421c8 <check_keyboard+0xad>
            argument = "allocator";
   421be:	48 c7 45 e8 7f 4e 04 	movq   $0x44e7f,-0x18(%rbp)
   421c5:	00 
   421c6:	eb 2e                	jmp    421f6 <check_keyboard+0xdb>
        } else if (c == 'c') {
   421c8:	83 7d e4 63          	cmpl   $0x63,-0x1c(%rbp)
   421cc:	75 0a                	jne    421d8 <check_keyboard+0xbd>
            argument = "alloctests";
   421ce:	48 c7 45 e8 89 4e 04 	movq   $0x44e89,-0x18(%rbp)
   421d5:	00 
   421d6:	eb 1e                	jmp    421f6 <check_keyboard+0xdb>
        } else if(c == 't'){
   421d8:	83 7d e4 74          	cmpl   $0x74,-0x1c(%rbp)
   421dc:	75 0a                	jne    421e8 <check_keyboard+0xcd>
            argument = "test";
   421de:	48 c7 45 e8 94 4e 04 	movq   $0x44e94,-0x18(%rbp)
   421e5:	00 
   421e6:	eb 0e                	jmp    421f6 <check_keyboard+0xdb>
        }
        else if(c == '2'){
   421e8:	83 7d e4 32          	cmpl   $0x32,-0x1c(%rbp)
   421ec:	75 08                	jne    421f6 <check_keyboard+0xdb>
            argument = "test2";
   421ee:	48 c7 45 e8 99 4e 04 	movq   $0x44e99,-0x18(%rbp)
   421f5:	00 
        }
        uintptr_t argument_ptr = (uintptr_t) argument;
   421f6:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   421fa:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
        assert(argument_ptr < 0x100000000L);
   421fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
   42203:	48 3b 45 d0          	cmp    -0x30(%rbp),%rax
   42207:	73 14                	jae    4221d <check_keyboard+0x102>
   42209:	ba 9f 4e 04 00       	mov    $0x44e9f,%edx
   4220e:	be 5c 02 00 00       	mov    $0x25c,%esi
   42213:	bf bb 4e 04 00       	mov    $0x44ebb,%edi
   42218:	e8 1f 01 00 00       	call   4233c <assert_fail>
        multiboot_info[4] = (uint32_t) argument_ptr;
   4221d:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
   42221:	89 45 c4             	mov    %eax,-0x3c(%rbp)
        asm volatile("movl $0x2BADB002, %%eax; jmp entry_from_boot"
   42224:	48 8d 45 b4          	lea    -0x4c(%rbp),%rax
   42228:	48 89 c3             	mov    %rax,%rbx
   4222b:	b8 02 b0 ad 2b       	mov    $0x2badb002,%eax
   42230:	e9 cb dd ff ff       	jmp    40000 <entry_from_boot>
    if (c == 'a' || c == 'm' || c == 'c' || c == 't'|| c =='2') {
   42235:	eb 11                	jmp    42248 <check_keyboard+0x12d>
                     : : "b" (multiboot_info) : "memory");
    } else if (c == 0x03 || c == 'q') {
   42237:	83 7d e4 03          	cmpl   $0x3,-0x1c(%rbp)
   4223b:	74 06                	je     42243 <check_keyboard+0x128>
   4223d:	83 7d e4 71          	cmpl   $0x71,-0x1c(%rbp)
   42241:	75 05                	jne    42248 <check_keyboard+0x12d>
        poweroff();
   42243:	e8 99 f8 ff ff       	call   41ae1 <poweroff>
    }
    return c;
   42248:	8b 45 e4             	mov    -0x1c(%rbp),%eax
}
   4224b:	48 8b 5d f8          	mov    -0x8(%rbp),%rbx
   4224f:	c9                   	leave
   42250:	c3                   	ret

0000000000042251 <fail>:

// fail
//    Loop until user presses Control-C, then poweroff.

static void fail(void) __attribute__((noreturn));
static void fail(void) {
   42251:	55                   	push   %rbp
   42252:	48 89 e5             	mov    %rsp,%rbp
    while (1) {
        check_keyboard();
   42255:	e8 c1 fe ff ff       	call   4211b <check_keyboard>
   4225a:	eb f9                	jmp    42255 <fail+0x4>

000000000004225c <kernel_panic>:

// kernel_panic, assert_fail
//    Use console_printf() to print a failure message and then wait for
//    control-C. Also write the failure message to the log.

void kernel_panic(const char* format, ...) {
   4225c:	55                   	push   %rbp
   4225d:	48 89 e5             	mov    %rsp,%rbp
   42260:	48 83 ec 60          	sub    $0x60,%rsp
   42264:	48 89 7d a8          	mov    %rdi,-0x58(%rbp)
   42268:	48 89 75 d8          	mov    %rsi,-0x28(%rbp)
   4226c:	48 89 55 e0          	mov    %rdx,-0x20(%rbp)
   42270:	48 89 4d e8          	mov    %rcx,-0x18(%rbp)
   42274:	4c 89 45 f0          	mov    %r8,-0x10(%rbp)
   42278:	4c 89 4d f8          	mov    %r9,-0x8(%rbp)
    va_list val;
    va_start(val, format);
   4227c:	c7 45 b0 08 00 00 00 	movl   $0x8,-0x50(%rbp)
   42283:	48 8d 45 10          	lea    0x10(%rbp),%rax
   42287:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
   4228b:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
   4228f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)

    if (format) {
   42293:	48 83 7d a8 00       	cmpq   $0x0,-0x58(%rbp)
   42298:	0f 84 80 00 00 00    	je     4231e <kernel_panic+0xc2>
        // Print kernel_panic message to both the screen and the log
        int cpos = error_printf(CPOS(23, 0), 0xC000, "PANIC: ");
   4229e:	ba cf 4e 04 00       	mov    $0x44ecf,%edx
   422a3:	be 00 c0 00 00       	mov    $0xc000,%esi
   422a8:	bf 30 07 00 00       	mov    $0x730,%edi
   422ad:	b8 00 00 00 00       	mov    $0x0,%eax
   422b2:	e8 12 fe ff ff       	call   420c9 <error_printf>
   422b7:	89 45 cc             	mov    %eax,-0x34(%rbp)
        cpos = error_vprintf(cpos, 0xC000, format, val);
   422ba:	48 8d 4d b0          	lea    -0x50(%rbp),%rcx
   422be:	48 8b 55 a8          	mov    -0x58(%rbp),%rdx
   422c2:	8b 45 cc             	mov    -0x34(%rbp),%eax
   422c5:	be 00 c0 00 00       	mov    $0xc000,%esi
   422ca:	89 c7                	mov    %eax,%edi
   422cc:	e8 9a fd ff ff       	call   4206b <error_vprintf>
   422d1:	89 45 cc             	mov    %eax,-0x34(%rbp)
        if (CCOL(cpos)) {
   422d4:	8b 4d cc             	mov    -0x34(%rbp),%ecx
   422d7:	48 63 c1             	movslq %ecx,%rax
   422da:	48 69 c0 67 66 66 66 	imul   $0x66666667,%rax,%rax
   422e1:	48 c1 e8 20          	shr    $0x20,%rax
   422e5:	89 c2                	mov    %eax,%edx
   422e7:	c1 fa 05             	sar    $0x5,%edx
   422ea:	89 c8                	mov    %ecx,%eax
   422ec:	c1 f8 1f             	sar    $0x1f,%eax
   422ef:	29 c2                	sub    %eax,%edx
   422f1:	89 d0                	mov    %edx,%eax
   422f3:	c1 e0 02             	shl    $0x2,%eax
   422f6:	01 d0                	add    %edx,%eax
   422f8:	c1 e0 04             	shl    $0x4,%eax
   422fb:	29 c1                	sub    %eax,%ecx
   422fd:	89 ca                	mov    %ecx,%edx
   422ff:	85 d2                	test   %edx,%edx
   42301:	74 34                	je     42337 <kernel_panic+0xdb>
            error_printf(cpos, 0xC000, "\n");
   42303:	8b 45 cc             	mov    -0x34(%rbp),%eax
   42306:	ba d7 4e 04 00       	mov    $0x44ed7,%edx
   4230b:	be 00 c0 00 00       	mov    $0xc000,%esi
   42310:	89 c7                	mov    %eax,%edi
   42312:	b8 00 00 00 00       	mov    $0x0,%eax
   42317:	e8 ad fd ff ff       	call   420c9 <error_printf>
   4231c:	eb 19                	jmp    42337 <kernel_panic+0xdb>
        }
    } else {
        error_printf(CPOS(23, 0), 0xC000, "PANIC");
   4231e:	ba d9 4e 04 00       	mov    $0x44ed9,%edx
   42323:	be 00 c0 00 00       	mov    $0xc000,%esi
   42328:	bf 30 07 00 00       	mov    $0x730,%edi
   4232d:	b8 00 00 00 00       	mov    $0x0,%eax
   42332:	e8 92 fd ff ff       	call   420c9 <error_printf>
    }

    va_end(val);
    fail();
   42337:	e8 15 ff ff ff       	call   42251 <fail>

000000000004233c <assert_fail>:
}

void assert_fail(const char* file, int line, const char* msg) {
   4233c:	55                   	push   %rbp
   4233d:	48 89 e5             	mov    %rsp,%rbp
   42340:	48 83 ec 20          	sub    $0x20,%rsp
   42344:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
   42348:	89 75 f4             	mov    %esi,-0xc(%rbp)
   4234b:	48 89 55 e8          	mov    %rdx,-0x18(%rbp)
    kernel_panic("%s:%d: assertion '%s' failed\n", file, line, msg);
   4234f:	48 8b 4d e8          	mov    -0x18(%rbp),%rcx
   42353:	8b 55 f4             	mov    -0xc(%rbp),%edx
   42356:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   4235a:	48 89 c6             	mov    %rax,%rsi
   4235d:	bf df 4e 04 00       	mov    $0x44edf,%edi
   42362:	b8 00 00 00 00       	mov    $0x0,%eax
   42367:	e8 f0 fe ff ff       	call   4225c <kernel_panic>

000000000004236c <default_exception>:
}

void default_exception(proc* p){
   4236c:	55                   	push   %rbp
   4236d:	48 89 e5             	mov    %rsp,%rbp
   42370:	48 83 ec 20          	sub    $0x20,%rsp
   42374:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
    x86_64_registers * reg = &(p->p_registers);
   42378:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   4237c:	48 83 c0 18          	add    $0x18,%rax
   42380:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    kernel_panic("Unexpected exception %d!\n", reg->reg_intno);
   42384:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   42388:	48 8b 80 88 00 00 00 	mov    0x88(%rax),%rax
   4238f:	48 89 c6             	mov    %rax,%rsi
   42392:	bf fd 4e 04 00       	mov    $0x44efd,%edi
   42397:	b8 00 00 00 00       	mov    $0x0,%eax
   4239c:	e8 bb fe ff ff       	call   4225c <kernel_panic>

00000000000423a1 <pageindex>:
static inline int pageindex(uintptr_t addr, int level) {
   423a1:	55                   	push   %rbp
   423a2:	48 89 e5             	mov    %rsp,%rbp
   423a5:	48 83 ec 10          	sub    $0x10,%rsp
   423a9:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
   423ad:	89 75 f4             	mov    %esi,-0xc(%rbp)
    assert(level >= 0 && level <= 3);
   423b0:	83 7d f4 00          	cmpl   $0x0,-0xc(%rbp)
   423b4:	78 06                	js     423bc <pageindex+0x1b>
   423b6:	83 7d f4 03          	cmpl   $0x3,-0xc(%rbp)
   423ba:	7e 14                	jle    423d0 <pageindex+0x2f>
   423bc:	ba 18 4f 04 00       	mov    $0x44f18,%edx
   423c1:	be 1e 00 00 00       	mov    $0x1e,%esi
   423c6:	bf 31 4f 04 00       	mov    $0x44f31,%edi
   423cb:	e8 6c ff ff ff       	call   4233c <assert_fail>
    return (int) (addr >> (PAGEOFFBITS + (3 - level) * PAGEINDEXBITS)) & 0x1FF;
   423d0:	b8 03 00 00 00       	mov    $0x3,%eax
   423d5:	2b 45 f4             	sub    -0xc(%rbp),%eax
   423d8:	89 c2                	mov    %eax,%edx
   423da:	89 d0                	mov    %edx,%eax
   423dc:	c1 e0 03             	shl    $0x3,%eax
   423df:	01 d0                	add    %edx,%eax
   423e1:	83 c0 0c             	add    $0xc,%eax
   423e4:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
   423e8:	89 c1                	mov    %eax,%ecx
   423ea:	48 d3 ea             	shr    %cl,%rdx
   423ed:	48 89 d0             	mov    %rdx,%rax
   423f0:	25 ff 01 00 00       	and    $0x1ff,%eax
}
   423f5:	c9                   	leave
   423f6:	c3                   	ret

00000000000423f7 <virtual_memory_init>:

static x86_64_pagetable kernel_pagetables[5];
x86_64_pagetable* kernel_pagetable;


void virtual_memory_init(void) {
   423f7:	55                   	push   %rbp
   423f8:	48 89 e5             	mov    %rsp,%rbp
   423fb:	48 83 ec 20          	sub    $0x20,%rsp
    kernel_pagetable = &kernel_pagetables[0];
   423ff:	48 c7 05 f6 db 00 00 	movq   $0x51000,0xdbf6(%rip)        # 50000 <kernel_pagetable>
   42406:	00 10 05 00 
    memset(kernel_pagetables, 0, sizeof(kernel_pagetables));
   4240a:	ba 00 50 00 00       	mov    $0x5000,%edx
   4240f:	be 00 00 00 00       	mov    $0x0,%esi
   42414:	bf 00 10 05 00       	mov    $0x51000,%edi
   42419:	e8 e3 15 00 00       	call   43a01 <memset>

    // connect the pagetable pages
    kernel_pagetables[0].entry[0] =
        (x86_64_pageentry_t) &kernel_pagetables[1] | PTE_P | PTE_W | PTE_U;
   4241e:	b8 00 20 05 00       	mov    $0x52000,%eax
   42423:	48 83 c8 07          	or     $0x7,%rax
    kernel_pagetables[0].entry[0] =
   42427:	48 89 05 d2 eb 00 00 	mov    %rax,0xebd2(%rip)        # 51000 <kernel_pagetables>
    kernel_pagetables[1].entry[0] =
        (x86_64_pageentry_t) &kernel_pagetables[2] | PTE_P | PTE_W | PTE_U;
   4242e:	b8 00 30 05 00       	mov    $0x53000,%eax
   42433:	48 83 c8 07          	or     $0x7,%rax
    kernel_pagetables[1].entry[0] =
   42437:	48 89 05 c2 fb 00 00 	mov    %rax,0xfbc2(%rip)        # 52000 <kernel_pagetables+0x1000>
    kernel_pagetables[2].entry[0] =
        (x86_64_pageentry_t) &kernel_pagetables[3] | PTE_P | PTE_W | PTE_U;
   4243e:	b8 00 40 05 00       	mov    $0x54000,%eax
   42443:	48 83 c8 07          	or     $0x7,%rax
    kernel_pagetables[2].entry[0] =
   42447:	48 89 05 b2 0b 01 00 	mov    %rax,0x10bb2(%rip)        # 53000 <kernel_pagetables+0x2000>
    kernel_pagetables[2].entry[1] =
        (x86_64_pageentry_t) &kernel_pagetables[4] | PTE_P | PTE_W | PTE_U;
   4244e:	b8 00 50 05 00       	mov    $0x55000,%eax
   42453:	48 83 c8 07          	or     $0x7,%rax
    kernel_pagetables[2].entry[1] =
   42457:	48 89 05 aa 0b 01 00 	mov    %rax,0x10baa(%rip)        # 53008 <kernel_pagetables+0x2008>

    // identity map the page table
    virtual_memory_map(kernel_pagetable, (uintptr_t) 0, (uintptr_t) 0,
   4245e:	48 8b 05 9b db 00 00 	mov    0xdb9b(%rip),%rax        # 50000 <kernel_pagetable>
   42465:	41 b8 07 00 00 00    	mov    $0x7,%r8d
   4246b:	b9 00 00 20 00       	mov    $0x200000,%ecx
   42470:	ba 00 00 00 00       	mov    $0x0,%edx
   42475:	be 00 00 00 00       	mov    $0x0,%esi
   4247a:	48 89 c7             	mov    %rax,%rdi
   4247d:	e8 b9 01 00 00       	call   4263b <virtual_memory_map>
                       MEMSIZE_PHYSICAL, PTE_P | PTE_W | PTE_U);

    // check if kernel is identity mapped
    for(uintptr_t addr = 0 ; addr < MEMSIZE_PHYSICAL ; addr += PAGESIZE){
   42482:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
   42489:	00 
   4248a:	eb 62                	jmp    424ee <virtual_memory_init+0xf7>
        vamapping vmap = virtual_memory_lookup(kernel_pagetable, addr);
   4248c:	48 8b 0d 6d db 00 00 	mov    0xdb6d(%rip),%rcx        # 50000 <kernel_pagetable>
   42493:	48 8d 45 e0          	lea    -0x20(%rbp),%rax
   42497:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
   4249b:	48 89 ce             	mov    %rcx,%rsi
   4249e:	48 89 c7             	mov    %rax,%rdi
   424a1:	e8 58 05 00 00       	call   429fe <virtual_memory_lookup>
        // this assert will probably fail initially!
        // have you implemented virtual_memory_map and lookup_l4pagetable ?
        assert(vmap.pa == addr);
   424a6:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   424aa:	48 39 45 f8          	cmp    %rax,-0x8(%rbp)
   424ae:	74 14                	je     424c4 <virtual_memory_init+0xcd>
   424b0:	ba 45 4f 04 00       	mov    $0x44f45,%edx
   424b5:	be 2d 00 00 00       	mov    $0x2d,%esi
   424ba:	bf 55 4f 04 00       	mov    $0x44f55,%edi
   424bf:	e8 78 fe ff ff       	call   4233c <assert_fail>
        assert((vmap.perm & (PTE_P|PTE_W)) == (PTE_P|PTE_W));
   424c4:	8b 45 f0             	mov    -0x10(%rbp),%eax
   424c7:	48 98                	cltq
   424c9:	83 e0 03             	and    $0x3,%eax
   424cc:	48 83 f8 03          	cmp    $0x3,%rax
   424d0:	74 14                	je     424e6 <virtual_memory_init+0xef>
   424d2:	ba 68 4f 04 00       	mov    $0x44f68,%edx
   424d7:	be 2e 00 00 00       	mov    $0x2e,%esi
   424dc:	bf 55 4f 04 00       	mov    $0x44f55,%edi
   424e1:	e8 56 fe ff ff       	call   4233c <assert_fail>
    for(uintptr_t addr = 0 ; addr < MEMSIZE_PHYSICAL ; addr += PAGESIZE){
   424e6:	48 81 45 f8 00 10 00 	addq   $0x1000,-0x8(%rbp)
   424ed:	00 
   424ee:	48 81 7d f8 ff ff 1f 	cmpq   $0x1fffff,-0x8(%rbp)
   424f5:	00 
   424f6:	76 94                	jbe    4248c <virtual_memory_init+0x95>
    }

    // set pointer to this pagetable in the CR3 register
    // set_pagetable also does several checks for a valid pagetable
    set_pagetable(kernel_pagetable);
   424f8:	48 8b 05 01 db 00 00 	mov    0xdb01(%rip),%rax        # 50000 <kernel_pagetable>
   424ff:	48 89 c7             	mov    %rax,%rdi
   42502:	e8 03 00 00 00       	call   4250a <set_pagetable>
}
   42507:	90                   	nop
   42508:	c9                   	leave
   42509:	c3                   	ret

000000000004250a <set_pagetable>:
// set_pagetable
//    Change page directory. lcr3() is the hardware instruction;
//    set_pagetable() additionally checks that important kernel procedures are
//    mappable in `pagetable`, and calls kernel_panic() if they aren't.

void set_pagetable(x86_64_pagetable* pagetable) {
   4250a:	55                   	push   %rbp
   4250b:	48 89 e5             	mov    %rsp,%rbp
   4250e:	48 83 c4 80          	add    $0xffffffffffffff80,%rsp
   42512:	48 89 7d 88          	mov    %rdi,-0x78(%rbp)
    assert(PAGEOFFSET(pagetable) == 0); // must be page aligned
   42516:	48 8b 45 88          	mov    -0x78(%rbp),%rax
   4251a:	25 ff 0f 00 00       	and    $0xfff,%eax
   4251f:	48 85 c0             	test   %rax,%rax
   42522:	74 14                	je     42538 <set_pagetable+0x2e>
   42524:	ba 95 4f 04 00       	mov    $0x44f95,%edx
   42529:	be 3d 00 00 00       	mov    $0x3d,%esi
   4252e:	bf 55 4f 04 00       	mov    $0x44f55,%edi
   42533:	e8 04 fe ff ff       	call   4233c <assert_fail>
    // check for kernel space being mapped in pagetable
    assert(virtual_memory_lookup(pagetable, (uintptr_t) default_int_handler).pa
   42538:	ba 9c 00 04 00       	mov    $0x4009c,%edx
   4253d:	48 8d 45 98          	lea    -0x68(%rbp),%rax
   42541:	48 8b 4d 88          	mov    -0x78(%rbp),%rcx
   42545:	48 89 ce             	mov    %rcx,%rsi
   42548:	48 89 c7             	mov    %rax,%rdi
   4254b:	e8 ae 04 00 00       	call   429fe <virtual_memory_lookup>
   42550:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
   42554:	ba 9c 00 04 00       	mov    $0x4009c,%edx
   42559:	48 39 d0             	cmp    %rdx,%rax
   4255c:	74 14                	je     42572 <set_pagetable+0x68>
   4255e:	ba b0 4f 04 00       	mov    $0x44fb0,%edx
   42563:	be 3f 00 00 00       	mov    $0x3f,%esi
   42568:	bf 55 4f 04 00       	mov    $0x44f55,%edi
   4256d:	e8 ca fd ff ff       	call   4233c <assert_fail>
           == (uintptr_t) default_int_handler);
    assert(virtual_memory_lookup(kernel_pagetable, (uintptr_t) pagetable).pa
   42572:	48 8b 55 88          	mov    -0x78(%rbp),%rdx
   42576:	48 8b 0d 83 da 00 00 	mov    0xda83(%rip),%rcx        # 50000 <kernel_pagetable>
   4257d:	48 8d 45 b0          	lea    -0x50(%rbp),%rax
   42581:	48 89 ce             	mov    %rcx,%rsi
   42584:	48 89 c7             	mov    %rax,%rdi
   42587:	e8 72 04 00 00       	call   429fe <virtual_memory_lookup>
   4258c:	48 8b 55 b8          	mov    -0x48(%rbp),%rdx
   42590:	48 8b 45 88          	mov    -0x78(%rbp),%rax
   42594:	48 39 c2             	cmp    %rax,%rdx
   42597:	74 14                	je     425ad <set_pagetable+0xa3>
   42599:	ba 18 50 04 00       	mov    $0x45018,%edx
   4259e:	be 41 00 00 00       	mov    $0x41,%esi
   425a3:	bf 55 4f 04 00       	mov    $0x44f55,%edi
   425a8:	e8 8f fd ff ff       	call   4233c <assert_fail>
           == (uintptr_t) pagetable);
    assert(virtual_memory_lookup(pagetable, (uintptr_t) kernel_pagetable).pa
   425ad:	48 8b 05 4c da 00 00 	mov    0xda4c(%rip),%rax        # 50000 <kernel_pagetable>
   425b4:	48 89 c2             	mov    %rax,%rdx
   425b7:	48 8d 45 c8          	lea    -0x38(%rbp),%rax
   425bb:	48 8b 4d 88          	mov    -0x78(%rbp),%rcx
   425bf:	48 89 ce             	mov    %rcx,%rsi
   425c2:	48 89 c7             	mov    %rax,%rdi
   425c5:	e8 34 04 00 00       	call   429fe <virtual_memory_lookup>
   425ca:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
   425ce:	48 8b 15 2b da 00 00 	mov    0xda2b(%rip),%rdx        # 50000 <kernel_pagetable>
   425d5:	48 39 d0             	cmp    %rdx,%rax
   425d8:	74 14                	je     425ee <set_pagetable+0xe4>
   425da:	ba 78 50 04 00       	mov    $0x45078,%edx
   425df:	be 43 00 00 00       	mov    $0x43,%esi
   425e4:	bf 55 4f 04 00       	mov    $0x44f55,%edi
   425e9:	e8 4e fd ff ff       	call   4233c <assert_fail>
           == (uintptr_t) kernel_pagetable);
    assert(virtual_memory_lookup(pagetable, (uintptr_t) virtual_memory_map).pa
   425ee:	ba 3b 26 04 00       	mov    $0x4263b,%edx
   425f3:	48 8d 45 e0          	lea    -0x20(%rbp),%rax
   425f7:	48 8b 4d 88          	mov    -0x78(%rbp),%rcx
   425fb:	48 89 ce             	mov    %rcx,%rsi
   425fe:	48 89 c7             	mov    %rax,%rdi
   42601:	e8 f8 03 00 00       	call   429fe <virtual_memory_lookup>
   42606:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   4260a:	ba 3b 26 04 00       	mov    $0x4263b,%edx
   4260f:	48 39 d0             	cmp    %rdx,%rax
   42612:	74 14                	je     42628 <set_pagetable+0x11e>
   42614:	ba e0 50 04 00       	mov    $0x450e0,%edx
   42619:	be 45 00 00 00       	mov    $0x45,%esi
   4261e:	bf 55 4f 04 00       	mov    $0x44f55,%edi
   42623:	e8 14 fd ff ff       	call   4233c <assert_fail>
           == (uintptr_t) virtual_memory_map);
    lcr3((uintptr_t) pagetable);
   42628:	48 8b 45 88          	mov    -0x78(%rbp),%rax
   4262c:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    asm volatile("movq %0,%%cr3" : : "r" (val) : "memory");
   42630:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   42634:	0f 22 d8             	mov    %rax,%cr3
}
   42637:	90                   	nop
}
   42638:	90                   	nop
   42639:	c9                   	leave
   4263a:	c3                   	ret

000000000004263b <virtual_memory_map>:
//    Returns NULL otherwise
static x86_64_pagetable* lookup_l4pagetable(x86_64_pagetable* pagetable,
                 uintptr_t va, int perm);

int virtual_memory_map(x86_64_pagetable* pagetable, uintptr_t va,
                       uintptr_t pa, size_t sz, int perm) {
   4263b:	55                   	push   %rbp
   4263c:	48 89 e5             	mov    %rsp,%rbp
   4263f:	53                   	push   %rbx
   42640:	48 83 ec 58          	sub    $0x58,%rsp
   42644:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
   42648:	48 89 75 c0          	mov    %rsi,-0x40(%rbp)
   4264c:	48 89 55 b8          	mov    %rdx,-0x48(%rbp)
   42650:	48 89 4d b0          	mov    %rcx,-0x50(%rbp)
   42654:	44 89 45 ac          	mov    %r8d,-0x54(%rbp)

    // sanity checks for virtual address, size, and permisions
    assert(va % PAGESIZE == 0); // virtual address is page-aligned
   42658:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
   4265c:	25 ff 0f 00 00       	and    $0xfff,%eax
   42661:	48 85 c0             	test   %rax,%rax
   42664:	74 14                	je     4267a <virtual_memory_map+0x3f>
   42666:	ba 46 51 04 00       	mov    $0x45146,%edx
   4266b:	be 66 00 00 00       	mov    $0x66,%esi
   42670:	bf 55 4f 04 00       	mov    $0x44f55,%edi
   42675:	e8 c2 fc ff ff       	call   4233c <assert_fail>
    assert(sz % PAGESIZE == 0); // size is a multiple of PAGESIZE
   4267a:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
   4267e:	25 ff 0f 00 00       	and    $0xfff,%eax
   42683:	48 85 c0             	test   %rax,%rax
   42686:	74 14                	je     4269c <virtual_memory_map+0x61>
   42688:	ba 59 51 04 00       	mov    $0x45159,%edx
   4268d:	be 67 00 00 00       	mov    $0x67,%esi
   42692:	bf 55 4f 04 00       	mov    $0x44f55,%edi
   42697:	e8 a0 fc ff ff       	call   4233c <assert_fail>
    assert(va + sz >= va || va + sz == 0); // va range does not wrap
   4269c:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
   426a0:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
   426a4:	48 01 d0             	add    %rdx,%rax
   426a7:	48 3b 45 c0          	cmp    -0x40(%rbp),%rax
   426ab:	73 24                	jae    426d1 <virtual_memory_map+0x96>
   426ad:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
   426b1:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
   426b5:	48 01 d0             	add    %rdx,%rax
   426b8:	48 85 c0             	test   %rax,%rax
   426bb:	74 14                	je     426d1 <virtual_memory_map+0x96>
   426bd:	ba 6c 51 04 00       	mov    $0x4516c,%edx
   426c2:	be 68 00 00 00       	mov    $0x68,%esi
   426c7:	bf 55 4f 04 00       	mov    $0x44f55,%edi
   426cc:	e8 6b fc ff ff       	call   4233c <assert_fail>
    if (perm & PTE_P) {
   426d1:	8b 45 ac             	mov    -0x54(%rbp),%eax
   426d4:	48 98                	cltq
   426d6:	83 e0 01             	and    $0x1,%eax
   426d9:	48 85 c0             	test   %rax,%rax
   426dc:	74 6e                	je     4274c <virtual_memory_map+0x111>
        assert(pa % PAGESIZE == 0); // physical addr is page-aligned
   426de:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
   426e2:	25 ff 0f 00 00       	and    $0xfff,%eax
   426e7:	48 85 c0             	test   %rax,%rax
   426ea:	74 14                	je     42700 <virtual_memory_map+0xc5>
   426ec:	ba 8a 51 04 00       	mov    $0x4518a,%edx
   426f1:	be 6a 00 00 00       	mov    $0x6a,%esi
   426f6:	bf 55 4f 04 00       	mov    $0x44f55,%edi
   426fb:	e8 3c fc ff ff       	call   4233c <assert_fail>
        assert(pa + sz >= pa);      // physical address range does not wrap
   42700:	48 8b 55 b8          	mov    -0x48(%rbp),%rdx
   42704:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
   42708:	48 01 d0             	add    %rdx,%rax
   4270b:	48 3b 45 b8          	cmp    -0x48(%rbp),%rax
   4270f:	73 14                	jae    42725 <virtual_memory_map+0xea>
   42711:	ba 9d 51 04 00       	mov    $0x4519d,%edx
   42716:	be 6b 00 00 00       	mov    $0x6b,%esi
   4271b:	bf 55 4f 04 00       	mov    $0x44f55,%edi
   42720:	e8 17 fc ff ff       	call   4233c <assert_fail>
        assert(pa + sz <= MEMSIZE_PHYSICAL); // physical addresses exist
   42725:	48 8b 55 b8          	mov    -0x48(%rbp),%rdx
   42729:	48 8b 45 b0          	mov    -0x50(%rbp),%rax
   4272d:	48 01 d0             	add    %rdx,%rax
   42730:	48 3d 00 00 20 00    	cmp    $0x200000,%rax
   42736:	76 14                	jbe    4274c <virtual_memory_map+0x111>
   42738:	ba ab 51 04 00       	mov    $0x451ab,%edx
   4273d:	be 6c 00 00 00       	mov    $0x6c,%esi
   42742:	bf 55 4f 04 00       	mov    $0x44f55,%edi
   42747:	e8 f0 fb ff ff       	call   4233c <assert_fail>
    }
    assert(perm >= 0 && perm < 0x1000); // `perm` makes sense (perm can only be 12 bits)
   4274c:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
   42750:	78 09                	js     4275b <virtual_memory_map+0x120>
   42752:	81 7d ac ff 0f 00 00 	cmpl   $0xfff,-0x54(%rbp)
   42759:	7e 14                	jle    4276f <virtual_memory_map+0x134>
   4275b:	ba c7 51 04 00       	mov    $0x451c7,%edx
   42760:	be 6e 00 00 00       	mov    $0x6e,%esi
   42765:	bf 55 4f 04 00       	mov    $0x44f55,%edi
   4276a:	e8 cd fb ff ff       	call   4233c <assert_fail>
    assert((uintptr_t) pagetable % PAGESIZE == 0); // `pagetable` page-aligned
   4276f:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
   42773:	25 ff 0f 00 00       	and    $0xfff,%eax
   42778:	48 85 c0             	test   %rax,%rax
   4277b:	74 14                	je     42791 <virtual_memory_map+0x156>
   4277d:	ba e8 51 04 00       	mov    $0x451e8,%edx
   42782:	be 6f 00 00 00       	mov    $0x6f,%esi
   42787:	bf 55 4f 04 00       	mov    $0x44f55,%edi
   4278c:	e8 ab fb ff ff       	call   4233c <assert_fail>

    int last_index123 = -1;
   42791:	c7 45 ec ff ff ff ff 	movl   $0xffffffff,-0x14(%rbp)
    x86_64_pagetable* l4pagetable = NULL;
   42798:	48 c7 45 e0 00 00 00 	movq   $0x0,-0x20(%rbp)
   4279f:	00 

    // for each page-aligned address, set the appropriate page entry
    for (; sz != 0; va += PAGESIZE, pa += PAGESIZE, sz -= PAGESIZE) {
   427a0:	e9 e1 00 00 00       	jmp    42886 <virtual_memory_map+0x24b>
        int cur_index123 = (va >> (PAGEOFFBITS + PAGEINDEXBITS));
   427a5:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
   427a9:	48 c1 e8 15          	shr    $0x15,%rax
   427ad:	89 45 dc             	mov    %eax,-0x24(%rbp)
        if (cur_index123 != last_index123) {
   427b0:	8b 45 dc             	mov    -0x24(%rbp),%eax
   427b3:	3b 45 ec             	cmp    -0x14(%rbp),%eax
   427b6:	74 20                	je     427d8 <virtual_memory_map+0x19d>
            // find pointer to last level pagetable for current va
            l4pagetable = lookup_l4pagetable(pagetable, va, perm);
   427b8:	8b 55 ac             	mov    -0x54(%rbp),%edx
   427bb:	48 8b 4d c0          	mov    -0x40(%rbp),%rcx
   427bf:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
   427c3:	48 89 ce             	mov    %rcx,%rsi
   427c6:	48 89 c7             	mov    %rax,%rdi
   427c9:	e8 ce 00 00 00       	call   4289c <lookup_l4pagetable>
   427ce:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
            last_index123 = cur_index123;
   427d2:	8b 45 dc             	mov    -0x24(%rbp),%eax
   427d5:	89 45 ec             	mov    %eax,-0x14(%rbp)
        }
        if ((perm & PTE_P) && l4pagetable) { // if page is marked present
   427d8:	8b 45 ac             	mov    -0x54(%rbp),%eax
   427db:	48 98                	cltq
   427dd:	83 e0 01             	and    $0x1,%eax
   427e0:	48 85 c0             	test   %rax,%rax
   427e3:	74 34                	je     42819 <virtual_memory_map+0x1de>
   427e5:	48 83 7d e0 00       	cmpq   $0x0,-0x20(%rbp)
   427ea:	74 2d                	je     42819 <virtual_memory_map+0x1de>
            // set page table entry to pa and perm
            l4pagetable->entry[L4PAGEINDEX(va)] = pa | perm;
   427ec:	8b 45 ac             	mov    -0x54(%rbp),%eax
   427ef:	48 63 d8             	movslq %eax,%rbx
   427f2:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
   427f6:	be 03 00 00 00       	mov    $0x3,%esi
   427fb:	48 89 c7             	mov    %rax,%rdi
   427fe:	e8 9e fb ff ff       	call   423a1 <pageindex>
   42803:	89 c2                	mov    %eax,%edx
   42805:	48 0b 5d b8          	or     -0x48(%rbp),%rbx
   42809:	48 89 d9             	mov    %rbx,%rcx
   4280c:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
   42810:	48 63 d2             	movslq %edx,%rdx
   42813:	48 89 0c d0          	mov    %rcx,(%rax,%rdx,8)
   42817:	eb 55                	jmp    4286e <virtual_memory_map+0x233>
        } else if (l4pagetable) { // if page is NOT marked present
   42819:	48 83 7d e0 00       	cmpq   $0x0,-0x20(%rbp)
   4281e:	74 26                	je     42846 <virtual_memory_map+0x20b>
            // set page table entry to just perm
            l4pagetable->entry[L4PAGEINDEX(va)] = perm;
   42820:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
   42824:	be 03 00 00 00       	mov    $0x3,%esi
   42829:	48 89 c7             	mov    %rax,%rdi
   4282c:	e8 70 fb ff ff       	call   423a1 <pageindex>
   42831:	89 c2                	mov    %eax,%edx
   42833:	8b 45 ac             	mov    -0x54(%rbp),%eax
   42836:	48 63 c8             	movslq %eax,%rcx
   42839:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
   4283d:	48 63 d2             	movslq %edx,%rdx
   42840:	48 89 0c d0          	mov    %rcx,(%rax,%rdx,8)
   42844:	eb 28                	jmp    4286e <virtual_memory_map+0x233>
        } else if (perm & PTE_P) {
   42846:	8b 45 ac             	mov    -0x54(%rbp),%eax
   42849:	48 98                	cltq
   4284b:	83 e0 01             	and    $0x1,%eax
   4284e:	48 85 c0             	test   %rax,%rax
   42851:	74 1b                	je     4286e <virtual_memory_map+0x233>
            // error, no allocated l4 page found for va
            log_printf("[Kern Info] failed to find l4pagetable address at " __FILE__ ": %d\n", __LINE__);
   42853:	be 84 00 00 00       	mov    $0x84,%esi
   42858:	bf 10 52 04 00       	mov    $0x45210,%edi
   4285d:	b8 00 00 00 00       	mov    $0x0,%eax
   42862:	e8 b7 f7 ff ff       	call   4201e <log_printf>
            return -1;
   42867:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
   4286c:	eb 28                	jmp    42896 <virtual_memory_map+0x25b>
    for (; sz != 0; va += PAGESIZE, pa += PAGESIZE, sz -= PAGESIZE) {
   4286e:	48 81 45 c0 00 10 00 	addq   $0x1000,-0x40(%rbp)
   42875:	00 
   42876:	48 81 45 b8 00 10 00 	addq   $0x1000,-0x48(%rbp)
   4287d:	00 
   4287e:	48 81 6d b0 00 10 00 	subq   $0x1000,-0x50(%rbp)
   42885:	00 
   42886:	48 83 7d b0 00       	cmpq   $0x0,-0x50(%rbp)
   4288b:	0f 85 14 ff ff ff    	jne    427a5 <virtual_memory_map+0x16a>
        }
    }
    return 0;
   42891:	b8 00 00 00 00       	mov    $0x0,%eax
}
   42896:	48 8b 5d f8          	mov    -0x8(%rbp),%rbx
   4289a:	c9                   	leave
   4289b:	c3                   	ret

000000000004289c <lookup_l4pagetable>:
//
//    Returns an x86_64_pagetable pointer to the last level pagetable
//    if it exists and can be accessed with the given permissions
//    Returns NULL otherwise
static x86_64_pagetable* lookup_l4pagetable(x86_64_pagetable* pagetable,
                 uintptr_t va, int perm) {
   4289c:	55                   	push   %rbp
   4289d:	48 89 e5             	mov    %rsp,%rbp
   428a0:	48 83 ec 40          	sub    $0x40,%rsp
   428a4:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
   428a8:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
   428ac:	89 55 cc             	mov    %edx,-0x34(%rbp)
    x86_64_pagetable* pt = pagetable;
   428af:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
   428b3:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    // 1. Find index to the next pagetable entry using the `va`
    // 2. Check if this entry has the appropriate requested permissions
    // 3. Repeat the steps till you reach the l4 pagetable (i.e thrice)
    // 4. return the pagetable address

    for (int i = 0; i <= 2; ++i) {
   428b7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%rbp)
   428be:	e9 2b 01 00 00       	jmp    429ee <lookup_l4pagetable+0x152>
        // find page entry by finding `ith` level index of va to index pagetable entries of `pt`
        // you should read x86-64.h to understand relevant structs and macros to make this part easier
        x86_64_pageentry_t pe = pt->entry[PAGEINDEX(va, i)];
   428c3:	8b 55 f4             	mov    -0xc(%rbp),%edx
   428c6:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
   428ca:	89 d6                	mov    %edx,%esi
   428cc:	48 89 c7             	mov    %rax,%rdi
   428cf:	e8 cd fa ff ff       	call   423a1 <pageindex>
   428d4:	89 c2                	mov    %eax,%edx
   428d6:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   428da:	48 63 d2             	movslq %edx,%rdx
   428dd:	48 8b 04 d0          	mov    (%rax,%rdx,8),%rax
   428e1:	48 89 45 e8          	mov    %rax,-0x18(%rbp)

        if (!(pe & PTE_P)) { // address of next level should be present AND PTE_P should be set, error otherwise
   428e5:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   428e9:	83 e0 01             	and    $0x1,%eax
   428ec:	48 85 c0             	test   %rax,%rax
   428ef:	75 63                	jne    42954 <lookup_l4pagetable+0xb8>
            log_printf("[Kern Info] Error looking up l4pagetable: Pagetable address: 0x%x perm: 0x%x."
   428f1:	8b 45 f4             	mov    -0xc(%rbp),%eax
   428f4:	8d 48 02             	lea    0x2(%rax),%ecx
   428f7:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   428fb:	25 ff 0f 00 00       	and    $0xfff,%eax
   42900:	48 89 c2             	mov    %rax,%rdx
   42903:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   42907:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
   4290d:	48 89 c6             	mov    %rax,%rsi
   42910:	bf 58 52 04 00       	mov    $0x45258,%edi
   42915:	b8 00 00 00 00       	mov    $0x0,%eax
   4291a:	e8 ff f6 ff ff       	call   4201e <log_printf>
                    " Failed to get level (%d)\n",
                    PTE_ADDR(pe), PTE_FLAGS(pe), (i+2));
            if (!(perm & PTE_P)) {
   4291f:	8b 45 cc             	mov    -0x34(%rbp),%eax
   42922:	48 98                	cltq
   42924:	83 e0 01             	and    $0x1,%eax
   42927:	48 85 c0             	test   %rax,%rax
   4292a:	75 0a                	jne    42936 <lookup_l4pagetable+0x9a>
                return NULL;
   4292c:	b8 00 00 00 00       	mov    $0x0,%eax
   42931:	e9 c6 00 00 00       	jmp    429fc <lookup_l4pagetable+0x160>
            }
            log_printf("[Kern Info] failed to find pagetable address at " __FILE__ ": %d\n", __LINE__);
   42936:	be a7 00 00 00       	mov    $0xa7,%esi
   4293b:	bf c0 52 04 00       	mov    $0x452c0,%edi
   42940:	b8 00 00 00 00       	mov    $0x0,%eax
   42945:	e8 d4 f6 ff ff       	call   4201e <log_printf>
            return NULL;
   4294a:	b8 00 00 00 00       	mov    $0x0,%eax
   4294f:	e9 a8 00 00 00       	jmp    429fc <lookup_l4pagetable+0x160>
        }

        // sanity-check page entry and permissions
        assert(PTE_ADDR(pe) < MEMSIZE_PHYSICAL); // at sensible address
   42954:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   42958:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
   4295e:	48 3d ff ff 1f 00    	cmp    $0x1fffff,%rax
   42964:	76 14                	jbe    4297a <lookup_l4pagetable+0xde>
   42966:	ba 08 53 04 00       	mov    $0x45308,%edx
   4296b:	be ac 00 00 00       	mov    $0xac,%esi
   42970:	bf 55 4f 04 00       	mov    $0x44f55,%edi
   42975:	e8 c2 f9 ff ff       	call   4233c <assert_fail>
        if (perm & PTE_W) {       // if requester wants PTE_W,
   4297a:	8b 45 cc             	mov    -0x34(%rbp),%eax
   4297d:	48 98                	cltq
   4297f:	83 e0 02             	and    $0x2,%eax
   42982:	48 85 c0             	test   %rax,%rax
   42985:	74 20                	je     429a7 <lookup_l4pagetable+0x10b>
            assert(pe & PTE_W);   //   entry must allow PTE_W
   42987:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   4298b:	83 e0 02             	and    $0x2,%eax
   4298e:	48 85 c0             	test   %rax,%rax
   42991:	75 14                	jne    429a7 <lookup_l4pagetable+0x10b>
   42993:	ba 28 53 04 00       	mov    $0x45328,%edx
   42998:	be ae 00 00 00       	mov    $0xae,%esi
   4299d:	bf 55 4f 04 00       	mov    $0x44f55,%edi
   429a2:	e8 95 f9 ff ff       	call   4233c <assert_fail>
        }
        if (perm & PTE_U) {       // if requester wants PTE_U,
   429a7:	8b 45 cc             	mov    -0x34(%rbp),%eax
   429aa:	48 98                	cltq
   429ac:	83 e0 04             	and    $0x4,%eax
   429af:	48 85 c0             	test   %rax,%rax
   429b2:	74 20                	je     429d4 <lookup_l4pagetable+0x138>
            assert(pe & PTE_U);   //   entry must allow PTE_U
   429b4:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   429b8:	83 e0 04             	and    $0x4,%eax
   429bb:	48 85 c0             	test   %rax,%rax
   429be:	75 14                	jne    429d4 <lookup_l4pagetable+0x138>
   429c0:	ba 33 53 04 00       	mov    $0x45333,%edx
   429c5:	be b1 00 00 00       	mov    $0xb1,%esi
   429ca:	bf 55 4f 04 00       	mov    $0x44f55,%edi
   429cf:	e8 68 f9 ff ff       	call   4233c <assert_fail>
        }

        // set pt to physical address to next pagetable using `pe`
        pt = 0; // replace this
   429d4:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
   429db:	00 
        pt = (x86_64_pagetable*) PTE_ADDR(pe);
   429dc:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   429e0:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
   429e6:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    for (int i = 0; i <= 2; ++i) {
   429ea:	83 45 f4 01          	addl   $0x1,-0xc(%rbp)
   429ee:	83 7d f4 02          	cmpl   $0x2,-0xc(%rbp)
   429f2:	0f 8e cb fe ff ff    	jle    428c3 <lookup_l4pagetable+0x27>
    }
    return pt;
   429f8:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
   429fc:	c9                   	leave
   429fd:	c3                   	ret

00000000000429fe <virtual_memory_lookup>:

// virtual_memory_lookup(pagetable, va)
//    Returns information about the mapping of the virtual address `va` in
//    `pagetable`. The information is returned as a `vamapping` object.

vamapping virtual_memory_lookup(x86_64_pagetable* pagetable, uintptr_t va) {
   429fe:	55                   	push   %rbp
   429ff:	48 89 e5             	mov    %rsp,%rbp
   42a02:	48 83 ec 50          	sub    $0x50,%rsp
   42a06:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
   42a0a:	48 89 75 c0          	mov    %rsi,-0x40(%rbp)
   42a0e:	48 89 55 b8          	mov    %rdx,-0x48(%rbp)
    x86_64_pagetable* pt = pagetable;
   42a12:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
   42a16:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    x86_64_pageentry_t pe = PTE_W | PTE_U | PTE_P;
   42a1a:	48 c7 45 f0 07 00 00 	movq   $0x7,-0x10(%rbp)
   42a21:	00 
    for (int i = 0; i <= 3 && (pe & PTE_P); ++i) {
   42a22:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%rbp)
   42a29:	eb 41                	jmp    42a6c <virtual_memory_lookup+0x6e>
        pe = pt->entry[PAGEINDEX(va, i)] & ~(pe & (PTE_W | PTE_U));
   42a2b:	8b 55 ec             	mov    -0x14(%rbp),%edx
   42a2e:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
   42a32:	89 d6                	mov    %edx,%esi
   42a34:	48 89 c7             	mov    %rax,%rdi
   42a37:	e8 65 f9 ff ff       	call   423a1 <pageindex>
   42a3c:	89 c2                	mov    %eax,%edx
   42a3e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   42a42:	48 63 d2             	movslq %edx,%rdx
   42a45:	48 8b 14 d0          	mov    (%rax,%rdx,8),%rdx
   42a49:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   42a4d:	83 e0 06             	and    $0x6,%eax
   42a50:	48 f7 d0             	not    %rax
   42a53:	48 21 d0             	and    %rdx,%rax
   42a56:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
        pt = (x86_64_pagetable*) PTE_ADDR(pe);
   42a5a:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   42a5e:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
   42a64:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    for (int i = 0; i <= 3 && (pe & PTE_P); ++i) {
   42a68:	83 45 ec 01          	addl   $0x1,-0x14(%rbp)
   42a6c:	83 7d ec 03          	cmpl   $0x3,-0x14(%rbp)
   42a70:	7f 0c                	jg     42a7e <virtual_memory_lookup+0x80>
   42a72:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   42a76:	83 e0 01             	and    $0x1,%eax
   42a79:	48 85 c0             	test   %rax,%rax
   42a7c:	75 ad                	jne    42a2b <virtual_memory_lookup+0x2d>
    }
    vamapping vam = { -1, (uintptr_t) -1, 0 };
   42a7e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%rbp)
   42a85:	48 c7 45 d8 ff ff ff 	movq   $0xffffffffffffffff,-0x28(%rbp)
   42a8c:	ff 
   42a8d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%rbp)
    if (pe & PTE_P) {
   42a94:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   42a98:	83 e0 01             	and    $0x1,%eax
   42a9b:	48 85 c0             	test   %rax,%rax
   42a9e:	74 34                	je     42ad4 <virtual_memory_lookup+0xd6>
        vam.pn = PAGENUMBER(pe);
   42aa0:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   42aa4:	48 c1 e8 0c          	shr    $0xc,%rax
   42aa8:	89 45 d0             	mov    %eax,-0x30(%rbp)
        vam.pa = PTE_ADDR(pe) + PAGEOFFSET(va);
   42aab:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   42aaf:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
   42ab5:	48 89 c2             	mov    %rax,%rdx
   42ab8:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
   42abc:	25 ff 0f 00 00       	and    $0xfff,%eax
   42ac1:	48 09 d0             	or     %rdx,%rax
   42ac4:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
        vam.perm = PTE_FLAGS(pe);
   42ac8:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   42acc:	25 ff 0f 00 00       	and    $0xfff,%eax
   42ad1:	89 45 e0             	mov    %eax,-0x20(%rbp)
    }
    return vam;
   42ad4:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
   42ad8:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
   42adc:	48 89 10             	mov    %rdx,(%rax)
   42adf:	48 8b 55 d8          	mov    -0x28(%rbp),%rdx
   42ae3:	48 89 50 08          	mov    %rdx,0x8(%rax)
   42ae7:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
   42aeb:	48 89 50 10          	mov    %rdx,0x10(%rax)
}
   42aef:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
   42af3:	c9                   	leave
   42af4:	c3                   	ret

0000000000042af5 <program_load>:
//    `assign_physical_page` to as required. Returns 0 on success and
//    -1 on failure (e.g. out-of-memory). `allocator` is passed to
//    `virtual_memory_map`.

int program_load(proc* p, int programnumber,
                 x86_64_pagetable* (*allocator)(void)) {
   42af5:	55                   	push   %rbp
   42af6:	48 89 e5             	mov    %rsp,%rbp
   42af9:	48 83 ec 40          	sub    $0x40,%rsp
   42afd:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
   42b01:	89 75 d4             	mov    %esi,-0x2c(%rbp)
   42b04:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
    // is this a valid program?
    int nprograms = sizeof(ramimages) / sizeof(ramimages[0]);
   42b08:	c7 45 f8 04 00 00 00 	movl   $0x4,-0x8(%rbp)
    assert(programnumber >= 0 && programnumber < nprograms);
   42b0f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%rbp)
   42b13:	78 08                	js     42b1d <program_load+0x28>
   42b15:	8b 45 d4             	mov    -0x2c(%rbp),%eax
   42b18:	3b 45 f8             	cmp    -0x8(%rbp),%eax
   42b1b:	7c 14                	jl     42b31 <program_load+0x3c>
   42b1d:	ba 40 53 04 00       	mov    $0x45340,%edx
   42b22:	be 2e 00 00 00       	mov    $0x2e,%esi
   42b27:	bf 70 53 04 00       	mov    $0x45370,%edi
   42b2c:	e8 0b f8 ff ff       	call   4233c <assert_fail>
    elf_header* eh = (elf_header*) ramimages[programnumber].begin;
   42b31:	8b 45 d4             	mov    -0x2c(%rbp),%eax
   42b34:	48 98                	cltq
   42b36:	48 c1 e0 04          	shl    $0x4,%rax
   42b3a:	48 05 20 60 04 00    	add    $0x46020,%rax
   42b40:	48 8b 00             	mov    (%rax),%rax
   42b43:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
    assert(eh->e_magic == ELF_MAGIC);
   42b47:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   42b4b:	8b 00                	mov    (%rax),%eax
   42b4d:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
   42b52:	74 14                	je     42b68 <program_load+0x73>
   42b54:	ba 82 53 04 00       	mov    $0x45382,%edx
   42b59:	be 30 00 00 00       	mov    $0x30,%esi
   42b5e:	bf 70 53 04 00       	mov    $0x45370,%edi
   42b63:	e8 d4 f7 ff ff       	call   4233c <assert_fail>

    // load each loadable program segment into memory
    elf_program* ph = (elf_program*) ((const uint8_t*) eh + eh->e_phoff);
   42b68:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   42b6c:	48 8b 50 20          	mov    0x20(%rax),%rdx
   42b70:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   42b74:	48 01 d0             	add    %rdx,%rax
   42b77:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
    for (int i = 0; i < eh->e_phnum; ++i) {
   42b7b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
   42b82:	eb 6a                	jmp    42bee <program_load+0xf9>
        if (ph[i].p_type == ELF_PTYPE_LOAD) {
   42b84:	8b 45 fc             	mov    -0x4(%rbp),%eax
   42b87:	48 98                	cltq
   42b89:	48 6b d0 38          	imul   $0x38,%rax,%rdx
   42b8d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   42b91:	48 01 d0             	add    %rdx,%rax
   42b94:	8b 00                	mov    (%rax),%eax
   42b96:	83 f8 01             	cmp    $0x1,%eax
   42b99:	75 4f                	jne    42bea <program_load+0xf5>
            const uint8_t* pdata = (const uint8_t*) eh + ph[i].p_offset;
   42b9b:	8b 45 fc             	mov    -0x4(%rbp),%eax
   42b9e:	48 98                	cltq
   42ba0:	48 6b d0 38          	imul   $0x38,%rax,%rdx
   42ba4:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   42ba8:	48 01 d0             	add    %rdx,%rax
   42bab:	48 8b 50 08          	mov    0x8(%rax),%rdx
   42baf:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   42bb3:	48 01 d0             	add    %rdx,%rax
   42bb6:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
            if (program_load_segment(p, &ph[i], pdata, allocator) < 0) {
   42bba:	8b 45 fc             	mov    -0x4(%rbp),%eax
   42bbd:	48 98                	cltq
   42bbf:	48 6b d0 38          	imul   $0x38,%rax,%rdx
   42bc3:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   42bc7:	48 8d 34 02          	lea    (%rdx,%rax,1),%rsi
   42bcb:	48 8b 4d c8          	mov    -0x38(%rbp),%rcx
   42bcf:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
   42bd3:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
   42bd7:	48 89 c7             	mov    %rax,%rdi
   42bda:	e8 39 00 00 00       	call   42c18 <program_load_segment>
   42bdf:	85 c0                	test   %eax,%eax
   42be1:	79 07                	jns    42bea <program_load+0xf5>
                return -1;
   42be3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
   42be8:	eb 2c                	jmp    42c16 <program_load+0x121>
    for (int i = 0; i < eh->e_phnum; ++i) {
   42bea:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
   42bee:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   42bf2:	0f b7 40 38          	movzwl 0x38(%rax),%eax
   42bf6:	0f b7 c0             	movzwl %ax,%eax
   42bf9:	39 45 fc             	cmp    %eax,-0x4(%rbp)
   42bfc:	7c 86                	jl     42b84 <program_load+0x8f>
            }
        }
    }

    // set the entry point from the ELF header
    p->p_registers.reg_rip = eh->e_entry;
   42bfe:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   42c02:	48 8b 50 18          	mov    0x18(%rax),%rdx
   42c06:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
   42c0a:	48 89 90 b0 00 00 00 	mov    %rdx,0xb0(%rax)
    return 0;
   42c11:	b8 00 00 00 00       	mov    $0x0,%eax
}
   42c16:	c9                   	leave
   42c17:	c3                   	ret

0000000000042c18 <program_load_segment>:
//    Calls `assign_physical_page` to allocate pages and `virtual_memory_map`
//    to map them in `p->p_pagetable`. Returns 0 on success and -1 on failure.

static int program_load_segment(proc* p, const elf_program* ph,
                                const uint8_t* src,
                                x86_64_pagetable* (*allocator)(void)) {
   42c18:	55                   	push   %rbp
   42c19:	48 89 e5             	mov    %rsp,%rbp
   42c1c:	48 83 ec 70          	sub    $0x70,%rsp
   42c20:	48 89 7d a8          	mov    %rdi,-0x58(%rbp)
   42c24:	48 89 75 a0          	mov    %rsi,-0x60(%rbp)
   42c28:	48 89 55 98          	mov    %rdx,-0x68(%rbp)
   42c2c:	48 89 4d 90          	mov    %rcx,-0x70(%rbp)
    uintptr_t va = (uintptr_t) ph->p_va;
   42c30:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
   42c34:	48 8b 40 10          	mov    0x10(%rax),%rax
   42c38:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
    uintptr_t end_file = va + ph->p_filesz, end_mem = va + ph->p_memsz;
   42c3c:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
   42c40:	48 8b 50 20          	mov    0x20(%rax),%rdx
   42c44:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   42c48:	48 01 d0             	add    %rdx,%rax
   42c4b:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
   42c4f:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
   42c53:	48 8b 50 28          	mov    0x28(%rax),%rdx
   42c57:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   42c5b:	48 01 d0             	add    %rdx,%rax
   42c5e:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
    va &= ~(PAGESIZE - 1);                // round to page boundary
   42c62:	48 81 65 e8 00 f0 ff 	andq   $0xfffffffffffff000,-0x18(%rbp)
   42c69:	ff 


    // allocate memory
    for (uintptr_t addr = va; addr < end_mem; addr += PAGESIZE) {
   42c6a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   42c6e:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
   42c72:	eb 7c                	jmp    42cf0 <program_load_segment+0xd8>
        uintptr_t pa = (uintptr_t)palloc(p->p_pid);
   42c74:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
   42c78:	8b 00                	mov    (%rax),%eax
   42c7a:	89 c7                	mov    %eax,%edi
   42c7c:	e8 4e 01 00 00       	call   42dcf <palloc>
   42c81:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
        if(pa == (uintptr_t)NULL || virtual_memory_map(p->p_pagetable, addr, pa, PAGESIZE,
   42c85:	48 83 7d d0 00       	cmpq   $0x0,-0x30(%rbp)
   42c8a:	74 2a                	je     42cb6 <program_load_segment+0x9e>
   42c8c:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
   42c90:	48 8b 80 e0 00 00 00 	mov    0xe0(%rax),%rax
   42c97:	48 8b 55 d0          	mov    -0x30(%rbp),%rdx
   42c9b:	48 8b 75 f8          	mov    -0x8(%rbp),%rsi
   42c9f:	41 b8 07 00 00 00    	mov    $0x7,%r8d
   42ca5:	b9 00 10 00 00       	mov    $0x1000,%ecx
   42caa:	48 89 c7             	mov    %rax,%rdi
   42cad:	e8 89 f9 ff ff       	call   4263b <virtual_memory_map>
   42cb2:	85 c0                	test   %eax,%eax
   42cb4:	79 32                	jns    42ce8 <program_load_segment+0xd0>
                    PTE_W | PTE_P | PTE_U) < 0) {
            console_printf(CPOS(22, 0), 0xC000,
   42cb6:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
   42cba:	8b 00                	mov    (%rax),%eax
   42cbc:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
   42cc0:	49 89 d0             	mov    %rdx,%r8
   42cc3:	89 c1                	mov    %eax,%ecx
   42cc5:	ba a0 53 04 00       	mov    $0x453a0,%edx
   42cca:	be 00 c0 00 00       	mov    $0xc000,%esi
   42ccf:	bf e0 06 00 00       	mov    $0x6e0,%edi
   42cd4:	b8 00 00 00 00       	mov    $0x0,%eax
   42cd9:	e8 81 1b 00 00       	call   4485f <console_printf>
                    "program_load_segment(pid %d): can't assign address %p\n", p->p_pid, addr);
            return -1;
   42cde:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
   42ce3:	e9 e5 00 00 00       	jmp    42dcd <program_load_segment+0x1b5>
    for (uintptr_t addr = va; addr < end_mem; addr += PAGESIZE) {
   42ce8:	48 81 45 f8 00 10 00 	addq   $0x1000,-0x8(%rbp)
   42cef:	00 
   42cf0:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   42cf4:	48 3b 45 d8          	cmp    -0x28(%rbp),%rax
   42cf8:	0f 82 76 ff ff ff    	jb     42c74 <program_load_segment+0x5c>
        }
    }

    // ensure new memory mappings are active
    set_pagetable(p->p_pagetable);
   42cfe:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
   42d02:	48 8b 80 e0 00 00 00 	mov    0xe0(%rax),%rax
   42d09:	48 89 c7             	mov    %rax,%rdi
   42d0c:	e8 f9 f7 ff ff       	call   4250a <set_pagetable>

    // copy data from executable image into process memory
    memcpy((uint8_t*) va, src, end_file - va);
   42d11:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
   42d15:	48 2b 45 e8          	sub    -0x18(%rbp),%rax
   42d19:	48 89 c2             	mov    %rax,%rdx
   42d1c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   42d20:	48 8b 4d 98          	mov    -0x68(%rbp),%rcx
   42d24:	48 89 ce             	mov    %rcx,%rsi
   42d27:	48 89 c7             	mov    %rax,%rdi
   42d2a:	e8 d4 0b 00 00       	call   43903 <memcpy>
    memset((uint8_t*) end_file, 0, end_mem - end_file);
   42d2f:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
   42d33:	48 2b 45 e0          	sub    -0x20(%rbp),%rax
   42d37:	48 89 c2             	mov    %rax,%rdx
   42d3a:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
   42d3e:	be 00 00 00 00       	mov    $0x0,%esi
   42d43:	48 89 c7             	mov    %rax,%rdi
   42d46:	e8 b6 0c 00 00       	call   43a01 <memset>

    // restore kernel pagetable
    set_pagetable(kernel_pagetable);
   42d4b:	48 8b 05 ae d2 00 00 	mov    0xd2ae(%rip),%rax        # 50000 <kernel_pagetable>
   42d52:	48 89 c7             	mov    %rax,%rdi
   42d55:	e8 b0 f7 ff ff       	call   4250a <set_pagetable>


    if((ph->p_flags & ELF_PFLAG_WRITE) == 0) {
   42d5a:	48 8b 45 a0          	mov    -0x60(%rbp),%rax
   42d5e:	8b 40 04             	mov    0x4(%rax),%eax
   42d61:	83 e0 02             	and    $0x2,%eax
   42d64:	85 c0                	test   %eax,%eax
   42d66:	75 60                	jne    42dc8 <program_load_segment+0x1b0>
        for (uintptr_t addr = va; addr < end_mem; addr += PAGESIZE) {
   42d68:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   42d6c:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
   42d70:	eb 4c                	jmp    42dbe <program_load_segment+0x1a6>
            vamapping mapping = virtual_memory_lookup(p->p_pagetable, addr);
   42d72:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
   42d76:	48 8b 88 e0 00 00 00 	mov    0xe0(%rax),%rcx
   42d7d:	48 8d 45 b8          	lea    -0x48(%rbp),%rax
   42d81:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
   42d85:	48 89 ce             	mov    %rcx,%rsi
   42d88:	48 89 c7             	mov    %rax,%rdi
   42d8b:	e8 6e fc ff ff       	call   429fe <virtual_memory_lookup>

            virtual_memory_map(p->p_pagetable, addr, mapping.pa, PAGESIZE,
   42d90:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
   42d94:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
   42d98:	48 8b 80 e0 00 00 00 	mov    0xe0(%rax),%rax
   42d9f:	48 8b 75 f0          	mov    -0x10(%rbp),%rsi
   42da3:	41 b8 05 00 00 00    	mov    $0x5,%r8d
   42da9:	b9 00 10 00 00       	mov    $0x1000,%ecx
   42dae:	48 89 c7             	mov    %rax,%rdi
   42db1:	e8 85 f8 ff ff       	call   4263b <virtual_memory_map>
        for (uintptr_t addr = va; addr < end_mem; addr += PAGESIZE) {
   42db6:	48 81 45 f0 00 10 00 	addq   $0x1000,-0x10(%rbp)
   42dbd:	00 
   42dbe:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   42dc2:	48 3b 45 d8          	cmp    -0x28(%rbp),%rax
   42dc6:	72 aa                	jb     42d72 <program_load_segment+0x15a>
                    PTE_P | PTE_U);
        }
    }
    // TODO : Add code here
    return 0;
   42dc8:	b8 00 00 00 00       	mov    $0x0,%eax
}
   42dcd:	c9                   	leave
   42dce:	c3                   	ret

0000000000042dcf <palloc>:
   42dcf:	55                   	push   %rbp
   42dd0:	48 89 e5             	mov    %rsp,%rbp
   42dd3:	48 83 ec 20          	sub    $0x20,%rsp
   42dd7:	89 7d ec             	mov    %edi,-0x14(%rbp)
   42dda:	48 c7 45 f8 00 10 00 	movq   $0x1000,-0x8(%rbp)
   42de1:	00 
   42de2:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   42de6:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
   42dea:	e9 95 00 00 00       	jmp    42e84 <palloc+0xb5>
   42def:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   42df3:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
   42df7:	48 81 45 f8 00 10 00 	addq   $0x1000,-0x8(%rbp)
   42dfe:	00 
   42dff:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   42e03:	48 c1 e8 0c          	shr    $0xc,%rax
   42e07:	48 98                	cltq
   42e09:	0f b6 84 00 20 df 04 	movzbl 0x4df20(%rax,%rax,1),%eax
   42e10:	00 
   42e11:	84 c0                	test   %al,%al
   42e13:	75 6f                	jne    42e84 <palloc+0xb5>
   42e15:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   42e19:	48 c1 e8 0c          	shr    $0xc,%rax
   42e1d:	48 98                	cltq
   42e1f:	0f b6 84 00 21 df 04 	movzbl 0x4df21(%rax,%rax,1),%eax
   42e26:	00 
   42e27:	84 c0                	test   %al,%al
   42e29:	75 59                	jne    42e84 <palloc+0xb5>
   42e2b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   42e2f:	48 c1 e8 0c          	shr    $0xc,%rax
   42e33:	89 c2                	mov    %eax,%edx
   42e35:	48 63 c2             	movslq %edx,%rax
   42e38:	0f b6 84 00 21 df 04 	movzbl 0x4df21(%rax,%rax,1),%eax
   42e3f:	00 
   42e40:	83 c0 01             	add    $0x1,%eax
   42e43:	89 c1                	mov    %eax,%ecx
   42e45:	48 63 c2             	movslq %edx,%rax
   42e48:	88 8c 00 21 df 04 00 	mov    %cl,0x4df21(%rax,%rax,1)
   42e4f:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   42e53:	48 c1 e8 0c          	shr    $0xc,%rax
   42e57:	89 c1                	mov    %eax,%ecx
   42e59:	8b 45 ec             	mov    -0x14(%rbp),%eax
   42e5c:	89 c2                	mov    %eax,%edx
   42e5e:	48 63 c1             	movslq %ecx,%rax
   42e61:	88 94 00 20 df 04 00 	mov    %dl,0x4df20(%rax,%rax,1)
   42e68:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   42e6c:	ba 00 10 00 00       	mov    $0x1000,%edx
   42e71:	be cc 00 00 00       	mov    $0xcc,%esi
   42e76:	48 89 c7             	mov    %rax,%rdi
   42e79:	e8 83 0b 00 00       	call   43a01 <memset>
   42e7e:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   42e82:	eb 2c                	jmp    42eb0 <palloc+0xe1>
   42e84:	48 81 7d f8 ff ff 1f 	cmpq   $0x1fffff,-0x8(%rbp)
   42e8b:	00 
   42e8c:	0f 86 5d ff ff ff    	jbe    42def <palloc+0x20>
   42e92:	ba d8 53 04 00       	mov    $0x453d8,%edx
   42e97:	be 00 0c 00 00       	mov    $0xc00,%esi
   42e9c:	bf 80 07 00 00       	mov    $0x780,%edi
   42ea1:	b8 00 00 00 00       	mov    $0x0,%eax
   42ea6:	e8 b4 19 00 00       	call   4485f <console_printf>
   42eab:	b8 00 00 00 00       	mov    $0x0,%eax
   42eb0:	c9                   	leave
   42eb1:	c3                   	ret

0000000000042eb2 <palloc_target>:
   42eb2:	55                   	push   %rbp
   42eb3:	48 89 e5             	mov    %rsp,%rbp
   42eb6:	48 8b 05 43 31 01 00 	mov    0x13143(%rip),%rax        # 56000 <palloc_target_proc>
   42ebd:	48 85 c0             	test   %rax,%rax
   42ec0:	75 14                	jne    42ed6 <palloc_target+0x24>
   42ec2:	ba f1 53 04 00       	mov    $0x453f1,%edx
   42ec7:	be 27 00 00 00       	mov    $0x27,%esi
   42ecc:	bf 0c 54 04 00       	mov    $0x4540c,%edi
   42ed1:	e8 66 f4 ff ff       	call   4233c <assert_fail>
   42ed6:	48 8b 05 23 31 01 00 	mov    0x13123(%rip),%rax        # 56000 <palloc_target_proc>
   42edd:	8b 00                	mov    (%rax),%eax
   42edf:	89 c7                	mov    %eax,%edi
   42ee1:	e8 e9 fe ff ff       	call   42dcf <palloc>
   42ee6:	5d                   	pop    %rbp
   42ee7:	c3                   	ret

0000000000042ee8 <process_free>:
   42ee8:	55                   	push   %rbp
   42ee9:	48 89 e5             	mov    %rsp,%rbp
   42eec:	48 83 ec 60          	sub    $0x60,%rsp
   42ef0:	89 7d ac             	mov    %edi,-0x54(%rbp)
   42ef3:	8b 45 ac             	mov    -0x54(%rbp),%eax
   42ef6:	48 63 d0             	movslq %eax,%rdx
   42ef9:	48 89 d0             	mov    %rdx,%rax
   42efc:	48 c1 e0 04          	shl    $0x4,%rax
   42f00:	48 29 d0             	sub    %rdx,%rax
   42f03:	48 c1 e0 04          	shl    $0x4,%rax
   42f07:	48 05 d8 d0 04 00    	add    $0x4d0d8,%rax
   42f0d:	c7 00 00 00 00 00    	movl   $0x0,(%rax)
   42f13:	48 c7 45 f8 00 00 10 	movq   $0x100000,-0x8(%rbp)
   42f1a:	00 
   42f1b:	e9 ad 00 00 00       	jmp    42fcd <process_free+0xe5>
   42f20:	8b 45 ac             	mov    -0x54(%rbp),%eax
   42f23:	48 63 d0             	movslq %eax,%rdx
   42f26:	48 89 d0             	mov    %rdx,%rax
   42f29:	48 c1 e0 04          	shl    $0x4,%rax
   42f2d:	48 29 d0             	sub    %rdx,%rax
   42f30:	48 c1 e0 04          	shl    $0x4,%rax
   42f34:	48 05 e0 d0 04 00    	add    $0x4d0e0,%rax
   42f3a:	48 8b 08             	mov    (%rax),%rcx
   42f3d:	48 8d 45 b8          	lea    -0x48(%rbp),%rax
   42f41:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
   42f45:	48 89 ce             	mov    %rcx,%rsi
   42f48:	48 89 c7             	mov    %rax,%rdi
   42f4b:	e8 ae fa ff ff       	call   429fe <virtual_memory_lookup>
   42f50:	8b 45 c8             	mov    -0x38(%rbp),%eax
   42f53:	48 98                	cltq
   42f55:	83 e0 01             	and    $0x1,%eax
   42f58:	48 85 c0             	test   %rax,%rax
   42f5b:	74 68                	je     42fc5 <process_free+0xdd>
   42f5d:	8b 45 b8             	mov    -0x48(%rbp),%eax
   42f60:	48 63 d0             	movslq %eax,%rdx
   42f63:	0f b6 94 12 21 df 04 	movzbl 0x4df21(%rdx,%rdx,1),%edx
   42f6a:	00 
   42f6b:	83 ea 01             	sub    $0x1,%edx
   42f6e:	48 98                	cltq
   42f70:	88 94 00 21 df 04 00 	mov    %dl,0x4df21(%rax,%rax,1)
   42f77:	8b 45 b8             	mov    -0x48(%rbp),%eax
   42f7a:	48 98                	cltq
   42f7c:	0f b6 84 00 21 df 04 	movzbl 0x4df21(%rax,%rax,1),%eax
   42f83:	00 
   42f84:	84 c0                	test   %al,%al
   42f86:	75 0f                	jne    42f97 <process_free+0xaf>
   42f88:	8b 45 b8             	mov    -0x48(%rbp),%eax
   42f8b:	48 98                	cltq
   42f8d:	c6 84 00 20 df 04 00 	movb   $0x0,0x4df20(%rax,%rax,1)
   42f94:	00 
   42f95:	eb 2e                	jmp    42fc5 <process_free+0xdd>
   42f97:	8b 45 b8             	mov    -0x48(%rbp),%eax
   42f9a:	48 98                	cltq
   42f9c:	0f b6 84 00 20 df 04 	movzbl 0x4df20(%rax,%rax,1),%eax
   42fa3:	00 
   42fa4:	0f be c0             	movsbl %al,%eax
   42fa7:	39 45 ac             	cmp    %eax,-0x54(%rbp)
   42faa:	75 19                	jne    42fc5 <process_free+0xdd>
   42fac:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
   42fb0:	8b 55 ac             	mov    -0x54(%rbp),%edx
   42fb3:	48 89 c6             	mov    %rax,%rsi
   42fb6:	bf 18 54 04 00       	mov    $0x45418,%edi
   42fbb:	b8 00 00 00 00       	mov    $0x0,%eax
   42fc0:	e8 59 f0 ff ff       	call   4201e <log_printf>
   42fc5:	48 81 45 f8 00 10 00 	addq   $0x1000,-0x8(%rbp)
   42fcc:	00 
   42fcd:	48 81 7d f8 ff ff 2f 	cmpq   $0x2fffff,-0x8(%rbp)
   42fd4:	00 
   42fd5:	0f 86 45 ff ff ff    	jbe    42f20 <process_free+0x38>
   42fdb:	8b 45 ac             	mov    -0x54(%rbp),%eax
   42fde:	48 63 d0             	movslq %eax,%rdx
   42fe1:	48 89 d0             	mov    %rdx,%rax
   42fe4:	48 c1 e0 04          	shl    $0x4,%rax
   42fe8:	48 29 d0             	sub    %rdx,%rax
   42feb:	48 c1 e0 04          	shl    $0x4,%rax
   42fef:	48 05 e0 d0 04 00    	add    $0x4d0e0,%rax
   42ff5:	48 8b 00             	mov    (%rax),%rax
   42ff8:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
   42ffc:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   43000:	48 8b 00             	mov    (%rax),%rax
   43003:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
   43009:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
   4300d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   43011:	48 8b 00             	mov    (%rax),%rax
   43014:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
   4301a:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
   4301e:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
   43022:	48 8b 00             	mov    (%rax),%rax
   43025:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
   4302b:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
   4302f:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
   43033:	48 8b 40 08          	mov    0x8(%rax),%rax
   43037:	48 25 00 f0 ff ff    	and    $0xfffffffffffff000,%rax
   4303d:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
   43041:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   43045:	48 c1 e8 0c          	shr    $0xc,%rax
   43049:	48 98                	cltq
   4304b:	0f b6 84 00 21 df 04 	movzbl 0x4df21(%rax,%rax,1),%eax
   43052:	00 
   43053:	3c 01                	cmp    $0x1,%al
   43055:	74 14                	je     4306b <process_free+0x183>
   43057:	ba 50 54 04 00       	mov    $0x45450,%edx
   4305c:	be 4f 00 00 00       	mov    $0x4f,%esi
   43061:	bf 0c 54 04 00       	mov    $0x4540c,%edi
   43066:	e8 d1 f2 ff ff       	call   4233c <assert_fail>
   4306b:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   4306f:	48 c1 e8 0c          	shr    $0xc,%rax
   43073:	48 98                	cltq
   43075:	c6 84 00 21 df 04 00 	movb   $0x0,0x4df21(%rax,%rax,1)
   4307c:	00 
   4307d:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   43081:	48 c1 e8 0c          	shr    $0xc,%rax
   43085:	48 98                	cltq
   43087:	c6 84 00 20 df 04 00 	movb   $0x0,0x4df20(%rax,%rax,1)
   4308e:	00 
   4308f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   43093:	48 c1 e8 0c          	shr    $0xc,%rax
   43097:	48 98                	cltq
   43099:	0f b6 84 00 21 df 04 	movzbl 0x4df21(%rax,%rax,1),%eax
   430a0:	00 
   430a1:	3c 01                	cmp    $0x1,%al
   430a3:	74 14                	je     430b9 <process_free+0x1d1>
   430a5:	ba 78 54 04 00       	mov    $0x45478,%edx
   430aa:	be 52 00 00 00       	mov    $0x52,%esi
   430af:	bf 0c 54 04 00       	mov    $0x4540c,%edi
   430b4:	e8 83 f2 ff ff       	call   4233c <assert_fail>
   430b9:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   430bd:	48 c1 e8 0c          	shr    $0xc,%rax
   430c1:	48 98                	cltq
   430c3:	c6 84 00 21 df 04 00 	movb   $0x0,0x4df21(%rax,%rax,1)
   430ca:	00 
   430cb:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   430cf:	48 c1 e8 0c          	shr    $0xc,%rax
   430d3:	48 98                	cltq
   430d5:	c6 84 00 20 df 04 00 	movb   $0x0,0x4df20(%rax,%rax,1)
   430dc:	00 
   430dd:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
   430e1:	48 c1 e8 0c          	shr    $0xc,%rax
   430e5:	48 98                	cltq
   430e7:	0f b6 84 00 21 df 04 	movzbl 0x4df21(%rax,%rax,1),%eax
   430ee:	00 
   430ef:	3c 01                	cmp    $0x1,%al
   430f1:	74 14                	je     43107 <process_free+0x21f>
   430f3:	ba a0 54 04 00       	mov    $0x454a0,%edx
   430f8:	be 55 00 00 00       	mov    $0x55,%esi
   430fd:	bf 0c 54 04 00       	mov    $0x4540c,%edi
   43102:	e8 35 f2 ff ff       	call   4233c <assert_fail>
   43107:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
   4310b:	48 c1 e8 0c          	shr    $0xc,%rax
   4310f:	48 98                	cltq
   43111:	c6 84 00 21 df 04 00 	movb   $0x0,0x4df21(%rax,%rax,1)
   43118:	00 
   43119:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
   4311d:	48 c1 e8 0c          	shr    $0xc,%rax
   43121:	48 98                	cltq
   43123:	c6 84 00 20 df 04 00 	movb   $0x0,0x4df20(%rax,%rax,1)
   4312a:	00 
   4312b:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
   4312f:	48 c1 e8 0c          	shr    $0xc,%rax
   43133:	48 98                	cltq
   43135:	0f b6 84 00 21 df 04 	movzbl 0x4df21(%rax,%rax,1),%eax
   4313c:	00 
   4313d:	3c 01                	cmp    $0x1,%al
   4313f:	74 14                	je     43155 <process_free+0x26d>
   43141:	ba c8 54 04 00       	mov    $0x454c8,%edx
   43146:	be 58 00 00 00       	mov    $0x58,%esi
   4314b:	bf 0c 54 04 00       	mov    $0x4540c,%edi
   43150:	e8 e7 f1 ff ff       	call   4233c <assert_fail>
   43155:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
   43159:	48 c1 e8 0c          	shr    $0xc,%rax
   4315d:	48 98                	cltq
   4315f:	c6 84 00 21 df 04 00 	movb   $0x0,0x4df21(%rax,%rax,1)
   43166:	00 
   43167:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
   4316b:	48 c1 e8 0c          	shr    $0xc,%rax
   4316f:	48 98                	cltq
   43171:	c6 84 00 20 df 04 00 	movb   $0x0,0x4df20(%rax,%rax,1)
   43178:	00 
   43179:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
   4317d:	48 c1 e8 0c          	shr    $0xc,%rax
   43181:	48 98                	cltq
   43183:	0f b6 84 00 21 df 04 	movzbl 0x4df21(%rax,%rax,1),%eax
   4318a:	00 
   4318b:	3c 01                	cmp    $0x1,%al
   4318d:	74 14                	je     431a3 <process_free+0x2bb>
   4318f:	ba f0 54 04 00       	mov    $0x454f0,%edx
   43194:	be 5b 00 00 00       	mov    $0x5b,%esi
   43199:	bf 0c 54 04 00       	mov    $0x4540c,%edi
   4319e:	e8 99 f1 ff ff       	call   4233c <assert_fail>
   431a3:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
   431a7:	48 c1 e8 0c          	shr    $0xc,%rax
   431ab:	48 98                	cltq
   431ad:	c6 84 00 21 df 04 00 	movb   $0x0,0x4df21(%rax,%rax,1)
   431b4:	00 
   431b5:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
   431b9:	48 c1 e8 0c          	shr    $0xc,%rax
   431bd:	48 98                	cltq
   431bf:	c6 84 00 20 df 04 00 	movb   $0x0,0x4df20(%rax,%rax,1)
   431c6:	00 
   431c7:	90                   	nop
   431c8:	c9                   	leave
   431c9:	c3                   	ret

00000000000431ca <process_config_tables>:
   431ca:	55                   	push   %rbp
   431cb:	48 89 e5             	mov    %rsp,%rbp
   431ce:	48 83 ec 40          	sub    $0x40,%rsp
   431d2:	89 7d cc             	mov    %edi,-0x34(%rbp)
   431d5:	8b 45 cc             	mov    -0x34(%rbp),%eax
   431d8:	89 c7                	mov    %eax,%edi
   431da:	e8 f0 fb ff ff       	call   42dcf <palloc>
   431df:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
   431e3:	8b 45 cc             	mov    -0x34(%rbp),%eax
   431e6:	89 c7                	mov    %eax,%edi
   431e8:	e8 e2 fb ff ff       	call   42dcf <palloc>
   431ed:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
   431f1:	8b 45 cc             	mov    -0x34(%rbp),%eax
   431f4:	89 c7                	mov    %eax,%edi
   431f6:	e8 d4 fb ff ff       	call   42dcf <palloc>
   431fb:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
   431ff:	8b 45 cc             	mov    -0x34(%rbp),%eax
   43202:	89 c7                	mov    %eax,%edi
   43204:	e8 c6 fb ff ff       	call   42dcf <palloc>
   43209:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
   4320d:	8b 45 cc             	mov    -0x34(%rbp),%eax
   43210:	89 c7                	mov    %eax,%edi
   43212:	e8 b8 fb ff ff       	call   42dcf <palloc>
   43217:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
   4321b:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
   43220:	74 20                	je     43242 <process_config_tables+0x78>
   43222:	48 83 7d f0 00       	cmpq   $0x0,-0x10(%rbp)
   43227:	74 19                	je     43242 <process_config_tables+0x78>
   43229:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
   4322e:	74 12                	je     43242 <process_config_tables+0x78>
   43230:	48 83 7d e0 00       	cmpq   $0x0,-0x20(%rbp)
   43235:	74 0b                	je     43242 <process_config_tables+0x78>
   43237:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
   4323c:	0f 85 e1 00 00 00    	jne    43323 <process_config_tables+0x159>
   43242:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
   43247:	74 24                	je     4326d <process_config_tables+0xa3>
   43249:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   4324d:	48 c1 e8 0c          	shr    $0xc,%rax
   43251:	48 98                	cltq
   43253:	c6 84 00 20 df 04 00 	movb   $0x0,0x4df20(%rax,%rax,1)
   4325a:	00 
   4325b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   4325f:	48 c1 e8 0c          	shr    $0xc,%rax
   43263:	48 98                	cltq
   43265:	c6 84 00 21 df 04 00 	movb   $0x0,0x4df21(%rax,%rax,1)
   4326c:	00 
   4326d:	48 83 7d f0 00       	cmpq   $0x0,-0x10(%rbp)
   43272:	74 24                	je     43298 <process_config_tables+0xce>
   43274:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   43278:	48 c1 e8 0c          	shr    $0xc,%rax
   4327c:	48 98                	cltq
   4327e:	c6 84 00 20 df 04 00 	movb   $0x0,0x4df20(%rax,%rax,1)
   43285:	00 
   43286:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   4328a:	48 c1 e8 0c          	shr    $0xc,%rax
   4328e:	48 98                	cltq
   43290:	c6 84 00 21 df 04 00 	movb   $0x0,0x4df21(%rax,%rax,1)
   43297:	00 
   43298:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
   4329d:	74 24                	je     432c3 <process_config_tables+0xf9>
   4329f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   432a3:	48 c1 e8 0c          	shr    $0xc,%rax
   432a7:	48 98                	cltq
   432a9:	c6 84 00 20 df 04 00 	movb   $0x0,0x4df20(%rax,%rax,1)
   432b0:	00 
   432b1:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   432b5:	48 c1 e8 0c          	shr    $0xc,%rax
   432b9:	48 98                	cltq
   432bb:	c6 84 00 21 df 04 00 	movb   $0x0,0x4df21(%rax,%rax,1)
   432c2:	00 
   432c3:	48 83 7d e0 00       	cmpq   $0x0,-0x20(%rbp)
   432c8:	74 24                	je     432ee <process_config_tables+0x124>
   432ca:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
   432ce:	48 c1 e8 0c          	shr    $0xc,%rax
   432d2:	48 98                	cltq
   432d4:	c6 84 00 20 df 04 00 	movb   $0x0,0x4df20(%rax,%rax,1)
   432db:	00 
   432dc:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
   432e0:	48 c1 e8 0c          	shr    $0xc,%rax
   432e4:	48 98                	cltq
   432e6:	c6 84 00 21 df 04 00 	movb   $0x0,0x4df21(%rax,%rax,1)
   432ed:	00 
   432ee:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
   432f3:	74 24                	je     43319 <process_config_tables+0x14f>
   432f5:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
   432f9:	48 c1 e8 0c          	shr    $0xc,%rax
   432fd:	48 98                	cltq
   432ff:	c6 84 00 20 df 04 00 	movb   $0x0,0x4df20(%rax,%rax,1)
   43306:	00 
   43307:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
   4330b:	48 c1 e8 0c          	shr    $0xc,%rax
   4330f:	48 98                	cltq
   43311:	c6 84 00 21 df 04 00 	movb   $0x0,0x4df21(%rax,%rax,1)
   43318:	00 
   43319:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
   4331e:	e9 f3 01 00 00       	jmp    43516 <process_config_tables+0x34c>
   43323:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   43327:	ba 00 10 00 00       	mov    $0x1000,%edx
   4332c:	be 00 00 00 00       	mov    $0x0,%esi
   43331:	48 89 c7             	mov    %rax,%rdi
   43334:	e8 c8 06 00 00       	call   43a01 <memset>
   43339:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   4333d:	ba 00 10 00 00       	mov    $0x1000,%edx
   43342:	be 00 00 00 00       	mov    $0x0,%esi
   43347:	48 89 c7             	mov    %rax,%rdi
   4334a:	e8 b2 06 00 00       	call   43a01 <memset>
   4334f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   43353:	ba 00 10 00 00       	mov    $0x1000,%edx
   43358:	be 00 00 00 00       	mov    $0x0,%esi
   4335d:	48 89 c7             	mov    %rax,%rdi
   43360:	e8 9c 06 00 00       	call   43a01 <memset>
   43365:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
   43369:	ba 00 10 00 00       	mov    $0x1000,%edx
   4336e:	be 00 00 00 00       	mov    $0x0,%esi
   43373:	48 89 c7             	mov    %rax,%rdi
   43376:	e8 86 06 00 00       	call   43a01 <memset>
   4337b:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
   4337f:	ba 00 10 00 00       	mov    $0x1000,%edx
   43384:	be 00 00 00 00       	mov    $0x0,%esi
   43389:	48 89 c7             	mov    %rax,%rdi
   4338c:	e8 70 06 00 00       	call   43a01 <memset>
   43391:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   43395:	48 83 c8 07          	or     $0x7,%rax
   43399:	48 89 c2             	mov    %rax,%rdx
   4339c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   433a0:	48 89 10             	mov    %rdx,(%rax)
   433a3:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   433a7:	48 83 c8 07          	or     $0x7,%rax
   433ab:	48 89 c2             	mov    %rax,%rdx
   433ae:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   433b2:	48 89 10             	mov    %rdx,(%rax)
   433b5:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
   433b9:	48 83 c8 07          	or     $0x7,%rax
   433bd:	48 89 c2             	mov    %rax,%rdx
   433c0:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   433c4:	48 89 10             	mov    %rdx,(%rax)
   433c7:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
   433cb:	48 83 c8 07          	or     $0x7,%rax
   433cf:	48 89 c2             	mov    %rax,%rdx
   433d2:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   433d6:	48 89 50 08          	mov    %rdx,0x8(%rax)
   433da:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   433de:	41 b9 00 00 00 00    	mov    $0x0,%r9d
   433e4:	41 b8 03 00 00 00    	mov    $0x3,%r8d
   433ea:	b9 00 00 10 00       	mov    $0x100000,%ecx
   433ef:	ba 00 00 00 00       	mov    $0x0,%edx
   433f4:	be 00 00 00 00       	mov    $0x0,%esi
   433f9:	48 89 c7             	mov    %rax,%rdi
   433fc:	e8 3a f2 ff ff       	call   4263b <virtual_memory_map>
   43401:	85 c0                	test   %eax,%eax
   43403:	75 2f                	jne    43434 <process_config_tables+0x26a>
   43405:	ba 00 80 0b 00       	mov    $0xb8000,%edx
   4340a:	be 00 80 0b 00       	mov    $0xb8000,%esi
   4340f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   43413:	41 b9 00 00 00 00    	mov    $0x0,%r9d
   43419:	41 b8 07 00 00 00    	mov    $0x7,%r8d
   4341f:	b9 00 10 00 00       	mov    $0x1000,%ecx
   43424:	48 89 c7             	mov    %rax,%rdi
   43427:	e8 0f f2 ff ff       	call   4263b <virtual_memory_map>
   4342c:	85 c0                	test   %eax,%eax
   4342e:	0f 84 bb 00 00 00    	je     434ef <process_config_tables+0x325>
   43434:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   43438:	48 c1 e8 0c          	shr    $0xc,%rax
   4343c:	48 98                	cltq
   4343e:	c6 84 00 20 df 04 00 	movb   $0x0,0x4df20(%rax,%rax,1)
   43445:	00 
   43446:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   4344a:	48 c1 e8 0c          	shr    $0xc,%rax
   4344e:	48 98                	cltq
   43450:	c6 84 00 21 df 04 00 	movb   $0x0,0x4df21(%rax,%rax,1)
   43457:	00 
   43458:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   4345c:	48 c1 e8 0c          	shr    $0xc,%rax
   43460:	48 98                	cltq
   43462:	c6 84 00 20 df 04 00 	movb   $0x0,0x4df20(%rax,%rax,1)
   43469:	00 
   4346a:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   4346e:	48 c1 e8 0c          	shr    $0xc,%rax
   43472:	48 98                	cltq
   43474:	c6 84 00 21 df 04 00 	movb   $0x0,0x4df21(%rax,%rax,1)
   4347b:	00 
   4347c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   43480:	48 c1 e8 0c          	shr    $0xc,%rax
   43484:	48 98                	cltq
   43486:	c6 84 00 20 df 04 00 	movb   $0x0,0x4df20(%rax,%rax,1)
   4348d:	00 
   4348e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   43492:	48 c1 e8 0c          	shr    $0xc,%rax
   43496:	48 98                	cltq
   43498:	c6 84 00 21 df 04 00 	movb   $0x0,0x4df21(%rax,%rax,1)
   4349f:	00 
   434a0:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
   434a4:	48 c1 e8 0c          	shr    $0xc,%rax
   434a8:	48 98                	cltq
   434aa:	c6 84 00 20 df 04 00 	movb   $0x0,0x4df20(%rax,%rax,1)
   434b1:	00 
   434b2:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
   434b6:	48 c1 e8 0c          	shr    $0xc,%rax
   434ba:	48 98                	cltq
   434bc:	c6 84 00 21 df 04 00 	movb   $0x0,0x4df21(%rax,%rax,1)
   434c3:	00 
   434c4:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
   434c8:	48 c1 e8 0c          	shr    $0xc,%rax
   434cc:	48 98                	cltq
   434ce:	c6 84 00 20 df 04 00 	movb   $0x0,0x4df20(%rax,%rax,1)
   434d5:	00 
   434d6:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
   434da:	48 c1 e8 0c          	shr    $0xc,%rax
   434de:	48 98                	cltq
   434e0:	c6 84 00 21 df 04 00 	movb   $0x0,0x4df21(%rax,%rax,1)
   434e7:	00 
   434e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
   434ed:	eb 27                	jmp    43516 <process_config_tables+0x34c>
   434ef:	8b 45 cc             	mov    -0x34(%rbp),%eax
   434f2:	48 63 d0             	movslq %eax,%rdx
   434f5:	48 89 d0             	mov    %rdx,%rax
   434f8:	48 c1 e0 04          	shl    $0x4,%rax
   434fc:	48 29 d0             	sub    %rdx,%rax
   434ff:	48 c1 e0 04          	shl    $0x4,%rax
   43503:	48 8d 90 e0 d0 04 00 	lea    0x4d0e0(%rax),%rdx
   4350a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   4350e:	48 89 02             	mov    %rax,(%rdx)
   43511:	b8 00 00 00 00       	mov    $0x0,%eax
   43516:	c9                   	leave
   43517:	c3                   	ret

0000000000043518 <process_load>:
   43518:	55                   	push   %rbp
   43519:	48 89 e5             	mov    %rsp,%rbp
   4351c:	48 83 ec 20          	sub    $0x20,%rsp
   43520:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
   43524:	89 75 e4             	mov    %esi,-0x1c(%rbp)
   43527:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   4352b:	48 89 05 ce 2a 01 00 	mov    %rax,0x12ace(%rip)        # 56000 <palloc_target_proc>
   43532:	8b 4d e4             	mov    -0x1c(%rbp),%ecx
   43535:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   43539:	ba b2 2e 04 00       	mov    $0x42eb2,%edx
   4353e:	89 ce                	mov    %ecx,%esi
   43540:	48 89 c7             	mov    %rax,%rdi
   43543:	e8 ad f5 ff ff       	call   42af5 <program_load>
   43548:	89 45 fc             	mov    %eax,-0x4(%rbp)
   4354b:	8b 45 fc             	mov    -0x4(%rbp),%eax
   4354e:	c9                   	leave
   4354f:	c3                   	ret

0000000000043550 <process_setup_stack>:
   43550:	55                   	push   %rbp
   43551:	48 89 e5             	mov    %rsp,%rbp
   43554:	48 83 ec 20          	sub    $0x20,%rsp
   43558:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
   4355c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   43560:	8b 00                	mov    (%rax),%eax
   43562:	89 c7                	mov    %eax,%edi
   43564:	e8 66 f8 ff ff       	call   42dcf <palloc>
   43569:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
   4356d:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   43571:	48 c7 80 c8 00 00 00 	movq   $0x300000,0xc8(%rax)
   43578:	00 00 30 00 
   4357c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   43580:	48 8b 80 e0 00 00 00 	mov    0xe0(%rax),%rax
   43587:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
   4358b:	41 b9 00 00 00 00    	mov    $0x0,%r9d
   43591:	41 b8 07 00 00 00    	mov    $0x7,%r8d
   43597:	b9 00 10 00 00       	mov    $0x1000,%ecx
   4359c:	be 00 f0 2f 00       	mov    $0x2ff000,%esi
   435a1:	48 89 c7             	mov    %rax,%rdi
   435a4:	e8 92 f0 ff ff       	call   4263b <virtual_memory_map>
   435a9:	90                   	nop
   435aa:	c9                   	leave
   435ab:	c3                   	ret

00000000000435ac <find_free_pid>:
   435ac:	55                   	push   %rbp
   435ad:	48 89 e5             	mov    %rsp,%rbp
   435b0:	48 83 ec 10          	sub    $0x10,%rsp
   435b4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
   435bb:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%rbp)
   435c2:	eb 24                	jmp    435e8 <find_free_pid+0x3c>
   435c4:	8b 45 fc             	mov    -0x4(%rbp),%eax
   435c7:	48 63 d0             	movslq %eax,%rdx
   435ca:	48 89 d0             	mov    %rdx,%rax
   435cd:	48 c1 e0 04          	shl    $0x4,%rax
   435d1:	48 29 d0             	sub    %rdx,%rax
   435d4:	48 c1 e0 04          	shl    $0x4,%rax
   435d8:	48 05 d8 d0 04 00    	add    $0x4d0d8,%rax
   435de:	8b 00                	mov    (%rax),%eax
   435e0:	85 c0                	test   %eax,%eax
   435e2:	74 0c                	je     435f0 <find_free_pid+0x44>
   435e4:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
   435e8:	83 7d fc 0f          	cmpl   $0xf,-0x4(%rbp)
   435ec:	7e d6                	jle    435c4 <find_free_pid+0x18>
   435ee:	eb 01                	jmp    435f1 <find_free_pid+0x45>
   435f0:	90                   	nop
   435f1:	83 7d fc 10          	cmpl   $0x10,-0x4(%rbp)
   435f5:	74 05                	je     435fc <find_free_pid+0x50>
   435f7:	8b 45 fc             	mov    -0x4(%rbp),%eax
   435fa:	eb 05                	jmp    43601 <find_free_pid+0x55>
   435fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
   43601:	c9                   	leave
   43602:	c3                   	ret

0000000000043603 <process_fork>:
   43603:	55                   	push   %rbp
   43604:	48 89 e5             	mov    %rsp,%rbp
   43607:	48 83 ec 40          	sub    $0x40,%rsp
   4360b:	48 89 7d c8          	mov    %rdi,-0x38(%rbp)
   4360f:	b8 00 00 00 00       	mov    $0x0,%eax
   43614:	e8 93 ff ff ff       	call   435ac <find_free_pid>
   43619:	89 45 f4             	mov    %eax,-0xc(%rbp)
   4361c:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%rbp)
   43620:	75 0a                	jne    4362c <process_fork+0x29>
   43622:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
   43627:	e9 67 02 00 00       	jmp    43893 <process_fork+0x290>
   4362c:	8b 45 f4             	mov    -0xc(%rbp),%eax
   4362f:	48 63 d0             	movslq %eax,%rdx
   43632:	48 89 d0             	mov    %rdx,%rax
   43635:	48 c1 e0 04          	shl    $0x4,%rax
   43639:	48 29 d0             	sub    %rdx,%rax
   4363c:	48 c1 e0 04          	shl    $0x4,%rax
   43640:	48 05 00 d0 04 00    	add    $0x4d000,%rax
   43646:	be 00 00 00 00       	mov    $0x0,%esi
   4364b:	48 89 c7             	mov    %rax,%rdi
   4364e:	e8 17 e5 ff ff       	call   41b6a <process_init>
   43653:	8b 45 f4             	mov    -0xc(%rbp),%eax
   43656:	89 c7                	mov    %eax,%edi
   43658:	e8 6d fb ff ff       	call   431ca <process_config_tables>
   4365d:	83 f8 ff             	cmp    $0xffffffff,%eax
   43660:	75 0a                	jne    4366c <process_fork+0x69>
   43662:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
   43667:	e9 27 02 00 00       	jmp    43893 <process_fork+0x290>
   4366c:	48 c7 45 f8 00 00 10 	movq   $0x100000,-0x8(%rbp)
   43673:	00 
   43674:	e9 79 01 00 00       	jmp    437f2 <process_fork+0x1ef>
   43679:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
   4367d:	8b 00                	mov    (%rax),%eax
   4367f:	48 63 d0             	movslq %eax,%rdx
   43682:	48 89 d0             	mov    %rdx,%rax
   43685:	48 c1 e0 04          	shl    $0x4,%rax
   43689:	48 29 d0             	sub    %rdx,%rax
   4368c:	48 c1 e0 04          	shl    $0x4,%rax
   43690:	48 05 e0 d0 04 00    	add    $0x4d0e0,%rax
   43696:	48 8b 08             	mov    (%rax),%rcx
   43699:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
   4369d:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
   436a1:	48 89 ce             	mov    %rcx,%rsi
   436a4:	48 89 c7             	mov    %rax,%rdi
   436a7:	e8 52 f3 ff ff       	call   429fe <virtual_memory_lookup>
   436ac:	8b 45 e0             	mov    -0x20(%rbp),%eax
   436af:	48 98                	cltq
   436b1:	83 e0 07             	and    $0x7,%eax
   436b4:	48 83 f8 07          	cmp    $0x7,%rax
   436b8:	0f 85 a1 00 00 00    	jne    4375f <process_fork+0x15c>
   436be:	8b 45 f4             	mov    -0xc(%rbp),%eax
   436c1:	89 c7                	mov    %eax,%edi
   436c3:	e8 07 f7 ff ff       	call   42dcf <palloc>
   436c8:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
   436cc:	48 83 7d e8 00       	cmpq   $0x0,-0x18(%rbp)
   436d1:	75 14                	jne    436e7 <process_fork+0xe4>
   436d3:	8b 45 f4             	mov    -0xc(%rbp),%eax
   436d6:	89 c7                	mov    %eax,%edi
   436d8:	e8 0b f8 ff ff       	call   42ee8 <process_free>
   436dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
   436e2:	e9 ac 01 00 00       	jmp    43893 <process_fork+0x290>
   436e7:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
   436eb:	48 89 c1             	mov    %rax,%rcx
   436ee:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   436f2:	ba 00 10 00 00       	mov    $0x1000,%edx
   436f7:	48 89 ce             	mov    %rcx,%rsi
   436fa:	48 89 c7             	mov    %rax,%rdi
   436fd:	e8 01 02 00 00       	call   43903 <memcpy>
   43702:	48 8b 7d e8          	mov    -0x18(%rbp),%rdi
   43706:	8b 45 f4             	mov    -0xc(%rbp),%eax
   43709:	48 63 d0             	movslq %eax,%rdx
   4370c:	48 89 d0             	mov    %rdx,%rax
   4370f:	48 c1 e0 04          	shl    $0x4,%rax
   43713:	48 29 d0             	sub    %rdx,%rax
   43716:	48 c1 e0 04          	shl    $0x4,%rax
   4371a:	48 05 e0 d0 04 00    	add    $0x4d0e0,%rax
   43720:	48 8b 00             	mov    (%rax),%rax
   43723:	48 8b 75 f8          	mov    -0x8(%rbp),%rsi
   43727:	41 b9 00 00 00 00    	mov    $0x0,%r9d
   4372d:	41 b8 07 00 00 00    	mov    $0x7,%r8d
   43733:	b9 00 10 00 00       	mov    $0x1000,%ecx
   43738:	48 89 fa             	mov    %rdi,%rdx
   4373b:	48 89 c7             	mov    %rax,%rdi
   4373e:	e8 f8 ee ff ff       	call   4263b <virtual_memory_map>
   43743:	85 c0                	test   %eax,%eax
   43745:	0f 84 9f 00 00 00    	je     437ea <process_fork+0x1e7>
   4374b:	8b 45 f4             	mov    -0xc(%rbp),%eax
   4374e:	89 c7                	mov    %eax,%edi
   43750:	e8 93 f7 ff ff       	call   42ee8 <process_free>
   43755:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
   4375a:	e9 34 01 00 00       	jmp    43893 <process_fork+0x290>
   4375f:	8b 45 e0             	mov    -0x20(%rbp),%eax
   43762:	48 98                	cltq
   43764:	83 e0 05             	and    $0x5,%eax
   43767:	48 83 f8 05          	cmp    $0x5,%rax
   4376b:	75 7d                	jne    437ea <process_fork+0x1e7>
   4376d:	48 8b 7d d8          	mov    -0x28(%rbp),%rdi
   43771:	8b 45 f4             	mov    -0xc(%rbp),%eax
   43774:	48 63 d0             	movslq %eax,%rdx
   43777:	48 89 d0             	mov    %rdx,%rax
   4377a:	48 c1 e0 04          	shl    $0x4,%rax
   4377e:	48 29 d0             	sub    %rdx,%rax
   43781:	48 c1 e0 04          	shl    $0x4,%rax
   43785:	48 05 e0 d0 04 00    	add    $0x4d0e0,%rax
   4378b:	48 8b 00             	mov    (%rax),%rax
   4378e:	48 8b 75 f8          	mov    -0x8(%rbp),%rsi
   43792:	41 b9 00 00 00 00    	mov    $0x0,%r9d
   43798:	41 b8 05 00 00 00    	mov    $0x5,%r8d
   4379e:	b9 00 10 00 00       	mov    $0x1000,%ecx
   437a3:	48 89 fa             	mov    %rdi,%rdx
   437a6:	48 89 c7             	mov    %rax,%rdi
   437a9:	e8 8d ee ff ff       	call   4263b <virtual_memory_map>
   437ae:	85 c0                	test   %eax,%eax
   437b0:	74 14                	je     437c6 <process_fork+0x1c3>
   437b2:	8b 45 f4             	mov    -0xc(%rbp),%eax
   437b5:	89 c7                	mov    %eax,%edi
   437b7:	e8 2c f7 ff ff       	call   42ee8 <process_free>
   437bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
   437c1:	e9 cd 00 00 00       	jmp    43893 <process_fork+0x290>
   437c6:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
   437ca:	48 c1 e8 0c          	shr    $0xc,%rax
   437ce:	89 c2                	mov    %eax,%edx
   437d0:	48 63 c2             	movslq %edx,%rax
   437d3:	0f b6 84 00 21 df 04 	movzbl 0x4df21(%rax,%rax,1),%eax
   437da:	00 
   437db:	83 c0 01             	add    $0x1,%eax
   437de:	89 c1                	mov    %eax,%ecx
   437e0:	48 63 c2             	movslq %edx,%rax
   437e3:	88 8c 00 21 df 04 00 	mov    %cl,0x4df21(%rax,%rax,1)
   437ea:	48 81 45 f8 00 10 00 	addq   $0x1000,-0x8(%rbp)
   437f1:	00 
   437f2:	48 81 7d f8 ff ff 2f 	cmpq   $0x2fffff,-0x8(%rbp)
   437f9:	00 
   437fa:	0f 86 79 fe ff ff    	jbe    43679 <process_fork+0x76>
   43800:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
   43804:	8b 08                	mov    (%rax),%ecx
   43806:	8b 45 f4             	mov    -0xc(%rbp),%eax
   43809:	48 63 d0             	movslq %eax,%rdx
   4380c:	48 89 d0             	mov    %rdx,%rax
   4380f:	48 c1 e0 04          	shl    $0x4,%rax
   43813:	48 29 d0             	sub    %rdx,%rax
   43816:	48 c1 e0 04          	shl    $0x4,%rax
   4381a:	48 8d b0 10 d0 04 00 	lea    0x4d010(%rax),%rsi
   43821:	48 63 d1             	movslq %ecx,%rdx
   43824:	48 89 d0             	mov    %rdx,%rax
   43827:	48 c1 e0 04          	shl    $0x4,%rax
   4382b:	48 29 d0             	sub    %rdx,%rax
   4382e:	48 c1 e0 04          	shl    $0x4,%rax
   43832:	48 8d 90 10 d0 04 00 	lea    0x4d010(%rax),%rdx
   43839:	48 8d 46 08          	lea    0x8(%rsi),%rax
   4383d:	48 83 c2 08          	add    $0x8,%rdx
   43841:	b9 18 00 00 00       	mov    $0x18,%ecx
   43846:	48 89 c7             	mov    %rax,%rdi
   43849:	48 89 d6             	mov    %rdx,%rsi
   4384c:	f3 48 a5             	rep movsq (%rsi),(%rdi)
   4384f:	8b 45 f4             	mov    -0xc(%rbp),%eax
   43852:	48 63 d0             	movslq %eax,%rdx
   43855:	48 89 d0             	mov    %rdx,%rax
   43858:	48 c1 e0 04          	shl    $0x4,%rax
   4385c:	48 29 d0             	sub    %rdx,%rax
   4385f:	48 c1 e0 04          	shl    $0x4,%rax
   43863:	48 05 18 d0 04 00    	add    $0x4d018,%rax
   43869:	48 c7 00 00 00 00 00 	movq   $0x0,(%rax)
   43870:	8b 45 f4             	mov    -0xc(%rbp),%eax
   43873:	48 63 d0             	movslq %eax,%rdx
   43876:	48 89 d0             	mov    %rdx,%rax
   43879:	48 c1 e0 04          	shl    $0x4,%rax
   4387d:	48 29 d0             	sub    %rdx,%rax
   43880:	48 c1 e0 04          	shl    $0x4,%rax
   43884:	48 05 d8 d0 04 00    	add    $0x4d0d8,%rax
   4388a:	c7 00 01 00 00 00    	movl   $0x1,(%rax)
   43890:	8b 45 f4             	mov    -0xc(%rbp),%eax
   43893:	c9                   	leave
   43894:	c3                   	ret

0000000000043895 <process_page_alloc>:
   43895:	55                   	push   %rbp
   43896:	48 89 e5             	mov    %rsp,%rbp
   43899:	48 83 ec 20          	sub    $0x20,%rsp
   4389d:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
   438a1:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
   438a5:	48 81 7d e0 ff ff 0f 	cmpq   $0xfffff,-0x20(%rbp)
   438ac:	00 
   438ad:	77 07                	ja     438b6 <process_page_alloc+0x21>
   438af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
   438b4:	eb 4b                	jmp    43901 <process_page_alloc+0x6c>
   438b6:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   438ba:	8b 00                	mov    (%rax),%eax
   438bc:	89 c7                	mov    %eax,%edi
   438be:	e8 0c f5 ff ff       	call   42dcf <palloc>
   438c3:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
   438c7:	48 83 7d f8 00       	cmpq   $0x0,-0x8(%rbp)
   438cc:	74 2e                	je     438fc <process_page_alloc+0x67>
   438ce:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
   438d2:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   438d6:	48 8b 80 e0 00 00 00 	mov    0xe0(%rax),%rax
   438dd:	48 8b 75 e0          	mov    -0x20(%rbp),%rsi
   438e1:	41 b9 00 00 00 00    	mov    $0x0,%r9d
   438e7:	41 b8 07 00 00 00    	mov    $0x7,%r8d
   438ed:	b9 00 10 00 00       	mov    $0x1000,%ecx
   438f2:	48 89 c7             	mov    %rax,%rdi
   438f5:	e8 41 ed ff ff       	call   4263b <virtual_memory_map>
   438fa:	eb 05                	jmp    43901 <process_page_alloc+0x6c>
   438fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
   43901:	c9                   	leave
   43902:	c3                   	ret

0000000000043903 <memcpy>:


// memcpy, memmove, memset, strcmp, strlen, strnlen
//    We must provide our own implementations.

void* memcpy(void* dst, const void* src, size_t n) {
   43903:	55                   	push   %rbp
   43904:	48 89 e5             	mov    %rsp,%rbp
   43907:	48 83 ec 28          	sub    $0x28,%rsp
   4390b:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
   4390f:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
   43913:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
    const char* s = (const char*) src;
   43917:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
   4391b:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    for (char* d = (char*) dst; n > 0; --n, ++s, ++d) {
   4391f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   43923:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
   43927:	eb 1c                	jmp    43945 <memcpy+0x42>
        *d = *s;
   43929:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   4392d:	0f b6 10             	movzbl (%rax),%edx
   43930:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   43934:	88 10                	mov    %dl,(%rax)
    for (char* d = (char*) dst; n > 0; --n, ++s, ++d) {
   43936:	48 83 6d d8 01       	subq   $0x1,-0x28(%rbp)
   4393b:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
   43940:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
   43945:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
   4394a:	75 dd                	jne    43929 <memcpy+0x26>
    }
    return dst;
   4394c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
   43950:	c9                   	leave
   43951:	c3                   	ret

0000000000043952 <memmove>:

void* memmove(void* dst, const void* src, size_t n) {
   43952:	55                   	push   %rbp
   43953:	48 89 e5             	mov    %rsp,%rbp
   43956:	48 83 ec 28          	sub    $0x28,%rsp
   4395a:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
   4395e:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
   43962:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
    const char* s = (const char*) src;
   43966:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
   4396a:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    char* d = (char*) dst;
   4396e:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   43972:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
    if (s < d && s + n > d) {
   43976:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   4397a:	48 3b 45 f0          	cmp    -0x10(%rbp),%rax
   4397e:	73 6a                	jae    439ea <memmove+0x98>
   43980:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
   43984:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
   43988:	48 01 d0             	add    %rdx,%rax
   4398b:	48 39 45 f0          	cmp    %rax,-0x10(%rbp)
   4398f:	73 59                	jae    439ea <memmove+0x98>
        s += n, d += n;
   43991:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
   43995:	48 01 45 f8          	add    %rax,-0x8(%rbp)
   43999:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
   4399d:	48 01 45 f0          	add    %rax,-0x10(%rbp)
        while (n-- > 0) {
   439a1:	eb 17                	jmp    439ba <memmove+0x68>
            *--d = *--s;
   439a3:	48 83 6d f8 01       	subq   $0x1,-0x8(%rbp)
   439a8:	48 83 6d f0 01       	subq   $0x1,-0x10(%rbp)
   439ad:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   439b1:	0f b6 10             	movzbl (%rax),%edx
   439b4:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   439b8:	88 10                	mov    %dl,(%rax)
        while (n-- > 0) {
   439ba:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
   439be:	48 8d 50 ff          	lea    -0x1(%rax),%rdx
   439c2:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
   439c6:	48 85 c0             	test   %rax,%rax
   439c9:	75 d8                	jne    439a3 <memmove+0x51>
    if (s < d && s + n > d) {
   439cb:	eb 2e                	jmp    439fb <memmove+0xa9>
        }
    } else {
        while (n-- > 0) {
            *d++ = *s++;
   439cd:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
   439d1:	48 8d 42 01          	lea    0x1(%rdx),%rax
   439d5:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
   439d9:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   439dd:	48 8d 48 01          	lea    0x1(%rax),%rcx
   439e1:	48 89 4d f0          	mov    %rcx,-0x10(%rbp)
   439e5:	0f b6 12             	movzbl (%rdx),%edx
   439e8:	88 10                	mov    %dl,(%rax)
        while (n-- > 0) {
   439ea:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
   439ee:	48 8d 50 ff          	lea    -0x1(%rax),%rdx
   439f2:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
   439f6:	48 85 c0             	test   %rax,%rax
   439f9:	75 d2                	jne    439cd <memmove+0x7b>
        }
    }
    return dst;
   439fb:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
   439ff:	c9                   	leave
   43a00:	c3                   	ret

0000000000043a01 <memset>:

void* memset(void* v, int c, size_t n) {
   43a01:	55                   	push   %rbp
   43a02:	48 89 e5             	mov    %rsp,%rbp
   43a05:	48 83 ec 28          	sub    $0x28,%rsp
   43a09:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
   43a0d:	89 75 e4             	mov    %esi,-0x1c(%rbp)
   43a10:	48 89 55 d8          	mov    %rdx,-0x28(%rbp)
    for (char* p = (char*) v; n > 0; ++p, --n) {
   43a14:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   43a18:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
   43a1c:	eb 15                	jmp    43a33 <memset+0x32>
        *p = c;
   43a1e:	8b 45 e4             	mov    -0x1c(%rbp),%eax
   43a21:	89 c2                	mov    %eax,%edx
   43a23:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   43a27:	88 10                	mov    %dl,(%rax)
    for (char* p = (char*) v; n > 0; ++p, --n) {
   43a29:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
   43a2e:	48 83 6d d8 01       	subq   $0x1,-0x28(%rbp)
   43a33:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
   43a38:	75 e4                	jne    43a1e <memset+0x1d>
    }
    return v;
   43a3a:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
   43a3e:	c9                   	leave
   43a3f:	c3                   	ret

0000000000043a40 <strlen>:

size_t strlen(const char* s) {
   43a40:	55                   	push   %rbp
   43a41:	48 89 e5             	mov    %rsp,%rbp
   43a44:	48 83 ec 18          	sub    $0x18,%rsp
   43a48:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
    size_t n;
    for (n = 0; *s != '\0'; ++s) {
   43a4c:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
   43a53:	00 
   43a54:	eb 0a                	jmp    43a60 <strlen+0x20>
        ++n;
   43a56:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
    for (n = 0; *s != '\0'; ++s) {
   43a5b:	48 83 45 e8 01       	addq   $0x1,-0x18(%rbp)
   43a60:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   43a64:	0f b6 00             	movzbl (%rax),%eax
   43a67:	84 c0                	test   %al,%al
   43a69:	75 eb                	jne    43a56 <strlen+0x16>
    }
    return n;
   43a6b:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
   43a6f:	c9                   	leave
   43a70:	c3                   	ret

0000000000043a71 <strnlen>:

size_t strnlen(const char* s, size_t maxlen) {
   43a71:	55                   	push   %rbp
   43a72:	48 89 e5             	mov    %rsp,%rbp
   43a75:	48 83 ec 20          	sub    $0x20,%rsp
   43a79:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
   43a7d:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
    size_t n;
    for (n = 0; n != maxlen && *s != '\0'; ++s) {
   43a81:	48 c7 45 f8 00 00 00 	movq   $0x0,-0x8(%rbp)
   43a88:	00 
   43a89:	eb 0a                	jmp    43a95 <strnlen+0x24>
        ++n;
   43a8b:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
    for (n = 0; n != maxlen && *s != '\0'; ++s) {
   43a90:	48 83 45 e8 01       	addq   $0x1,-0x18(%rbp)
   43a95:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   43a99:	48 3b 45 e0          	cmp    -0x20(%rbp),%rax
   43a9d:	74 0b                	je     43aaa <strnlen+0x39>
   43a9f:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   43aa3:	0f b6 00             	movzbl (%rax),%eax
   43aa6:	84 c0                	test   %al,%al
   43aa8:	75 e1                	jne    43a8b <strnlen+0x1a>
    }
    return n;
   43aaa:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
}
   43aae:	c9                   	leave
   43aaf:	c3                   	ret

0000000000043ab0 <strcpy>:

char* strcpy(char* dst, const char* src) {
   43ab0:	55                   	push   %rbp
   43ab1:	48 89 e5             	mov    %rsp,%rbp
   43ab4:	48 83 ec 20          	sub    $0x20,%rsp
   43ab8:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
   43abc:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
    char* d = dst;
   43ac0:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   43ac4:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    do {
        *d++ = *src++;
   43ac8:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
   43acc:	48 8d 42 01          	lea    0x1(%rdx),%rax
   43ad0:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
   43ad4:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   43ad8:	48 8d 48 01          	lea    0x1(%rax),%rcx
   43adc:	48 89 4d f8          	mov    %rcx,-0x8(%rbp)
   43ae0:	0f b6 12             	movzbl (%rdx),%edx
   43ae3:	88 10                	mov    %dl,(%rax)
    } while (d[-1]);
   43ae5:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   43ae9:	48 83 e8 01          	sub    $0x1,%rax
   43aed:	0f b6 00             	movzbl (%rax),%eax
   43af0:	84 c0                	test   %al,%al
   43af2:	75 d4                	jne    43ac8 <strcpy+0x18>
    return dst;
   43af4:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
   43af8:	c9                   	leave
   43af9:	c3                   	ret

0000000000043afa <strcmp>:

int strcmp(const char* a, const char* b) {
   43afa:	55                   	push   %rbp
   43afb:	48 89 e5             	mov    %rsp,%rbp
   43afe:	48 83 ec 10          	sub    $0x10,%rsp
   43b02:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
   43b06:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
    while (*a && *b && *a == *b) {
   43b0a:	eb 0a                	jmp    43b16 <strcmp+0x1c>
        ++a, ++b;
   43b0c:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
   43b11:	48 83 45 f0 01       	addq   $0x1,-0x10(%rbp)
    while (*a && *b && *a == *b) {
   43b16:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   43b1a:	0f b6 00             	movzbl (%rax),%eax
   43b1d:	84 c0                	test   %al,%al
   43b1f:	74 1d                	je     43b3e <strcmp+0x44>
   43b21:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   43b25:	0f b6 00             	movzbl (%rax),%eax
   43b28:	84 c0                	test   %al,%al
   43b2a:	74 12                	je     43b3e <strcmp+0x44>
   43b2c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   43b30:	0f b6 10             	movzbl (%rax),%edx
   43b33:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   43b37:	0f b6 00             	movzbl (%rax),%eax
   43b3a:	38 c2                	cmp    %al,%dl
   43b3c:	74 ce                	je     43b0c <strcmp+0x12>
    }
    return ((unsigned char) *a > (unsigned char) *b)
   43b3e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   43b42:	0f b6 00             	movzbl (%rax),%eax
   43b45:	89 c2                	mov    %eax,%edx
   43b47:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   43b4b:	0f b6 00             	movzbl (%rax),%eax
   43b4e:	38 d0                	cmp    %dl,%al
   43b50:	0f 92 c0             	setb   %al
   43b53:	0f b6 d0             	movzbl %al,%edx
        - ((unsigned char) *a < (unsigned char) *b);
   43b56:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   43b5a:	0f b6 00             	movzbl (%rax),%eax
   43b5d:	89 c1                	mov    %eax,%ecx
   43b5f:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   43b63:	0f b6 00             	movzbl (%rax),%eax
   43b66:	38 c1                	cmp    %al,%cl
   43b68:	0f 92 c0             	setb   %al
   43b6b:	0f b6 c0             	movzbl %al,%eax
   43b6e:	29 c2                	sub    %eax,%edx
   43b70:	89 d0                	mov    %edx,%eax
}
   43b72:	c9                   	leave
   43b73:	c3                   	ret

0000000000043b74 <strchr>:

char* strchr(const char* s, int c) {
   43b74:	55                   	push   %rbp
   43b75:	48 89 e5             	mov    %rsp,%rbp
   43b78:	48 83 ec 10          	sub    $0x10,%rsp
   43b7c:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
   43b80:	89 75 f4             	mov    %esi,-0xc(%rbp)
    while (*s && *s != (char) c) {
   43b83:	eb 05                	jmp    43b8a <strchr+0x16>
        ++s;
   43b85:	48 83 45 f8 01       	addq   $0x1,-0x8(%rbp)
    while (*s && *s != (char) c) {
   43b8a:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   43b8e:	0f b6 00             	movzbl (%rax),%eax
   43b91:	84 c0                	test   %al,%al
   43b93:	74 0e                	je     43ba3 <strchr+0x2f>
   43b95:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   43b99:	0f b6 00             	movzbl (%rax),%eax
   43b9c:	8b 55 f4             	mov    -0xc(%rbp),%edx
   43b9f:	38 d0                	cmp    %dl,%al
   43ba1:	75 e2                	jne    43b85 <strchr+0x11>
    }
    if (*s == (char) c) {
   43ba3:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   43ba7:	0f b6 00             	movzbl (%rax),%eax
   43baa:	8b 55 f4             	mov    -0xc(%rbp),%edx
   43bad:	38 d0                	cmp    %dl,%al
   43baf:	75 06                	jne    43bb7 <strchr+0x43>
        return (char*) s;
   43bb1:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   43bb5:	eb 05                	jmp    43bbc <strchr+0x48>
    } else {
        return NULL;
   43bb7:	b8 00 00 00 00       	mov    $0x0,%eax
    }
}
   43bbc:	c9                   	leave
   43bbd:	c3                   	ret

0000000000043bbe <rand>:
// rand, srand

static int rand_seed_set;
static unsigned rand_seed;

int rand(void) {
   43bbe:	55                   	push   %rbp
   43bbf:	48 89 e5             	mov    %rsp,%rbp
    if (!rand_seed_set) {
   43bc2:	8b 05 40 24 01 00    	mov    0x12440(%rip),%eax        # 56008 <rand_seed_set>
   43bc8:	85 c0                	test   %eax,%eax
   43bca:	75 0a                	jne    43bd6 <rand+0x18>
        srand(819234718U);
   43bcc:	bf 9e 87 d4 30       	mov    $0x30d4879e,%edi
   43bd1:	e8 24 00 00 00       	call   43bfa <srand>
    }
    rand_seed = rand_seed * 1664525U + 1013904223U;
   43bd6:	8b 05 30 24 01 00    	mov    0x12430(%rip),%eax        # 5600c <rand_seed>
   43bdc:	69 c0 0d 66 19 00    	imul   $0x19660d,%eax,%eax
   43be2:	05 5f f3 6e 3c       	add    $0x3c6ef35f,%eax
   43be7:	89 05 1f 24 01 00    	mov    %eax,0x1241f(%rip)        # 5600c <rand_seed>
    return rand_seed & RAND_MAX;
   43bed:	8b 05 19 24 01 00    	mov    0x12419(%rip),%eax        # 5600c <rand_seed>
   43bf3:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
}
   43bf8:	5d                   	pop    %rbp
   43bf9:	c3                   	ret

0000000000043bfa <srand>:

void srand(unsigned seed) {
   43bfa:	55                   	push   %rbp
   43bfb:	48 89 e5             	mov    %rsp,%rbp
   43bfe:	48 83 ec 08          	sub    $0x8,%rsp
   43c02:	89 7d fc             	mov    %edi,-0x4(%rbp)
    rand_seed = seed;
   43c05:	8b 45 fc             	mov    -0x4(%rbp),%eax
   43c08:	89 05 fe 23 01 00    	mov    %eax,0x123fe(%rip)        # 5600c <rand_seed>
    rand_seed_set = 1;
   43c0e:	c7 05 f0 23 01 00 01 	movl   $0x1,0x123f0(%rip)        # 56008 <rand_seed_set>
   43c15:	00 00 00 
}
   43c18:	90                   	nop
   43c19:	c9                   	leave
   43c1a:	c3                   	ret

0000000000043c1b <fill_numbuf>:
//    Print a message onto the console, starting at the given cursor position.

// snprintf, vsnprintf
//    Format a string into a buffer.

static char* fill_numbuf(char* numbuf_end, unsigned long val, int base) {
   43c1b:	55                   	push   %rbp
   43c1c:	48 89 e5             	mov    %rsp,%rbp
   43c1f:	48 83 ec 28          	sub    $0x28,%rsp
   43c23:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
   43c27:	48 89 75 e0          	mov    %rsi,-0x20(%rbp)
   43c2b:	89 55 dc             	mov    %edx,-0x24(%rbp)
    static const char upper_digits[] = "0123456789ABCDEF";
    static const char lower_digits[] = "0123456789abcdef";

    const char* digits = upper_digits;
   43c2e:	48 c7 45 f8 40 55 04 	movq   $0x45540,-0x8(%rbp)
   43c35:	00 
    if (base < 0) {
   43c36:	83 7d dc 00          	cmpl   $0x0,-0x24(%rbp)
   43c3a:	79 0b                	jns    43c47 <fill_numbuf+0x2c>
        digits = lower_digits;
   43c3c:	48 c7 45 f8 60 55 04 	movq   $0x45560,-0x8(%rbp)
   43c43:	00 
        base = -base;
   43c44:	f7 5d dc             	negl   -0x24(%rbp)
    }

    *--numbuf_end = '\0';
   43c47:	48 83 6d e8 01       	subq   $0x1,-0x18(%rbp)
   43c4c:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   43c50:	c6 00 00             	movb   $0x0,(%rax)
    do {
        *--numbuf_end = digits[val % base];
   43c53:	8b 45 dc             	mov    -0x24(%rbp),%eax
   43c56:	48 63 c8             	movslq %eax,%rcx
   43c59:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
   43c5d:	ba 00 00 00 00       	mov    $0x0,%edx
   43c62:	48 f7 f1             	div    %rcx
   43c65:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   43c69:	48 01 d0             	add    %rdx,%rax
   43c6c:	48 83 6d e8 01       	subq   $0x1,-0x18(%rbp)
   43c71:	0f b6 10             	movzbl (%rax),%edx
   43c74:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   43c78:	88 10                	mov    %dl,(%rax)
        val /= base;
   43c7a:	8b 45 dc             	mov    -0x24(%rbp),%eax
   43c7d:	48 63 f0             	movslq %eax,%rsi
   43c80:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
   43c84:	ba 00 00 00 00       	mov    $0x0,%edx
   43c89:	48 f7 f6             	div    %rsi
   43c8c:	48 89 45 e0          	mov    %rax,-0x20(%rbp)
    } while (val != 0);
   43c90:	48 83 7d e0 00       	cmpq   $0x0,-0x20(%rbp)
   43c95:	75 bc                	jne    43c53 <fill_numbuf+0x38>
    return numbuf_end;
   43c97:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
}
   43c9b:	c9                   	leave
   43c9c:	c3                   	ret

0000000000043c9d <printer_vprintf>:
#define FLAG_NUMERIC            (1<<5)
#define FLAG_SIGNED             (1<<6)
#define FLAG_NEGATIVE           (1<<7)
#define FLAG_ALT2               (1<<8)

void printer_vprintf(printer* p, int color, const char* format, va_list val) {
   43c9d:	55                   	push   %rbp
   43c9e:	48 89 e5             	mov    %rsp,%rbp
   43ca1:	53                   	push   %rbx
   43ca2:	48 81 ec 98 00 00 00 	sub    $0x98,%rsp
   43ca9:	48 89 bd 78 ff ff ff 	mov    %rdi,-0x88(%rbp)
   43cb0:	89 b5 74 ff ff ff    	mov    %esi,-0x8c(%rbp)
   43cb6:	48 89 95 68 ff ff ff 	mov    %rdx,-0x98(%rbp)
   43cbd:	48 89 8d 60 ff ff ff 	mov    %rcx,-0xa0(%rbp)
#define NUMBUFSIZ 24
    char numbuf[NUMBUFSIZ];

    for (; *format; ++format) {
   43cc4:	e9 32 0a 00 00       	jmp    446fb <printer_vprintf+0xa5e>
        if (*format != '%') {
   43cc9:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
   43cd0:	0f b6 00             	movzbl (%rax),%eax
   43cd3:	3c 25                	cmp    $0x25,%al
   43cd5:	74 31                	je     43d08 <printer_vprintf+0x6b>
            p->putc(p, *format, color);
   43cd7:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
   43cde:	4c 8b 00             	mov    (%rax),%r8
   43ce1:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
   43ce8:	0f b6 00             	movzbl (%rax),%eax
   43ceb:	8b 95 74 ff ff ff    	mov    -0x8c(%rbp),%edx
   43cf1:	0f b6 c8             	movzbl %al,%ecx
   43cf4:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
   43cfb:	89 ce                	mov    %ecx,%esi
   43cfd:	48 89 c7             	mov    %rax,%rdi
   43d00:	41 ff d0             	call   *%r8
            continue;
   43d03:	e9 eb 09 00 00       	jmp    446f3 <printer_vprintf+0xa56>
        }

        // process flags
        int flags = 0;
   43d08:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%rbp)
        for (++format; *format; ++format) {
   43d0f:	48 83 85 68 ff ff ff 	addq   $0x1,-0x98(%rbp)
   43d16:	01 
   43d17:	eb 44                	jmp    43d5d <printer_vprintf+0xc0>
            const char* flagc = strchr(flag_chars, *format);
   43d19:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
   43d20:	0f b6 00             	movzbl (%rax),%eax
   43d23:	0f be c0             	movsbl %al,%eax
   43d26:	89 c6                	mov    %eax,%esi
   43d28:	bf 20 55 04 00       	mov    $0x45520,%edi
   43d2d:	e8 42 fe ff ff       	call   43b74 <strchr>
   43d32:	48 89 45 a8          	mov    %rax,-0x58(%rbp)
            if (flagc) {
   43d36:	48 83 7d a8 00       	cmpq   $0x0,-0x58(%rbp)
   43d3b:	74 30                	je     43d6d <printer_vprintf+0xd0>
                flags |= 1 << (flagc - flag_chars);
   43d3d:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
   43d41:	48 2d 20 55 04 00    	sub    $0x45520,%rax
   43d47:	ba 01 00 00 00       	mov    $0x1,%edx
   43d4c:	89 c1                	mov    %eax,%ecx
   43d4e:	d3 e2                	shl    %cl,%edx
   43d50:	89 d0                	mov    %edx,%eax
   43d52:	09 45 ec             	or     %eax,-0x14(%rbp)
        for (++format; *format; ++format) {
   43d55:	48 83 85 68 ff ff ff 	addq   $0x1,-0x98(%rbp)
   43d5c:	01 
   43d5d:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
   43d64:	0f b6 00             	movzbl (%rax),%eax
   43d67:	84 c0                	test   %al,%al
   43d69:	75 ae                	jne    43d19 <printer_vprintf+0x7c>
   43d6b:	eb 01                	jmp    43d6e <printer_vprintf+0xd1>
            } else {
                break;
   43d6d:	90                   	nop
            }
        }

        // process width
        int width = -1;
   43d6e:	c7 45 e8 ff ff ff ff 	movl   $0xffffffff,-0x18(%rbp)
        if (*format >= '1' && *format <= '9') {
   43d75:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
   43d7c:	0f b6 00             	movzbl (%rax),%eax
   43d7f:	3c 30                	cmp    $0x30,%al
   43d81:	7e 67                	jle    43dea <printer_vprintf+0x14d>
   43d83:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
   43d8a:	0f b6 00             	movzbl (%rax),%eax
   43d8d:	3c 39                	cmp    $0x39,%al
   43d8f:	7f 59                	jg     43dea <printer_vprintf+0x14d>
            for (width = 0; *format >= '0' && *format <= '9'; ) {
   43d91:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%rbp)
   43d98:	eb 2e                	jmp    43dc8 <printer_vprintf+0x12b>
                width = 10 * width + *format++ - '0';
   43d9a:	8b 55 e8             	mov    -0x18(%rbp),%edx
   43d9d:	89 d0                	mov    %edx,%eax
   43d9f:	c1 e0 02             	shl    $0x2,%eax
   43da2:	01 d0                	add    %edx,%eax
   43da4:	01 c0                	add    %eax,%eax
   43da6:	89 c1                	mov    %eax,%ecx
   43da8:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
   43daf:	48 8d 50 01          	lea    0x1(%rax),%rdx
   43db3:	48 89 95 68 ff ff ff 	mov    %rdx,-0x98(%rbp)
   43dba:	0f b6 00             	movzbl (%rax),%eax
   43dbd:	0f be c0             	movsbl %al,%eax
   43dc0:	01 c8                	add    %ecx,%eax
   43dc2:	83 e8 30             	sub    $0x30,%eax
   43dc5:	89 45 e8             	mov    %eax,-0x18(%rbp)
            for (width = 0; *format >= '0' && *format <= '9'; ) {
   43dc8:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
   43dcf:	0f b6 00             	movzbl (%rax),%eax
   43dd2:	3c 2f                	cmp    $0x2f,%al
   43dd4:	0f 8e 85 00 00 00    	jle    43e5f <printer_vprintf+0x1c2>
   43dda:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
   43de1:	0f b6 00             	movzbl (%rax),%eax
   43de4:	3c 39                	cmp    $0x39,%al
   43de6:	7e b2                	jle    43d9a <printer_vprintf+0xfd>
        if (*format >= '1' && *format <= '9') {
   43de8:	eb 75                	jmp    43e5f <printer_vprintf+0x1c2>
            }
        } else if (*format == '*') {
   43dea:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
   43df1:	0f b6 00             	movzbl (%rax),%eax
   43df4:	3c 2a                	cmp    $0x2a,%al
   43df6:	75 68                	jne    43e60 <printer_vprintf+0x1c3>
            width = va_arg(val, int);
   43df8:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
   43dff:	8b 00                	mov    (%rax),%eax
   43e01:	83 f8 2f             	cmp    $0x2f,%eax
   43e04:	77 30                	ja     43e36 <printer_vprintf+0x199>
   43e06:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
   43e0d:	48 8b 50 10          	mov    0x10(%rax),%rdx
   43e11:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
   43e18:	8b 00                	mov    (%rax),%eax
   43e1a:	89 c0                	mov    %eax,%eax
   43e1c:	48 01 d0             	add    %rdx,%rax
   43e1f:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
   43e26:	8b 12                	mov    (%rdx),%edx
   43e28:	8d 4a 08             	lea    0x8(%rdx),%ecx
   43e2b:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
   43e32:	89 0a                	mov    %ecx,(%rdx)
   43e34:	eb 1a                	jmp    43e50 <printer_vprintf+0x1b3>
   43e36:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
   43e3d:	48 8b 40 08          	mov    0x8(%rax),%rax
   43e41:	48 8d 48 08          	lea    0x8(%rax),%rcx
   43e45:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
   43e4c:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
   43e50:	8b 00                	mov    (%rax),%eax
   43e52:	89 45 e8             	mov    %eax,-0x18(%rbp)
            ++format;
   43e55:	48 83 85 68 ff ff ff 	addq   $0x1,-0x98(%rbp)
   43e5c:	01 
   43e5d:	eb 01                	jmp    43e60 <printer_vprintf+0x1c3>
        if (*format >= '1' && *format <= '9') {
   43e5f:	90                   	nop
        }

        // process precision
        int precision = -1;
   43e60:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%rbp)
        if (*format == '.') {
   43e67:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
   43e6e:	0f b6 00             	movzbl (%rax),%eax
   43e71:	3c 2e                	cmp    $0x2e,%al
   43e73:	0f 85 00 01 00 00    	jne    43f79 <printer_vprintf+0x2dc>
            ++format;
   43e79:	48 83 85 68 ff ff ff 	addq   $0x1,-0x98(%rbp)
   43e80:	01 
            if (*format >= '0' && *format <= '9') {
   43e81:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
   43e88:	0f b6 00             	movzbl (%rax),%eax
   43e8b:	3c 2f                	cmp    $0x2f,%al
   43e8d:	7e 67                	jle    43ef6 <printer_vprintf+0x259>
   43e8f:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
   43e96:	0f b6 00             	movzbl (%rax),%eax
   43e99:	3c 39                	cmp    $0x39,%al
   43e9b:	7f 59                	jg     43ef6 <printer_vprintf+0x259>
                for (precision = 0; *format >= '0' && *format <= '9'; ) {
   43e9d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%rbp)
   43ea4:	eb 2e                	jmp    43ed4 <printer_vprintf+0x237>
                    precision = 10 * precision + *format++ - '0';
   43ea6:	8b 55 e4             	mov    -0x1c(%rbp),%edx
   43ea9:	89 d0                	mov    %edx,%eax
   43eab:	c1 e0 02             	shl    $0x2,%eax
   43eae:	01 d0                	add    %edx,%eax
   43eb0:	01 c0                	add    %eax,%eax
   43eb2:	89 c1                	mov    %eax,%ecx
   43eb4:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
   43ebb:	48 8d 50 01          	lea    0x1(%rax),%rdx
   43ebf:	48 89 95 68 ff ff ff 	mov    %rdx,-0x98(%rbp)
   43ec6:	0f b6 00             	movzbl (%rax),%eax
   43ec9:	0f be c0             	movsbl %al,%eax
   43ecc:	01 c8                	add    %ecx,%eax
   43ece:	83 e8 30             	sub    $0x30,%eax
   43ed1:	89 45 e4             	mov    %eax,-0x1c(%rbp)
                for (precision = 0; *format >= '0' && *format <= '9'; ) {
   43ed4:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
   43edb:	0f b6 00             	movzbl (%rax),%eax
   43ede:	3c 2f                	cmp    $0x2f,%al
   43ee0:	0f 8e 85 00 00 00    	jle    43f6b <printer_vprintf+0x2ce>
   43ee6:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
   43eed:	0f b6 00             	movzbl (%rax),%eax
   43ef0:	3c 39                	cmp    $0x39,%al
   43ef2:	7e b2                	jle    43ea6 <printer_vprintf+0x209>
            if (*format >= '0' && *format <= '9') {
   43ef4:	eb 75                	jmp    43f6b <printer_vprintf+0x2ce>
                }
            } else if (*format == '*') {
   43ef6:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
   43efd:	0f b6 00             	movzbl (%rax),%eax
   43f00:	3c 2a                	cmp    $0x2a,%al
   43f02:	75 68                	jne    43f6c <printer_vprintf+0x2cf>
                precision = va_arg(val, int);
   43f04:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
   43f0b:	8b 00                	mov    (%rax),%eax
   43f0d:	83 f8 2f             	cmp    $0x2f,%eax
   43f10:	77 30                	ja     43f42 <printer_vprintf+0x2a5>
   43f12:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
   43f19:	48 8b 50 10          	mov    0x10(%rax),%rdx
   43f1d:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
   43f24:	8b 00                	mov    (%rax),%eax
   43f26:	89 c0                	mov    %eax,%eax
   43f28:	48 01 d0             	add    %rdx,%rax
   43f2b:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
   43f32:	8b 12                	mov    (%rdx),%edx
   43f34:	8d 4a 08             	lea    0x8(%rdx),%ecx
   43f37:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
   43f3e:	89 0a                	mov    %ecx,(%rdx)
   43f40:	eb 1a                	jmp    43f5c <printer_vprintf+0x2bf>
   43f42:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
   43f49:	48 8b 40 08          	mov    0x8(%rax),%rax
   43f4d:	48 8d 48 08          	lea    0x8(%rax),%rcx
   43f51:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
   43f58:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
   43f5c:	8b 00                	mov    (%rax),%eax
   43f5e:	89 45 e4             	mov    %eax,-0x1c(%rbp)
                ++format;
   43f61:	48 83 85 68 ff ff ff 	addq   $0x1,-0x98(%rbp)
   43f68:	01 
   43f69:	eb 01                	jmp    43f6c <printer_vprintf+0x2cf>
            if (*format >= '0' && *format <= '9') {
   43f6b:	90                   	nop
            }
            if (precision < 0) {
   43f6c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%rbp)
   43f70:	79 07                	jns    43f79 <printer_vprintf+0x2dc>
                precision = 0;
   43f72:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%rbp)
            }
        }

        // process main conversion character
        int base = 10;
   43f79:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%rbp)
        unsigned long num = 0;
   43f80:	48 c7 45 d8 00 00 00 	movq   $0x0,-0x28(%rbp)
   43f87:	00 
        int length = 0;
   43f88:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%rbp)
        char* data = "";
   43f8f:	48 c7 45 c8 26 55 04 	movq   $0x45526,-0x38(%rbp)
   43f96:	00 
    again:
        switch (*format) {
   43f97:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
   43f9e:	0f b6 00             	movzbl (%rax),%eax
   43fa1:	0f be c0             	movsbl %al,%eax
   43fa4:	83 f8 7a             	cmp    $0x7a,%eax
   43fa7:	0f 84 a4 00 00 00    	je     44051 <printer_vprintf+0x3b4>
   43fad:	83 f8 7a             	cmp    $0x7a,%eax
   43fb0:	0f 8f 3d 04 00 00    	jg     443f3 <printer_vprintf+0x756>
   43fb6:	83 f8 78             	cmp    $0x78,%eax
   43fb9:	0f 84 76 02 00 00    	je     44235 <printer_vprintf+0x598>
   43fbf:	83 f8 78             	cmp    $0x78,%eax
   43fc2:	0f 8f 2b 04 00 00    	jg     443f3 <printer_vprintf+0x756>
   43fc8:	83 f8 75             	cmp    $0x75,%eax
   43fcb:	0f 84 94 01 00 00    	je     44165 <printer_vprintf+0x4c8>
   43fd1:	83 f8 75             	cmp    $0x75,%eax
   43fd4:	0f 8f 19 04 00 00    	jg     443f3 <printer_vprintf+0x756>
   43fda:	83 f8 73             	cmp    $0x73,%eax
   43fdd:	0f 84 dc 02 00 00    	je     442bf <printer_vprintf+0x622>
   43fe3:	83 f8 73             	cmp    $0x73,%eax
   43fe6:	0f 8f 07 04 00 00    	jg     443f3 <printer_vprintf+0x756>
   43fec:	83 f8 70             	cmp    $0x70,%eax
   43fef:	0f 84 58 02 00 00    	je     4424d <printer_vprintf+0x5b0>
   43ff5:	83 f8 70             	cmp    $0x70,%eax
   43ff8:	0f 8f f5 03 00 00    	jg     443f3 <printer_vprintf+0x756>
   43ffe:	83 f8 6c             	cmp    $0x6c,%eax
   44001:	74 4e                	je     44051 <printer_vprintf+0x3b4>
   44003:	83 f8 6c             	cmp    $0x6c,%eax
   44006:	0f 8f e7 03 00 00    	jg     443f3 <printer_vprintf+0x756>
   4400c:	83 f8 69             	cmp    $0x69,%eax
   4400f:	74 54                	je     44065 <printer_vprintf+0x3c8>
   44011:	83 f8 69             	cmp    $0x69,%eax
   44014:	0f 8f d9 03 00 00    	jg     443f3 <printer_vprintf+0x756>
   4401a:	83 f8 64             	cmp    $0x64,%eax
   4401d:	74 46                	je     44065 <printer_vprintf+0x3c8>
   4401f:	83 f8 64             	cmp    $0x64,%eax
   44022:	0f 8f cb 03 00 00    	jg     443f3 <printer_vprintf+0x756>
   44028:	83 f8 63             	cmp    $0x63,%eax
   4402b:	0f 84 57 03 00 00    	je     44388 <printer_vprintf+0x6eb>
   44031:	83 f8 63             	cmp    $0x63,%eax
   44034:	0f 8f b9 03 00 00    	jg     443f3 <printer_vprintf+0x756>
   4403a:	83 f8 43             	cmp    $0x43,%eax
   4403d:	0f 84 e0 02 00 00    	je     44323 <printer_vprintf+0x686>
   44043:	83 f8 58             	cmp    $0x58,%eax
   44046:	0f 84 f5 01 00 00    	je     44241 <printer_vprintf+0x5a4>
   4404c:	e9 a2 03 00 00       	jmp    443f3 <printer_vprintf+0x756>
        case 'l':
        case 'z':
            length = 1;
   44051:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%rbp)
            ++format;
   44058:	48 83 85 68 ff ff ff 	addq   $0x1,-0x98(%rbp)
   4405f:	01 
            goto again;
   44060:	e9 32 ff ff ff       	jmp    43f97 <printer_vprintf+0x2fa>
        case 'd':
        case 'i': {
            long x = length ? va_arg(val, long) : va_arg(val, int);
   44065:	83 7d d4 00          	cmpl   $0x0,-0x2c(%rbp)
   44069:	74 61                	je     440cc <printer_vprintf+0x42f>
   4406b:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
   44072:	8b 00                	mov    (%rax),%eax
   44074:	83 f8 2f             	cmp    $0x2f,%eax
   44077:	77 30                	ja     440a9 <printer_vprintf+0x40c>
   44079:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
   44080:	48 8b 50 10          	mov    0x10(%rax),%rdx
   44084:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
   4408b:	8b 00                	mov    (%rax),%eax
   4408d:	89 c0                	mov    %eax,%eax
   4408f:	48 01 d0             	add    %rdx,%rax
   44092:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
   44099:	8b 12                	mov    (%rdx),%edx
   4409b:	8d 4a 08             	lea    0x8(%rdx),%ecx
   4409e:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
   440a5:	89 0a                	mov    %ecx,(%rdx)
   440a7:	eb 1a                	jmp    440c3 <printer_vprintf+0x426>
   440a9:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
   440b0:	48 8b 40 08          	mov    0x8(%rax),%rax
   440b4:	48 8d 48 08          	lea    0x8(%rax),%rcx
   440b8:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
   440bf:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
   440c3:	48 8b 00             	mov    (%rax),%rax
   440c6:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
   440ca:	eb 60                	jmp    4412c <printer_vprintf+0x48f>
   440cc:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
   440d3:	8b 00                	mov    (%rax),%eax
   440d5:	83 f8 2f             	cmp    $0x2f,%eax
   440d8:	77 30                	ja     4410a <printer_vprintf+0x46d>
   440da:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
   440e1:	48 8b 50 10          	mov    0x10(%rax),%rdx
   440e5:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
   440ec:	8b 00                	mov    (%rax),%eax
   440ee:	89 c0                	mov    %eax,%eax
   440f0:	48 01 d0             	add    %rdx,%rax
   440f3:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
   440fa:	8b 12                	mov    (%rdx),%edx
   440fc:	8d 4a 08             	lea    0x8(%rdx),%ecx
   440ff:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
   44106:	89 0a                	mov    %ecx,(%rdx)
   44108:	eb 1a                	jmp    44124 <printer_vprintf+0x487>
   4410a:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
   44111:	48 8b 40 08          	mov    0x8(%rax),%rax
   44115:	48 8d 48 08          	lea    0x8(%rax),%rcx
   44119:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
   44120:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
   44124:	8b 00                	mov    (%rax),%eax
   44126:	48 98                	cltq
   44128:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
            int negative = x < 0 ? FLAG_NEGATIVE : 0;
   4412c:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
   44130:	48 c1 f8 38          	sar    $0x38,%rax
   44134:	25 80 00 00 00       	and    $0x80,%eax
   44139:	89 45 a4             	mov    %eax,-0x5c(%rbp)
            num = negative ? -x : x;
   4413c:	83 7d a4 00          	cmpl   $0x0,-0x5c(%rbp)
   44140:	74 0d                	je     4414f <printer_vprintf+0x4b2>
   44142:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
   44146:	48 f7 d8             	neg    %rax
   44149:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
   4414d:	eb 08                	jmp    44157 <printer_vprintf+0x4ba>
   4414f:	48 8b 45 c0          	mov    -0x40(%rbp),%rax
   44153:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
            flags |= FLAG_NUMERIC | FLAG_SIGNED | negative;
   44157:	8b 45 a4             	mov    -0x5c(%rbp),%eax
   4415a:	83 c8 60             	or     $0x60,%eax
   4415d:	09 45 ec             	or     %eax,-0x14(%rbp)
            break;
   44160:	e9 d3 02 00 00       	jmp    44438 <printer_vprintf+0x79b>
        }
        case 'u':
        format_unsigned:
            num = length ? va_arg(val, unsigned long) : va_arg(val, unsigned);
   44165:	83 7d d4 00          	cmpl   $0x0,-0x2c(%rbp)
   44169:	74 61                	je     441cc <printer_vprintf+0x52f>
   4416b:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
   44172:	8b 00                	mov    (%rax),%eax
   44174:	83 f8 2f             	cmp    $0x2f,%eax
   44177:	77 30                	ja     441a9 <printer_vprintf+0x50c>
   44179:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
   44180:	48 8b 50 10          	mov    0x10(%rax),%rdx
   44184:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
   4418b:	8b 00                	mov    (%rax),%eax
   4418d:	89 c0                	mov    %eax,%eax
   4418f:	48 01 d0             	add    %rdx,%rax
   44192:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
   44199:	8b 12                	mov    (%rdx),%edx
   4419b:	8d 4a 08             	lea    0x8(%rdx),%ecx
   4419e:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
   441a5:	89 0a                	mov    %ecx,(%rdx)
   441a7:	eb 1a                	jmp    441c3 <printer_vprintf+0x526>
   441a9:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
   441b0:	48 8b 40 08          	mov    0x8(%rax),%rax
   441b4:	48 8d 48 08          	lea    0x8(%rax),%rcx
   441b8:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
   441bf:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
   441c3:	48 8b 00             	mov    (%rax),%rax
   441c6:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
   441ca:	eb 60                	jmp    4422c <printer_vprintf+0x58f>
   441cc:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
   441d3:	8b 00                	mov    (%rax),%eax
   441d5:	83 f8 2f             	cmp    $0x2f,%eax
   441d8:	77 30                	ja     4420a <printer_vprintf+0x56d>
   441da:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
   441e1:	48 8b 50 10          	mov    0x10(%rax),%rdx
   441e5:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
   441ec:	8b 00                	mov    (%rax),%eax
   441ee:	89 c0                	mov    %eax,%eax
   441f0:	48 01 d0             	add    %rdx,%rax
   441f3:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
   441fa:	8b 12                	mov    (%rdx),%edx
   441fc:	8d 4a 08             	lea    0x8(%rdx),%ecx
   441ff:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
   44206:	89 0a                	mov    %ecx,(%rdx)
   44208:	eb 1a                	jmp    44224 <printer_vprintf+0x587>
   4420a:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
   44211:	48 8b 40 08          	mov    0x8(%rax),%rax
   44215:	48 8d 48 08          	lea    0x8(%rax),%rcx
   44219:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
   44220:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
   44224:	8b 00                	mov    (%rax),%eax
   44226:	89 c0                	mov    %eax,%eax
   44228:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
            flags |= FLAG_NUMERIC;
   4422c:	83 4d ec 20          	orl    $0x20,-0x14(%rbp)
            break;
   44230:	e9 03 02 00 00       	jmp    44438 <printer_vprintf+0x79b>
        case 'x':
            base = -16;
   44235:	c7 45 e0 f0 ff ff ff 	movl   $0xfffffff0,-0x20(%rbp)
            goto format_unsigned;
   4423c:	e9 24 ff ff ff       	jmp    44165 <printer_vprintf+0x4c8>
        case 'X':
            base = 16;
   44241:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%rbp)
            goto format_unsigned;
   44248:	e9 18 ff ff ff       	jmp    44165 <printer_vprintf+0x4c8>
        case 'p':
            num = (uintptr_t) va_arg(val, void*);
   4424d:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
   44254:	8b 00                	mov    (%rax),%eax
   44256:	83 f8 2f             	cmp    $0x2f,%eax
   44259:	77 30                	ja     4428b <printer_vprintf+0x5ee>
   4425b:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
   44262:	48 8b 50 10          	mov    0x10(%rax),%rdx
   44266:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
   4426d:	8b 00                	mov    (%rax),%eax
   4426f:	89 c0                	mov    %eax,%eax
   44271:	48 01 d0             	add    %rdx,%rax
   44274:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
   4427b:	8b 12                	mov    (%rdx),%edx
   4427d:	8d 4a 08             	lea    0x8(%rdx),%ecx
   44280:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
   44287:	89 0a                	mov    %ecx,(%rdx)
   44289:	eb 1a                	jmp    442a5 <printer_vprintf+0x608>
   4428b:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
   44292:	48 8b 40 08          	mov    0x8(%rax),%rax
   44296:	48 8d 48 08          	lea    0x8(%rax),%rcx
   4429a:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
   442a1:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
   442a5:	48 8b 00             	mov    (%rax),%rax
   442a8:	48 89 45 d8          	mov    %rax,-0x28(%rbp)
            base = -16;
   442ac:	c7 45 e0 f0 ff ff ff 	movl   $0xfffffff0,-0x20(%rbp)
            flags |= FLAG_ALT | FLAG_ALT2 | FLAG_NUMERIC;
   442b3:	81 4d ec 21 01 00 00 	orl    $0x121,-0x14(%rbp)
            break;
   442ba:	e9 79 01 00 00       	jmp    44438 <printer_vprintf+0x79b>
        case 's':
            data = va_arg(val, char*);
   442bf:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
   442c6:	8b 00                	mov    (%rax),%eax
   442c8:	83 f8 2f             	cmp    $0x2f,%eax
   442cb:	77 30                	ja     442fd <printer_vprintf+0x660>
   442cd:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
   442d4:	48 8b 50 10          	mov    0x10(%rax),%rdx
   442d8:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
   442df:	8b 00                	mov    (%rax),%eax
   442e1:	89 c0                	mov    %eax,%eax
   442e3:	48 01 d0             	add    %rdx,%rax
   442e6:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
   442ed:	8b 12                	mov    (%rdx),%edx
   442ef:	8d 4a 08             	lea    0x8(%rdx),%ecx
   442f2:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
   442f9:	89 0a                	mov    %ecx,(%rdx)
   442fb:	eb 1a                	jmp    44317 <printer_vprintf+0x67a>
   442fd:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
   44304:	48 8b 40 08          	mov    0x8(%rax),%rax
   44308:	48 8d 48 08          	lea    0x8(%rax),%rcx
   4430c:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
   44313:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
   44317:	48 8b 00             	mov    (%rax),%rax
   4431a:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
            break;
   4431e:	e9 15 01 00 00       	jmp    44438 <printer_vprintf+0x79b>
        case 'C':
            color = va_arg(val, int);
   44323:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
   4432a:	8b 00                	mov    (%rax),%eax
   4432c:	83 f8 2f             	cmp    $0x2f,%eax
   4432f:	77 30                	ja     44361 <printer_vprintf+0x6c4>
   44331:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
   44338:	48 8b 50 10          	mov    0x10(%rax),%rdx
   4433c:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
   44343:	8b 00                	mov    (%rax),%eax
   44345:	89 c0                	mov    %eax,%eax
   44347:	48 01 d0             	add    %rdx,%rax
   4434a:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
   44351:	8b 12                	mov    (%rdx),%edx
   44353:	8d 4a 08             	lea    0x8(%rdx),%ecx
   44356:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
   4435d:	89 0a                	mov    %ecx,(%rdx)
   4435f:	eb 1a                	jmp    4437b <printer_vprintf+0x6de>
   44361:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
   44368:	48 8b 40 08          	mov    0x8(%rax),%rax
   4436c:	48 8d 48 08          	lea    0x8(%rax),%rcx
   44370:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
   44377:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
   4437b:	8b 00                	mov    (%rax),%eax
   4437d:	89 85 74 ff ff ff    	mov    %eax,-0x8c(%rbp)
            goto done;
   44383:	e9 6b 03 00 00       	jmp    446f3 <printer_vprintf+0xa56>
        case 'c':
            data = numbuf;
   44388:	48 8d 45 8c          	lea    -0x74(%rbp),%rax
   4438c:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
            numbuf[0] = va_arg(val, int);
   44390:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
   44397:	8b 00                	mov    (%rax),%eax
   44399:	83 f8 2f             	cmp    $0x2f,%eax
   4439c:	77 30                	ja     443ce <printer_vprintf+0x731>
   4439e:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
   443a5:	48 8b 50 10          	mov    0x10(%rax),%rdx
   443a9:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
   443b0:	8b 00                	mov    (%rax),%eax
   443b2:	89 c0                	mov    %eax,%eax
   443b4:	48 01 d0             	add    %rdx,%rax
   443b7:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
   443be:	8b 12                	mov    (%rdx),%edx
   443c0:	8d 4a 08             	lea    0x8(%rdx),%ecx
   443c3:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
   443ca:	89 0a                	mov    %ecx,(%rdx)
   443cc:	eb 1a                	jmp    443e8 <printer_vprintf+0x74b>
   443ce:	48 8b 85 60 ff ff ff 	mov    -0xa0(%rbp),%rax
   443d5:	48 8b 40 08          	mov    0x8(%rax),%rax
   443d9:	48 8d 48 08          	lea    0x8(%rax),%rcx
   443dd:	48 8b 95 60 ff ff ff 	mov    -0xa0(%rbp),%rdx
   443e4:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
   443e8:	8b 00                	mov    (%rax),%eax
   443ea:	88 45 8c             	mov    %al,-0x74(%rbp)
            numbuf[1] = '\0';
   443ed:	c6 45 8d 00          	movb   $0x0,-0x73(%rbp)
            break;
   443f1:	eb 45                	jmp    44438 <printer_vprintf+0x79b>
        default:
            data = numbuf;
   443f3:	48 8d 45 8c          	lea    -0x74(%rbp),%rax
   443f7:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
            numbuf[0] = (*format ? *format : '%');
   443fb:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
   44402:	0f b6 00             	movzbl (%rax),%eax
   44405:	84 c0                	test   %al,%al
   44407:	74 0c                	je     44415 <printer_vprintf+0x778>
   44409:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
   44410:	0f b6 00             	movzbl (%rax),%eax
   44413:	eb 05                	jmp    4441a <printer_vprintf+0x77d>
   44415:	b8 25 00 00 00       	mov    $0x25,%eax
   4441a:	88 45 8c             	mov    %al,-0x74(%rbp)
            numbuf[1] = '\0';
   4441d:	c6 45 8d 00          	movb   $0x0,-0x73(%rbp)
            if (!*format) {
   44421:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
   44428:	0f b6 00             	movzbl (%rax),%eax
   4442b:	84 c0                	test   %al,%al
   4442d:	75 08                	jne    44437 <printer_vprintf+0x79a>
                format--;
   4442f:	48 83 ad 68 ff ff ff 	subq   $0x1,-0x98(%rbp)
   44436:	01 
            }
            break;
   44437:	90                   	nop
        }

        if (flags & FLAG_NUMERIC) {
   44438:	8b 45 ec             	mov    -0x14(%rbp),%eax
   4443b:	83 e0 20             	and    $0x20,%eax
   4443e:	85 c0                	test   %eax,%eax
   44440:	74 1e                	je     44460 <printer_vprintf+0x7c3>
            data = fill_numbuf(numbuf + NUMBUFSIZ, num, base);
   44442:	48 8d 45 8c          	lea    -0x74(%rbp),%rax
   44446:	48 83 c0 18          	add    $0x18,%rax
   4444a:	8b 55 e0             	mov    -0x20(%rbp),%edx
   4444d:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
   44451:	48 89 ce             	mov    %rcx,%rsi
   44454:	48 89 c7             	mov    %rax,%rdi
   44457:	e8 bf f7 ff ff       	call   43c1b <fill_numbuf>
   4445c:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
        }

        const char* prefix = "";
   44460:	48 c7 45 b8 26 55 04 	movq   $0x45526,-0x48(%rbp)
   44467:	00 
        if ((flags & FLAG_NUMERIC) && (flags & FLAG_SIGNED)) {
   44468:	8b 45 ec             	mov    -0x14(%rbp),%eax
   4446b:	83 e0 20             	and    $0x20,%eax
   4446e:	85 c0                	test   %eax,%eax
   44470:	74 48                	je     444ba <printer_vprintf+0x81d>
   44472:	8b 45 ec             	mov    -0x14(%rbp),%eax
   44475:	83 e0 40             	and    $0x40,%eax
   44478:	85 c0                	test   %eax,%eax
   4447a:	74 3e                	je     444ba <printer_vprintf+0x81d>
            if (flags & FLAG_NEGATIVE) {
   4447c:	8b 45 ec             	mov    -0x14(%rbp),%eax
   4447f:	25 80 00 00 00       	and    $0x80,%eax
   44484:	85 c0                	test   %eax,%eax
   44486:	74 0a                	je     44492 <printer_vprintf+0x7f5>
                prefix = "-";
   44488:	48 c7 45 b8 27 55 04 	movq   $0x45527,-0x48(%rbp)
   4448f:	00 
            if (flags & FLAG_NEGATIVE) {
   44490:	eb 75                	jmp    44507 <printer_vprintf+0x86a>
            } else if (flags & FLAG_PLUSPOSITIVE) {
   44492:	8b 45 ec             	mov    -0x14(%rbp),%eax
   44495:	83 e0 10             	and    $0x10,%eax
   44498:	85 c0                	test   %eax,%eax
   4449a:	74 0a                	je     444a6 <printer_vprintf+0x809>
                prefix = "+";
   4449c:	48 c7 45 b8 29 55 04 	movq   $0x45529,-0x48(%rbp)
   444a3:	00 
            if (flags & FLAG_NEGATIVE) {
   444a4:	eb 61                	jmp    44507 <printer_vprintf+0x86a>
            } else if (flags & FLAG_SPACEPOSITIVE) {
   444a6:	8b 45 ec             	mov    -0x14(%rbp),%eax
   444a9:	83 e0 08             	and    $0x8,%eax
   444ac:	85 c0                	test   %eax,%eax
   444ae:	74 57                	je     44507 <printer_vprintf+0x86a>
                prefix = " ";
   444b0:	48 c7 45 b8 2b 55 04 	movq   $0x4552b,-0x48(%rbp)
   444b7:	00 
            if (flags & FLAG_NEGATIVE) {
   444b8:	eb 4d                	jmp    44507 <printer_vprintf+0x86a>
            }
        } else if ((flags & FLAG_NUMERIC) && (flags & FLAG_ALT)
   444ba:	8b 45 ec             	mov    -0x14(%rbp),%eax
   444bd:	83 e0 20             	and    $0x20,%eax
   444c0:	85 c0                	test   %eax,%eax
   444c2:	74 44                	je     44508 <printer_vprintf+0x86b>
   444c4:	8b 45 ec             	mov    -0x14(%rbp),%eax
   444c7:	83 e0 01             	and    $0x1,%eax
   444ca:	85 c0                	test   %eax,%eax
   444cc:	74 3a                	je     44508 <printer_vprintf+0x86b>
                   && (base == 16 || base == -16)
   444ce:	83 7d e0 10          	cmpl   $0x10,-0x20(%rbp)
   444d2:	74 06                	je     444da <printer_vprintf+0x83d>
   444d4:	83 7d e0 f0          	cmpl   $0xfffffff0,-0x20(%rbp)
   444d8:	75 2e                	jne    44508 <printer_vprintf+0x86b>
                   && (num || (flags & FLAG_ALT2))) {
   444da:	48 83 7d d8 00       	cmpq   $0x0,-0x28(%rbp)
   444df:	75 0c                	jne    444ed <printer_vprintf+0x850>
   444e1:	8b 45 ec             	mov    -0x14(%rbp),%eax
   444e4:	25 00 01 00 00       	and    $0x100,%eax
   444e9:	85 c0                	test   %eax,%eax
   444eb:	74 1b                	je     44508 <printer_vprintf+0x86b>
            prefix = (base == -16 ? "0x" : "0X");
   444ed:	83 7d e0 f0          	cmpl   $0xfffffff0,-0x20(%rbp)
   444f1:	75 0a                	jne    444fd <printer_vprintf+0x860>
   444f3:	48 c7 45 b8 2d 55 04 	movq   $0x4552d,-0x48(%rbp)
   444fa:	00 
   444fb:	eb 0b                	jmp    44508 <printer_vprintf+0x86b>
   444fd:	48 c7 45 b8 30 55 04 	movq   $0x45530,-0x48(%rbp)
   44504:	00 
   44505:	eb 01                	jmp    44508 <printer_vprintf+0x86b>
            if (flags & FLAG_NEGATIVE) {
   44507:	90                   	nop
        }

        int len;
        if (precision >= 0 && !(flags & FLAG_NUMERIC)) {
   44508:	83 7d e4 00          	cmpl   $0x0,-0x1c(%rbp)
   4450c:	78 24                	js     44532 <printer_vprintf+0x895>
   4450e:	8b 45 ec             	mov    -0x14(%rbp),%eax
   44511:	83 e0 20             	and    $0x20,%eax
   44514:	85 c0                	test   %eax,%eax
   44516:	75 1a                	jne    44532 <printer_vprintf+0x895>
            len = strnlen(data, precision);
   44518:	8b 45 e4             	mov    -0x1c(%rbp),%eax
   4451b:	48 63 d0             	movslq %eax,%rdx
   4451e:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
   44522:	48 89 d6             	mov    %rdx,%rsi
   44525:	48 89 c7             	mov    %rax,%rdi
   44528:	e8 44 f5 ff ff       	call   43a71 <strnlen>
   4452d:	89 45 b4             	mov    %eax,-0x4c(%rbp)
   44530:	eb 0f                	jmp    44541 <printer_vprintf+0x8a4>
        } else {
            len = strlen(data);
   44532:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
   44536:	48 89 c7             	mov    %rax,%rdi
   44539:	e8 02 f5 ff ff       	call   43a40 <strlen>
   4453e:	89 45 b4             	mov    %eax,-0x4c(%rbp)
        }
        int zeros;
        if ((flags & FLAG_NUMERIC) && precision >= 0) {
   44541:	8b 45 ec             	mov    -0x14(%rbp),%eax
   44544:	83 e0 20             	and    $0x20,%eax
   44547:	85 c0                	test   %eax,%eax
   44549:	74 22                	je     4456d <printer_vprintf+0x8d0>
   4454b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%rbp)
   4454f:	78 1c                	js     4456d <printer_vprintf+0x8d0>
            zeros = precision > len ? precision - len : 0;
   44551:	8b 45 e4             	mov    -0x1c(%rbp),%eax
   44554:	3b 45 b4             	cmp    -0x4c(%rbp),%eax
   44557:	7e 0b                	jle    44564 <printer_vprintf+0x8c7>
   44559:	8b 45 e4             	mov    -0x1c(%rbp),%eax
   4455c:	2b 45 b4             	sub    -0x4c(%rbp),%eax
   4455f:	89 45 b0             	mov    %eax,-0x50(%rbp)
   44562:	eb 65                	jmp    445c9 <printer_vprintf+0x92c>
   44564:	c7 45 b0 00 00 00 00 	movl   $0x0,-0x50(%rbp)
   4456b:	eb 5c                	jmp    445c9 <printer_vprintf+0x92c>
        } else if ((flags & FLAG_NUMERIC) && (flags & FLAG_ZERO)
   4456d:	8b 45 ec             	mov    -0x14(%rbp),%eax
   44570:	83 e0 20             	and    $0x20,%eax
   44573:	85 c0                	test   %eax,%eax
   44575:	74 4b                	je     445c2 <printer_vprintf+0x925>
   44577:	8b 45 ec             	mov    -0x14(%rbp),%eax
   4457a:	83 e0 02             	and    $0x2,%eax
   4457d:	85 c0                	test   %eax,%eax
   4457f:	74 41                	je     445c2 <printer_vprintf+0x925>
                   && !(flags & FLAG_LEFTJUSTIFY)
   44581:	8b 45 ec             	mov    -0x14(%rbp),%eax
   44584:	83 e0 04             	and    $0x4,%eax
   44587:	85 c0                	test   %eax,%eax
   44589:	75 37                	jne    445c2 <printer_vprintf+0x925>
                   && len + (int) strlen(prefix) < width) {
   4458b:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
   4458f:	48 89 c7             	mov    %rax,%rdi
   44592:	e8 a9 f4 ff ff       	call   43a40 <strlen>
   44597:	89 c2                	mov    %eax,%edx
   44599:	8b 45 b4             	mov    -0x4c(%rbp),%eax
   4459c:	01 d0                	add    %edx,%eax
   4459e:	39 45 e8             	cmp    %eax,-0x18(%rbp)
   445a1:	7e 1f                	jle    445c2 <printer_vprintf+0x925>
            zeros = width - len - strlen(prefix);
   445a3:	8b 45 e8             	mov    -0x18(%rbp),%eax
   445a6:	2b 45 b4             	sub    -0x4c(%rbp),%eax
   445a9:	89 c3                	mov    %eax,%ebx
   445ab:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
   445af:	48 89 c7             	mov    %rax,%rdi
   445b2:	e8 89 f4 ff ff       	call   43a40 <strlen>
   445b7:	89 c2                	mov    %eax,%edx
   445b9:	89 d8                	mov    %ebx,%eax
   445bb:	29 d0                	sub    %edx,%eax
   445bd:	89 45 b0             	mov    %eax,-0x50(%rbp)
   445c0:	eb 07                	jmp    445c9 <printer_vprintf+0x92c>
        } else {
            zeros = 0;
   445c2:	c7 45 b0 00 00 00 00 	movl   $0x0,-0x50(%rbp)
        }
        width -= len + zeros + strlen(prefix);
   445c9:	8b 55 b4             	mov    -0x4c(%rbp),%edx
   445cc:	8b 45 b0             	mov    -0x50(%rbp),%eax
   445cf:	01 d0                	add    %edx,%eax
   445d1:	48 63 d8             	movslq %eax,%rbx
   445d4:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
   445d8:	48 89 c7             	mov    %rax,%rdi
   445db:	e8 60 f4 ff ff       	call   43a40 <strlen>
   445e0:	48 8d 14 03          	lea    (%rbx,%rax,1),%rdx
   445e4:	8b 45 e8             	mov    -0x18(%rbp),%eax
   445e7:	29 d0                	sub    %edx,%eax
   445e9:	89 45 e8             	mov    %eax,-0x18(%rbp)
        for (; !(flags & FLAG_LEFTJUSTIFY) && width > 0; --width) {
   445ec:	eb 25                	jmp    44613 <printer_vprintf+0x976>
            p->putc(p, ' ', color);
   445ee:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
   445f5:	48 8b 08             	mov    (%rax),%rcx
   445f8:	8b 95 74 ff ff ff    	mov    -0x8c(%rbp),%edx
   445fe:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
   44605:	be 20 00 00 00       	mov    $0x20,%esi
   4460a:	48 89 c7             	mov    %rax,%rdi
   4460d:	ff d1                	call   *%rcx
        for (; !(flags & FLAG_LEFTJUSTIFY) && width > 0; --width) {
   4460f:	83 6d e8 01          	subl   $0x1,-0x18(%rbp)
   44613:	8b 45 ec             	mov    -0x14(%rbp),%eax
   44616:	83 e0 04             	and    $0x4,%eax
   44619:	85 c0                	test   %eax,%eax
   4461b:	75 36                	jne    44653 <printer_vprintf+0x9b6>
   4461d:	83 7d e8 00          	cmpl   $0x0,-0x18(%rbp)
   44621:	7f cb                	jg     445ee <printer_vprintf+0x951>
        }
        for (; *prefix; ++prefix) {
   44623:	eb 2e                	jmp    44653 <printer_vprintf+0x9b6>
            p->putc(p, *prefix, color);
   44625:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
   4462c:	4c 8b 00             	mov    (%rax),%r8
   4462f:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
   44633:	0f b6 00             	movzbl (%rax),%eax
   44636:	8b 95 74 ff ff ff    	mov    -0x8c(%rbp),%edx
   4463c:	0f b6 c8             	movzbl %al,%ecx
   4463f:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
   44646:	89 ce                	mov    %ecx,%esi
   44648:	48 89 c7             	mov    %rax,%rdi
   4464b:	41 ff d0             	call   *%r8
        for (; *prefix; ++prefix) {
   4464e:	48 83 45 b8 01       	addq   $0x1,-0x48(%rbp)
   44653:	48 8b 45 b8          	mov    -0x48(%rbp),%rax
   44657:	0f b6 00             	movzbl (%rax),%eax
   4465a:	84 c0                	test   %al,%al
   4465c:	75 c7                	jne    44625 <printer_vprintf+0x988>
        }
        for (; zeros > 0; --zeros) {
   4465e:	eb 25                	jmp    44685 <printer_vprintf+0x9e8>
            p->putc(p, '0', color);
   44660:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
   44667:	48 8b 08             	mov    (%rax),%rcx
   4466a:	8b 95 74 ff ff ff    	mov    -0x8c(%rbp),%edx
   44670:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
   44677:	be 30 00 00 00       	mov    $0x30,%esi
   4467c:	48 89 c7             	mov    %rax,%rdi
   4467f:	ff d1                	call   *%rcx
        for (; zeros > 0; --zeros) {
   44681:	83 6d b0 01          	subl   $0x1,-0x50(%rbp)
   44685:	83 7d b0 00          	cmpl   $0x0,-0x50(%rbp)
   44689:	7f d5                	jg     44660 <printer_vprintf+0x9c3>
        }
        for (; len > 0; ++data, --len) {
   4468b:	eb 32                	jmp    446bf <printer_vprintf+0xa22>
            p->putc(p, *data, color);
   4468d:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
   44694:	4c 8b 00             	mov    (%rax),%r8
   44697:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
   4469b:	0f b6 00             	movzbl (%rax),%eax
   4469e:	8b 95 74 ff ff ff    	mov    -0x8c(%rbp),%edx
   446a4:	0f b6 c8             	movzbl %al,%ecx
   446a7:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
   446ae:	89 ce                	mov    %ecx,%esi
   446b0:	48 89 c7             	mov    %rax,%rdi
   446b3:	41 ff d0             	call   *%r8
        for (; len > 0; ++data, --len) {
   446b6:	48 83 45 c8 01       	addq   $0x1,-0x38(%rbp)
   446bb:	83 6d b4 01          	subl   $0x1,-0x4c(%rbp)
   446bf:	83 7d b4 00          	cmpl   $0x0,-0x4c(%rbp)
   446c3:	7f c8                	jg     4468d <printer_vprintf+0x9f0>
        }
        for (; width > 0; --width) {
   446c5:	eb 25                	jmp    446ec <printer_vprintf+0xa4f>
            p->putc(p, ' ', color);
   446c7:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
   446ce:	48 8b 08             	mov    (%rax),%rcx
   446d1:	8b 95 74 ff ff ff    	mov    -0x8c(%rbp),%edx
   446d7:	48 8b 85 78 ff ff ff 	mov    -0x88(%rbp),%rax
   446de:	be 20 00 00 00       	mov    $0x20,%esi
   446e3:	48 89 c7             	mov    %rax,%rdi
   446e6:	ff d1                	call   *%rcx
        for (; width > 0; --width) {
   446e8:	83 6d e8 01          	subl   $0x1,-0x18(%rbp)
   446ec:	83 7d e8 00          	cmpl   $0x0,-0x18(%rbp)
   446f0:	7f d5                	jg     446c7 <printer_vprintf+0xa2a>
        }
    done: ;
   446f2:	90                   	nop
    for (; *format; ++format) {
   446f3:	48 83 85 68 ff ff ff 	addq   $0x1,-0x98(%rbp)
   446fa:	01 
   446fb:	48 8b 85 68 ff ff ff 	mov    -0x98(%rbp),%rax
   44702:	0f b6 00             	movzbl (%rax),%eax
   44705:	84 c0                	test   %al,%al
   44707:	0f 85 bc f5 ff ff    	jne    43cc9 <printer_vprintf+0x2c>
    }
}
   4470d:	90                   	nop
   4470e:	90                   	nop
   4470f:	48 8b 5d f8          	mov    -0x8(%rbp),%rbx
   44713:	c9                   	leave
   44714:	c3                   	ret

0000000000044715 <console_putc>:
typedef struct console_printer {
    printer p;
    uint16_t* cursor;
} console_printer;

static void console_putc(printer* p, unsigned char c, int color) {
   44715:	55                   	push   %rbp
   44716:	48 89 e5             	mov    %rsp,%rbp
   44719:	48 83 ec 20          	sub    $0x20,%rsp
   4471d:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
   44721:	40 88 75 e7          	mov    %sil,-0x19(%rbp)
   44725:	89 55 e0             	mov    %edx,-0x20(%rbp)
    console_printer* cp = (console_printer*) p;
   44728:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   4472c:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
    if (cp->cursor >= console + CONSOLE_ROWS * CONSOLE_COLUMNS) {
   44730:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   44734:	48 8b 40 08          	mov    0x8(%rax),%rax
   44738:	ba a0 8f 0b 00       	mov    $0xb8fa0,%edx
   4473d:	48 39 d0             	cmp    %rdx,%rax
   44740:	72 0c                	jb     4474e <console_putc+0x39>
        cp->cursor = console;
   44742:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   44746:	48 c7 40 08 00 80 0b 	movq   $0xb8000,0x8(%rax)
   4474d:	00 
    }
    if (c == '\n') {
   4474e:	80 7d e7 0a          	cmpb   $0xa,-0x19(%rbp)
   44752:	75 78                	jne    447cc <console_putc+0xb7>
        int pos = (cp->cursor - console) % 80;
   44754:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   44758:	48 8b 40 08          	mov    0x8(%rax),%rax
   4475c:	48 2d 00 80 0b 00    	sub    $0xb8000,%rax
   44762:	48 d1 f8             	sar    $1,%rax
   44765:	48 89 c1             	mov    %rax,%rcx
   44768:	48 ba 67 66 66 66 66 	movabs $0x6666666666666667,%rdx
   4476f:	66 66 66 
   44772:	48 89 c8             	mov    %rcx,%rax
   44775:	48 f7 ea             	imul   %rdx
   44778:	48 c1 fa 05          	sar    $0x5,%rdx
   4477c:	48 89 c8             	mov    %rcx,%rax
   4477f:	48 c1 f8 3f          	sar    $0x3f,%rax
   44783:	48 29 c2             	sub    %rax,%rdx
   44786:	48 89 d0             	mov    %rdx,%rax
   44789:	48 c1 e0 02          	shl    $0x2,%rax
   4478d:	48 01 d0             	add    %rdx,%rax
   44790:	48 c1 e0 04          	shl    $0x4,%rax
   44794:	48 29 c1             	sub    %rax,%rcx
   44797:	48 89 ca             	mov    %rcx,%rdx
   4479a:	89 55 fc             	mov    %edx,-0x4(%rbp)
        for (; pos != 80; pos++) {
   4479d:	eb 25                	jmp    447c4 <console_putc+0xaf>
            *cp->cursor++ = ' ' | color;
   4479f:	8b 45 e0             	mov    -0x20(%rbp),%eax
   447a2:	83 c8 20             	or     $0x20,%eax
   447a5:	89 c6                	mov    %eax,%esi
   447a7:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   447ab:	48 8b 40 08          	mov    0x8(%rax),%rax
   447af:	48 8d 48 02          	lea    0x2(%rax),%rcx
   447b3:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
   447b7:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
   447bb:	89 f2                	mov    %esi,%edx
   447bd:	66 89 10             	mov    %dx,(%rax)
        for (; pos != 80; pos++) {
   447c0:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
   447c4:	83 7d fc 50          	cmpl   $0x50,-0x4(%rbp)
   447c8:	75 d5                	jne    4479f <console_putc+0x8a>
        }
    } else {
        *cp->cursor++ = c | color;
    }
}
   447ca:	eb 24                	jmp    447f0 <console_putc+0xdb>
        *cp->cursor++ = c | color;
   447cc:	0f b6 45 e7          	movzbl -0x19(%rbp),%eax
   447d0:	8b 55 e0             	mov    -0x20(%rbp),%edx
   447d3:	09 d0                	or     %edx,%eax
   447d5:	89 c6                	mov    %eax,%esi
   447d7:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   447db:	48 8b 40 08          	mov    0x8(%rax),%rax
   447df:	48 8d 48 02          	lea    0x2(%rax),%rcx
   447e3:	48 8b 55 f0          	mov    -0x10(%rbp),%rdx
   447e7:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
   447eb:	89 f2                	mov    %esi,%edx
   447ed:	66 89 10             	mov    %dx,(%rax)
}
   447f0:	90                   	nop
   447f1:	c9                   	leave
   447f2:	c3                   	ret

00000000000447f3 <console_vprintf>:

int console_vprintf(int cpos, int color, const char* format, va_list val) {
   447f3:	55                   	push   %rbp
   447f4:	48 89 e5             	mov    %rsp,%rbp
   447f7:	48 83 ec 30          	sub    $0x30,%rsp
   447fb:	89 7d ec             	mov    %edi,-0x14(%rbp)
   447fe:	89 75 e8             	mov    %esi,-0x18(%rbp)
   44801:	48 89 55 e0          	mov    %rdx,-0x20(%rbp)
   44805:	48 89 4d d8          	mov    %rcx,-0x28(%rbp)
    struct console_printer cp;
    cp.p.putc = console_putc;
   44809:	48 c7 45 f0 15 47 04 	movq   $0x44715,-0x10(%rbp)
   44810:	00 
    if (cpos < 0 || cpos >= CONSOLE_ROWS * CONSOLE_COLUMNS) {
   44811:	83 7d ec 00          	cmpl   $0x0,-0x14(%rbp)
   44815:	78 09                	js     44820 <console_vprintf+0x2d>
   44817:	81 7d ec cf 07 00 00 	cmpl   $0x7cf,-0x14(%rbp)
   4481e:	7e 07                	jle    44827 <console_vprintf+0x34>
        cpos = 0;
   44820:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%rbp)
    }
    cp.cursor = console + cpos;
   44827:	8b 45 ec             	mov    -0x14(%rbp),%eax
   4482a:	48 98                	cltq
   4482c:	48 01 c0             	add    %rax,%rax
   4482f:	48 05 00 80 0b 00    	add    $0xb8000,%rax
   44835:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    printer_vprintf(&cp.p, color, format, val);
   44839:	48 8b 4d d8          	mov    -0x28(%rbp),%rcx
   4483d:	48 8b 55 e0          	mov    -0x20(%rbp),%rdx
   44841:	8b 75 e8             	mov    -0x18(%rbp),%esi
   44844:	48 8d 45 f0          	lea    -0x10(%rbp),%rax
   44848:	48 89 c7             	mov    %rax,%rdi
   4484b:	e8 4d f4 ff ff       	call   43c9d <printer_vprintf>
    return cp.cursor - console;
   44850:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   44854:	48 2d 00 80 0b 00    	sub    $0xb8000,%rax
   4485a:	48 d1 f8             	sar    $1,%rax
}
   4485d:	c9                   	leave
   4485e:	c3                   	ret

000000000004485f <console_printf>:

int console_printf(int cpos, int color, const char* format, ...) {
   4485f:	55                   	push   %rbp
   44860:	48 89 e5             	mov    %rsp,%rbp
   44863:	48 83 ec 60          	sub    $0x60,%rsp
   44867:	89 7d ac             	mov    %edi,-0x54(%rbp)
   4486a:	89 75 a8             	mov    %esi,-0x58(%rbp)
   4486d:	48 89 55 a0          	mov    %rdx,-0x60(%rbp)
   44871:	48 89 4d e8          	mov    %rcx,-0x18(%rbp)
   44875:	4c 89 45 f0          	mov    %r8,-0x10(%rbp)
   44879:	4c 89 4d f8          	mov    %r9,-0x8(%rbp)
    va_list val;
    va_start(val, format);
   4487d:	c7 45 b8 18 00 00 00 	movl   $0x18,-0x48(%rbp)
   44884:	48 8d 45 10          	lea    0x10(%rbp),%rax
   44888:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
   4488c:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
   44890:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    cpos = console_vprintf(cpos, color, format, val);
   44894:	48 8d 4d b8          	lea    -0x48(%rbp),%rcx
   44898:	48 8b 55 a0          	mov    -0x60(%rbp),%rdx
   4489c:	8b 75 a8             	mov    -0x58(%rbp),%esi
   4489f:	8b 45 ac             	mov    -0x54(%rbp),%eax
   448a2:	89 c7                	mov    %eax,%edi
   448a4:	e8 4a ff ff ff       	call   447f3 <console_vprintf>
   448a9:	89 45 ac             	mov    %eax,-0x54(%rbp)
    va_end(val);
    return cpos;
   448ac:	8b 45 ac             	mov    -0x54(%rbp),%eax
}
   448af:	c9                   	leave
   448b0:	c3                   	ret

00000000000448b1 <string_putc>:
    printer p;
    char* s;
    char* end;
} string_printer;

static void string_putc(printer* p, unsigned char c, int color) {
   448b1:	55                   	push   %rbp
   448b2:	48 89 e5             	mov    %rsp,%rbp
   448b5:	48 83 ec 20          	sub    $0x20,%rsp
   448b9:	48 89 7d e8          	mov    %rdi,-0x18(%rbp)
   448bd:	40 88 75 e7          	mov    %sil,-0x19(%rbp)
   448c1:	89 55 e0             	mov    %edx,-0x20(%rbp)
    string_printer* sp = (string_printer*) p;
   448c4:	48 8b 45 e8          	mov    -0x18(%rbp),%rax
   448c8:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    if (sp->s < sp->end) {
   448cc:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   448d0:	48 8b 50 08          	mov    0x8(%rax),%rdx
   448d4:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   448d8:	48 8b 40 10          	mov    0x10(%rax),%rax
   448dc:	48 39 c2             	cmp    %rax,%rdx
   448df:	73 1a                	jae    448fb <string_putc+0x4a>
        *sp->s++ = c;
   448e1:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
   448e5:	48 8b 40 08          	mov    0x8(%rax),%rax
   448e9:	48 8d 48 01          	lea    0x1(%rax),%rcx
   448ed:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
   448f1:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
   448f5:	0f b6 55 e7          	movzbl -0x19(%rbp),%edx
   448f9:	88 10                	mov    %dl,(%rax)
    }
    (void) color;
}
   448fb:	90                   	nop
   448fc:	c9                   	leave
   448fd:	c3                   	ret

00000000000448fe <vsnprintf>:

int vsnprintf(char* s, size_t size, const char* format, va_list val) {
   448fe:	55                   	push   %rbp
   448ff:	48 89 e5             	mov    %rsp,%rbp
   44902:	48 83 ec 40          	sub    $0x40,%rsp
   44906:	48 89 7d d8          	mov    %rdi,-0x28(%rbp)
   4490a:	48 89 75 d0          	mov    %rsi,-0x30(%rbp)
   4490e:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
   44912:	48 89 4d c0          	mov    %rcx,-0x40(%rbp)
    string_printer sp;
    sp.p.putc = string_putc;
   44916:	48 c7 45 e8 b1 48 04 	movq   $0x448b1,-0x18(%rbp)
   4491d:	00 
    sp.s = s;
   4491e:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
   44922:	48 89 45 f0          	mov    %rax,-0x10(%rbp)
    if (size) {
   44926:	48 83 7d d0 00       	cmpq   $0x0,-0x30(%rbp)
   4492b:	74 33                	je     44960 <vsnprintf+0x62>
        sp.end = s + size - 1;
   4492d:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
   44931:	48 8d 50 ff          	lea    -0x1(%rax),%rdx
   44935:	48 8b 45 d8          	mov    -0x28(%rbp),%rax
   44939:	48 01 d0             	add    %rdx,%rax
   4493c:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
        printer_vprintf(&sp.p, 0, format, val);
   44940:	48 8b 4d c0          	mov    -0x40(%rbp),%rcx
   44944:	48 8b 55 c8          	mov    -0x38(%rbp),%rdx
   44948:	48 8d 45 e8          	lea    -0x18(%rbp),%rax
   4494c:	be 00 00 00 00       	mov    $0x0,%esi
   44951:	48 89 c7             	mov    %rax,%rdi
   44954:	e8 44 f3 ff ff       	call   43c9d <printer_vprintf>
        *sp.s = 0;
   44959:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   4495d:	c6 00 00             	movb   $0x0,(%rax)
    }
    return sp.s - s;
   44960:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
   44964:	48 2b 45 d8          	sub    -0x28(%rbp),%rax
}
   44968:	c9                   	leave
   44969:	c3                   	ret

000000000004496a <snprintf>:

int snprintf(char* s, size_t size, const char* format, ...) {
   4496a:	55                   	push   %rbp
   4496b:	48 89 e5             	mov    %rsp,%rbp
   4496e:	48 83 ec 70          	sub    $0x70,%rsp
   44972:	48 89 7d a8          	mov    %rdi,-0x58(%rbp)
   44976:	48 89 75 a0          	mov    %rsi,-0x60(%rbp)
   4497a:	48 89 55 98          	mov    %rdx,-0x68(%rbp)
   4497e:	48 89 4d e8          	mov    %rcx,-0x18(%rbp)
   44982:	4c 89 45 f0          	mov    %r8,-0x10(%rbp)
   44986:	4c 89 4d f8          	mov    %r9,-0x8(%rbp)
    va_list val;
    va_start(val, format);
   4498a:	c7 45 b0 18 00 00 00 	movl   $0x18,-0x50(%rbp)
   44991:	48 8d 45 10          	lea    0x10(%rbp),%rax
   44995:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
   44999:	48 8d 45 d0          	lea    -0x30(%rbp),%rax
   4499d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
    int n = vsnprintf(s, size, format, val);
   449a1:	48 8d 4d b0          	lea    -0x50(%rbp),%rcx
   449a5:	48 8b 55 98          	mov    -0x68(%rbp),%rdx
   449a9:	48 8b 75 a0          	mov    -0x60(%rbp),%rsi
   449ad:	48 8b 45 a8          	mov    -0x58(%rbp),%rax
   449b1:	48 89 c7             	mov    %rax,%rdi
   449b4:	e8 45 ff ff ff       	call   448fe <vsnprintf>
   449b9:	89 45 cc             	mov    %eax,-0x34(%rbp)
    va_end(val);
    return n;
   449bc:	8b 45 cc             	mov    -0x34(%rbp),%eax
}
   449bf:	c9                   	leave
   449c0:	c3                   	ret

00000000000449c1 <console_clear>:


// console_clear
//    Erases the console and moves the cursor to the upper left (CPOS(0, 0)).

void console_clear(void) {
   449c1:	55                   	push   %rbp
   449c2:	48 89 e5             	mov    %rsp,%rbp
   449c5:	48 83 ec 10          	sub    $0x10,%rsp
    for (int i = 0; i < CONSOLE_ROWS * CONSOLE_COLUMNS; ++i) {
   449c9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%rbp)
   449d0:	eb 13                	jmp    449e5 <console_clear+0x24>
        console[i] = ' ' | 0x0700;
   449d2:	8b 45 fc             	mov    -0x4(%rbp),%eax
   449d5:	48 98                	cltq
   449d7:	66 c7 84 00 00 80 0b 	movw   $0x720,0xb8000(%rax,%rax,1)
   449de:	00 20 07 
    for (int i = 0; i < CONSOLE_ROWS * CONSOLE_COLUMNS; ++i) {
   449e1:	83 45 fc 01          	addl   $0x1,-0x4(%rbp)
   449e5:	81 7d fc cf 07 00 00 	cmpl   $0x7cf,-0x4(%rbp)
   449ec:	7e e4                	jle    449d2 <console_clear+0x11>
    }
    cursorpos = 0;
   449ee:	c7 05 04 46 07 00 00 	movl   $0x0,0x74604(%rip)        # b8ffc <cursorpos>
   449f5:	00 00 00 
}
   449f8:	90                   	nop
   449f9:	c9                   	leave
   449fa:	c3                   	ret
