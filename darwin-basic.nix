{
  pkgs,
  ...
}:
let
  caskaydia-cove = pkgs.callPackage ./pkgs/caskaydia-cove/package.nix { };
in
{
  nix = {
    enable = true;
    optimise.automatic = true;
    settings = {
      extra-experimental-features = "nix-command flakes pipe-operators";
    };
    channel = {
      enable = true;
    };
  };
  ids.gids.nixbld = 30000;
  system = {
    stateVersion = 5;
    defaults = {
      finder = {
        AppleShowAllFiles = true;
        AppleShowAllExtensions = true;
      };
      dock = {
        autohide = true;
        show-recents = false;
        orientation = "left";
      };
    };
  };
  fonts.packages = with pkgs; [
    caskaydia-cove
    rounded-mgenplus
    noto-fonts-color-emoji
  ];
  environment = {
    shells = with pkgs; [
      fish
    ];
  };
  homebrew = {
    enable = true;
    casks = [
      "1password"
      "alacritty"
      "aquaskk"
      "claude"
      "discord"
      "ghostty"
      "loop"
      "nordvpn"
      "notion"
      "notion-calendar"
      "orion"
      "slack"
      "spotify"
      "steam"
      "container"
      "microsoft-edge"
    ];
    onActivation = {
      autoUpdate = true;
      cleanup = "uninstall";
      upgrade = true;
    };
    taps = [
      "homebrew/bundle"
      "homebrew/core"
    ];
  };
}
