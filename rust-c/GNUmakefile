IMAGE = weensyos.img
all: $(IMAGE)
-include build/rules.mk

# DIRECTORIES
C_KERN_DIR  = ./kernel
R_KERN_DIR  = ./kernel/rust
SHARED_RUST_DIR = ./shared/rust
USPACE_DIR  = ./uspace
TEST_DIR = ./tests

ROOT_DIR := $(shell realpath $(CURDIR))

# '$(V)' controls whether the lab makefiles print verbose commands (the
# actual shell commands run by Make), as well as the "overview" commands
# (such as '+ cc lib/readline.c').
#
# For overview commands only, run 'make all'.
# For overview and verbose commands, run 'make V=1 all'.
V = 0

# $(INTERACTIVE) reports whether make is running in interactive shell or to file
# it will be used to enable/disable color coding
INTERACTIVE:=$(shell [ -t 0 ] && echo 1)

# COLOR OUTPUT CODES
# (`printf` interprets \033 portably across shells; `echo -e` does not --
# e.g. macOS's /bin/sh prints a literal "-e" instead of honoring the flag)
ifdef INTERACTIVE
	ccred:=$(shell printf '\033[0;31m')
	ccyellow:=$(shell printf '\033[0;33m')
	ccgreen:=$(shell printf '\033[1;32m')
	ccend:=$(shell printf '\033[0m')
else
	ccred:=""
	ccyellow:=""
	ccgreen:=""
	ccend:=""
endif

# If you are working locally, set to 0 to disable
# If you are using node.zoo.cs.edu, set 1 to enable
# (defaults off on macOS: `lockfile`, from procmail, isn't installed there)
USE_HOST_LOCK ?= $(if $(filter Darwin,$(shell uname -s)),0,1)

# locked img error messages
errbef:="$(ccred)Error, could not obtain lock. Are you running a session in - $(ccgreen)"
erraft:="$(ccred)If so try running $(ccgreen)make kill-lock$(ccred),\
		otherwise $(ccyellow)ssh in manually and run make kill$(ccend)"

HOST_FILE='.hosts.txt'
HOST_LOCK='.hosts.lock'

ifeq ($(V),1)
compile = $(CC) $(CPPFLAGS) $(CFLAGS) $(DEPCFLAGS) $(1)
link = $(LD) $(LDFLAGS) $(1)
run = $(1) $(3)
else
compile = @/bin/echo " " $(2) $< && $(CC) $(CPPFLAGS) $(CFLAGS) $(DEPCFLAGS) $(1)
link = @/bin/echo " " $(2) $(patsubst %.full,%,$@) && $(LD) $(LDFLAGS) $(1)
run = @$(if $(2),/bin/echo " " $(2) $(3) &&,) $(1) $(3)
endif


# --- Object sets ---

BOOT_OBJS = $(OBJDIR)/bootstart.o $(OBJDIR)/boot.o
KERNEL_LINKER_FILES = link/kernel.ld link/shared.ld
PROCESS_LINKER_FILES = link/process.ld link/shared.ld

PROCESS_BINARIES = $(OBJDIR)/p-allocator \
	$(OBJDIR)/p-malloc $(OBJDIR)/p-alloctests \
	$(OBJDIR)/p-test

LIB_OBJS = $(OBJDIR)/lib.o
PROCESS_LIB_OBJS = $(OBJDIR)/process.o $(OBJDIR)/malloc.o
PROCESS_OBJS = $(OBJDIR)/p-allocator.o $(OBJDIR)/p-malloc.o \
	$(OBJDIR)/p-alloctests.o $(OBJDIR)/p-test.o


# --- Rust build integration (kernel only -- uspace is plain C below) ---
export CARGO_TARGET_DIR := $(ROOT_DIR)/$(OBJDIR)/rust-target
RUST_RELEASE_DIR := $(CARGO_TARGET_DIR)/x86_64-weensyos/release

SHARED_RUST_SRCS := $(shell find $(SHARED_RUST_DIR)/src -type f) $(SHARED_RUST_DIR)/Cargo.toml

