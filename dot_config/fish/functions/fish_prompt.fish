function fish_prompt
  set components

  set -a components "$USER"

  # User can find that if he is in a git repository
  set -l git_repo $(git rev-parse --show-toplevel 2> /dev/null)
  if [ $status -eq 0 ]
    set -l git_branch $(git branch --show-current)
    set -a components "($(basename "$git_repo"):$git_branch)"
  end

  set -a components (path_shortn "$PWD")

  printf '\033]133;A\007'
  printf '\n%s\n> ' (string join ' ' $components)
  printf '\033]133;B\007'
end
