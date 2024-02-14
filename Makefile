DIR := $(shell git rev-parse --show-toplevel)
NVIM := $(DIR)/nvim.d
ifndef XDG_CONFIG_HOME
	XDG_CONFIG_HOME := $(HOME)/.config
endif

.PHONY: install
install:
	git config core.hooksPath ./.githooks
	ln -s $(NVIM) $(XDG_CONFIG_HOME)/nvim
