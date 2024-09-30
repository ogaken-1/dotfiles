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

TMUX_SRC := $(DIR)/tmux.conf
TMUX_DEST := $(XDG_CONFIG_HOME)/tmux/tmux.conf

NIX_SRC := $(DIR)/nix.conf
NIX_DEST := $(XDG_CONFIG_HOME)/nix/nix.conf

.PHONY: install
install: $(NVIM_DEST) $(FISH_DEST) $(ALACRITTY_DEST) $(TMUX_DEST) $(NIX_DEST)
	ls --color -l $(XDG_CONFIG_HOME)

$(NVIM_DEST): $(NVIM_SRC)
	ln -s $< $@

$(FISH_DEST): $(FISH_SRC)
	ln -s $< $@

$(ALACRITTY_DEST): $(ALACRITTY_SRC)
	[ -d $(@D) ] || mkdir $(@D)
	ln -s $< $@

$(TMUX_DEST): $(TMUX_SRC)
	[ -d $(@D) ] || mkdir $(@D)
	ln -s $< $@

$(NIX_DEST): $(NIX_SRC)
	[ -d $(@D) ] || mkdir $(@D)
	ln -s $< $@
