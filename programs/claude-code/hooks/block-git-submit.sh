#!/usr/bin/env bash
# Block commits, pushes and PR operations: the user does all submission work.
# Staging (git add, git rm, ...) and read-only commands are allowed.
# Used as a PreToolUse hook for the Bash tool (applies to the main session and sub-agents).
#
# Input: JSON on stdin with tool_input.command field
# Exit 0: allow, Exit 2: block

COMMAND=$(jq -r '.tool_input.command // empty')

if [ -z "$COMMAND" ]; then
  exit 0
fi

# git [global options such as -C <dir> or -c <k=v>] <subcommand>
# Subcommands that create commits or send them elsewhere.
git_re='(^|[^[:alnum:]_./-])git([[:space:]]+-[^[:space:]]+([[:space:]]+[^-[:space:]][^[:space:]]*)?)*[[:space:]]+(commit|push|merge|rebase|cherry-pick|revert|am)([[:space:]]|$)'
# Creating or merging GitHub PRs / GitLab MRs.
gh_re='(^|[^[:alnum:]_./-])gh[[:space:]]+pr[[:space:]]+(create|merge)([[:space:]]|$)'
glab_re='(^|[^[:alnum:]_./-])glab[[:space:]]+mr[[:space:]]+(create|merge)([[:space:]]|$)'

if echo "$COMMAND" | grep -qE "$git_re|$gh_re|$glab_re"; then
  echo 'コミット・push・PR作成などの提出作業はユーザーが行います。エージェントは実行しないでください（git add などのステージングは可）。' >&2
  exit 2
fi

exit 0
