{ inputs }:
{ pkgs, ... }:
let
  dirModules = dir: builtins.map (file: dir + "/${file}") (builtins.attrNames (builtins.readDir dir));
  programs = dirModules ./programs;
in
{
  nixpkgs.overlays = with inputs; [
    emacs-overlay.overlay
    neovim-nightly-overlay.overlays.default
  ];
  home = {
    stateVersion = "24.05";
    packages = with pkgs; [
      azure-cli
      bat
      bc
      fd
      gcc14
      ghq
      gnumake
      gnupg
      kubectl
      lazygit
      nvd
      postgresql_16
      ripgrep
      rustup
      tailscale
      vim
      wget
    ];
  };
  xdg.enable = true;
  imports = programs;
}