define RUST_CRATE_RULES
$(1)_EXTRACT_DIR = $(RUST_RELEASE_DIR)/extracted-$(3)
$(1)_OBJ = $$($(1)_EXTRACT_DIR)/$(3).o
$(1)_STAMP = $(CARGO_TARGET_DIR)/.cargo_build-$(3)
$(1)_SRCS := $$(shell find $(2)/src -type f) $(2)/Cargo.toml $$(SHARED_RUST_SRCS) $(4)

$$($(1)_STAMP): $$($(1)_SRCS)
	@echo "  CARGO $(2)"
	@mkdir -p $(CARGO_TARGET_DIR)
	@cd $(2) && cargo build --release
	@touch $$@

$$($(1)_OBJ): $$($(1)_STAMP)
	@mkdir -p $$($(1)_EXTRACT_DIR) && cd $$($(1)_EXTRACT_DIR) && rm -f *.o merged.o && \
	$(AR) x $(RUST_RELEASE_DIR)/lib$(3).a && sync && \
	$(LD) -r -o merged.o *.o && \
	mv -f merged.o $(3).o
endef

$(eval $(call RUST_CRATE_RULES,KERNEL,$(R_KERN_DIR),weensyos,))

# --- End Rust build integration ---

# --- Plain-C uspace build (Part 2 of this assignment, done entirely in
# C: malloc.c and the four test programs, compiled and linked exactly
# as in c/final, not through cargo at all) ---

$(LIB_OBJS): $(OBJDIR)/%.o: shared/%.c $(BUILDSTAMPS)
	$(call compile,-c $< -o $@,COMPILE)

$(PROCESS_LIB_OBJS): $(OBJDIR)/%.o: $(USPACE_DIR)/%.c $(BUILDSTAMPS)
	$(call compile,-O1 -DWEENSYOS_PROCESS -I ./shared -c $< -o $@,COMPILE)

$(PROCESS_OBJS): $(OBJDIR)/%.o: $(USPACE_DIR)/%.c $(BUILDSTAMPS)
	$(call compile,-O1 -DWEENSYOS_PROCESS -I ./shared -c $< -o $@,COMPILE)

# --- End plain-C uspace build ---

# k-vm.o: provided in compiled form only (no source), see kernel.rs's
# top-of-file comment -- just copy it into obj/ like any other object
# file so it can be linked into the final kernel binary.
$(OBJDIR)/k-vm.o: $(C_KERN_DIR)/k-vm.o $(BUILDSTAMPS)
	$(call run,cp $(C_KERN_DIR)/k-vm.o $(OBJDIR)/k-vm.o,COPY k-vm.o)


# Generic rules for making object files (boot chain only)

$(OBJDIR)/boot.o: $(OBJDIR)/%.o: $(C_KERN_DIR)/boot.c $(BUILDSTAMPS)
	$(call compile,-Os -fomit-frame-pointer -I ./shared -c $< -o $@,COMPILE)

$(OBJDIR)/%.o: $(C_KERN_DIR)/%.S $(BUILDSTAMPS)
	$(call compile,-I ./shared -c $< -o $@,ASSEMBLE)


# Specific rules for WeensyOS

$(OBJDIR)/kernel.full: $(KERNEL_OBJ) $(OBJDIR)/k-exception.o $(OBJDIR)/k-vm.o $(PROCESS_BINARIES) $(KERNEL_LINKER_FILES)
	$(call link,-T $(KERNEL_LINKER_FILES) -o $@ --start-group $(KERNEL_OBJ) $(OBJDIR)/k-exception.o $(OBJDIR)/k-vm.o --end-group -b binary $(PROCESS_BINARIES),LINK)

$(OBJDIR)/p-allocator.full: $(OBJDIR)/p-allocator.o $(LIB_OBJS) $(PROCESS_LIB_OBJS) link/p-allocator.ld link/shared.ld
	$(call link,-T link/p-allocator.ld link/shared.ld -o $@ $< $(PROCESS_LIB_OBJS) $(LIB_OBJS),LINK)

