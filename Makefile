DIR := $(shell git rev-parse --show-toplevel)
ifndef XDG_CONFIG_HOME
	XDG_CONFIG_HOME := $(HOME)/.config
endif

NVIM_SRC := $(DIR)/nvim.d
NVIM_DEST := $(XDG_CONFIG_HOME)/nvim

FISH_SRC := $(DIR)/fish.d
FISH_DEST := $(XDG_CONFIG_HOME)/fish

ALACRITTY_SRC := $(DIR)/alacritty.toml
ALACRITTY_DEST := $(XDG_CONFIG_HOME)/alacritty/alacritty.toml

GIT_SRC := $(DIR)/git.d
GIT_DEST := $(XDG_CONFIG_HOME)/git

.PHONY: install
install: $(NVIM_DEST) $(FISH_DEST) $(ALACRITTY_DEST) $(GIT_DEST)
	ls --color -l $(XDG_CONFIG_HOME)

$(NVIM_DEST): $(NVIM_SRC)
	ln -s $< $@

$(FISH_DEST): $(FISH_SRC)
	ln -s $< $@

$(ALACRITTY_DEST): $(ALACRITTY_SRC)
	[ -d $(@D) ] || mkdir $(@D)
	ln -s $< $@

$(GIT_DEST): $(GIT_SRC)
	ln -s $< $@
