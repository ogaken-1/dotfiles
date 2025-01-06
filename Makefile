export NIX_CONFIG := extra-experimental-features = flakes

UNAME := $(shell uname -s)
ifeq ($(UNAME),Darwin)
	REBUILD := nix run nix-darwin --
	HOSTNAME := $(shell scutil --get ComputerName)
else ifeq ($(UNAME),Linux)
	REBUILD := sudo nixos-rebuild
	HOSTNAME := $(shell hostname)
endif

.PHONY: switch
switch:
	$(REBUILD) switch --flake .#$(HOSTNAME)

.PHONY: update
update:
	nix flake update
	make os
	make home
	git restore --staged .
	git add flake.lock
	git commit --message 'chore: Update flake'
