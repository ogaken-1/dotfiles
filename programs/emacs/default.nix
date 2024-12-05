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
  };
}
