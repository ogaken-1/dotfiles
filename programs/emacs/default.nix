{
  pkgs,
  lib,
  config,
  ...
}:
let
  emacsPackage = pkgs.emacs30-gtk3;
  elispNames = builtins.filter (x: lib.isString x && x != "") (
    builtins.split "\n" (
      builtins.readFile (
        pkgs.runCommand "names" {
          buildInputs = [ emacsPackage ];
        } "${emacsPackage}/bin/emacs --batch -l ${./list-required-packages.el} ${./init.el} > $out"
      )
    )
  );
in
rec {
  home.file = {
    "${config.xdg.configHome}/emacs/init.elc" = {
      source =
        pkgs.runCommand "init.elc"
          {
            buildInputs = [ (emacsPackage.pkgs.withPackages (programs.emacs.extraPackages)) ];
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
  ];
  home.sessionVariables = {
    MIGEMO_UTF8_DICT = "${pkgs.cmigemo}/share/migemo/utf-8/migemo-dict";
  };
  programs.emacs = {
    enable = true;
    package = emacsPackage;
    extraPackages =
      epkgs:
      with epkgs;
      [
        leaf
        treesit-grammars.with-all-grammars
      ]
      ++ (map (name: epkgs."${name}") elispNames);
  };
}
