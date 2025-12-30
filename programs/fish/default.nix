{ config, pkgs, ... }:
let
  zeno = import ./zeno.nix { inherit pkgs; };
in
{
  home.file = {
    "${config.xdg.configHome}/fish/functions/" = {
      source = ./functions;
      recursive = true;
    };
    "${config.xdg.configHome}/zeno/config.yaml" = {
      source = ./zeno.yaml;
    };
  };
  home.packages = [
    zeno
  ];
  programs.fish = {
    enable = true;
    shellInit = ''
      if status --is-interactive && test -z $TMUX
        bind \cqs 'tmux attach-session -t (tmux list-sessions -F \'#{session_name}\' 2> /dev/null | fzf --layout=reverse --border=block) > /dev/null 2> /dev/null'
      end
      if [ "''$ZENO_LOADED" = "1" ]
        bind ' ' zeno-auto-snippet
        bind \r zeno-auto-snippet-and-accept-line
        bind \t zeno-completion
        bind \cx\x20 zeno-insert-space
      end
    '';
  };
}
