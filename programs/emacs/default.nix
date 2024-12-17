{ pkgs, config, ... }:
{
  home.file = {
    "${config.xdg.configHome}/emacs/init.el" = {
      source = ./init.el;
    };
  };
  home.packages = with pkgs; [
    cmigemo
  ];
  home.sessionVariables = {
    MIGEMO_UTF8_DICT = "${pkgs.cmigemo}/share/migemo/utf-8/migemo-dict";
  };
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-gtk;
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
        ddskk
        ddskk-posframe
        direnv
        doom-modeline
        editorconfig
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
        perfect-margin
        puni
        spacious-padding
        typescript-mode
        vertico
        which-key
        yaml-mode
        zenburn-theme
      ];
  };
}
