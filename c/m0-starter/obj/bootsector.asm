
obj/bootsector.full:     file format elf64-x86-64


Disassembly of section .text:

0000000000007c00 <boot_start>:
.set SEGSEL_BOOT_CODE,0x8       # code segment selector

.globl boot_start                               # Entry point
boot_start:
        .code16                         # This runs in real mode
        cli                             # Disable interrupts
    7c00:	fa                   	cli
        cld                             # String operations increment
    7c01:	fc                   	cld

        # All segments are initially 0.
        # Set up the stack pointer, growing downward from 0x7c00.
        movw    $boot_start, %sp
    7c02:	bc                   	.byte 0xbc
    7c03:	00                   	.byte 0
    7c04:	7c                   	.byte 0x7c

0000000000007c05 <seta20.1>:
#   and subsequent 80286-based PCs wanted to retain maximum compatibility),
#   physical address line 20 is tied to low when the machine boots.
#   Obviously this a bit of a drag for us, especially when trying to
#   address memory above 1MB.  This code undoes this.

seta20.1:       inb     $0x64, %al              # Get status
    7c05:	e4 64                	in     $0x64,%al
                testb   $0x2, %al               # Busy?
    7c07:	a8 02                	test   $0x2,%al
                jnz     seta20.1                # Yes
    7c09:	75 fa                	jne    7c05 <seta20.1>
                movb    $0xd1, %al              # Command: Write
    7c0b:	b0 d1                	mov    $0xd1,%al
                outb    %al, $0x64              #  output port
    7c0d:	e6 64                	out    %al,$0x64

0000000000007c0f <seta20.2>:
seta20.2:       inb     $0x64, %al              # Get status
    7c0f:	e4 64                	in     $0x64,%al
                testb   $0x2, %al               # Busy?
    7c11:	a8 02                	test   $0x2,%al
                jnz     seta20.2                # Yes
    7c13:	75 fa                	jne    7c0f <seta20.2>
                movb    $0xdf, %al              # Command: Enable
    7c15:	b0 df                	mov    $0xdf,%al
                outb    %al, $0x60              #  A20
    7c17:	e6 60                	out    %al,$0x60

0000000000007c19 <init_pt>:
        .set PTE_U,4
        .set PTE_PS,128

        .code16
init_pt:
        movl    $INITIAL_PT, %edi       # clear page table memory
    7c19:	66 bf 00 80          	mov    $0x8000,%di
    7c1d:	00 00                	add    %al,(%rax)
        xorl    %eax, %eax
    7c1f:	66 31 c0             	xor    %ax,%ax
        movl    $(0x3000 / 4), %ecx
    7c22:	66 b9 00 0c          	mov    $0xc00,%cx
    7c26:	00 00                	add    %al,(%rax)
        rep stosl
    7c28:	66 f3 ab             	rep stos %ax,(%rdi)
        # 0x8000: L1 page table; entry 0 points to:
        # 0x9000: L2 page table; entry 0 points to:
        # 0xA000: L3 page table; entry 0 is a huge page covering 0-0x3FFFFFFF
        # Modern x86-64 processors support PTE_PS on L2 page entries,
        # but the this QEMU version does not.
        movl    $INITIAL_PT, %edi       # set up page table: use a large page
    7c2b:	66 bf 00 80          	mov    $0x8000,%di
    7c2f:	00 00                	add    %al,(%rax)
        leal    (0x1000 + PTE_P + PTE_W + PTE_U)(%edi), %ecx
    7c31:	67 66 8d 8f 07 10 00 	lea    0x1007(%edi),%cx
    7c38:	00 
        movl    %ecx, (%edi)
    7c39:	67 66 89 0f          	mov    %cx,(%edi)
        leal    (0x2000 + PTE_P + PTE_W + PTE_U)(%edi), %ecx
    7c3d:	67 66 8d 8f 07 20 00 	lea    0x2007(%edi),%cx
    7c44:	00 
        movl    %ecx, 0x1000(%edi)
    7c45:	67 66 89 8f 00 10 00 	mov    %cx,0x1000(%edi)
    7c4c:	00 
        movl    $(PTE_P + PTE_W + PTE_U + PTE_PS), -7(%ecx)
    7c4d:	67 66 c7 41 f9 87 00 	movw   $0x87,-0x7(%ecx)
    7c54:	00 00                	add    %al,(%rax)
        movl    %edi, %cr3
    7c56:	0f 22 df             	mov    %rdi,%cr3

