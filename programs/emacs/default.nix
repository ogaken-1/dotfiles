{ pkgs, config, ... }:
let
  emacsPackage = pkgs.emacs30-gtk3;
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
      epkgs: with epkgs; [
        ace-window
        affe
        astro-ts-mode
        basic-mode
        blackout
        cape
        consult
        consult-ghq
        corfu
        dashboard
        ddskk
        ddskk-posframe
        direnv
        doom-modeline
        editorconfig
        eglot
        eldoc-box
        embark
        embark-consult
        exec-path-from-shell
        git-gutter-fringe
        leaf
        leaf-convert
        leaf-keywords
        magit
        marginalia
        migemo
        nix-mode
        orderless
        org-modern
        puni
        spacious-padding
        tree-sitter
        tree-sitter-langs
        treesit-auto
        treesit-grammars.with-all-grammars
        vertico
        web-mode
        which-key
        yaml-mode
        zenburn-theme
      ];
  };
}
