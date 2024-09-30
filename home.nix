{ pkgs, ... }:
let
  dirModules = dir: builtins.map (file: dir + "/${file}") (builtins.attrNames (builtins.readDir dir));
  programs =  dirModules ./programs;
in
{
  home = {
    username = "ogaken";
    homeDirectory = "/home/ogaken";
    stateVersion = "24.05";
    packages = with pkgs; [
      azure-cli
      bc
      deno
      fd
      gcc14
      ghq
      gnumake
      gnupg
      gopls
      kubectl
      lua-language-server
      nil
      postgresql_16
      ripgrep
      skk-dicts
      stylua
      tailscale
      trash-cli
      vim
      vscode-langservers-extracted
      wget
      yaml-language-server
    ];
    sessionVariables = {
      SKK_DICT_DIR = "${pkgs.skk-dicts}/share" ;
    };
  };
  xdg.enable = true;
  imports = programs;
}
