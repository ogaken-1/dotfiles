{ inputs }:
{ pkgs, ... }:
let
  git-select-author = pkgs.callPackage ./pkgs/git-select-author { };
in
{
  nixpkgs.overlays = with inputs; [
    emacs-overlay.overlay
    vim-overlay.overlays.default
    neovim-overlay.overlays.default
    fish-fzf-complete.overlays.default
    mcp-servers-nix.overlays.default
  ];
  home = {
    stateVersion = "24.05";
    packages = with pkgs; [
      azure-cli
      bc
      devenv
      docker-client
      eza
      fsautocomplete
      ghq
      git-absorb
      git-select-author
      gnumake
      gnupg
      jq
      kubectl
      mermaid-cli
      nvd
      pgcli
      prisma-language-server
      ripgrep
      ruby
      rustup
      skkDictionaries.geo
      skkDictionaries.jinmei
      skkDictionaries.l
      tailscale
      tree-sitter
      unzip
      vim
      wget
      yq
    ];
  };
  xdg.enable = true;
  imports = import ./programs;
}
