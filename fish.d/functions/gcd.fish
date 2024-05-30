function gcd -d 'Select git project and start a tmux session.'
  set -l repo (ghq list --full-path | fzf --prompt='Project >' --preview 'bat {}/README.*' --ansi)

  if [ -z "$repo" ]
    echoerr 'ghq-cd: No projects selected.'
    return 1
  end

  set -l session_name (basename "$repo" | tr '.' '_')

  tmux new-session -d -s "$session_name" -c "$repo"

  if [ -n "$TMUX" ]
    tmux switch-client -t "$session_name"
  else
    tmux attach-session -t "$session_name"
  end
end
