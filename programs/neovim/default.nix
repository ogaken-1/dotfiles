{ pkgs, config, ... }:
{
  home = {
    file = {
      "${config.xdg.configHome}/nvim/" = {
        source = ./config.d;
        recursive = true;
      };
    };
    packages =
      with pkgs;
      let
        omnisharp = omnisharp-roslyn.overrideAttrs (oldAttrs: {
          useDotnetFromEnv = false;
        });
      in
      [
        csharpier
        deno
        gopls
        lua-language-server
        nixd
        nixfmt-rfc-style
        omnisharp
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
      SKK_DICT_DIRS =

        with pkgs.skkDictionaries;
        [
          l
          jinmei
          geo
        ]
        |> map (d: "${d}/share/skk")
        |> builtins.concatStringsSep ":";
      MANPAGER = "${pkgs.neovim}/bin/nvim +Man!";
    };
  };
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };
}