0000000000007c59 <real_to_prot>:
        .set IA32_EFER_SCE,1            # enable syscall/sysret
        .set IA32_EFER_LME,0x100        # enable 64-bit mode
        .set IA32_EFER_NXE,0x800

real_to_prot:
        movl    %cr4, %eax              # enable physical address extensions
    7c59:	0f 20 e0             	mov    %cr4,%rax
        orl     $(CR4_PSE | CR4_PAE), %eax
    7c5c:	66 83 c8 30          	or     $0x30,%ax
        movl    %eax, %cr4
    7c60:	0f 22 e0             	mov    %rax,%cr4

        movl    $MSR_IA32_EFER, %ecx    # turn on 64-bit mode
    7c63:	66 b9 80 00          	mov    $0x80,%cx
    7c67:	00 c0                	add    %al,%al
        rdmsr
    7c69:	0f 32                	rdmsr
        orl     $(IA32_EFER_LME | IA32_EFER_SCE | IA32_EFER_NXE), %eax
    7c6b:	66 0d 01 09          	or     $0x901,%ax
    7c6f:	00 00                	add    %al,(%rax)
        wrmsr
    7c71:	0f 30                	wrmsr

        movl    %cr0, %eax              # turn on protected mode
    7c73:	0f 20 c0             	mov    %cr0,%rax
        orl     $(CR0_PE | CR0_WP | CR0_PG), %eax
    7c76:	66 0d 01 00          	or     $0x1,%ax
    7c7a:	01 80 0f 22 c0 0f    	add    %eax,0xfc0220f(%rax)
        movl    %eax, %cr0

        lgdt    gdtdesc                 # load GDT
    7c80:	01 16                	add    %edx,(%rsi)
    7c82:	9c                   	pushf
    7c83:	7c ea                	jl     7c6f <real_to_prot+0x16>

        # CPU magic: jump to relocation, flush prefetch queue, and
        # reload %cs.  Has the effect of just jmp to the next
        # instruction, but simultaneously loads CS with
        # $SEGSEL_BOOT_CODE.
        ljmp    $SEGSEL_BOOT_CODE, $boot
    7c85:	5b                   	pop    %rbx
    7c86:	7d 08                	jge    7c90 <gdt+0x4>
    7c88:	00 0f                	add    %cl,(%rdi)
    7c8a:	1f                   	(bad)
	...

0000000000007c8c <gdt>:
	...
    7c98:	00                   	.byte 0
    7c99:	98                   	cwtl
    7c9a:	20 00                	and    %al,(%rax)

0000000000007c9c <gdtdesc>:
    7c9c:	0f 00 8c 7c 00 00 00 	str    0x0(%rsp,%rdi,2)
    7ca3:	00 
	...

0000000000007ca6 <boot_readseg>:
//    Load an ELF segment at virtual address `dst` from the IDE disk's sector
//    `src_sect`. Copies `filesz` bytes into memory at `dst` from sectors
//    `src_sect` and up, then clears memory in the range
//    `[dst+filesz, dst+memsz)`.
static void boot_readseg(uintptr_t ptr, uint32_t src_sect,
                         size_t filesz, size_t memsz) {
    7ca6:	41 57                	push   %r15
    7ca8:	41 89 f0             	mov    %esi,%r8d
    uintptr_t end_ptr = ptr + filesz;
    memsz += ptr;

    // round down to sector boundary
    ptr &= ~(SECTORSIZE - 1);
    7cab:	48 89 fe             	mov    %rdi,%rsi
    uintptr_t end_ptr = ptr + filesz;
    7cae:	4c 8d 0c 17          	lea    (%rdi,%rdx,1),%r9
                         size_t filesz, size_t memsz) {
    7cb2:	41 56                	push   %r14
    memsz += ptr;
    7cb4:	4c 8d 1c 0f          	lea    (%rdi,%rcx,1),%r11
    ptr &= ~(SECTORSIZE - 1);
    7cb8:	48 81 e6 00 fe ff ff 	and    $0xfffffffffffffe00,%rsi
                         size_t filesz, size_t memsz) {
    7cbf:	41 55                	push   %r13
    7cc1:	41 54                	push   %r12
    7cc3:	55                   	push   %rbp
                 : "d" (port), "0" (addr), "1" (cnt)
                 : "memory", "cc");
}

