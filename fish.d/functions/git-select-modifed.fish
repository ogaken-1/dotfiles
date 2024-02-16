function git-select-modifed
  git ls-files --exclude-standard --others --modified | fzf -m --prompt='Stage files >' --preview='git diff -- {}'
end

