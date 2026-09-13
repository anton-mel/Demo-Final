# Repo-wide clean, for use right before `git add`/`git commit`.
#
# This Makefile builds nothing itself -- it just finds every project
# under c/ and rust/ (each one has its own GNUmakefile/Makefile with a
# real `clean` target) and runs `clean` in each of them, so generated
# build artifacts (obj/, target/, *.img, log.txt, etc.) never end up
# staged by accident. Same approach as ../Demo/Makefile.

VARIANT_DIRS := c rust

# Every subdirectory that has its own GNUmakefile or Makefile, found
# dynamically rather than hardcoding project names -- so this keeps
# working if a project gets renamed, added, or removed.
BUILD_DIRS := $(sort $(dir $(shell find $(VARIANT_DIRS) -mindepth 2 -maxdepth 4 \
	\( -name GNUmakefile -o -name Makefile \) \
	-not -path '*/target/*' -not -path '*/obj/*' 2>/dev/null)))

.PHONY: clean
clean:
	@for d in $(BUILD_DIRS); do \
		echo "==> make clean in $$d"; \
		$(MAKE) -C "$$d" clean || echo "    (clean failed in $$d, continuing)"; \
	done
	@echo "Done. Run 'git status' to confirm nothing generated is left to stage."

.PHONY: list
list:
	@for d in $(BUILD_DIRS); do echo "$$d"; done
