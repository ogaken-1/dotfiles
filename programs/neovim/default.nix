{ pkgs, ... }:
{
  home = {
    file = {
      ".config/nvim/" = {
        source = ./config.d;
        recursive = true;
      };
    };
    packages = with pkgs; [
      deno
      gopls
      lua-language-server
      nil
      nixfmt-rfc-style
      shellcheck
      skk-dicts
      stylua
      trash-cli
      vscode-langservers-extracted
      yaml-language-server
    ];
    sessionVariables = {
      SKK_DICT_DIR = "${pkgs.skk-dicts}/share";
    };
  };
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };
}
