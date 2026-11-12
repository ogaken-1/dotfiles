#!/usr/bin/env bash
# Ask for confirmation when find is used with side-effect actions (-exec, -delete, etc.).
# Used as a PreToolUse hook for the Bash tool at the top level.
#
# Input: JSON on stdin with tool_input.command field
# Exit 0 with no output: defer to the normal permission flow
# Exit 0 with permissionDecision "ask": prompt the user

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [ -z "$COMMAND" ]; then
  exit 0
fi

# find is not in command position: nothing to do
if ! echo "$COMMAND" | grep -qE '(^|[;&|])[[:space:]]*find\b'; then
  exit 0
fi

if echo "$COMMAND" | grep -qE '(^|[[:space:]])-(exec|execdir|ok|okdir|delete|fprint0?|fprintf|fls)([[:space:]]|$)'; then
  jq -n '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"ask",permissionDecisionReason:"findの-exec/-delete等の副作用を伴うアクションはユーザー確認が必要です。"}}'
fi

exit 0
