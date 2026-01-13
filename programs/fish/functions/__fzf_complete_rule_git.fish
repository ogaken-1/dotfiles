# __fzf_complete_git.fish - Git Completion rules
# See: ../conf.d/fzf_complete.fish ./fzf_complete.fish
#
# Git completion patterns ported from zeno.zsh
# https://github.com/yuki-yano/zeno.zsh
#
# MIT License
# Copyright (c) 2021 Yuki Yano

# === Transformers ===
# fzfでの選択結果をcommandline引数形式に変換
function __fzf_git_status_to_arg
  cat | string sub -s 4
end

function __fzf_git_ref_to_arg
  cat | string split \t | head -1 | awk '{ print $2 }'
end

function __fzf_git_stash_to_arg
  cat | string split \t | head -1 | awk '{ print $1 }'
end

function __fzf_complete_rule_git
  set -l cmd (commandline)
  set -l source ''
  set -l opts $FZF_COMPLETE_COMMON_OPTS
  set -l transformer ''

  # git add
  if string match -rq '^git add(?: .*)? $' -- $cmd
    set source $FZF_GIT_STATUS_SOURCE
    set -a opts $FZF_GIT_PRESET_STATUS --prompt='Git Add Files> '
    set transformer __fzf_git_status_to_arg

    # git diff files (with --)
  else if string match -rq '^git diff(?=.* -- ) .* $' -- $cmd
    and not string match -rq '^git diff.* [^-].* -- ' -- $cmd
    and not string match -rq ' --no-index ' -- $cmd
    set source $FZF_GIT_STATUS_SOURCE
    set -a opts $FZF_GIT_PRESET_STATUS --prompt='Git Diff Files> '
    set transformer __fzf_git_status_to_arg

    # git diff branch files
  else if string match -rq '^git diff(?=.* -- ) .* $' -- $cmd
    or string match -rq '^git diff(?=.* --no-index ) .* $' -- $cmd
    set source $FZF_GIT_LS_FILES_SOURCE
    set -a opts $FZF_GIT_PRESET_LS_FILES --prompt='Git Diff Branch Files> '

    # git diff
  else if string match -rq '^git diff(?: .*)? $' -- $cmd
    set source $FZF_GIT_BRANCH_SOURCE
    set -a opts $FZF_GIT_PRESET_REF --multi --header=$FZF_GIT_REF_HEADER_FULL --prompt='Git Diff> '
    set transformer __fzf_git_ref_to_arg

    # git commit -c/-C/--fixup/--squash
  else if string match -rq '^git commit(?: .*)? -[cC] $' -- $cmd
    or string match -rq '^git commit(?: .*)? --fixup[= ](?:amend:|reword:)?$' -- $cmd
    or string match -rq '^git commit(?: .*)? --(?:(?:reuse:reedit)-message|squash)[= ]$' -- $cmd
    and not string match -rq ' -- ' -- $cmd
    set source $FZF_GIT_LOG_SOURCE
    set -a opts $FZF_GIT_PRESET_LOG_SIMPLE --prompt='Git Commit> '
    set transformer __fzf_git_ref_to_arg

    # git commit files
  else if string match -rq '^git commit(?: .*) $' -- $cmd
    and not string match -rq ' -[mF] $' -- $cmd
    and not string match -rq ' --(?:author|date|template|trailer) $' -- $cmd
    set source $FZF_GIT_STATUS_SOURCE
    set -a opts $FZF_GIT_PRESET_STATUS --prompt='Git Commit Files> '
    set transformer __fzf_git_status_to_arg

    # git checkout branch files
  else if string match -rq '^git checkout(?=.*(?<! (?:-[bBt]|--orphan|--track|--conflict|--pathspec-from-file)) [^-]) .* $' -- $cmd
    and not string match -rq ' --(?:conflict|pathspec-from-file) $' -- $cmd
    set source $FZF_GIT_LS_FILES_SOURCE
    set -a opts $FZF_GIT_PRESET_LS_FILES --prompt='Git Checkout Branch Files> '

    # git checkout
  else if string match -rq '^git checkout(?: .*)? (?:--track=)?$' -- $cmd
    and not string match -rq ' -- ' -- $cmd
    and not string match -rq ' --(?:conflict|pathspec-from-file) $' -- $cmd
    set source $FZF_GIT_BRANCH_SOURCE
    set -a opts $FZF_GIT_PRESET_REF --header=$FZF_GIT_REF_HEADER_NO_COMMIT --prompt='Git Checkout> '
    set transformer __fzf_git_ref_to_arg

    # git checkout files
  else if string match -rq '^git checkout(?: .*)? $' -- $cmd
    and not string match -rq ' --(?:conflict|pathspec-from-file) $' -- $cmd
    set source $FZF_GIT_STATUS_SOURCE
    set -a opts $FZF_GIT_PRESET_STATUS --prompt='Git Checkout Files> '
    set transformer __fzf_git_status_to_arg

    # git branch -d/-D
  else if string match -rq '^git branch (?:-d|-D)(?: .*)? $' -- $cmd
    and not string match -rq ' --(?:conflict|pathspec-from-file) $' -- $cmd
    set source $FZF_GIT_BRANCH_SOURCE
    set -a opts $FZF_GIT_PRESET_REF --multi --prompt='Git Delete Branch> '
    set transformer __fzf_git_ref_to_arg

    # git reset branch files
  else if string match -rq '^git reset(?=.*(?<! --pathspec-from-file) [^-]) .* $' -- $cmd
    and not string match -rq ' --pathspec-from-file $' -- $cmd
    set source $FZF_GIT_LS_FILES_SOURCE
    set -a opts $FZF_GIT_PRESET_LS_FILES --prompt='Git Reset Branch Files> '

    # git reset
  else if string match -rq '^git reset(?: .*)? $' -- $cmd
    and not string match -rq ' -- ' -- $cmd
    and not string match -rq ' --pathspec-from-file $' -- $cmd
    set source $FZF_GIT_LOG_SOURCE
    set -a opts $FZF_GIT_PRESET_REF --header=$FZF_GIT_REF_HEADER_FULL --prompt='Git Reset> '
    set transformer __fzf_git_ref_to_arg

    # git reset files (fallback)
  else if string match -rq '^git reset(?: .*)? $' -- $cmd
    and not string match -rq ' --pathspec-from-file $' -- $cmd
    set source $FZF_GIT_STATUS_SOURCE
    set -a opts $FZF_GIT_PRESET_STATUS --prompt='Git Reset Files> '

    # git switch
  else if string match -rq '^git switch(?: .*)? $' -- $cmd
    set source $FZF_GIT_BRANCH_SOURCE
    set -a opts $FZF_GIT_PRESET_REF --header=$FZF_GIT_REF_HEADER_FULL --prompt='Git Switch> '

    # git restore --source
  else if string match -rq '^git restore(?: .*)? (?:-s |--source[= ])$' -- $cmd
    and not string match -rq ' -- ' -- $cmd
    set source $FZF_GIT_BRANCH_SOURCE
    set -a opts $FZF_GIT_PRESET_REF --header=$FZF_GIT_REF_HEADER_FULL --prompt='Git Restore Source> '
    set transformer __fzf_git_ref_to_arg

    # git restore source files
  else if string match -rq '^git restore(?=.* (?:-s |--source[= ])) .* $' -- $cmd
    set source $FZF_GIT_LS_FILES_SOURCE
    set -a opts $FZF_GIT_PRESET_LS_FILES --prompt='Git Restore Files> '

    # git rebase branch
  else if string match -rq '^git rebase(?=.*(?<! (?:-[xsX]|--exec|--strategy(?:-options)?|--onto)) [^-]) .* $' -- $cmd
    set source $FZF_GIT_BRANCH_SOURCE
    set -a opts $FZF_GIT_PRESET_REF --header=$FZF_GIT_REF_HEADER_FULL --prompt='Git Rebase Branch> '
    set transformer __fzf_git_ref_to_arg

    # git rebase
  else if string match -rq '^git rebase(?: .*)? (?:--onto[= ])?$' -- $cmd
    and not string match -rq ' -[xsX] $' -- $cmd
    and not string match -rq ' --(?:exec|strategy(?:-option)?) $' -- $cmd
    set source $FZF_GIT_LOG_SOURCE
    set -a opts $FZF_GIT_PRESET_REF --header=$FZF_GIT_REF_HEADER_FULL --prompt='Git Rebase Branch> '
    set transformer __fzf_git_ref_to_arg

    # git merge --into-name
  else if string match -rq '^git merge(?: .*)? --into-name[= ]$' -- $cmd
    set source $FZF_GIT_BRANCH_SOURCE
    set -a opts $FZF_GIT_PRESET_REF --header=$FZF_GIT_REF_HEADER_FULL --prompt='Git Merge Branch> '
    set transformer __fzf_git_ref_to_arg

    # git merge
  else if string match -rq 'git merge(?: .*)? $' -- $cmd
    and not string match -rq ' -[mFsX] $' -- $cmd
    and not string match -rq ' --(?:file|strategy(?:-option)?) $' -- $cmd
    set source $FZF_GIT_LOG_SOURCE
    set -a opts $FZF_GIT_PRESET_REF --header=$FZF_GIT_REF_HEADER_FULL --prompt='Git Merge> '
    set transformer __fzf_git_ref_to_arg

    # git stash apply/drop/pop/show
  else if string match -rq 'git stash (?:apply|drop|pop|show)(?: .*)? $' -- $cmd
    or string match -rq 'git stash branch(?=.* [^-]) .* $' -- $cmd
    set source $FZF_GIT_STASH_SOURCE
    set -a opts $FZF_GIT_PRESET_STASH --prompt='Git Stash> '
    set transformer __fzf_git_stash_to_arg

    # git stash branch
  else if string match -rq 'git stash branch(?: .*)? $' -- $cmd
    set source $FZF_GIT_BRANCH_SOURCE
    set -a opts $FZF_GIT_PRESET_REF --header=$FZF_GIT_REF_HEADER_FULL --prompt='Git Stash Branch> '
    set transformer __fzf_git_ref_to_arg

    # git stash push files
  else if string match -rq 'git stash push(?: .*)? $' -- $cmd
    set source $FZF_GIT_STATUS_SOURCE
    set -a opts $FZF_GIT_PRESET_STATUS --prompt='Git Stash Push Files> '
    set transformer __fzf_git_status_to_arg

    # git log file
  else if string match -rq '^git log(?=.* -- ) .* $' -- $cmd
    set source $FZF_GIT_LS_FILES_SOURCE
    set -a opts $FZF_GIT_PRESET_LS_FILES --prompt='Git Log File> '

    # git log
  else if string match -rq '^git log(?: .*)? $' -- $cmd
    and not string match -rq ' --(?:skip|since|after|until|before|author|committer|date) $' -- $cmd
    and not string match -rq ' --(?:branches|tags|remotes|glob|exclude|pretty|format) $' -- $cmd
    and not string match -rq ' --grep(?:-reflog)? $' -- $cmd
    and not string match -rq ' --(?:min|max)-parents $' -- $cmd
    set source $FZF_GIT_BRANCH_SOURCE
    set -a opts $FZF_GIT_PRESET_REF --header=$FZF_GIT_REF_HEADER_FULL --prompt='Git Log> '
    set transformer __fzf_git_ref_to_arg

    # git tag list commit
  else if string match -rq '^git tag(?=.* (?:-l|--list) )(?: .*)? --(?:(?:no-)?(?:contains|merged)|points-at) $' -- $cmd
    set source $FZF_GIT_LOG_SOURCE
    set -a opts $FZF_GIT_PRESET_REF --header=$FZF_GIT_REF_HEADER_FULL --prompt='Git Tag List Commit> '
    set transformer __fzf_git_ref_to_arg

    # git tag delete
  else if string match -rq '^git tag(?=.* (?:-d|--delete) )(?: .*)? $' -- $cmd
    set source $FZF_GIT_TAG_SOURCE
    set -a opts $FZF_GIT_PRESET_REF --header=$FZF_GIT_REF_HEADER_FULL --prompt='Git Tag Delete> '
    set transformer __fzf_git_ref_to_arg

    # git tag
  else if string match -rq '^git tag(?: .*)? $' -- $cmd
    and not string match -rq ' -[umF] $' -- $cmd
    and not string match -rq ' --(?:local-user|format) $' -- $cmd
    set source $FZF_GIT_TAG_SOURCE
    set -a opts $FZF_GIT_PRESET_REF --header=$FZF_GIT_REF_HEADER_FULL --prompt='Git Tag> '
    set transformer __fzf_git_ref_to_arg

    # git mv files
  else if string match -rq '^git mv(?: .*)? $' -- $cmd
    set source $FZF_GIT_LS_FILES_SOURCE
    set -a opts $FZF_GIT_PRESET_LS_FILES --prompt='Git Mv Files> '

    # git rm files
  else if string match -rq '^git rm(?: .*)? $' -- $cmd
    set source $FZF_GIT_LS_FILES_SOURCE
    set -a opts $FZF_GIT_PRESET_LS_FILES --prompt='Git Rm Files> '

    # git show
  else if string match -rq '^git show(?: .*)? $' -- $cmd
    and not string match -rq ' --(?:pretty|format) $' -- $cmd
    set source $FZF_GIT_LOG_SOURCE
    set -a opts $FZF_GIT_PRESET_REF --header=$FZF_GIT_REF_HEADER_FULL --prompt='Git Show> '
    set transformer __fzf_git_ref_to_arg

    # git revert
  else if string match -rq '^git revert(?: .*)? $' -- $cmd
    set source $FZF_GIT_LOG_SOURCE
    set -a opts $FZF_GIT_PRESET_LOG_SIMPLE --prompt='Git Revert> '
    set transformer __fzf_git_ref_to_arg

  else
    return 1
  end

  __fzf_complete_run "$source" "$transformer" $opts
  return 0
end
