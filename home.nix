{ inputs }:
{ pkgs, ... }:
let
  dirModules =
    dir: builtins.readDir dir |> builtins.attrNames |> builtins.map (file: dir + "/${file}");
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
      bc
      docker-client
      fd
      gcc14
      ghq
      gnumake
      gnupg
      jq
      kubectl
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
