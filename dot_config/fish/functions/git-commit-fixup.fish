function git-commit-fixup
  git commit --fixup="$(git log --oneline | fzf --prompt='Commit >' --preview='git show {1}' | awk '{ print $1 }')"
end
