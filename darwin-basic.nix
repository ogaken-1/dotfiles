{
  pkgs,
  ...
}:
let
  fonts = import ./lib/fonts.nix { inherit pkgs; };
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
  fonts.packages = fonts;
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