static inline void outb(int port, uint8_t data) {
    asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
    7cc4:	bd f3 01 00 00       	mov    $0x1f3,%ebp
    7cc9:	53                   	push   %rbx

    // read sectors
    for (; ptr < end_ptr; ptr += SECTORSIZE, ++src_sect) {
    7cca:	4c 39 ce             	cmp    %r9,%rsi
    7ccd:	73 73                	jae    7d42 <boot_readseg+0x9c>
    asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
    7ccf:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7cd4:	ec                   	in     (%dx),%al
// boot_waitdisk
//    Wait for the disk to be ready.
static void boot_waitdisk(void) {
    // Wait until the ATA status register says ready (0x40 is on)
    // & not busy (0x80 is off)
    while ((inb(0x1F7) & 0xC0) != 0x40) {
    7cd5:	83 e0 c0             	and    $0xffffffc0,%eax
    7cd8:	3c 40                	cmp    $0x40,%al
    7cda:	75 f3                	jne    7ccf <boot_readseg+0x29>
    asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
    7cdc:	b0 01                	mov    $0x1,%al
    7cde:	ba f2 01 00 00       	mov    $0x1f2,%edx
    7ce3:	ee                   	out    %al,(%dx)
    7ce4:	44 89 c0             	mov    %r8d,%eax
    7ce7:	89 ea                	mov    %ebp,%edx
    7ce9:	ee                   	out    %al,(%dx)
static void boot_readsect(uintptr_t dst, uint32_t src_sect) {
    // programmed I/O for "read sector"
    boot_waitdisk();
    outb(0x1F2, 1);             // send `count = 1` as an ATA argument
    outb(0x1F3, src_sect);      // send `src_sect`, the sector number
    outb(0x1F4, src_sect >> 8);
    7cea:	44 89 c0             	mov    %r8d,%eax
    7ced:	ba f4 01 00 00       	mov    $0x1f4,%edx
    7cf2:	c1 e8 08             	shr    $0x8,%eax
    7cf5:	ee                   	out    %al,(%dx)
    outb(0x1F5, src_sect >> 16);
    7cf6:	44 89 c0             	mov    %r8d,%eax
    7cf9:	ba f5 01 00 00       	mov    $0x1f5,%edx
    7cfe:	c1 e8 10             	shr    $0x10,%eax
    7d01:	ee                   	out    %al,(%dx)
    outb(0x1F6, (src_sect >> 24) | 0xE0);
    7d02:	44 89 c0             	mov    %r8d,%eax
    7d05:	ba f6 01 00 00       	mov    $0x1f6,%edx
    7d0a:	c1 e8 18             	shr    $0x18,%eax
    7d0d:	83 c8 e0             	or     $0xffffffe0,%eax
    7d10:	ee                   	out    %al,(%dx)
    7d11:	b0 20                	mov    $0x20,%al
    7d13:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7d18:	ee                   	out    %al,(%dx)
    asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
    7d19:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7d1e:	ec                   	in     (%dx),%al
    while ((inb(0x1F7) & 0xC0) != 0x40) {
    7d1f:	83 e0 c0             	and    $0xffffffc0,%eax
    7d22:	3c 40                	cmp    $0x40,%al
    7d24:	75 f3                	jne    7d19 <boot_readseg+0x73>
    asm volatile("cld\n\trepne\n\tinsl"
    7d26:	48 89 f7             	mov    %rsi,%rdi
    7d29:	b9 80 00 00 00       	mov    $0x80,%ecx
    7d2e:	ba f0 01 00 00       	mov    $0x1f0,%edx
    7d33:	fc                   	cld
    7d34:	f2 6d                	repnz insl (%dx),(%rdi)
    for (; ptr < end_ptr; ptr += SECTORSIZE, ++src_sect) {
    7d36:	48 81 c6 00 02 00 00 	add    $0x200,%rsi
    7d3d:	41 ff c0             	inc    %r8d
    7d40:	eb 88                	jmp    7cca <boot_readseg+0x24>
    for (; end_ptr < memsz; ++end_ptr) {
    7d42:	4d 39 d9             	cmp    %r11,%r9
    7d45:	73 09                	jae    7d50 <boot_readseg+0xaa>
        *(uint8_t*) end_ptr = 0;
    7d47:	41 c6 01 00          	movb   $0x0,(%r9)
    for (; end_ptr < memsz; ++end_ptr) {
    7d4b:	49 ff c1             	inc    %r9
    7d4e:	eb f2                	jmp    7d42 <boot_readseg+0x9c>
}
    7d50:	5b                   	pop    %rbx
    7d51:	5d                   	pop    %rbp
    7d52:	41 5c                	pop    %r12
    7d54:	41 5d                	pop    %r13
    7d56:	41 5e                	pop    %r14
    7d58:	41 5f                	pop    %r15
    7d5a:	c3                   	ret

0000000000007d5b <boot>:
void boot(void) {
    7d5b:	53                   	push   %rbx
    boot_readseg((uintptr_t) ELFHDR, 1, PAGESIZE, PAGESIZE);
    7d5c:	b9 00 10 00 00       	mov    $0x1000,%ecx
    7d61:	ba 00 10 00 00       	mov    $0x1000,%edx
    7d66:	be 01 00 00 00       	mov    $0x1,%esi
    7d6b:	bf 00 00 01 00       	mov    $0x10000,%edi
    7d70:	e8 31 ff ff ff       	call   7ca6 <boot_readseg>
    while (ELFHDR->e_magic != ELF_MAGIC) {
    7d75:	81 3c 25 00 00 01 00 	cmpl   $0x464c457f,0x10000
    7d7c:	7f 45 4c 46 
    7d80:	74 02                	je     7d84 <boot+0x29>
    7d82:	eb fe                	jmp    7d82 <boot+0x27>
    elf_program* eph = ph + ELFHDR->e_phnum;
    7d84:	0f b7 1c 25 38 00 01 	movzwl 0x10038,%ebx
    7d8b:	00 
    elf_program* ph = (elf_program*) ((uint8_t*) ELFHDR + ELFHDR->e_phoff);
    7d8c:	48 8b 04 25 20 00 01 	mov    0x10020,%rax
    7d93:	00 
    elf_program* eph = ph + ELFHDR->e_phnum;
    7d94:	48 6b db 38          	imul   $0x38,%rbx,%rbx
    elf_program* ph = (elf_program*) ((uint8_t*) ELFHDR + ELFHDR->e_phoff);
    7d98:	4c 8d 90 00 00 01 00 	lea    0x10000(%rax),%r10
    elf_program* eph = ph + ELFHDR->e_phnum;
    7d9f:	4c 01 d3             	add    %r10,%rbx
    for (; ph < eph; ++ph) {
    7da2:	49 39 da             	cmp    %rbx,%r10
    7da5:	73 21                	jae    7dc8 <boot+0x6d>
        boot_readseg(ph->p_va, ph->p_offset / SECTORSIZE + 1,
    7da7:	49 8b 72 08          	mov    0x8(%r10),%rsi
    7dab:	49 8b 4a 28          	mov    0x28(%r10),%rcx
    for (; ph < eph; ++ph) {
    7daf:	49 83 c2 38          	add    $0x38,%r10
        boot_readseg(ph->p_va, ph->p_offset / SECTORSIZE + 1,
    7db3:	49 8b 52 e8          	mov    -0x18(%r10),%rdx
    7db7:	49 8b 7a d8          	mov    -0x28(%r10),%rdi
    7dbb:	48 c1 ee 09          	shr    $0x9,%rsi
    7dbf:	ff c6                	inc    %esi
    7dc1:	e8 e0 fe ff ff       	call   7ca6 <boot_readseg>
    for (; ph < eph; ++ph) {
    7dc6:	eb da                	jmp    7da2 <boot+0x47>
    kernel_entry();
    7dc8:	ff 14 25 18 00 01 00 	call   *0x10018
