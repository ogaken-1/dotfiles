{
  pkgs,
  ...
}:
let
  lib = import ./lib.nix;
in
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
      code-quality = builtins.readFile ./agents/code-quality.xml;
      coding = builtins.readFile ./agents/coding.xml;
      database = builtins.readFile ./agents/database.xml;
      design = builtins.readFile ./agents/design.xml;
      devops = builtins.readFile ./agents/devops.xml;
      docs = builtins.readFile ./agents/docs.xml;
      explore = builtins.readFile ./agents/explore.xml;
      fact-check = builtins.readFile ./agents/fact-check.xml;
      git = builtins.readFile ./agents/git.xml;
      performance = builtins.readFile ./agents/performance.xml;
      quality-assurance = builtins.readFile ./agents/quality-assurance.xml;
      security = builtins.readFile ./agents/security.xml;
      test = builtins.readFile ./agents/test.xml;
      validator = builtins.readFile ./agents/validator.xml;
    };
    commands = {
      markdown = lib.buildMarkdown {
        front-matter = {
          name = "markdown";
          description = "Markdown text update command";
          argument-hint = "[file-path]";
        };
        body = ./commands/markdown.xml;
        order = [ "name" "description" "argument-hint" ];
      };
      execute = lib.buildMarkdown {
        front-matter = {
          name = "execute";
          description = "Task execution command";
          argument-hint = "[task-description]";
        };
        body = ./commands/execute.xml;
        order = [ "name" "description" "argument-hint" ];
      };
      ask = lib.buildMarkdown {
        front-matter = {
          name = "ask";
          description = "Question and inquiry command";
          argument-hint = "[question]";
        };
        body = ./commands/ask.xml;
        order = [ "name" "description" "argument-hint" ];
      };
      bug = lib.buildMarkdown {
        front-matter = {
          name = "bug";
          description = "Root cause investigation command";
          argument-hint = "[error-message]";
        };
        body = ./commands/bug.xml;
        order = [ "name" "description" "argument-hint" ];
      };
      define = lib.buildMarkdown {
        front-matter = {
          name = "define";
          description = "Requirements definition command";
          argument-hint = "[message]";
        };
        body = ./commands/define.xml;
        order = [ "name" "description" "argument-hint" ];
      };
      feedback = lib.buildMarkdown {
        front-matter = {
          name = "feedback";
          description = "Review command for Claude Code's recent work";
          argument-hint = "[previous-command]";
        };
        body = ./commands/feedback.xml;
        order = [ "name" "description" "argument-hint" ];
      };
    };
    skills = {
      serena-usage = lib.buildMarkdown {
        front-matter = {
          name = "Serena Usage";
          description = "This skill should be used when the user asks to \"use serena\", \"semantic search\", \"symbol analysis\", \"find references\", \"code navigation\", or needs Serena MCP guidance. Provides Serena tool usage patterns.";
        };
        body = ./skills/serena-usage.xml;
        order = [ "name" "description" ];
      };
      context7-usage = lib.buildMarkdown {
        front-matter = {
          name = "Context7 Usage";
          description = "This skill should be used when the user asks to \"check documentation\", \"latest API\", \"library docs\", \"context7\", or needs up-to-date library documentation. Provides Context7 MCP usage patterns.";
        };
        body = ./skills/context7-usage.xml;
        order = [ "name" "description" ];
      };
      orchestration = lib.buildMarkdown {
        front-matter = {
          name = "Orchestration";
          description = "This skill should be used for complex multi-agent tasks, parallel execution, cross-validation, or when orchestrating multiple sub-agents. Provides workflow patterns for agent coordination.";
        };
        body = ./skills/orchestration.xml;
        order = [ "name" "description" ];
      };
      execution-workflow = lib.buildMarkdown {
        front-matter = {
          name = "Execution Workflow";
          description = "This skill should be used when the user asks to \"execute task\", \"implement feature\", \"delegate work\", \"run workflow\", \"review code\", \"code quality check\", or needs task orchestration and code review guidance. Provides execution, delegation, and code review patterns.";
        };
        body = ./skills/execution-workflow.xml;
        order = [ "name" "description" ];
      };
      fact-check = lib.buildMarkdown {
        front-matter = {
          name = "Fact Check";
          description = "This skill should be used when the user asks to \"verify claims\", \"fact check\", \"validate documentation\", \"check sources\", or needs verification of external source references. Provides patterns for systematic fact verification using Context7 and WebSearch.";
        };
        body = ./skills/fact-check.xml;
        order = [ "name" "description" ];
      };
      investigation-patterns = lib.buildMarkdown {
        front-matter = {
          name = "Investigation Patterns";
          description = "This skill should be used when the user asks to \"investigate code\", \"analyze implementation\", \"find patterns\", \"understand codebase\", \"debug issue\", \"find bug\", \"troubleshoot\", or needs evidence-based code analysis and debugging. Provides systematic investigation and debugging methodology.";
        };
        body = ./skills/investigation-patterns.xml;
        order = [ "name" "description" ];
      };
      testing-patterns = lib.buildMarkdown {
        front-matter = {
          name = "Testing Patterns";
          description = "This skill should be used when the user asks to \"write tests\", \"test strategy\", \"coverage\", \"unit test\", \"integration test\", or needs testing guidance. Provides testing methodology and patterns.";
        };
        body = ./skills/testing-patterns.xml;
        order = [ "name" "description" ];
      };
    };
    mcpServers = {
      serena = {
        command = "${pkgs.serena}/bin/serena";
        args = [
          "start-mcp-server"
          "--context"
          "claude-code"
          "--project-from-cwd"
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
