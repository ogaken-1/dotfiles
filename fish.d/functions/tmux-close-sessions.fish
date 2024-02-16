function tmux-close-sessions
  for session_name in (tmux ls -F '#{session_name}' | fzf -m)
    tmux kill-session -t "$session_name"
  end
end
