{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    escapeTime = 1;
    # 端末で右クリックコピーとかペーストとかしたいときに
    # tmuxがマウスハンドルするのは不便なのでmouseは無効化する
    mouse = false;
    prefix = "C-q";
    terminal = "tmux-256color";
    shell = "${pkgs.fish}/bin/fish";
    keyMode = "vi";
    extraConfig = builtins.readFile ./tmux.conf;
  };
}
