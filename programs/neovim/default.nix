{ pkgs, config, ... }:
{
  home = {
    file = {
      "${config.xdg.configHome}/nvim/" = {
        source = ./config.d;
        recursive = true;
      };
    };
    packages = with pkgs; [
      csharpier
      deno
      gitlab-ci-ls
      gopls
      libxml2
      lua-language-server
      nixd
      nixfmt
      omnisharp-roslyn
      shellcheck
      skkDictionaries.geo
      skkDictionaries.jinmei
      skkDictionaries.l
      stylua
      tinymist
      trash-cli
      vscode-langservers-extracted
      vtsls
      yaml-language-server
    ];
    sessionVariables = {
      MANPAGER = "${pkgs.neovim}/bin/nvim +Man!";
    };
  };
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };
}
