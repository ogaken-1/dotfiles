{ pkgs, ... }:
let
  # Hook to deny a specific command pattern and suggest an alternative
  denyCommand =
    {
      pattern,
      message,
    }:
    {
      type = "command";
      command = ''COMMAND=$(jq -r '.tool_input.command') && if echo "$COMMAND" | grep -qE '(^|[;&|])\s*${pattern}\b'; then echo '${message}' >&2; exit 2; fi'';
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
    permissions = {
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
              pattern = "grep";
              message = "grepコマンドは使用禁止です。代わりにrgを使ってください。";
            })
            (denyCommand {
              pattern = "cat";
              message = "catコマンドは使用禁止です。ファイルの読み取りにはReadツール、書き込みにはWriteツールを使ってください。";
            })
            (denyCommand {
              pattern = "sed[[:space:]]+(-[a-zA-Z]+[[:space:]]+)*-n[[:space:]]+[^;&|]*[0-9]+,[0-9]+p";
              message = "sed -n でのファイル行範囲抽出は禁止です。Readツールの offset と limit パラメータを使ってください。";
            })
            (denyCommand {
              pattern = "python3?";
              message = "pythonは使用禁止です。代わりにperlまたはrubyを使ってください。";
            })
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
