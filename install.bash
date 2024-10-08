#!/usr/bin/env -S bash
set -euo pipefail
repo=github.com/ogaken-1/dotfiles
dir="${HOME}/repos/${repo}"

# 1. Clone dotfiles repo
nix-shell \
  --packages git \
  --run "git clone https://${repo}.git ${dir}"

# 2. If NixOS, apply os configurations
if which nixos-rebuild > /dev/null 2> /dev/null; then
  nix-shell \
    --packages git home-manager \
    --run "sudo nixos-rebuild --flake ${dir} switch"
fi

# 3. Apply home-manager configurations
nix-shell \
  --packages git home-manager \
  --run "home-manager --flake ${dir} switch"
