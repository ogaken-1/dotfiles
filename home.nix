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
    neovim-nightly-overlay.overlays.default
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
      gnumake
      gnupg
      jq
      kubectl
      nvd
      postgresql_16
      ripgrep
      ruby
      rustup
      tailscale
      vim
      wget
      git-select-author
      skkDictionaries.l
      skkDictionaries.jinmei
      skkDictionaries.geo
    ];
  };
  xdg.enable = true;
  imports = programs;
}
