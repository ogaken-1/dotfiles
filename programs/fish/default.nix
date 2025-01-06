{ config, ... }:
{
  home.file = {
    "${config.xdg.configHome}/fish/functions/" = {
      source = ./functions;
      recursive = true;
    };
  };
  programs.fish = {
    enable = true;
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
      gpu = "git push -u origin \"$(git branch --show-current)\"";
      gs = "git status --short --branch -uall";
      gst = "git stash";
      gsw = "git switch";
    };
    shellInit = ''
      if status --is-interactive && test -z $TMUX
        bind \cqs 'tmux attach-session -t (tmux list-sessions -F \'#{session_name}\' 2> /dev/null | fzf --layout=reverse --border=block) > /dev/null 2> /dev/null'
      end
    '';
  };
}
