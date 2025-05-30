{ pkgs, ... }:
{
  programs.fzf = {
    enable = true;
    defaultCommand = "${pkgs.fd}/bin/fd -t file";
    defaultOptions = [
      "--bind=ctrl-k:kill-line"
      "--color=bg+:#414559,bg:#303446,spinner:#f2d5cf,hl:#e78284"
      "--color=fg:#c6d0f5,header:#e78284,info:#ca9ee6,pointer:#f2d5cf"
      "--color=marker:#f2d5cf,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#e78284"
      "--border=rounded"
      "--layout=reverse"
      "--height 40%"
      "--preview='${./fzf-preview} {}'"
      "--preview-window=right:60%:border-rounded"
    ];
  };
}
