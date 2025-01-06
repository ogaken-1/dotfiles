function fish_prompt
  set -l previous_command_status $status

  set components

  if [ "$DEVBOX_SHELL_ENABLED" = "1" ]
    set -a components '(devbox)'
  end

  if [ "$CHEZMOI" = '1' ]
    set -a components '(chezmoi)'
  end

  set -a components "$(sgr color:yellow "$USER")@$(sgr color:magenta "$hostname")"

  # User can find that if he is in a git repository
  set -l git_repo $(git rev-parse --show-toplevel 2> /dev/null)
  if [ $status -eq 0 ]
    set -l git_branch (sgr color:magenta (git branch --show-current))
    set -l git_repo_name (sgr color:cyan (basename "$git_repo"))

    function _git_status
      set -l git_status_row (git status -s | string sub -l 2 | sort | uniq)
      for char in $git_status_row
        if [ $char = ' M' ]
          echo '!'
        else if [ $char = '??' ]
          echo '?'
        else if [ $char = ' D' ]
          echo 'x'
        else if [ $char = 'M ' ]
          echo '+'
        else if [ $char = 'A ' ]
          echo '+'
        end
      end
    end

    set -l git_status (sgr color:red "[$(string join '' (_git_status))]")

    set -a components "($git_repo_name:$git_branch $git_status)"
  end

  set -a components (path_shortn "$PWD")

  if [ -n "$PGHOST" ]
    set -a components "$(sgr color:blue "PGHOST"):$PGHOST"
  end

  if [ "$previous_command_status" != '0' ]
    set -a components (sgr color:red "[$previous_command_status]")
  end

  printf '\n%s\n> ' (string join ' ' $components)
end
