{
  pkgs,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;
  programs.claude-code = {
    enable = true;
    memory.source = ./CLAUDE.md;
    settings = {
      autoUpdates = false;
      autoCompactEnabled = true;
      attribution = {
        commit = "";
        pr = "";
      };
    };
    agents = {
      code-quality = builtins.readFile ./agents/code-quality.md;
      database = builtins.readFile ./agents/database.md;
      design = builtins.readFile ./agents/design.md;
      devops = builtins.readFile ./agents/devops.md;
      docs = builtins.readFile ./agents/docs.md;
      explore = builtins.readFile ./agents/explore.md;
      fact-check = builtins.readFile ./agents/fact-check.md;
      git = builtins.readFile ./agents/git.md;
      performance = builtins.readFile ./agents/performance.md;
      quality-assurance = builtins.readFile ./agents/quality-assurance.md;
      security = builtins.readFile ./agents/security.md;
      test = builtins.readFile ./agents/test.md;
      validator = builtins.readFile ./agents/validator.md;
    };
    commands = {
      markdown = builtins.readFile ./commands/markdown.md;
      execute = builtins.readFile ./commands/execute.md;
      ask = builtins.readFile ./commands/ask.md;
      bug = builtins.readFile ./commands/bug.md;
      define = builtins.readFile ./commands/define.md;
      feedback = builtins.readFile ./commands/feedback.md;
    };
    skills = {
      serena-usage = builtins.readFile ./skills/serena-usage.md;
      context7-usage = builtins.readFile ./skills/context7-usage.md;
      orchestration = builtins.readFile ./skills/orchestration.md;
      execution-workflow = builtins.readFile skills/execution-workflow.md;
      fact-check = builtins.readFile skills/fact-check.md;
      investigation-patterns = builtins.readFile skills/investigation-patterns.md;
      testing-patterns = builtins.readFile skills/testing-patterns.md;
    };
    mcpServers = {
      serena = {
        command = "${pkgs.serena}/bin/serena";
        args = [
          "start-mcp-server"
        ];
        type = "stdio";
      };
      context7 = {
        command = "${pkgs.context7-mcp}/bin/context7-mcp";
        type = "stdio";
      };
    };
  };
}
