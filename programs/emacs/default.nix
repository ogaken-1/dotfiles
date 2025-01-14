{
  pkgs,
  config,
  ...
}:
let
  emacsPkg = pkgs.emacsWithPackagesFromUsePackage {
    config = ./init.el;
    defaultInitFile = false;
    package = pkgs.emacs-unstable;
    alwaysEnsure = false;
    alwaysTangle = false;
    extraEmacsPackages =
      epkgs: with epkgs; [
        treesit-grammars.with-all-grammars
      ];
  };
  byteCompile =
    { src, name }:
    pkgs.runCommand name
      {
        buildInputs = [ emacsPkg ];
        XDG_DATA_HOME = "${config.xdg.dataHome}";
      }
      ''
        cp ${src} src.el
        emacs --batch \
          --funcall batch-byte-compile src.el
        cp src.elc $out
      '';
in
{
  home.file = {
    "${config.xdg.configHome}/emacs/init.elc" = {
      source = byteCompile {
        src = ./init.el;
        name = "init.elc";
      };
    };
    "${config.xdg.configHome}/emacs/early-init.elc" = {
      source = byteCompile {
        src = ./early-init.el;
        name = "early-init.elc";
      };
    };
  };
  home.packages = with pkgs; [
    cmigemo
    emacs-lsp-booster
    emacsPkg
  ];
  home.sessionVariables = {
    MIGEMO_UTF8_DICT = "${pkgs.cmigemo}/share/migemo/utf-8/migemo-dict";
  };
}
