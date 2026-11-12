---
name: "sample-agent"
description: "Test-first agent."
model: "sonnet"
memory: "project"
skills: ["onboarding", "serena-usage"]
tools: ["Read", "mcp__plugin_hm_serena__find_symbol"]
disallowedTools: ["mcp__codex__codex-reply"]
color: "blue"
effort: "high"
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - command: "/nix/store/fake-hook/bin/hook"
          type: "command"
---

    <purpose>Agent body.</purpose>
