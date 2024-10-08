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
      shellcheck
      skkDictionaries.l
      skkDictionaries.jinmei
      skkDictionaries.geo
      stylua
      trash-cli
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
