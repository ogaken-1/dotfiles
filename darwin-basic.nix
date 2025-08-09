{
  pkgs,
  ...
}:
let
  caskaydia-cove = pkgs.callPackage ./packages/caskaydia-cove/package.nix { };
in
{
  nix = {
    enable = true;
    optimise.automatic = true;
    settings = {
      extra-experimental-features = "nix-command flakes pipe-operators";
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
}
