{ inputs }:
let
  inherit (inputs) nix-darwin home-manager;
  system = "aarch64-darwin";
  username = "ogaken";
in
nix-darwin.lib.darwinSystem {
  inherit system;
  inherit (inputs.nixpkgs) lib;
  specialArgs = {
    inherit username;
  };
  modules = [
    {
      users.users.${username}.home = "/Users/${username}";
    }
    ../darwin-basic.nix
    home-manager.darwinModules.home-manager
    {
      home-manager.useUserPackages = false;
      home-manager.users.${username} = import ../home.nix;
    }
  ];
}
