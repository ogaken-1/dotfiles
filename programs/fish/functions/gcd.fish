function gcd -d 'Select git project and open it as a herdr workspace.'
  set -l repo (__list_repos | fzf --prompt='Project >' --preview 'bat {}/README.md' --ansi)

  if [ -z "$repo" ]
    echoerr 'gcd: No projects selected.'
    return 1
  end

  set -l label (basename "$repo")

  # CLI commands do not auto-start the server.
  if not herdr workspace list > /dev/null 2> /dev/null
    herdr server > /dev/null 2>&1 &
    disown
    set -l ready 0
    for i in (seq 50)
      if herdr workspace list > /dev/null 2> /dev/null
        set ready 1
        break
      end
      sleep 0.1
    end
    if [ $ready -eq 0 ]
      echoerr 'gcd: herdr server did not start.'
      return 1
    end
  end

  # Workspaces have no cwd field and labels may repeat, so the label is the key.
  set -l id (herdr workspace list | jq -r --arg label "$label" \
    '[.result.workspaces[] | select(.label == $label)][0].workspace_id // empty')

  if [ -n "$id" ]
    herdr workspace focus "$id" > /dev/null
  else
    herdr workspace create --cwd "$repo" --label "$label" --focus > /dev/null
  end

  if [ -z "$HERDR_ENV" ]
    herdr
  end
end

function __find_repos
  find $argv -name '.git' -type d | while read -l git_dir
    dirname $git_dir
  end
end

function __list_repos
  if which ghq > /dev/null 2> /dev/null
    ghq list --full-path
  else
    __find_repos ~/repos
  end
  __find_repos $XDG_DATA_HOME/nvim/lazy
end
