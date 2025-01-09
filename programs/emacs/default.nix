{
  pkgs,
  lib,
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
        leaf
        treesit-grammars.with-all-grammars
      ];
  };
in
{
  home.file = {
    "${config.xdg.configHome}/emacs/init.elc" = {
      source =
        pkgs.runCommand "init.elc"
          {
            buildInputs = [ emacsPkg ];
            XDG_DATA_HOME = "${config.xdg.dataHome}";
          }
          ''
            cp ${./init.el} init.el
            emacs --batch \
              --funcall batch-byte-compile init.el
            cp init.elc $out
          '';
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
