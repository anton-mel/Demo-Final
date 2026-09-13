OBJDIR := obj
comma = ,

# Cross-compiler toolchain
#
# macOS ships a Mach-O-only `cc`/`ld` (Clang + ld64), which can't produce
# the ELF binaries this OS needs. On Darwin, use the `x86_64-elf-*` cross
# toolchain instead (e.g. `brew install x86_64-elf-gcc x86_64-elf-binutils`).
# Linux (including the course's Zoo machines) keeps using the native tools.
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
GCCPREFIX ?= x86_64-elf-
CC      = $(GCCPREFIX)gcc
CXX     = $(GCCPREFIX)g++
else
GCCPREFIX ?=
CC      = $(GCCPREFIX)cc
CXX     = $(GCCPREFIX)c++
endif
AS      = $(GCCPREFIX)as
AR      = $(GCCPREFIX)ar
LD      = $(GCCPREFIX)ld
OBJCOPY = $(GCCPREFIX)objcopy
OBJDUMP = $(GCCPREFIX)objdump
NM      = $(GCCPREFIX)nm
STRIP   = $(GCCPREFIX)strip

# Native commands
HOSTCC  = cc
TAR     = tar
PERL    = perl
# Compiler flags
# -Os is required for the boot loader to fit within 512 bytes;
# -ffreestanding means there is no standard library.
CPPFLAGS := $(DEFS) -I. -nostdinc
CFLAGS := $(CFLAGS) \
	-std=gnu11 -m64 \
	-mno-red-zone -mno-mmx -mno-sse -mno-sse2 -mno-sse3 -mno-3dnow \
	-ffreestanding -fno-omit-frame-pointer \
	-Wall -W -Wshadow -Wno-format -Wno-unused -Werror -gdwarf-2 \
	-Wa,--divide
# Include -fno-stack-protector if the option exists.
CFLAGS += $(shell $(CC) -fno-stack-protector -E -x c /dev/null >/dev/null 2>&1 && echo -fno-stack-protector)
DEPCFLAGS = -MD -MF $(DEPSDIR)/$*.d -MP

# Linker flags
LDFLAGS := $(LDFLAGS) --gc-sections -z max-page-size=0x1000 -static -nostdlib -n -o startfiles
LDFLAGS	+= $(shell $(LD) -m elf_x86_64 --help >/dev/null 2>&1 && echo -m elf_x86_64)


# Dependencies
DEPSDIR := .deps
BUILDSTAMP := $(DEPSDIR)/rebuildstamp
DEPFILES := $(wildcard $(DEPSDIR)/*.d)
ifneq ($(DEPFILES),)
include $(DEPFILES)
endif

ifneq ($(DEP_CC),$(CC) $(CPPFLAGS) $(CFLAGS) $(DEPCFLAGS) $(O) _ $(LDFLAGS))
DEP_CC := $(shell mkdir -p $(DEPSDIR); echo >$(BUILDSTAMP); echo "DEP_CC:=$(CC) $(CPPFLAGS) $(CFLAGS) $(DEPCFLAGS) $(O) _ $(LDFLAGS)" >$(DEPSDIR)/_cc.d; echo "DEP_PREFER_GCC:=$(PREFER_GCC)" >>$(DEPSDIR)/_cc.d)
endif

BUILDSTAMPS = $(OBJDIR)/stamp $(BUILDSTAMP)

$(OBJDIR)/stamp $(BUILDSTAMP):
	$(call run,mkdir -p $(@D))
	$(call run,touch $@)


# Qemu emulator
INFERRED_QEMU := $(shell if which qemu-system-x86_64 2>/dev/null | grep ^/ >/dev/null 2>&1; \
	then echo qemu-system-x86_64; \
	elif grep 16 /etc/fedora-release >/dev/null 2>&1; \
	then echo qemu; else echo qemu-system-x86_64; fi)
QEMU ?= $(INFERRED_QEMU)
QEMUOPT	= -net none -parallel file:log.txt
QEMUCONSOLE ?= $(if $(DISPLAY),,1)
QEMUDISPLAY = $(if $(QEMUCONSOLE),console,graphic)

QEMU_PRELOAD_LIBRARY = $(OBJDIR)/libqemu-nograb.so.1

$(QEMU_PRELOAD_LIBRARY): build/qemu-nograb.c
	$(call run,mkdir -p $(@D))
# The LD_PRELOAD nograb trick is Linux/X11-only, so skip building it on
# macOS (its dyld has no equivalent, and its `ld` doesn't understand -soname).
ifneq ($(UNAME_S),Darwin)
	-$(call run,$(HOSTCC) -fPIC -shared -Wl$(comma)-soname$(comma)$(@F) -ldl -o $@ $<)
endif

QEMU_PRELOAD = $(shell if test -r $(QEMU_PRELOAD_LIBRARY); then echo LD_PRELOAD=$(QEMU_PRELOAD_LIBRARY); fi)

QEMUIMG = -drive file=$<,if=ide,format=raw


# Run the emulator

check-qemu: $(QEMU_PRELOAD_LIBRARY)
	@if test -z "$$(which $(QEMU) 2>/dev/null)"; then \
	    echo 1>&2; echo "***" 1>&2; \
	    echo "*** Cannot run $(QEMU). You may not have installed it yet." 1>&2; \
	    if test -x /usr/bin/apt-get; then \
	        cmd="apt-get -y install"; else cmd="yum install -y"; fi; \
	    if test $$(whoami) = jharvard; then \
	        echo "*** I am going to try to install it for you." 1>&2; \
	        echo "***" 1>&2; echo 1>&2; \
	        echo sudo $$cmd qemu-system-x86; \
	        sudo $$cmd qemu-system-x86 || exit 1; \
	    else echo "*** Try running this command to install it:" 1>&2; \
	        echo sudo $$cmd qemu-system-x86 1>&2; \
	        echo 1>&2; exit 1; fi; \
	else :; fi

# Delete the build
clean:
	$(call run,rm -rf $(DEPSDIR) $(OBJDIR) *.img core *.core,CLEAN)

realclean: clean
	$(call run,rm -rf $(DISTDIR)-$(USER).tar.gz $(DISTDIR)-$(USER))

distclean: realclean
	@:


# Boilerplate
always:
	@:

# These targets don't correspond to files
.PHONY: all always clean realclean distclean \
	run run-qemu run-graphic run-console run-gdb \
	run-gdb-graphic run-gdb-console run-graphic-gdb run-console-gdb \
	check-qemu kill \
	run-% run-qemu-% run-graphic-% run-console-% \
	run-gdb-% run-gdb-graphic-% run-gdb-console-% \
	test-% \
	restore

# Eliminate default suffix rules
.SUFFIXES:

# Keep intermediate files
.SECONDARY:

# Delete target files if there is an error (or make is interrupted)
.DELETE_ON_ERROR:

# But no intermediate .o files should be deleted
.PRECIOUS: %.o $(OBJDIR)/%.o $(OBJDIR)/%.full $(OBJDIR)/bootsector
