{ pkgs, ... }:
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
      stylua
      tailscale
      tmux
      trash-cli
      vim
      vscode-langservers-extracted
      wget
      yaml-language-server
    ];
  };
  imports = import ./programs;
}