$(OBJDIR)/p-malloc.full: $(OBJDIR)/p-malloc.o $(LIB_OBJS) $(PROCESS_LIB_OBJS) $(PROCESS_LINKER_FILES)
	$(call link,-T $(PROCESS_LINKER_FILES) -o $@ $< $(PROCESS_LIB_OBJS) $(LIB_OBJS),LINK)

$(OBJDIR)/p-alloctests.full: $(OBJDIR)/p-alloctests.o $(LIB_OBJS) $(PROCESS_LIB_OBJS) link/p-alloctests.ld link/shared.ld
	$(call link,-T link/p-alloctests.ld link/shared.ld -o $@ $< $(PROCESS_LIB_OBJS) $(LIB_OBJS),LINK)

$(OBJDIR)/p-test.full: $(OBJDIR)/p-test.o $(LIB_OBJS) $(PROCESS_LIB_OBJS) $(PROCESS_LINKER_FILES)
	$(call link,-T $(PROCESS_LINKER_FILES) -o $@ $< $(PROCESS_LIB_OBJS) $(LIB_OBJS),LINK)

$(OBJDIR)/%: $(OBJDIR)/%.full
	$(call run,$(OBJDUMP) -S $< >$@.asm)
	$(call run,$(NM) -n $< >$@.sym)
	$(call run,$(OBJCOPY) -j .text -j .rodata -j .data -j .bss $<,STRIP,$@)

$(OBJDIR)/bootsector: $(BOOT_OBJS) link/boot.ld link/shared.ld
	$(call link,-T link/boot.ld link/shared.ld -o $@.full $(BOOT_OBJS),LINK)
	$(call run,$(OBJDUMP) -S $@.full >$@.asm)
	$(call run,$(NM) -n $@.full >$@.sym)
	$(call run,$(OBJCOPY) -S -O binary -j .text $@.full $@)

$(OBJDIR)/mkbootdisk: build/mkbootdisk.c $(BUILDSTAMPS)
	$(call run,$(HOSTCC) -I./shared -o $(OBJDIR)/mkbootdisk,HOSTCOMPILE,build/mkbootdisk.c)

weensyos.img: $(OBJDIR)/mkbootdisk $(OBJDIR)/bootsector $(OBJDIR)/kernel
	$(call run,$(OBJDIR)/mkbootdisk $(OBJDIR)/bootsector $(OBJDIR)/kernel > $@,CREATE $@)


run-%: run-qemu-%
	@:

run-qemu-%: run-$(QEMUDISPLAY)-%
	@:

run-graphic-%: %.img check-qemu
	@if [ "$(USE_HOST_LOCK)" -eq 1 ]; then \
	    lockfile -r 0 ./$(HOST_LOCK) || (echo ${errbef} && cat $(HOST_FILE); echo ${erraft}; exit 1); \
	    hostname > $(HOST_FILE); \
	fi
	$(call run,$(QEMU_PRELOAD) $(QEMU) $(QEMUOPT) $(QEMUIMG),QEMU $<)
	@if [ "$(USE_HOST_LOCK)" -eq 1 ]; then \
	    rm -f ./$(HOST_FILE); \
	    rm -f ./$(HOST_LOCK); \
	fi

run-console-%: %.img check-qemu
	@if [ "$(USE_HOST_LOCK)" -eq 1 ]; then \
	    lockfile -r 0 ./$(HOST_LOCK) || (echo ${errbef} && cat $(HOST_FILE); echo ${erraft}; exit 1); \
	    hostname > $(HOST_FILE); \
	fi
	$(call run,$(QEMU_PRELOAD) $(QEMU) $(QEMUOPT) -display curses $(QEMUIMG),QEMU $<)
	@if [ "$(USE_HOST_LOCK)" -eq 1 ]; then \
	    rm -f ./$(HOST_FILE); \
	    rm -f ./$(HOST_LOCK); \
	fi

