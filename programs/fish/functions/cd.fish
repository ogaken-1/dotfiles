function cd
  if [ (count $argv) -eq 0 ]
    set -l dir (fd . -t directory | fzf)
    if [ -n "$dir" ]
      builtin cd "$dir"
      __dirhistadd
    end
    return
  end
  # Use `cd -` for moving last directory
  if [ "$argv" = '-' ]
    __dirp
    return
  end
  builtin cd $argv
  __dirhistadd
end

complete --command cd --arguments '(__fish_complete_directories)'

function __dirhistadd
  if [ -z "$XDG_STATE_HOME" ]
    return 1
  end
  set -l dir "$XDG_STATE_HOME/fish"
  [ -d "$dir" ] || mkdir -p "$dir"
  set -l dirh "$dir/dirh"
  set -l last (tail --lines 1 "$dirh")
  if [ "$PWD" != "$last" ]
    echo "$PWD" >> "$dirh"
  end
end

function __dirp
  if [ -z "$XDG_STATE_HOME" ]
    return 1
  end
  set -l dir "$XDG_STATE_HOME/fish"
  [ -d "$dir" ] || mkdir -p "$dir"
  set -l dirh "$dir/dirh"
  set -l prev (tail --lines 2 "$dirh" | head --lines 1)
  [ -d "$dir" ] && cd "$prev"
end
