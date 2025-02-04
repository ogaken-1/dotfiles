{ config, pkgs, ... }:
{
  home.file = {
    "${config.xdg.configHome}/fish/functions/" = {
      source = ./functions;
      recursive = true;
    };
  };
  programs.fish = {
    enable = true;
    plugins = [
      # FIXME: You should run `emit enhancd_install` manually to enable enhancd.
      # The state isn't managed by nix.
      {
        name = "enhancd";
        src = pkgs.fetchFromGitHub {
          owner = "babarot";
          repo = "enhancd";
          rev = "5afb4eb6ba36c15821de6e39c0a7bb9d6b0ba415";
          hash = "sha256-pKQbwiqE0KdmRDbHQcW18WfxyJSsKfymWt/TboY2iic=";
        };
      }
    ];
    shellAbbrs = {
      ga = "git add";
      gci = "git commit";
      gcia = "git commit --amend";
      gcif = "git commit --fixup=";
      gd = "git diff";
      gf = "git fetch";
      gF = "git pull";
      gp = "git push";
      gpf = "git push --force-if-includes --force-with-lease";
      gpu = "git push --set-upstream origin \"$(git branch --show-current)\"";
      gs = "git status --short --branch -uall";
      gst = "git stash";
      gstl = "git stash list";
      gsw = "git switch";
      gswc = "git switch --create";
    };
    shellInit = ''
      if status --is-interactive && test -z $TMUX
        bind \cqs 'tmux attach-session -t (tmux list-sessions -F \'#{session_name}\' 2> /dev/null | fzf --layout=reverse --border=block) > /dev/null 2> /dev/null'
      end
    '';
  };
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };
}
