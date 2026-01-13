# fzf_complete.fish
#
# Git completion patterns ported from zeno.zsh
# https://github.com/yuki-yano/zeno.zsh
#
# MIT License
# Copyright (c) 2021 Yuki Yano

# === Configuration ===
set -g FZF_GIT_CAT 'cat' # ex.) bat
set -g FZF_GIT_TREE 'tree' # eza --tree等に変更可

# === Source Commands ===
set -g FZF_GIT_LOG_FORMAT '%C(magenta)%h%x09%C(yellow)%cr%x09%C(blue)[%an]%x09%C(auto)%s%d'
set -g FZF_GIT_REF_FORMAT '%(color:magenta)%(refname:short)%09%(color:yellow)%(authordate:short)%09%(color:blue)[%(authorname)]'
set -g FZF_GIT_STASH_FORMAT '%C(magenta)%gd%x09%C(yellow)%cr%x09%C(auto)%s'

set -g FZF_GIT_STATUS_SOURCE 'git -c color.status=always status --short'
set -g FZF_GIT_LS_FILES_SOURCE 'git ls-files -z'
set -g FZF_GIT_LOG_SOURCE "git log --decorate --color=always --format='%C(green)[commit] $FZF_GIT_LOG_FORMAT' | column -t -s (printf '\\t')"
set -g FZF_GIT_BRANCH_SOURCE "git for-each-ref refs/heads refs/remotes --color=always --format='%(color:green)[branch] $FZF_GIT_REF_FORMAT' 2>/dev/null | column -t -s (printf '\\t')"
set -g FZF_GIT_TAG_SOURCE "git for-each-ref refs/tags --color=always --format='%(color:green)[tag] $FZF_GIT_REF_FORMAT' 2>/dev/null | column -t -s (printf '\\t')"
set -g FZF_GIT_REFLOG_SOURCE "git reflog --decorate --color=always --format='%C(green)[reflog] $FZF_GIT_LOG_FORMAT' 2>/dev/null | column -t -s (printf '\\t')"
set -g FZF_GIT_STASH_SOURCE "git stash list --color=always --format='$FZF_GIT_STASH_FORMAT' | column -t -s (printf '\\t')"

# === Preview Commands ===

set -g FZF_GIT_STATUS_PREVIEW "! git diff --exit-code --color=always -- {-1} || ! git diff --exit-code --cached --color=always -- {-1} 2>/dev/null || $FZF_GIT_TREE {-1} 2>/dev/null"
set -g FZF_GIT_LS_FILES_PREVIEW "$FZF_GIT_CAT {}"
set -g FZF_GIT_LOG_PREVIEW 'git show --color=always {2}'
set -g FZF_GIT_STASH_PREVIEW 'git show --color=always {1}'
set -g FZF_GIT_REF_PREVIEW "
  switch {1}
    case '[branch]'
      git log {2} --decorate --pretty='format:%C(yellow)%h %C(green)%cd %C(reset)%s%C(red)%d %C(cyan)[%an]' --date=iso --graph --color=always
    case '[tag]'
      git log {2} --pretty='format:%C(yellow)%h %C(green)%cd %C(reset)%s%C(red)%d %C(cyan)[%an]' --date=iso --graph --color=always
    case '[commit]' '[reflog]'
      git show --color=always {2}
  end
"

# === Common Options
set -g FZF_GIT_COMMON_OPTS \
  --ansi \
  --expect=alt-enter \
  --height='80%' \
  --print0 \
  --no-separator

set -g FZF_GIT_DEFAULT_BIND 'ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up,?:toggle-preview'
set -g FZF_GIT_REF_BIND "ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up,?:toggle-preview,ctrl-b:reload($FZF_GIT_BRANCH_SOURCE),ctrl-c:reload($FZF_GIT_LOG_SOURCE),ctrl-t:reload($FZF_GIT_TAG_SOURCE),ctrl-r:reload($FZF_GIT_REFLOG_SOURCE)"

# === Callbacks ===
function __fzf_git_status_callback
  string sub -s 4 -- $argv
end

function __fzf_git_ref_callback
  string split \t -- $argv | head -1 | awk '{ print $2 }'
end

