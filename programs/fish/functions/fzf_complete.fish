# fzf_complete.fish
# ref: ../conf.d/fzf_complete.fish

function __fzf_complete_load_rules
  set -g __fzf_complete_rules_loaded && return
  set -g __fzf_complete_rules_loaded 1

  for dir in $fish_function_path
    for file in $dir/__fzf_complete_rule_*.fish
      test -f $file && source $file
    end
  end
end

function __fzf_complete_run
  set -l source $argv[1]
  set -l transformer $argv[2]
  set -e argv[1..2]
  set -l opts $argv

  # Run fzf
  set -l selections (eval $source | fzf $FZF_COMPLETE_COMMON_OPTS $opts | string split0)

  # first element is typed key (--expect)
  set -l key $selections[1]
  set -e selections[1]

  if [ (count $selections) -eq 0 ]
    commandline -f repaint
    return
  end

  set -l results
  for sel in $selections
    if [ -n "$transformer" ]
      set -a results (printf '%s' "$sel" | eval $transformer)
    else
      set -a results $sel
    end
  end

  commandline -a (string join ' ' -- (string escape -- $results))
  commandline -f repaint
end

function fzf_complete
  __fzf_complete_load_rules

  for func in (functions -a | string match '__fzf_complete_rule_*')
    if $func
      return 0
    end
  end

  commandline -f complete
end
