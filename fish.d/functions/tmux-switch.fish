function tmux-switch
  set -l session (tmux ls -F '#{session_name}' | fzf --prompt='Session >')
  if [ -z "$TMUX" ]
    tmux a -t "$session"
  else
    tmux switch-client -t "$session"
  end
end
