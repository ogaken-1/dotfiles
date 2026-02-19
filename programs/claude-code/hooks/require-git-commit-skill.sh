#!/usr/bin/env bash
# Require the create-git-commit skill to be invoked before git add/commit.
# Used as a PreToolUse hook for the Bash tool at the top level.
#
# Input: JSON on stdin with tool_input.command and session_id fields
# Exit 0: allow, Exit 2: block

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')

if [ -z "$COMMAND" ] || [ -z "$SESSION_ID" ]; then
  exit 0
fi

if echo "$COMMAND" | grep -iE '\bgit\s+(add|commit)\b' > /dev/null; then
  if [ ! -f "/tmp/claude-git-commit-skill-$SESSION_ID" ]; then
    echo "Blocked: git add/commit requires the create-git-commit skill. Run /create-git-commit first." >&2
    exit 2
  fi
fi

exit 0
