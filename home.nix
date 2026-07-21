{ inputs }:
{ pkgs, ... }:
let
  nerv = pkgs.callPackage ./pkgs/nerv/package.nix { };
in
{
  nixpkgs.overlays = with inputs; [
    emacs-overlay.overlay
    vim-overlay.overlays.default
    neovim-overlay.overlays.default
    fish-lophius.overlays.default
    mcp-servers-nix.overlays.default
    nix-claude-code.overlays.default
  ];
  home = {
    stateVersion = "24.05";
    packages = with pkgs; [
      age
      azure-cli
      bc
      devenv
      docker-client
      eza
      fsautocomplete
      ghq
      git-absorb
      glow
      gnumake
      gnupg
      jq
      kubectl
      mermaid-cli
      nerv
      nvd
      pgcli
      prisma-language-server
      ripgrep
      ruby
      rustup
      skkDictionaries.geo
      skkDictionaries.jinmei
      skkDictionaries.l
      skkDictionaries.jis2004
      skkDictionaries.jis3_4
      tailscale
      tree-sitter
      unzip
      vim
      wget
      yq
      bun
    ];
  };
  xdg.enable = true;
}
