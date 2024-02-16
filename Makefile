DIR := $(shell git rev-parse --show-toplevel)
ifndef XDG_CONFIG_HOME
	XDG_CONFIG_HOME := $(HOME)/.config
endif
NVIM_SRC := $(DIR)/nvim.d
NVIM := $(XDG_CONFIG_HOME)/nvim
FISH_SRC := $(DIR)/fish.d
FISH := $(XDG_CONFIG_HOME)/fish

.PHONY: install
install: $(NVIM) $(FISH)
	ls --color -l $(XDG_CONFIG_HOME)

$(NVIM): $(NVIM_SRC)
	ln -s $(NVIM_SRC) $(NVIM)

$(FISH): $(FISH_SRC)
	ln -s $(FISH_SRC) $(FISH)
