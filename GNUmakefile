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

PROCESS_BINARIES = $(OBJDIR)/p-allocator $(OBJDIR)/p-allocator2 \
	$(OBJDIR)/p-allocator3 $(OBJDIR)/p-allocator4 \
	$(OBJDIR)/p-fork $(OBJDIR)/p-forkexit $(OBJDIR)/p-test \
	$(OBJDIR)/p-brk-allocator $(OBJDIR)/p-malloc $(OBJDIR)/p-alloctests


# --- Rust build integration ---
#
# Every Rust piece here (the kernel crate and the four uspace program
# crates) builds the same way: `cargo build --release` produces a
# staticlib archive nested under target/x86_64-weensyos/release/ (a custom
# JSON target, so there's no prebuilt std -- see .cargo/config.toml in
# each crate), which we then unpack with `ar` and keep just the one .o
# that holds that crate's own code (plus whatever it statically pulled in
# from shared/rust and, for uspace programs, uspace/process).

SHARED_RUST_SRCS := $(shell find $(SHARED_RUST_DIR)/src -type f) $(SHARED_RUST_DIR)/Cargo.toml

define RUST_CRATE_RULES
$(1)_ARCHIVE_DIR = $(2)/target/x86_64-weensyos/release
$(1)_OBJ = $$($(1)_ARCHIVE_DIR)/$(3).o
$(1)_SRCS := $$(shell find $(2)/src -type f) $(2)/Cargo.toml $$(SHARED_RUST_SRCS) $(4)

$$($(1)_ARCHIVE_DIR)/.cargo_build: $$($(1)_SRCS)
	@echo "  CARGO $(2)"
	@cd $(2) && cargo build --release
	@touch $$@

$$($(1)_OBJ): $$($(1)_ARCHIVE_DIR)/.cargo_build
	@cd $$($(1)_ARCHIVE_DIR) && rm -f *.o merged.o && \
	$(AR) x lib*.a && sync && \
	$(LD) -r -o merged.o *.o && \
	mv -f merged.o $(3).o
endef

$(eval $(call RUST_CRATE_RULES,KERNEL,$(R_KERN_DIR),weensyos,))
$(eval $(call RUST_CRATE_RULES,P_ALLOCATOR,$(USPACE_DIR)/p-allocator,p_allocator,$(shell find $(USPACE_DIR)/process/src -type f) $(USPACE_DIR)/process/Cargo.toml))
$(eval $(call RUST_CRATE_RULES,P_FORK,$(USPACE_DIR)/p-fork,p_fork,$(shell find $(USPACE_DIR)/process/src -type f) $(USPACE_DIR)/process/Cargo.toml))
$(eval $(call RUST_CRATE_RULES,P_FORKEXIT,$(USPACE_DIR)/p-forkexit,p_forkexit,$(shell find $(USPACE_DIR)/process/src -type f) $(USPACE_DIR)/process/Cargo.toml))
$(eval $(call RUST_CRATE_RULES,P_TEST,$(USPACE_DIR)/p-test,p_test,$(shell find $(USPACE_DIR)/process/src -type f) $(USPACE_DIR)/process/Cargo.toml))

# Final-project additions. p-malloc and p-alloctests also depend on the
# uspace/malloc library crate (weensyos_malloc), so its sources are
# listed as extra dependencies too, same as uspace/process already is
# for every program above.
MALLOC_SRCS := $(shell find $(USPACE_DIR)/malloc/src -type f) $(USPACE_DIR)/malloc/Cargo.toml
PROCESS_SRCS := $(shell find $(USPACE_DIR)/process/src -type f) $(USPACE_DIR)/process/Cargo.toml
$(eval $(call RUST_CRATE_RULES,P_BRK_ALLOCATOR,$(USPACE_DIR)/p-brk-allocator,p_brk_allocator,$(PROCESS_SRCS)))
$(eval $(call RUST_CRATE_RULES,P_MALLOC,$(USPACE_DIR)/p-malloc,p_malloc,$(PROCESS_SRCS) $(MALLOC_SRCS)))
$(eval $(call RUST_CRATE_RULES,P_ALLOCTESTS,$(USPACE_DIR)/p-alloctests,p_alloctests,$(PROCESS_SRCS) $(MALLOC_SRCS)))

