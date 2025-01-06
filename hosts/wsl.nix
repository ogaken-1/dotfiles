{ inputs }:
let
  inherit (inputs)
    nixpkgs
    nixos-wsl
    vscode-server
    home-manager
    ;
  system = "x86_64-linux";
  username = "ogaken";
in
nixpkgs.lib.nixosSystem {
  inherit system;
  modules = [
    nixos-wsl.nixosModules.default
    vscode-server.nixosModules.default
    (import ../nixos-basic.nix {
      inherit username;
      homeDirectory = "/home/${username}";
    })
    home-manager.nixosModules.home-manager
    {
      home-manager.useUserPackages = false;
      home-manager.users.${username} = import ../home.nix;
    }
  ];
}
