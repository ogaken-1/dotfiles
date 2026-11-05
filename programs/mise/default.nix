{
  programs = {
    mise = {
      enable = true;
      enableFishIntegration = true;
    };
    git.ignores = [
      "mise.local.toml"
    ];
  };
}
