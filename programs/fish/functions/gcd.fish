function gcd -d 'Select git project and start a tmux session.'
  set -l repo (__find_repos | fzf --prompt='Project >' --preview 'bat {}/README.md' --ansi)

  if [ -z "$repo" ]
    echoerr 'gcd: No projects selected.'
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

function __find_repos
  if which ghq > /dev/null 2> /dev/null
    ghq list --full-path
    return
  end
  find ~/repos -name '.git' -type d | while read -l git_dir
    dirname $git_dir
  end
end
