{ inputs }:
let
  inherit (inputs) nix-darwin home-manager mac-app-util;
  system = "aarch64-darwin";
  username = "ogaken";
  homeConfiguration = (import ../home.nix { inherit inputs; });
  config =
    { pkgs, ... }:
    {
      nixpkgs = {
        overlays = [
          nix-darwin.overlays.default
        ];
      };
      system.primaryUser = username;
      environment.systemPackages = with pkgs; [
        darwin-rebuild
      ];
      security.sudo.extraConfig = ''
        admin ALL=(${username}) NOPASSWD: ${pkgs.darwin-rebuild}/bin/darwin-rebuild
      '';
      users.users.${username} = {
        home = "/Users/${username}";
        shell = pkgs.fish;
      };
      programs.fish.enable = true;
      home-manager.sharedModules = [
        mac-app-util.homeManagerModules.default
      ];
      home-manager.useUserPackages = false;
      home-manager.users.${username} = homeConfiguration;
    };
in
nix-darwin.lib.darwinSystem {
  inherit system;
  inherit (inputs.nixpkgs) lib;
  specialArgs = {
    inherit username;
  };
  modules = [
    home-manager.darwinModules.home-manager
    ../darwin-basic.nix
    config
  ];
}
