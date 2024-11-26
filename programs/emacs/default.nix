{ pkgs, config, ... }:
{
  home.file = {
    "${config.xdg.configHome}/emacs/init.el" = {
      source = ./init.el;
    };
  };
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-gtk;
  };
}
