{ pkgs, ... }:
let
  # Hook to deny a specific command pattern and suggest an alternative.
  # Set onlyAtStart = true to match only when the command appears at the start of
  # the input (i.e. not via pipe), useful when piped usage is legitimate.
  denyCommand =
    {
      pattern,
      message,
      onlyAtStart ? false,
    }:
    let
      anchor = if onlyAtStart then "^" else "(^|[;&|])";
    in
    {
      type = "command";
      command = ''COMMAND=$(jq -r '.tool_input.command') && if echo "$COMMAND" | grep -qE '${anchor}\s*${pattern}\b'; then echo '${message}' >&2; exit 2; fi'';
    };
  statusline-script = pkgs.writeShellScript "claude-statusline" ''
    INPUT=$(cat)
    SESSION_ID=$(echo "$INPUT" | jq -r '.session_id')
    REMAINING=$(echo "$INPUT" | jq -r '.context_window.remaining_percentage // 100')
    echo "$REMAINING" > "/tmp/claude-context-$SESSION_ID"
    MODEL=$(echo "$INPUT" | jq -r '.model.display_name')
    USED=$(echo "$INPUT" | jq -r '.context_window.used_percentage // 0')

    # Extract cwd and project_dir
    CWD=$(echo "$INPUT" | jq -r '.cwd')
    PROJECT_DIR=$(echo "$INPUT" | jq -r '.workspace.project_dir')

    # Build base status
    STATUS="[$MODEL] $USED% used"

    # Add cwd indicator if different from project_dir
    if [ "$CWD" != "$PROJECT_DIR" ]; then
      # Substitute HOME with ~ for shorter display
      CWD_DISPLAY=$(echo "$CWD" | sed "s|^$HOME|~|")
      STATUS="$STATUS | 📂 $CWD_DISPLAY"
    fi

    echo "$STATUS"
  '';
in
{
  programs.claude-code.settings = {
    language = "japanese";
    effortLevel = "high";
    autoUpdates = false;
    autoCompactEnabled = true;
    tui = "fullscreen";
    permissions = {
      allow = [
        # MCP: read-only code navigation (Serena) — safe across all projects
        "mcp__plugin_claude-code-home-manager_serena__find_symbol"
        "mcp__plugin_claude-code-home-manager_serena__find_referencing_symbols"
        "mcp__plugin_claude-code-home-manager_serena__find_implementations"
        "mcp__plugin_claude-code-home-manager_serena__find_declaration"
        "mcp__plugin_claude-code-home-manager_serena__get_symbols_overview"
        "mcp__plugin_claude-code-home-manager_serena__get_diagnostics_for_file"
        "mcp__plugin_claude-code-home-manager_serena__list_memories"
        "mcp__plugin_claude-code-home-manager_serena__read_memory"
        "mcp__plugin_claude-code-home-manager_serena__initial_instructions"
        "mcp__plugin_claude-code-home-manager_serena__onboarding"
        # MCP: docs lookup (read-only servers) — wildcard is safe, all tools are read-only
        "mcp__plugin_claude-code-home-manager_context7__*"
        "mcp__claude_ai_Microsoft_Docs__*"
        # Web search (read-only)
        "WebSearch"
        # Bash: read-only file/dir inspection (find/grep/cat are blocked by PreToolUse hooks)
        "Bash(ls *)"
        "Bash(fd *)"
        "Bash(rg *)"
        "Bash(grep *)"
        "Bash(wc *)"
        "Bash(head *)"
        "Bash(tail *)"
        "Bash(tree *)"
        # Bash: git read-only subcommands
        "Bash(git status *)"
        "Bash(git log *)"
        "Bash(git diff *)"
        "Bash(git show *)"
        "Bash(git ls-tree *)"
        "Bash(git diff-tree *)"
        # Skills: orchestration entrypoints (downstream tools remain permission-gated)
        "Skill(execute)"
        "Skill(plan-workflow)"
        "Skill(impl-workflow)"
        "Skill(feedback)"
        "Skill(bug)"
        "Skill(ask)"
        "Skill(define)"
        "Skill(fact-check)"
        "Skill(investigation-patterns)"
        "Skill(markdown)"
      ];
      deny = [
        "Read(.envrc)"
      ];
    };
    statusLine = {
      type = "command";
      command = "${statusline-script}";
    };
    attribution = {
      commit = "";
      pr = "";
    };
    hooks = {
      PreToolUse = [
        {
          matcher = "EnterPlanMode";
          hooks = [
            {
              type = "command";
              command = "echo 'EnterPlanModeは使用禁止。/plan-workflow コマンドを使ってください' >&2 && exit 2";
            }
          ];
        }
        {
          matcher = "TaskOutput";
          hooks = [
            {
              type = "command";
              command = "echo 'TaskOutputは使用禁止です。バックグラウンドタスクの結果はサブエージェントが完了時に自動で返却されるため、TaskOutputで明示的に取得する必要はありません。context windowの圧迫を防ぐため、TaskOutputの代わりにTaskツールのblock=trueオプションまたはサブエージェントの自動返却を利用してください。' >&2 && exit 2";
            }
          ];
        }
        {
          matcher = "Bash";
          hooks = [
            (denyCommand {
              pattern = "find";
              message = "findコマンドは使用禁止です。代わりにfdを使ってください。";
            })
            (denyCommand {
              pattern = "cat";
              message = "catコマンドは使用禁止です。ファイルの読み取りにはReadツール、書き込みにはWriteツールを使ってください。";
            })
            (denyCommand {
              pattern = "sed[[:space:]]+(-[a-zA-Z]+[[:space:]]+)*-n[[:space:]]+[^;&|]*[0-9]+,[0-9]+p";
              message = "sed -n でのファイル行範囲抽出は禁止です。Readツールの offset と limit パラメータを使ってください。";
              onlyAtStart = true;
            })
            (denyCommand {
              pattern = "python3?";
              message = "pythonは使用禁止です。代わりにperlまたはrubyを使ってください。";
            })
            {
              type = "command";
              command = ''COMMAND=$(jq -r '.tool_input.command') && if echo "$COMMAND" | grep -qE '(^|[[:space:]=])/tmp(/|$|[[:space:]])'; then echo '/tmpの使用は禁止です。一時ファイルはプロジェクト内の./tmpに置いてください。' >&2; exit 2; fi'';
            }
            {
              type = "command";
              command = "${./hooks/require-git-commit-skill.sh}";
            }
          ];
        }
        {
          matcher = "Skill";
          hooks = [
            {
              type = "command";
              command = "${./hooks/mark-git-commit-skill.sh}";
            }
          ];
        }
      ];
    };
  };
}
