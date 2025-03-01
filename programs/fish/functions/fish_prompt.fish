function fish_prompt
  set -l previous_command_status $status

  set components

  if [ "$DEVBOX_SHELL_ENABLED" = "1" ]
    set -a components '(devbox)'
  else if [ -n "$IN_NIX_SHELL"  ]
    set -a components '(nix)'
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
    set -l git_status (sgr color:red "[$(git_status_prompt)]")

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
