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
      deno
      gopls
      lua-language-server
      nil
      nixfmt-rfc-style
      omnisharp-roslyn
      rust-analyzer
      shellcheck
      skkDictionaries.geo
      skkDictionaries.jinmei
      skkDictionaries.l
      stylua
      trash-cli
      typst-lsp
      vscode-langservers-extracted
      yaml-language-server
    ];
    sessionVariables = {
      SKK_DICT_DIRS = builtins.concatStringsSep ":" (
        map (d: "${d}/share/skk") (
          with pkgs.skkDictionaries;
          [
            l
            jinmei
            geo
          ]
        )
      );
    };
  };
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };
}
