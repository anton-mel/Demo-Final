// elf.rs (ported from shared/elf.h)
//
//   Structures and constants for ELF (Executable Linking Format) executable
//   files.

pub const ELF_MAGIC: u32 = 0x464C457F; // "\x7FELF" in little endian

// executable header
#[repr(C)]
#[derive(Clone, Copy)]
pub struct ElfHeader {
    pub e_magic: u32,     // @0 must equal ELF_MAGIC
    pub e_elf: [u8; 12],
    pub e_type: u16,      // @0x10
    pub e_machine: u16,
    pub e_version: u32,
    pub e_entry: u64,     // @0x18 entry point: address of first instruction
    pub e_phoff: u64,     // @0x20 offset from ElfHeader to 1st ElfProgram
    pub e_shoff: u64,     // @0x28 offset from ElfHeader to 1st ElfSection
    pub e_flags: u32,
    pub e_ehsize: u16,
    pub e_phentsize: u16, // @0x36 should equal size_of::<ElfProgram>()
    pub e_phnum: u16,     // @0x38 number of ElfPrograms
    pub e_shentsize: u16, // @0x3a should equal size_of::<ElfSection>()
    pub e_shnum: u16,     // @0x3c number of ElfSections
    pub e_shstrndx: u16,  // @0x3e
}

// program header (required by the loader)
#[repr(C)]
#[derive(Clone, Copy)]
pub struct ElfProgram {
    pub p_type: u32,   // @0x00 see ELF_PTYPE below
    pub p_flags: u32,  // @0x04 see ELF_PFLAG below
    pub p_offset: u64, // @0x08 offset from ElfHeader to program data
    pub p_va: u64,     // @0x10 virtual address to load data
    pub p_pa: u64,     // @0x18 not used
    pub p_filesz: u64, // @0x20 number of bytes of program data
    pub p_memsz: u64,  // @0x28 number of bytes in memory (any bytes beyond
                       //   p_filesz are initialized to zero)
    pub p_align: u64,  // @0x30
}

// Values for ElfProgram::p_type
pub const ELF_PTYPE_LOAD: u32 = 1;

// Flag bits for ElfProgram::p_flags
pub const ELF_PFLAG_EXEC: u32 = 1;
pub const ELF_PFLAG_WRITE: u32 = 2;
pub const ELF_PFLAG_READ: u32 = 4;

// Values for elf_section::s_type
pub const ELF_STYPE_NULL: u32 = 0;
pub const ELF_STYPE_PROGBITS: u32 = 1;
pub const ELF_STYPE_SYMTAB: u32 = 2;
pub const ELF_STYPE_STRTAB: u32 = 3;

// Values for ElfSection::s_name
pub const ELF_SNAME_UNDEF: u32 = 0;
