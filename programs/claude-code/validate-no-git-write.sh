#!/usr/bin/env bash
# Validate that a Bash command does not perform git write operations.
# Used as a PreToolUse hook for sub-agents that should not create commits.
#
# Input: JSON on stdin with tool_input.command field
# Exit 0: allow, Exit 2: block

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [ -z "$COMMAND" ]; then
  exit 0
fi

# Block git write operations (case-insensitive)
if echo "$COMMAND" | grep -iE '\bgit\s+(add|commit|push|rebase|merge|cherry-pick|revert|tag)\b' > /dev/null; then
  echo "Blocked: git write operations are not allowed in this agent. Return your changes to the parent agent for committing." >&2
  exit 2
fi

exit 0
