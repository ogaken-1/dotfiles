{ inputs }:
let
  inherit (inputs)
    nixpkgs
    nixos-wsl
    vscode-server
    home-manager
    ;
  userInfo = import ../lib/user.nix;
  system = "x86_64-linux";
  username = userInfo.username;
  wslConfig =
    { pkgs, ... }:
    {
      nixpkgs = {
        overlays = [
          inputs.emacs-overlay.overlay
        ];
      };
      wsl = {
        enable = true;
        defaultUser = username;
        docker-desktop.enable = false;
        interop = {
          includePath = false;
          register = true;
        };
        # emacsclientをWindowsのランチャーから認識できるように/usr/share/applicationsに配置する
        startMenuLaunchers = true;
      };
      environment = {
        systemPackages = with pkgs; [
          emacs-unstable
        ];
      };
      services = {
        vscode-server = {
          enable = true;
          nodejsPackage = pkgs.nodejs;
        };
      };
      home-manager.users.${username} = {
        imports = [ ../modules/wsl-ssh-agent-relay.nix ] ++ (import ../programs/cli.nix);
      };
    };
  homeConfig = {
    home-manager = {
      useUserPackages = false;
      extraSpecialArgs = { inherit userInfo; };
      users.${username} = import ../home.nix { inherit inputs; };
      backupFileExtension = "backup";
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
