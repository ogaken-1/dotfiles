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
      nixpkgs = {
        overlays = [
          inputs.emacs-overlay.overlay
          (import ../overlays/wsl.nix)
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
        home.sessionVariables = {
          SSH_AUTH_SOCK = "\${XDG_RUNTIME_DIR}/ssh-agent.sock";
        };
        systemd.user.services.ssh-agent-relay = {
          Unit = {
            Description = "SSH Agent Relay to Windows";
            StartLimitIntervalSec = 0;
          };
          Service = {
            Type = "exec";
            KillMode = "process";
            ExecStart = "${pkgs.socat}/bin/socat UNIX-LISTEN:%t/ssh-agent.sock,fork EXEC:\"${pkgs.npiperelay}/bin/npiperelay.exe -ei -s //./pipe/openssh-ssh-agent\",nofork";
          };
          Install = {
            WantedBy = [ "default.target" ];
          };
        };
      };
    };
  homeConfig = {
    home-manager = {
      useUserPackages = false;
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
