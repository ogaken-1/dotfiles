function fish_prompt
  set components

  set -a components (sgr color:yellow "$USER")

  # User can find that if he is in a git repository
  set -l git_repo $(git rev-parse --show-toplevel 2> /dev/null)
  if [ $status -eq 0 ]
    set -l git_branch $(git branch --show-current)
    set -l git_repo_name (sgr color:cyan (basename "$git_repo"))
    set -a components "($git_repo_name:$git_branch)"
  end

  set -a components (path_shortn "$PWD")

  osc_133 'A'
  printf '\n%s\n> ' (string join ' ' $components)
  osc_133 'B'
end
