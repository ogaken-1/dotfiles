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
  wslConfig =
    { pkgs, ... }:
    {
      nixpkgs.overlays = [
        inputs.emacs-overlay.overlay
      ];
      wsl = {
        enable = true;
        defaultUser = username;
        docker-desktop.enable = false;
        interop = {
          includePath = false;
        };
        # emacsclientをWindowsのランチャーから認識できるように/usr/share/applicationsに配置する
        startMenuLaunchers = true;
      };
      environment = {
        systemPackages = with pkgs; [
          emacs-unstable
        ];
      };
    };
  homeConfig = {
    home-manager = {
      useUserPackages = false;
      users.${username} = import ../home.nix { inherit inputs; };
    };
  };
  nixosConfig = import ../nixos-basic.nix {
    inherit username;
    homeDirectory = "/home/${username}";
  };
in
nixpkgs.lib.nixosSystem {
  inherit system;
  modules = [
    nixos-wsl.nixosModules.default
    vscode-server.nixosModules.default
    home-manager.nixosModules.home-manager
    nixosConfig
    wslConfig
    homeConfig
  ];
}
