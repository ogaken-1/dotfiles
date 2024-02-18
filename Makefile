DIR := $(shell git rev-parse --show-toplevel)
ifndef XDG_CONFIG_HOME
	XDG_CONFIG_HOME := $(HOME)/.config
endif
NVIM_SRC := $(DIR)/nvim.d
NVIM := $(XDG_CONFIG_HOME)/nvim
FISH_SRC := $(DIR)/fish.d
FISH := $(XDG_CONFIG_HOME)/fish

ALACRITTY_SRC := $(DIR)/alacritty.toml
ALACRITTY_BASE := $(XDG_CONFIG_HOME)/alacritty
ALACRITTY := $(ALACRITTY_BASE)/alacritty.toml

.PHONY: install
install: $(NVIM) $(FISH) $(ALACRITTY)
	ls --color -l $(XDG_CONFIG_HOME)

$(NVIM): $(NVIM_SRC)
	ln -s $(NVIM_SRC) $(NVIM)

$(FISH): $(FISH_SRC)
	ln -s $(FISH_SRC) $(FISH)

$(ALACRITTY): $(ALACRITTY_SRC)
	[ -d $(ALACRITTY_BASE) ] || mkdir $(ALACRITTY_BASE)
	ln -s $(ALACRITTY_SRC) $(ALACRITTY)