USPACE_CRATE_DIRS = $(USPACE_DIR)/p-allocator $(USPACE_DIR)/p-fork $(USPACE_DIR)/p-forkexit $(USPACE_DIR)/p-test \
	$(USPACE_DIR)/p-brk-allocator $(USPACE_DIR)/p-malloc $(USPACE_DIR)/p-alloctests $(USPACE_DIR)/malloc

# --- End Rust build integration ---


# Generic rules for making object files (boot chain only -- everything
# else is Rust now)

$(OBJDIR)/boot.o: $(OBJDIR)/%.o: $(C_KERN_DIR)/boot.c $(BUILDSTAMPS)
	$(call compile,-Os -fomit-frame-pointer -I ./shared -c $< -o $@,COMPILE)

$(OBJDIR)/%.o: $(C_KERN_DIR)/%.S $(BUILDSTAMPS)
	$(call compile,-I ./shared -c $< -o $@,ASSEMBLE)


# Specific rules for WeensyOS

$(OBJDIR)/kernel.full: $(KERNEL_OBJ) $(OBJDIR)/k-exception.o $(PROCESS_BINARIES) $(KERNEL_LINKER_FILES)
	$(call link,-T $(KERNEL_LINKER_FILES) -o $@ --start-group $(KERNEL_OBJ) $(OBJDIR)/k-exception.o --end-group -b binary $(PROCESS_BINARIES),LINK)

$(OBJDIR)/p-allocator.full: $(P_ALLOCATOR_OBJ) $(PROCESS_LINKER_FILES)
	$(call link,-T $(PROCESS_LINKER_FILES) -o $@ $(P_ALLOCATOR_OBJ),LINK)

$(OBJDIR)/p-allocator2.full: $(P_ALLOCATOR_OBJ) link/p-allocator2.ld link/shared.ld
	$(call link,-T link/p-allocator2.ld link/shared.ld -o $@ $(P_ALLOCATOR_OBJ),LINK)

$(OBJDIR)/p-allocator3.full: $(P_ALLOCATOR_OBJ) link/p-allocator3.ld link/shared.ld
	$(call link,-T link/p-allocator3.ld link/shared.ld -o $@ $(P_ALLOCATOR_OBJ),LINK)

$(OBJDIR)/p-allocator4.full: $(P_ALLOCATOR_OBJ) link/p-allocator4.ld link/shared.ld
	$(call link,-T link/p-allocator4.ld link/shared.ld -o $@ $(P_ALLOCATOR_OBJ),LINK)

$(OBJDIR)/p-fork.full: $(P_FORK_OBJ) $(PROCESS_LINKER_FILES)
	$(call link,-T $(PROCESS_LINKER_FILES) -o $@ $(P_FORK_OBJ),LINK)

$(OBJDIR)/p-forkexit.full: $(P_FORKEXIT_OBJ) $(PROCESS_LINKER_FILES)
	$(call link,-T $(PROCESS_LINKER_FILES) -o $@ $(P_FORKEXIT_OBJ),LINK)

$(OBJDIR)/p-test.full: $(P_TEST_OBJ) $(PROCESS_LINKER_FILES)
	$(call link,-T $(PROCESS_LINKER_FILES) -o $@ $(P_TEST_OBJ),LINK)

$(OBJDIR)/p-brk-allocator.full: $(P_BRK_ALLOCATOR_OBJ) $(PROCESS_LINKER_FILES)
	$(call link,-T $(PROCESS_LINKER_FILES) -o $@ $(P_BRK_ALLOCATOR_OBJ),LINK)

$(OBJDIR)/p-malloc.full: $(P_MALLOC_OBJ) $(PROCESS_LINKER_FILES)
	$(call link,-T $(PROCESS_LINKER_FILES) -o $@ $(P_MALLOC_OBJ),LINK)

$(OBJDIR)/p-alloctests.full: $(P_ALLOCTESTS_OBJ) $(PROCESS_LINKER_FILES)
	$(call link,-T $(PROCESS_LINKER_FILES) -o $@ $(P_ALLOCTESTS_OBJ),LINK)

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