function __fzf_git_stash_callback
  string split \t -- $argv | head -1 | awk '{ print $1 }'
end

# === Completion Sources ===
function __fzf_git_try_complete
  set -l cmd (commandline)
  set -l source ''
  set -l opts $FZF_GIT_COMMON_OPTS
  set -l callback ''
  set -l prompt ''

  # git add
  if string match -rq '^git add(?: .*)? $' -- $cmd
    set source $FZF_GIT_STATUS_SOURCE
    set -a opts --multi --no-sort --bind=$FZF_GIT_DEFAULT_BIND --preview=$FZF_GIT_STATUS_PREVIEW --prompt='Git Add Files> '
    set callback __fzf_git_status_callback

    # git diff files (with --)
  else if string match -rq '^git diff(?=.* -- ) .* $' -- $cmd
    and not string match -rq '^git diff.* [^-].* -- ' -- $cmd
    and not string match -rq ' --no-index ' -- $cmd
    set source $FZF_GIT_STATUS_SOURCE
    set -a opts --multi --no-sort --bind=$FZF_GIT_DEFAULT_BIND --preview=$FZF_GIT_STATUS_PREVIEW --prompt='Git Diff Files> '
    set callback __fzf_git_status_callback

    # git diff branch files
  else if string match -rq '^git diff(?=.* -- ) .* $' -- $cmd
    or string match -rq '^git diff(?=.* --no-index ) .* $' -- $cmd
    set source $FZF_GIT_LS_FILES_SOURCE
    set -a opts --multi --read0 --bind=$FZF_GIT_DEFAULT_BIND --preview=$FZF_GIT_LS_FILES_PREVIEW --prompt='Git Diff Branch Files> '

    # git diff
  else if string match -rq '^git diff(?: .*)? $' -- $cmd
    set source $FZF_GIT_BRANCH_SOURCE
    set -a opts --multi --bind=$FZF_GIT_REF_BIND --preview=$FZF_GIT_REF_PREVIEW --preview-window=down --header='C-b: branch, C-c: commit, C-t: tag, C-r: reflog' --prompt='Git Diff> '
    set callback __fzf_git_ref_callback

    # git commit -c/-C/--fixup/--squash
  else if string match -rq '^git commit(?: .*)? -[cC] $' -- $cmd
    or string match -rq '^git commit(?: .*)? --fixup[= ](?:amend:|reword:)?$' -- $cmd
    or string match -rq '^git commit(?: .*)? --(?:(?:reuse:reedit)-message|squash)[= ]$' -- $cmd
    and not string match -rq ' -- ' -- $cmd
    set source $FZF_GIT_LOG_SOURCE
    set -a opts --no-sort --bind=$FZF_GIT_DEFAULT_BIND --preview=$FZF_GIT_LOG_PREVIEW --prompt='Git Commit> '
    set callback __fzf_git_ref_callback

    # git commit files
  else if string match -rq '^git commit(?: .*) $' -- $cmd
    and not string match -rq ' -[mF] $' -- $cmd
    and not string match -rq ' --(?:author|date|template|trailer) $' -- $cmd
    set source $FZF_GIT_STATUS_SOURCE
    set -a opts --multi --no-sort --bind=$FZF_GIT_DEFAULT_BIND --preview=$FZF_GIT_STATUS_PREVIEW --prompt='Git Commit Files> '
    set callback __fzf_git_status_callback

    # git checkout branch files
  else if string match -rq '^git checkout(?=.*(?<! (?:-[bBt]|--orphan|--track|--conflict|--pathspec-from-file)) [^-]) .* $' -- $cmd
    and not string match -rq ' --(?:conflict|pathspec-from-file) $' -- $cmd
    set source $FZF_GIT_LS_FILES_SOURCE
    set -a opts --multi --read0 --bind=$FZF_GIT_DEFAULT_BIND --preview=$FZF_GIT_LS_FILES_PREVIEW --prompt='Git Checkout Branch Files> '

    # git checkout
  else if string match -rq '^git checkout(?: .*)? (?:--track=)?$' -- $cmd
    and not string match -rq ' -- ' -- $cmd
    and not string match -rq ' --(?:conflict|pathspec-from-file) $' -- $cmd
    set source $FZF_GIT_BRANCH_SOURCE
    set -a opts --bind=$FZF_GIT_REF_BIND --preview=$FZF_GIT_REF_PREVIEW --preview-window=down --header='C-b: branch, C-t: tag, C-r: reflog' --prompt='Git Checkout> '
    set callback __fzf_git_ref_callback

    # git checkout files
  else if string match -rq '^git checkout(?: .*)? $' -- $cmd
    and not string match -rq ' --(?:conflict|pathspec-from-file) $' -- $cmd
    set source $FZF_GIT_STATUS_SOURCE
    set -a opts --multi --no-sort --bind=$FZF_GIT_DEFAULT_BIND --preview=$FZF_GIT_STATUS_PREVIEW --prompt='Git Checkout Files> '
    set callback __fzf_git_status_callback

    # git branch -d/-D
  else if string match -rq '^git branch (?:-d|-D)(?: .*)? $' -- $cmd
    and not string match -rq ' --(?:conflict|pathspec-from-file) $' -- $cmd
    set source $FZF_GIT_BRANCH_SOURCE
    set -a opts --multi --no-sort --bind=$FZF_GIT_DEFAULT_BIND --preview=$FZF_GIT_STATUS_PREVIEW --prompt='Git Delete Branch> '
    set callback __fzf_git_ref_callback

    # git reset branch files
  else if string match -rq '^git reset(?=.*(?<! --pathspec-from-file) [^-]) .* $' -- $cmd
    and not string match -rq ' --pathspec-from-file $' -- $cmd
    set source $FZF_GIT_LS_FILES_SOURCE
    set -a opts --multi --read0 --bind=$FZF_GIT_DEFAULT_BIND --preview=$FZF_GIT_LS_FILES_PREVIEW --prompt='Git Reset Branch Files> '

    # git reset
  else if string match -rq '^git reset(?: .*)? $' -- $cmd
    and not string match -rq ' -- ' -- $cmd
    and not string match -rq ' --pathspec-from-file $' -- $cmd
    set source $FZF_GIT_LOG_SOURCE
    set -a opts --bind=$FZF_GIT_REF_BIND --preview=$FZF_GIT_REF_PREVIEW --preview-window=down --header='C-b: branch, C-c: commit, C-t: tag, C-r: reflog' --prompt='Git Reset> '
    set callback __fzf_git_ref_callback

    # git reset files (fallback)
  else if string match -rq '^git reset(?: .*)? $' -- $cmd
    and not string match -rq ' --pathspec-from-file $' -- $cmd
    set source $FZF_GIT_STATUS_SOURCE
    set -a opts --multi --no-sort --bind=$FZF_GIT_DEFAULT_BIND --preview=$FZF_GIT_STATUS_PREVIEW --prompt='Git Reset Files> '

    # git switch
  else if string match -rq '^git switch(?: .*)? $' -- $cmd
    set source $FZF_GIT_BRANCH_SOURCE
    set -a opts --bind=$FZF_GIT_REF_BIND --preview=$FZF_GIT_REF_PREVIEW --preview-window=down --header='C-b: branch, C-c: commit, C-t: tag, C-r: reflog' --prompt='Git Switch> '

    # git restore --source
  else if string match -rq '^git restore(?: .*)? (?:-s |--source[= ])$' -- $cmd
    and not string match -rq ' -- ' -- $cmd
    set source $FZF_GIT_BRANCH_SOURCE
    set -a opts --bind=$FZF_GIT_REF_BIND --preview=$FZF_GIT_REF_PREVIEW --preview-window=down --header='C-b: branch, C-c: commit, C-t: tag, C-r: reflog' --prompt='Git Restore Source> '
    set callback __fzf_git_ref_callback

    # git restore source files
  else if string match -rq '^git restore(?=.* (?:-s |--source[= ])) .* $' -- $cmd
    set source $FZF_GIT_LS_FILES_SOURCE
    set -a opts --multi --read0 --bind=$FZF_GIT_DEFAULT_BIND --preview=$FZF_GIT_LS_FILES_PREVIEW --prompt='Git Restore Files> '

    # git rebase branch
  else if string match -rq '^git rebase(?=.*(?<! (?:-[xsX]|--exec|--strategy(?:-options)?|--onto)) [^-]) .* $' -- $cmd
    set source $FZF_GIT_BRANCH_SOURCE
    set -a opts --bind=$FZF_GIT_REF_BIND --preview=$FZF_GIT_REF_PREVIEW --preview-window=down --header='C-b: branch, C-c: commit, C-t: tag, C-r: reflog' --prompt='Git Rebase Branch> '
    set callback __fzf_git_ref_callback

    # git rebase
  else if string match -rq '^git rebase(?: .*)? (?:--onto[= ])?$' -- $cmd
    and not string match -rq ' -[xsX] $' -- $cmd
    and not string match -rq ' --(?:exec|strategy(?:-option)?) $' -- $cmd
    set source $FZF_GIT_LOG_SOURCE
    set -a opts --bind=$FZF_GIT_REF_BIND --preview=$FZF_GIT_REF_PREVIEW --preview-window=down --header='C-b: branch, C-c: commit, C-t: tag, C-r: reflog' --prompt='Git Rebase Branch> '
    set callback __fzf_git_ref_callback

    # git merge --into-name
  else if string match -rq '^git merge(?: .*)? --into-name[= ]$' -- $cmd
    set source $FZF_GIT_BRANCH_SOURCE
    set -a opts --bind=$FZF_GIT_REF_BIND --preview=$FZF_GIT_REF_PREVIEW --preview-window=down --header='C-b: branch, C-c: commit, C-t: tag, C-r: reflog' --prompt='Git Merge Branch> '
    set callback __fzf_git_ref_callback

    # git merge
  else if string match -rq 'git merge(?: .*)? $' -- $cmd
    and not string match -rq ' -[mFsX] $' -- $cmd
    and not string match -rq ' --(?:file|strategy(?:-option)?) $' -- $cmd
    set source $FZF_GIT_LOG_SOURCE
    set -a opts --bind=$FZF_GIT_REF_BIND --preview=$FZF_GIT_REF_PREVIEW --preview-window=down --header='C-b: branch, C-c: commit, C-t: tag, C-r: reflog' --prompt='Git Merge> '
    set callback __fzf_git_ref_callback

    # git stash apply/drop/pop/show
  else if string match -rq 'git stash (?:apply|drop|pop|show)(?: .*)? $' -- $cmd
    or string match -rq 'git stash branch(?=.* [^-]) .* $' -- $cmd
    set source $FZF_GIT_STASH_SOURCE
    set -a opts --bind=$FZF_GIT_DEFAULT_BIND --preview=$FZF_GIT_STASH_PREVIEW --prompt='Git Stash> '
    set callback __fzf_git_stash_callback

    # git stash branch
  else if string match -rq 'git stash branch(?: .*)? $' -- $cmd
    set source $FZF_GIT_BRANCH_SOURCE
    set -a opts --bind=$FZF_GIT_REF_BIND --preview=$FZF_GIT_REF_PREVIEW --preview-window=down --header='C-b: branch, C-c: commit, C-t: tag, C-r: reflog' --prompt='Git Stash Branch> '
    set callback __fzf_git_ref_callback

    # git stash push files
  else if string match -rq 'git stash push(?: .*)? $' -- $cmd
    set source $FZF_GIT_STATUS_SOURCE
    set -a opts --multi --no-sort --bind=$FZF_GIT_DEFAULT_BIND --preview=$FZF_GIT_STATUS_PREVIEW --prompt='Git Stash Push Files> '
    set callback __fzf_git_status_callback

    # git log file
  else if string match -rq '^git log(?=.* -- ) .* $' -- $cmd
    set source $FZF_GIT_LS_FILES_SOURCE
    set -a opts --read0 --bind=$FZF_GIT_DEFAULT_BIND --preview=$FZF_GIT_LS_FILES_PREVIEW --prompt='Git Log File> '

    # git log
  else if string match -rq '^git log(?: .*)? $' -- $cmd
    and not string match -rq ' --(?:skip|since|after|until|before|author|committer|date) $' -- $cmd
    and not string match -rq ' --(?:branches|tags|remotes|glob|exclude|pretty|format) $' -- $cmd
    and not string match -rq ' --grep(?:-reflog)? $' -- $cmd
    and not string match -rq ' --(?:min|max)-parents $' -- $cmd
    set source $FZF_GIT_BRANCH_SOURCE
    set -a opts --bind=$FZF_GIT_REF_BIND --preview=$FZF_GIT_REF_PREVIEW --preview-window=down --header='C-b: branch, C-c: commit, C-t: tag, C-r: reflog' --prompt='Git Log> '
    set callback __fzf_git_ref_callback

    # git tag list commit
  else if string match -rq '^git tag(?=.* (?:-l|--list) )(?: .*)? --(?:(?:no-)?(?:contains|merged)|points-at) $' -- $cmd
    set source $FZF_GIT_LOG_SOURCE
    set -a opts --bind=$FZF_GIT_REF_BIND --preview=$FZF_GIT_REF_PREVIEW --preview-window=down --header='C-b: branch, C-c: commit, C-t: tag, C-r: reflog' --prompt='Git Tag List Commit> '
    set callback __fzf_git_ref_callback

    # git tag delete
  else if string match -rq '^git tag(?=.* (?:-d|--delete) )(?: .*)? $' -- $cmd
    set source $FZF_GIT_TAG_SOURCE
    set -a opts --bind=$FZF_GIT_REF_BIND --preview=$FZF_GIT_REF_PREVIEW --preview-window=down --header='C-b: branch, C-c: commit, C-t: tag, C-r: reflog' --prompt='Git Tag Delete> '
    set callback __fzf_git_ref_callback

    # git tag
  else if string match -rq '^git tag(?: .*)? $' -- $cmd
    and not string match -rq ' -[umF] $' -- $cmd
    and not string match -rq ' --(?:local-user|format) $' -- $cmd
    set source $FZF_GIT_TAG_SOURCE
    set -a opts --bind=$FZF_GIT_REF_BIND --preview=$FZF_GIT_REF_PREVIEW --preview-window=down --header='C-b: branch, C-c: commit, C-t: tag, C-r: reflog' --prompt='Git Tag> '
    set callback __fzf_git_ref_callback

    # git mv files
  else if string match -rq '^git mv(?: .*)? $' -- $cmd
    set source $FZF_GIT_LS_FILES_SOURCE
    set -a opts --multi --read0 --bind=$FZF_GIT_DEFAULT_BIND --preview=$FZF_GIT_LS_FILES_PREVIEW --prompt='Git Mv Files> '

    # git rm files
  else if string match -rq '^git rm(?: .*)? $' -- $cmd
    set source $FZF_GIT_LS_FILES_SOURCE
    set -a opts --multi --read0 --bind=$FZF_GIT_DEFAULT_BIND --preview=$FZF_GIT_LS_FILES_PREVIEW --prompt='Git Rm Files> '

    # git show
  else if string match -rq '^git show(?: .*)? $' -- $cmd
    and not string match -rq ' --(?:pretty|format) $' -- $cmd
    set source $FZF_GIT_LOG_SOURCE
    set -a opts --bind=$FZF_GIT_REF_BIND --preview=$FZF_GIT_REF_PREVIEW --preview-window=down --header='C-b: branch, C-c: commit, C-t: tag, C-r: reflog' --prompt='Git Show> '
    set callback __fzf_git_ref_callback

    # git revert
  else if string match -rq '^git revert(?: .*)? $' -- $cmd
    set source $FZF_GIT_LOG_SOURCE
    set -a opts --no-sort --bind=$FZF_GIT_DEFAULT_BIND --preview=$FZF_GIT_LOG_PREVIEW --prompt='Git Revert> '
    set callback __fzf_git_ref_callback

  else
    return 1
  end

  # Run fzf
  set -l selections (eval $source | fzf $opts | string split0)

  # first element is typed key (--expect)
  set -l key $selections[1]
  set -e selections[1]

  if [ (count $selections) -eq 0 ]
    commandline -f repaint
    return
  end

  set -l results
  for sel in $selections
    if [ -n "$callback" ]
      set -a results ($callback $sel)
    else
      set -a results $sel
    end
  end

  commandline -a (string join ' ' -- (string escape -- $results))
  commandline -f repaint
end

function fzf_complete
  if not __fzf_git_try_complete
    commandline -f complete
  end
end
