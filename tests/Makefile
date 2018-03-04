SHELL := /bin/bash
SHELL_PATH ?= $(SHELL)
SHELL_PATH_SQ = $(subst ','\'',$(SHELL_PATH))
TEST_OPTS ?= --verbose --chain-lint

TEST_FILES=$(sort $(wildcard ./t??_*.sh))

all: test

test:
	$(MAKE) clean
	$(TEST_FILES)

$(TEST_FILES):
	'$(SHELL_PATH_SQ)' $@ $(TEST_OPTS)

clean:
	@rm -rf test-results
	@rm -rf /tmp/pass-pwned

.PHONY: all clean test