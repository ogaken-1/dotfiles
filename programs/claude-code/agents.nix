{ ... }:
let
  lib = import ./lib.nix;
in
{
  programs.claude-code.agents = {
    code-quality = lib.buildMarkdown {
      front-matter = {
        name = "code-quality";
        description = "Code quality analysis and refactoring recommendations. Use proactively after code changes.";
        model = "sonnet";
        skills = [ "onboarding" ];
      };
      body = ./agents/code-quality.xml;
    };
    coding = lib.buildMarkdown {
      front-matter = {
        name = "coding";
        description = "Test-first workflow implementation (test → review → implement). Use proactively for code implementation tasks.";
        model = "sonnet";
        memory = "project";
        skills = [ "onboarding" ];
        disallowedTools = [
          "mcp__codex__codex"
          "mcp__codex__codex-reply"
        ];
        hooks = {
          PreToolUse = [
            {
              matcher = "Bash";
              hooks = [
                {
                  type = "command";
                  command = "${./hooks/validate-no-git-write.sh}";
                }
              ];
            }
          ];
        };
      };
      body = ./agents/coding.xml;
    };
    characterization = lib.buildMarkdown {
      front-matter = {
        name = "characterization";
        description = "Create characterization tests for non tested programs.";
        model = "sonnet";
        memory = "project";
        skills = [ "onboarding" ];
        hooks = {
          PreToolUse = [
            {
              matcher = "Bash";
              hooks = [
                {
                  type = "command";
                  command = "${./hooks/validate-no-git-write.sh}";
                }
              ];
            }
          ];
        };
      };
      body = ./agents/characterization.xml;
    };
    database = lib.buildMarkdown {
      front-matter = {
        name = "database";
        description = "Database design, optimization, and query analysis. Use for database-related tasks.";
        model = "sonnet";
        skills = [ "onboarding" ];
      };
      body = ./agents/database.xml;
    };
    design = lib.buildMarkdown {
      front-matter = {
        name = "design";
        description = "System architecture and API design analysis. Use for architectural decisions.";
        model = "opus";
        memory = "project";
        skills = [ "onboarding" ];
      };
      body = ./agents/design.xml;
    };
    devops = lib.buildMarkdown {
      front-matter = {
        name = "devops";
        description = "Infrastructure, CI/CD, and observability. Use for DevOps-related tasks.";
        model = "sonnet";
        skills = [ "onboarding" ];
      };
      body = ./agents/devops.xml;
    };
    docs = lib.buildMarkdown {
      front-matter = {
        name = "docs";
        description = "Documentation updates and maintenance. Use proactively after code changes.";
        model = "sonnet";
        skills = [ "onboarding" ];
      };
      body = ./agents/docs.xml;
    };
    explore = lib.buildMarkdown {
      front-matter = {
        name = "explore";
        description = "Codebase exploration and file discovery. Use for understanding code structure.";
        model = "haiku";
        skills = [ "onboarding" ];
      };
      body = ./agents/explore.xml;
    };
    fact-check = lib.buildMarkdown {
      front-matter = {
        name = "fact-check";
        description = "External source verification for claims about libraries, docs, and standards.";
        model = "sonnet";
        skills = [ "onboarding" ];
      };
      body = ./agents/fact-check.xml;
    };
    git = lib.buildMarkdown {
      front-matter = {
        name = "git";
        description = "Git workflow design and operations. Use for version control tasks.";
        model = "sonnet";
        skills = [ "onboarding" ];
      };
      body = ./agents/git.xml;
    };
    performance = lib.buildMarkdown {
      front-matter = {
        name = "performance";
        description = "Performance analysis and optimization. Use for performance-related tasks.";
        model = "sonnet";
        skills = [ "onboarding" ];
      };
      body = ./agents/performance.xml;
    };
    quality-assurance = lib.buildMarkdown {
      front-matter = {
        name = "quality-assurance";
        description = "Code review and quality validation. Use proactively after implementation.";
        model = "sonnet";
        memory = "project";
        skills = [ "onboarding" ];
      };
      body = ./agents/quality-assurance.xml;
    };
    security = lib.buildMarkdown {
      front-matter = {
        name = "security";
        description = "Security vulnerability detection and analysis. Use proactively for security review.";
        model = "sonnet";
        skills = [ "onboarding" ];
      };
      body = ./agents/security.xml;
    };
    test = lib.buildMarkdown {
      front-matter = {
        name = "test";
        description = "Test creation, coverage analysis, and test execution. Use for testing tasks.";
        model = "sonnet";
        skills = [ "onboarding" ];
      };
      body = ./agents/test.xml;
    };
    validator = lib.buildMarkdown {
      front-matter = {
        name = "validator";
        description = "Cross-validation and consensus verification. Use for verifying agent outputs.";
        model = "opus";
        skills = [ "onboarding" ];
      };
      body = ./agents/validator.xml;
    };
  };
}
