{ pkgs, ... }:
{
  programs.fzf = {
    enable = true;
    defaultCommand = "${pkgs.fd}/bin/fd -t file";
    defaultOptions = [
      "--bind=ctrl-k:kill-line"
      "--border=rounded"
      "--layout=reverse"
      "--height 40%"
      "--preview='${./fzf-preview} {}'"
      "--preview-window=right:60%:border-rounded"
    ];
  };
}
