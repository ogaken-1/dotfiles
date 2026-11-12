# Platform profile: facts about Claude Code 2.1.317 that origins do not state.
# Probed on 2026-11-12 (`claude --version` = 2.1.317).
{
  claudeCode = "2.1.317";
  probedAt = "2026-11-12";

  tools = [
    "Agent"
    "Artifact"
    "AskUserQuestion"
    "Bash"
    "Edit"
    "ListAgents"
    "Read"
    "ReportFindings"
    "ScheduleWakeup"
    "SendFeedback"
    "Skill"
    "ToolSearch"
    "Workflow"
    "Write"
    "ArtifactComments"
    "ArtifactData"
    "CronCreate"
    "CronDelete"
    "CronList"
    "DesignSync"
    "EndConversation"
    "EnterPlanMode"
    "EnterWorktree"
    "ExitPlanMode"
    "ExitWorktree"
    "ListMcpResourcesTool"
    "Monitor"
    "NotebookEdit"
    "PushNotification"
    "ReadMcpResourceDirTool"
    "ReadMcpResourceTool"
    "RemoteTrigger"
    "SendMessage"
    "SendToProject"
    "SendToProjectContext"
    "TaskStop"
    "WebFetch"
    "WebSearch"
  ];

  # Tool names that are also ordinary English words. In an origin's text they only count as a
  # mention when written in backticks, and in an attribute value only when a part of the value
  # (split at "/", "," and whitespace) is exactly the name.
  ambiguousToolNames = [
    "Read"
    "Edit"
    "Write"
    "Bash"
    "Agent"
    "Skill"
    "Monitor"
    "Workflow"
    "Artifact"
  ];

  # Built-in skills (confirmed in the main session on 2026-11-12).
  builtinSkills = [
    "code-review"
    "simplify"
    "fewer-permission-prompts"
    "loop"
    "schedule"
    "claude-api"
    "update-config"
    "keybindings-help"
    "init"
    "security-review"
    "run"
    "plugin-authoring"
    "workflow-authoring"
    "artifact-design"
    "artifact-diagramming"
    "artifact-capabilities"
    "dataviz"
  ];

  # Custom commands (~/.claude/commands/<n>.md) can also be invoked through the Skill tool, so
  # "skill:<n>" is a valid reference to them.
  commandsAreSkills = true;

  # Value is the successor tool name; null means no successor.
  removed = {
    TodoWrite = null;
    # Searching is done through Bash (find / grep).
    Glob = "Bash";
    Grep = "Bash";
    TaskOutput = null;
    Task = "Agent";
  };

  requires = [
    {
      act = "ExitPlanMode";
      pre = "EnterPlanMode";
    }
  ];

  mcpNaming = {
    direct = server: tool: "mcp__${server}__${tool}";
    plugin = plugin: server: tool: "mcp__plugin_${plugin}_${server}__${tool}";
    # claude.ai connectors
    connector = name: tool: "mcp__claude_ai_${name}__${tool}";
  };

  # Context inheritance of built-in agents. null = not measured (treated as inheriting:
  # a false positive is preferred over a missed conflict).
  agents = {
    general-purpose = {
      userMemory = true;
      projectMemory = true;
    };
    statusline-setup = {
      userMemory = true;
      projectMemory = true;
    };
    Explore = {
      userMemory = false;
      projectMemory = false;
    };
    Plan = null;
    claude-code-guide = null;
    claude = null;
  };

  customAgents = {
    userMemory = true;
    projectMemory = true;
  };
}
