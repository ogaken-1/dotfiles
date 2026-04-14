{
  pkgs,
  config,
  ...
}:
let
  context7-wrapped = pkgs.writeShellScriptBin "context7-mcp" ''
    export CONTEXT7_API_KEY="$(cat ${config.sops.secrets.context7-api-key.path})"
    exec ${pkgs.context7-mcp}/bin/context7-mcp "$@"
  '';
in
{
  programs.claude-code.mcpServers = {
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
      command = "${context7-wrapped}/bin/context7-mcp";
      type = "stdio";
    };
    playwright = {
      command = "${pkgs.playwright-mcp}/bin/playwright-mcp";
      args = [
        "--headless"
      ];
      type = "stdio";
    };
    codex = {
      command = "${pkgs.codex}/bin/codex";
      args = [
        "--sandbox"
        "workspace-write"
        "--ask-for-approval"
        "never"
        "mcp-server"
      ];
      type = "stdio";
    };
  };
}
