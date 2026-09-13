OUTPUT_FORMAT(elf64-x86-64)
OUTPUT_ARCH(i386:x86-64)
ENTRY(process_main)

PHDRS {
    /* Flags are pinned explicitly (PF_R=4, PF_X=1, PF_W=2) rather than left
       for `ld` to compute from included sections' own flags: Rust code
       generates `.data.rel.ro*` sections (relocation metadata) that are
       marked writable in the object file even though, for this statically
       linked, fixed-address binary, nothing ever writes to them after
       link time -- letting `ld` infer flags would make it drag SHF_WRITE
       onto the whole text segment, which defeats Step 6's read-only ELF
       segment detection. */
    text PT_LOAD FLAGS(5);
    data PT_LOAD FLAGS(6);
}

SECTIONS {
    . = 0x100000;

    /* Text segment: instructions and read-only globals */
    .text : {
        *(.text.unlikely .text.*_unlikely .text.unlikely.*)
        *(.text.exit .text.exit.*)
        *(.text.startup .text.startup.*)
        *(.text.hot .text.hot.*)
        *(.text .stub .text.* .gnu.linkonce.t.*)
    } :text
    PROVIDE(etext = .);    /* Define the `etext` symbol at this location */
    .rodata : {
        *(.rodata .rodata.* .gnu.linkonce.r.*)
        *(.data.rel.ro.local* .gnu.linkonce.d.rel.ro.local.*)
        *(.data.rel.ro .data.rel.ro.* .gnu.linkonce.d.rel.ro.*)
    } :text

    /* Data segment: read/write and zero-initialized globals */
    . = ALIGN(4096);       /* Align to a page boundary */
    .data : {
        *(.data .data.* .gnu.linkonce.d.*)
        SORT(CONSTRUCTORS)
    } :data
    PROVIDE(edata = .);
    .bss : {
        *(.bss .bss.* .gnu.linkonce.b.*)
    } :data
    PROVIDE(end = .);

    /DISCARD/ : { *(.eh_frame .note.GNU-stack) }
}
