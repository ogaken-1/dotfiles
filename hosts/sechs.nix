{ inputs }:
let
  inherit (inputs) nix-darwin home-manager;
  system = "aarch64-darwin";
  username = "ogaken";
  config =
    { pkgs, ... }:
    {
      system.primaryUser = username;
      users.users.${username} = {
        home = "/Users/${username}";
        shell = pkgs.fish;
      };
      programs.fish.enable = true;
    };
in
nix-darwin.lib.darwinSystem {
  inherit system;
  inherit (inputs.nixpkgs) lib;
  specialArgs = {
    inherit username;
  };
  modules = [
    config
    ../darwin-basic.nix
    home-manager.darwinModules.home-manager
    {
      home-manager.useUserPackages = false;
      home-manager.users.${username} = import ../home.nix { inherit inputs; };
    }
  ];
}
