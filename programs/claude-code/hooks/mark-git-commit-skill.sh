#!/usr/bin/env bash
# Mark that the create-git-commit skill has been invoked for this session.
# Used as a PreToolUse hook for the Skill tool.
#
# Input: JSON on stdin with tool_input.skill and session_id fields
# Exit 0: always allow (this hook only creates a marker)

INPUT=$(cat)
SKILL=$(echo "$INPUT" | jq -r '.tool_input.skill // empty')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')

if [ "$SKILL" = "create-git-commit" ] && [ -n "$SESSION_ID" ]; then
  touch "/tmp/claude-git-commit-skill-$SESSION_ID"
fi

exit 0
