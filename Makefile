DIR := $(shell git rev-parse --show-toplevel)
ifndef XDG_CONFIG_HOME
	XDG_CONFIG_HOME := $(HOME)/.config
endif

ALACRITTY_SRC := $(DIR)/alacritty.toml
ALACRITTY_DEST := $(XDG_CONFIG_HOME)/alacritty/alacritty.toml

NIX_SRC := $(DIR)/nix.conf
NIX_DEST := $(XDG_CONFIG_HOME)/nix/nix.conf

.PHONY: install
install: $(ALACRITTY_DEST) $(NIX_DEST)
	ls --color -l $(XDG_CONFIG_HOME)

$(ALACRITTY_DEST): $(ALACRITTY_SRC)
	[ -d $(@D) ] || mkdir $(@D)
	ln -s $< $@

$(NIX_DEST): $(NIX_SRC)
	[ -d $(@D) ] || mkdir $(@D)
	ln -s $< $@
