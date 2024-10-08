.PHONY: home
home:
	home-manager --flake . switch

.PHONY: os
os:
	sudo nixos-rebuild --flake . switch

.PHONY: update
update:
	nix flake update
	make os
	make home
	git restore --staged .
	git add flake.lock
	git commit --message 'chore: Update flake'