run-monitor-%: %.img check-qemu
	@if [ "$(USE_HOST_LOCK)" -eq 1 ]; then \
	    lockfile -r 0 ./$(HOST_LOCK) || (echo ${errbef} && cat $(HOST_FILE); echo ${erraft}; exit 1); \
	    hostname > $(HOST_FILE); \
	fi
	$(call run,$(QEMU_PRELOAD) $(QEMU) $(QEMUOPT) -monitor stdio $(QEMUIMG),QEMU $<)
	@if [ "$(USE_HOST_LOCK)" -eq 1 ]; then \
	    rm -f ./$(HOST_FILE); \
	    rm -f ./$(HOST_LOCK); \
	fi

run-gdb-%: run-gdb-$(QEMUDISPLAY)-%
	@:

run-gdb-graphic-%: %.img check-qemu
	@if [ "$(USE_HOST_LOCK)" -eq 1 ]; then \
	    lockfile -r 0 ./$(HOST_LOCK) || (echo ${errbef} && cat $(HOST_FILE); echo ${erraft}; exit 1); \
	    hostname > $(HOST_FILE); \
	fi
	$(call run,$(QEMU_PRELOAD) $(QEMU) $(QEMUOPT) -gdb tcp::1234 $(QEMUIMG) &,QEMU $<)
	$(call run,sleep 0.5; gdb -x .gdbinit,GDB)
	@if [ "$(USE_HOST_LOCK)" -eq 1 ]; then \
	    rm -f ./$(HOST_FILE); \
	    rm -f ./$(HOST_LOCK); \
	fi

run-gdb-console-%: %.img check-qemu
	@if [ "$(USE_HOST_LOCK)" -eq 1 ]; then \
	    lockfile -r 0 ./$(HOST_LOCK) || (echo ${errbef} && cat $(HOST_FILE); echo ${erraft}; exit 1); \
	    hostname > $(HOST_FILE); \
	fi
	$(call run,$(QEMU_PRELOAD) $(QEMU) $(QEMUOPT) -display curses -gdb tcp::1234 $(QEMUIMG),QEMU $<)
	@if [ "$(USE_HOST_LOCK)" -eq 1 ]; then \
	    rm -f ./$(HOST_FILE); \
	    rm -f ./$(HOST_LOCK); \
	fi

run: run-qemu-$(basename $(IMAGE))
run-qemu: run-qemu-$(basename $(IMAGE))
run-graphic: run-graphic-$(basename $(IMAGE))
run-console: run-console-$(basename $(IMAGE))
run-monitor: run-monitor-$(basename $(IMAGE))
run-gdb: run-gdb-$(basename $(IMAGE))
run-gdb-graphic: run-gdb-graphic-$(basename $(IMAGE))
run-gdb-console: run-gdb-console-$(basename $(IMAGE))
run-graphic-gdb: run-gdb-graphic-$(basename $(IMAGE))
run-console-gdb: run-gdb-console-$(basename $(IMAGE))

.PHONY:
test-%: $(TEST_DIR)/p-%.rs
	@cp $< ./uspace/p-test/src/lib.rs

.PHONY:
restore:
	@git checkout -- uspace/p-test/src/lib.rs 2>/dev/null || cp ./uspace/p-allocator/src/lib.rs ./uspace/p-test/src/lib.rs
	@echo "Restored uspace/p-test to default!"

# Kill all my qemus
kill:
	-killall -u $$(whoami) $(QEMU)
	@sleep 0.2; if ps -U $$(whoami) | grep $(QEMU) >/dev/null; then killall -9 -u $$(whoami) $(QEMU); fi

.PHONY:
kill-lock:
	HOST=$$(cat $(HOST_FILE));HOST_CMD=hostname; if [ "$$HOST" == "$$HOST_CMD" ]; then make kill; else echo $$HOST;CWD=$$(pwd);ssh $$HOST "cd $$CWD;make kill;" && make clean-secret;fi

.PHONY:
clean-secret:
	rm -rf $(HOST_LOCK) $(HOST_FILE)
