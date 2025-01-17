function cd
  set -f cdir "$PWD"
  # Invoke fzf to choice target directory
  # If this command called with no arguments
  if [ (count $argv) -eq 0 ]
    set -f dir (fd . -t directory | fzf)
    if [ -n "$dir" ]
      builtin cd "$dir"
      __set_dirprev "$cdir"
    end
    return
  end
  # Use `cd -` for moving last directory
  if [ "$argv" = '-' ]
    if [ -d "$dirprev" ]
      builtin cd "$dirprev"
      __set_dirprev "$cdir"
    else
      echo "cd: directory $dirprev does not exist."
    end
    return
  end
  builtin cd $argv
  __set_dirprev "$cdir"
end

complete --command cd --arguments '(__fish_complete_directories)'

function __set_dirprev -a dir
  if [ "$dir" != "$dirprev"  ]
    set -g dirprev "$dir"
  end
end
