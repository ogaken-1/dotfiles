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
      code-quality = lib.buildMarkdown {
        front-matter = {
          name = "code-quality";
          description = "Code quality analysis and refactoring recommendations. Use proactively after code changes.";
        };
        body = ./agents/code-quality.xml;
      };
      coding = lib.buildMarkdown {
        front-matter = {
          name = "coding";
          description = "Test-first workflow implementation (test → review → implement). Use proactively for code implementation tasks.";
        };
        body = ./agents/coding.xml;
      };
      database = lib.buildMarkdown {
        front-matter = {
          name = "database";
          description = "Database design, optimization, and query analysis. Use for database-related tasks.";
        };
        body = ./agents/database.xml;
      };
      design = lib.buildMarkdown {
        front-matter = {
          name = "design";
          description = "System architecture and API design analysis. Use for architectural decisions.";
        };
        body = ./agents/design.xml;
      };
      devops = lib.buildMarkdown {
        front-matter = {
          name = "devops";
          description = "Infrastructure, CI/CD, and observability. Use for DevOps-related tasks.";
        };
        body = ./agents/devops.xml;
      };
      docs = lib.buildMarkdown {
        front-matter = {
          name = "docs";
          description = "Documentation updates and maintenance. Use proactively after code changes.";
        };
        body = ./agents/docs.xml;
      };
      explore = lib.buildMarkdown {
        front-matter = {
          name = "explore";
          description = "Codebase exploration and file discovery. Use for understanding code structure.";
        };
        body = ./agents/explore.xml;
      };
      fact-check = lib.buildMarkdown {
        front-matter = {
          name = "fact-check";
          description = "External source verification for claims about libraries, docs, and standards.";
        };
        body = ./agents/fact-check.xml;
      };
      git = lib.buildMarkdown {
        front-matter = {
          name = "git";
          description = "Git workflow design and operations. Use for version control tasks.";
        };
        body = ./agents/git.xml;
      };
      performance = lib.buildMarkdown {
        front-matter = {
          name = "performance";
          description = "Performance analysis and optimization. Use for performance-related tasks.";
        };
        body = ./agents/performance.xml;
      };
      quality-assurance = lib.buildMarkdown {
        front-matter = {
          name = "quality-assurance";
          description = "Code review and quality validation. Use proactively after implementation.";
        };
        body = ./agents/quality-assurance.xml;
      };
      security = lib.buildMarkdown {
        front-matter = {
          name = "security";
          description = "Security vulnerability detection and analysis. Use proactively for security review.";
        };
        body = ./agents/security.xml;
      };
      test = lib.buildMarkdown {
        front-matter = {
          name = "test";
          description = "Test creation, coverage analysis, and test execution. Use for testing tasks.";
        };
        body = ./agents/test.xml;
      };
      validator = lib.buildMarkdown {
        front-matter = {
          name = "validator";
          description = "Cross-validation and consensus verification. Use for verifying agent outputs.";
        };
        body = ./agents/validator.xml;
      };
    };
    commands = {
      markdown = lib.buildMarkdown {
        front-matter = {
          name = "markdown";
          description = "Markdown text update command";
          argument-hint = "[file-path]";
        };
        body = ./commands/markdown.xml;
      };
      execute = lib.buildMarkdown {
        front-matter = {
          name = "execute";
          description = "Task execution command";
          argument-hint = "[task-description]";
        };
        body = ./commands/execute.xml;
      };
      ask = lib.buildMarkdown {
        front-matter = {
          name = "ask";
          description = "Question and inquiry command";
          argument-hint = "[question]";
        };
        body = ./commands/ask.xml;
      };
      bug = lib.buildMarkdown {
        front-matter = {
          name = "bug";
          description = "Root cause investigation command";
          argument-hint = "[error-message]";
        };
        body = ./commands/bug.xml;
      };
      define = lib.buildMarkdown {
        front-matter = {
          name = "define";
          description = "Requirements definition command";
          argument-hint = "[message]";
        };
        body = ./commands/define.xml;
      };
      feedback = lib.buildMarkdown {
        front-matter = {
          name = "feedback";
          description = "Review command for Claude Code's recent work";
          argument-hint = "[previous-command]";
        };
        body = ./commands/feedback.xml;
      };
      serena-usage = lib.buildMarkdown {
        front-matter = {
          name = "Serena Usage";
          description = "This skill should be used when the user asks to \"use serena\", \"semantic search\", \"symbol analysis\", \"find references\", \"code navigation\", or needs Serena MCP guidance. Provides Serena tool usage patterns.";
        };
        body = ./skills/serena-usage.xml;
      };
      context7-usage = lib.buildMarkdown {
        front-matter = {
          name = "Context7 Usage";
          description = "This skill should be used when the user asks to \"check documentation\", \"latest API\", \"library docs\", \"context7\", or needs up-to-date library documentation. Provides Context7 MCP usage patterns.";
        };
        body = ./skills/context7-usage.xml;
      };
      execution-workflow = lib.buildMarkdown {
        front-matter = {
          name = "Execution Workflow";
          description = "This skill should be used when the user asks to \"execute task\", \"implement feature\", \"delegate work\", \"run workflow\", \"review code\", \"code quality check\", or needs task orchestration and code review guidance. Provides execution, delegation, and code review patterns.";
        };
        body = ./skills/execution-workflow.xml;
      };
      fact-check = lib.buildMarkdown {
        front-matter = {
          name = "Fact Check";
          description = "This skill should be used when the user asks to \"verify claims\", \"fact check\", \"validate documentation\", \"check sources\", or needs verification of external source references. Provides patterns for systematic fact verification using Context7 and WebSearch.";
        };
        body = ./skills/fact-check.xml;
      };
      investigation-patterns = lib.buildMarkdown {
        front-matter = {
          name = "Investigation Patterns";
          description = "This skill should be used when the user asks to \"investigate code\", \"analyze implementation\", \"find patterns\", \"understand codebase\", \"debug issue\", \"find bug\", \"troubleshoot\", or needs evidence-based code analysis and debugging. Provides systematic investigation and debugging methodology.";
        };
        body = ./skills/investigation-patterns.xml;
      };
      testing-patterns = lib.buildMarkdown {
        front-matter = {
          name = "Testing Patterns";
          description = "This skill should be used when the user asks to \"write tests\", \"test strategy\", \"coverage\", \"unit test\", \"integration test\", or needs testing guidance. Provides testing methodology and patterns.";
        };
        body = ./skills/testing-patterns.xml;
      };
      nvim-ix-source = lib.buildMarkdown {
        front-matter = {
          name = "nvim-ix Source";
          description = "This skill should be used when the user asks to \"create nvim-ix source\", \"nvim-ix completion\", \"cmp-kit source\", \"neovim completion source\", or needs guidance on implementing custom completion sources for nvim-ix/nvim-cmp-kit. Provides interface specifications and implementation patterns.";
        };
        body = ./skills/nvim-ix-source.xml;
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
      codex = {
        command = "${pkgs.codex}/bin/codex";
        args = [
          "mcp-server"
          "-c"
          "sandbox_permissions=[\"read-only\"]"
        ];
        type = "stdio";
      };
    };
  };
  programs.codex = {
    package = pkgs.codex;
    enable = true;
    settings = {
      mcp_servers = {
        serena = {
          command = "${pkgs.serena}/bin/serena";
          args = [
            "start-mcp-server"
            "--context"
            "claude-code"
            "--project-from-cwd"
          ];
        };
      };
      instructions = ''
        When starting a task, use the serena MCP tools (list_memories, read_memory)
        to check for project-specific patterns and conventions stored in Serena memory.
      '';
    };
  };
}
