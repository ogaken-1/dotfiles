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
    functions = {
      fzf_tmux_session = {
        body = ''
          tmux attach-session -t (
            tmux list-sessions -F '#{session_name}' 2> /dev/null |
              fzf --layout=reverse --border=block
          ) > /dev/null 2> /dev/null
        '';
      };
    };
    shellInit = ''
      if status --is-interactive && [ -z $TMUX ]
        bind \cqs fzf_tmux_session
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
