{ inputs }:
{ pkgs, ... }:
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
      bun
    ];
  };
  xdg.enable = true;
}
