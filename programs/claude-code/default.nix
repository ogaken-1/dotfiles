{
  pkgs,
  config,
  lib,
  ...
}:
let
  slide-to-pdf = pkgs.callPackage ../../pkgs/slide-to-pdf/package.nix { };
in
{
  # homeManagerModule is a module function, so it must go through `imports`, not mkMerge.
  imports = [ (import ./eunomia.nix { inherit pkgs; }).homeManagerModule ];
  config = lib.mkMerge [
    (import ./settings.nix { inherit pkgs; })
    (import ./mcp-servers.nix { inherit pkgs config; })
    {
      nixpkgs.config.allowUnfree = true;
      programs.claude-code.enable = true;
      home.sessionVariables.CLAUDE_CODE_DISABLE_BACKGROUND_TASKS = "1";
      # claudeが起動時にマーケットプレイス更新のためにssh git@github.comすることを禁止したい。
      # sshキーによるアクセスだと非公開リポジトリにもアクセスできてしまうこと、sshキー指定してないので
      # agentが保持している鍵を1つ1つgithubに投げてしまうことが問題
      # workaround: https://github.com/anthropics/claude-code/issues/21108#issuecomment-4107383369
      home.sessionVariables.DISABLE_AUTOUPDATER = "1";
      home.packages = [
        slide-to-pdf
      ];
    }
  ];
}
