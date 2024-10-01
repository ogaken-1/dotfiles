.PHONY: home
home:
	home-manager --flake . switch

.PHONY: os
os:
	sudo nixos-rebuild --flake . switch
