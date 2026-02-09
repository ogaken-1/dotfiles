{ pkgs, config, ... }:
{
  home.file = {
    "${config.xdg.configHome}/fish/functions/" = {
      source = ./functions;
      recursive = true;
    };
  };
  home.packages = [
    pkgs.fishPlugins.fzf-complete
  ];
  programs.fish = {
    enable = true;
    shellAbbrs = {
      ga = "git add";
      gci = "git commit";
      gcia = "git commit --amend";
      gcif = "git commit --fixup";
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
      gt = "git tag";
      gtd = "git tag --delete";
      gr = "git restore";
      gR = "git reset";
      gRs = "git reset --soft";
      gRm = "git reset --mixed";
      gRh = "git reset --hard";
      gb = "git branch";
      gbd = "git branch --delete";
      gl = "git log";
      gm = "git merge";
    };
    functions = {
      fzf_tmux_session = {
        body = ''
          ${pkgs.tmux}/bin/tmux attach-session -t (
            ${pkgs.tmux}/bin/tmux list-sessions -F '#{session_name}' 2> /dev/null |
              ${pkgs.fzf}/bin/fzf --layout=reverse --border=block
          ) > /dev/null 2> /dev/null
        '';
      };
    };
    interactiveShellInit = ''
      if [ -z "$TMUX" ]
        bind \cqs fzf_tmux_session
      end
      set fish_color_command blue
      set fish_color_keyword green
      set fish_color_error red --bold
      set fish_color_comment brblack
      set fish_color_autosuggestion brblack
    '';
  };
}
