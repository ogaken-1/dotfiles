# Wires eunomia's mkClaudeConfig to this repository's Claude Code setup (checks and the home-manager module).
{ pkgs }:
let
  eunomia = import ../../pkgs/eunomia/lib { inherit pkgs; };

  # settings.nix is a home-manager module that only needs `pkgs`, so evaluate it directly and
  # reuse its values instead of copying them.
  settings = (import ./settings.nix { inherit pkgs; }).programs.claude-code.settings;

  # GoogleChrome/modern-web-guidance; only its modern-web-guidance skill is deployed.
  modern-web-guidance-src = pkgs.fetchFromGitHub {
    owner = "GoogleChrome";
    repo = "modern-web-guidance";
    rev = "4dd968349e54ca45a05dd5c818fb035c9054b022";
    hash = "sha256-bqsUEI1yaGy1sd8DBJzG5cOv4Yv0RSYac6e9egqYFJU=";
  };
in
eunomia.mkClaudeConfig {
  src = ./src;
  platform = eunomia.platforms."claude-code-2.1.317";
  memory = "user";

  # Tool names of the MCP servers declared in mcp-servers.nix (confirmed in the main session on
  # 2026-11-12), registered as plugin "hm".
  mcp = {
    serena = {
      plugin = "hm";
      tools = [
        "delete_memory"
        "edit_memory"
        "find_declaration"
        "find_implementations"
        "find_referencing_symbols"
        "find_symbol"
        "get_diagnostics_for_file"
        "get_symbols_overview"
        "initial_instructions"
        "insert_after_symbol"
        "insert_before_symbol"
        "list_memories"
        "onboarding"
        "read_memory"
        "rename_memory"
        "rename_symbol"
        "replace_content"
        "replace_in_files"
        "replace_symbol_body"
        "safe_delete_symbol"
        "write_memory"
      ];
    };
    context7 = {
      plugin = "hm";
      tools = [
        "query-docs"
        "resolve-library-id"
      ];
    };
    playwright = {
      plugin = "hm";
      tools = [
        "browser_click"
        "browser_close"
        "browser_console_messages"
        "browser_drag"
        "browser_drop"
        "browser_emulate_media"
        "browser_evaluate"
        "browser_file_upload"
        "browser_fill_form"
        "browser_find"
        "browser_handle_dialog"
        "browser_hover"
        "browser_navigate"
        "browser_navigate_back"
        "browser_network_request"
        "browser_network_requests"
        "browser_press_key"
        "browser_resize"
        "browser_run_code_unsafe"
        "browser_select_option"
        "browser_snapshot"
        "browser_tabs"
        "browser_take_screenshot"
        "browser_type"
        "browser_wait_for"
      ];
    };
  };

  permissionsAllow = settings.permissions.allow;
  inherit (settings) hooks;

  extra.skills.slide-generating = ./skills/slide-generating;
  extra.skills.modern-web-guidance = "${modern-web-guidance-src}/skills/modern-web-guidance";
}
