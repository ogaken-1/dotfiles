{ inputs }:
{ pkgs, ... }:
let
  dirModules =
    dir: builtins.readDir dir |> builtins.attrNames |> builtins.map (file: dir + "/${file}");
  programs = dirModules ./programs;
  git-select-author = pkgs.callPackage (import ./packages/git-select-author) { };
in
{
  nixpkgs.overlays = with inputs; [
    emacs-overlay.overlay
    vim-overlay.overlays.default
    neovim-overlay.overlays.default
  ];
  home = {
    stateVersion = "24.05";
    packages = with pkgs; [
      azure-cli
      bc
      devenv
      docker-client
      eza
      fd
      gcc14
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
      unzip
      vim
      wget
    ];
  };
  xdg.enable = true;
  imports = programs;
}
