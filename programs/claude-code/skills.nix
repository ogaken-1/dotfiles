{ ... }:
let
  lib = import ./lib.nix;
  skillDefs = {
    plan-workflow = lib.buildMarkdown {
      front-matter = {
        name = "plan-workflow";
        description = "This skill should be used when in Plan mode (EnterPlanMode) or when the user needs requirements definition, technical investigation, or design planning. Provides structured planning workflow with investigation, clarification, and requirements documentation.";
      };
      body = ./skills/plan-workflow.xml;
    };
    impl-workflow = lib.buildMarkdown {
      front-matter = {
        name = "impl-workflow";
        description = "Use for any code implementation task, from simple edits to complex features. Scales workflow to task complexity — handles sub-agent delegation, testing strategy, and git policy.";
      };
      body = ./skills/impl-workflow.xml;
    };
    execution-workflow = lib.buildMarkdown {
      front-matter = {
        name = "execution-workflow";
        description = ''This skill should be used when the user asks to "execute task", "implement feature", "delegate work", "run workflow", "review code", "code quality check", or needs task orchestration and code review guidance. Provides execution, delegation, and code review patterns.'';
      };
      body = ./skills/execution-workflow.xml;
    };
    serena-usage = lib.buildMarkdown {
      front-matter = {
        name = "serena-usage";
        description = ''This skill should be used when the user asks to "use serena", "semantic search", "symbol analysis", "find references", "code navigation", or needs Serena MCP guidance. Provides Serena tool usage patterns.'';
      };
      body = ./skills/serena-usage.xml;
    };
    context7-usage = lib.buildMarkdown {
      front-matter = {
        name = "context7-usage";
        description = ''This skill should be used when the user asks to "check documentation", "latest API", "library docs", "context7", or needs up-to-date library documentation. Provides Context7 MCP usage patterns.'';
      };
      body = ./skills/context7-usage.xml;
    };
    fact-check = lib.buildMarkdown {
      front-matter = {
        name = "fact-check";
        description = ''This skill should be used when the user asks to "verify claims", "fact check", "validate documentation", "check sources", or needs verification of external source references. Provides patterns for systematic fact verification using Context7 and WebSearch.'';
      };
      body = ./skills/fact-check.xml;
    };
    investigation-patterns = lib.buildMarkdown {
      front-matter = {
        name = "investigation-patterns";
        description = ''This skill should be used when the user asks to "investigate code", "analyze implementation", "find patterns", "understand codebase", "debug issue", "find bug", "troubleshoot", or needs evidence-based code analysis and debugging. Provides systematic investigation and debugging methodology.'';
      };
      body = ./skills/investigation-patterns.xml;
    };
    testing-patterns = lib.buildMarkdown {
      front-matter = {
        name = "testing-patterns";
        description = ''This skill should be used when the user asks to "write tests", "test strategy", "coverage", "unit test", "integration test", or needs testing guidance. Provides testing methodology and patterns.'';
      };
      body = ./skills/testing-patterns.xml;
    };
    nvim-ix-source = lib.buildMarkdown {
      front-matter = {
        name = "nvim-ix-source";
        description = ''This skill should be used when the user asks to "create nvim-ix source", "nvim-ix completion", "cmp-kit source", "neovim completion source", or needs guidance on implementing custom completion sources for nvim-ix/nvim-cmp-kit. Provides interface specifications and implementation patterns.'';
      };
      body = ./skills/nvim-ix-source.xml;
    };
    create-git-commit = lib.buildMarkdown {
      front-matter = {
        name = "create-git-commit";
        description = "Step-by-step workflow for creating git commits. Use when you need to commit changes: lint/format check, explicit staging, conventional commit message, and fixup decision.";
      };
      body = ./skills/create-git-commit.xml;
    };
    refactoring-loop = lib.buildMarkdown {
      front-matter = {
        name = "refactoring-loop";
        description = "Post-implementation refactoring loop. Use after feat/fix implementation to iteratively improve code quality. Ensures test safety net before refactoring, delegates analysis to code-quality agent and execution to coding agent, repeats until no more improvements are found (max 10 iterations).";
      };
      body = ./skills/refactoring-loop.xml;
    };
    onboarding = lib.buildMarkdown {
      front-matter = {
        name = "onboarding";
        description = "Read and follow CLAUDE.md project instructions before starting work. Ensures sub-agents are aware of project-specific rules and conventions.";
      };
      body = ./skills/onboarding.xml;
    };
  };
in
{
  home.file =
    (
      builtins.attrNames skillDefs
      |> map (name: {
        name = ".claude/skills/${name}/SKILL.md";
        value = {
          text = skillDefs.${name};
        };
      })
      |> builtins.listToAttrs
    )
    // {
      ".claude/skills/slide-generating/SKILL.md" = {
        source = ./skills/slide-generating/SKILL.md;
      };
      ".claude/skills/slide-generating/references" = {
        source = ./skills/slide-generating/references;
        recursive = true;
      };
    };
}
