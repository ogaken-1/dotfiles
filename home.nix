{ pkgs, ... }:
let
  dirModules = dir: builtins.map (file: dir + "/${file}") (builtins.attrNames (builtins.readDir dir));
  programs = dirModules ./programs;
in
{
  home = {
    username = "ogaken";
    homeDirectory = "/home/ogaken";
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
      postgresql_16
      ripgrep
      tailscale
      vim
      wget
      wslu
      rustup
    ];
  };
  nix = {
    package = pkgs.nix;
    extraOptions = "extra-experimental-features = flakes nix-command\n";
  };
  xdg.enable = true;
  imports = programs;
}
