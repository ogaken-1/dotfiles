{ ... }:
let
  lib = import ./lib.nix;
in
{
  programs.claude-code.commands = {
    markdown = lib.buildMarkdown {
      front-matter = {
        name = "markdown";
        description = "Markdown text update command";
        argument-hint = "[file-path]";
      };
      body = ./commands/markdown.xml;
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
    feedback = lib.buildMarkdown {
      front-matter = {
        name = "feedback";
        description = "Review command for Claude Code's recent work";
        argument-hint = "[previous-command]";
      };
      body = ./commands/feedback.xml;
    };
  };
}
