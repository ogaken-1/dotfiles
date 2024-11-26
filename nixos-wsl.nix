{ pkgs, ... }:
let
  home = ((import ./home.nix) pkgs).home;
in
{
  services = {
    vscode-server = {
      enable = true;
    };
  };

  boot = {
    tmp = {
      useTmpfs = true;
    };
  };

  virtualisation = {
    docker = {
      enable = true;
    };
  };

  wsl = {
    enable = true;
    defaultUser = home.username;
    docker-desktop.enable = false;
    interop = {
      includePath = false;
    };
  };

  system.stateVersion = "24.05";

  fonts.packages = with pkgs; [
    cascadia-code
  ];

  nix = {
    settings = {
      trusted-users = [
        "root"
        "@wheel"
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
    };
  };

  systemd = {
    user = {
      services = {
        vscode-server = {
          enable = true;
        };
      };
    };
  };

  time.timeZone = "Asia/Tokyo";

  users.users.${home.username} = {
    isNormalUser = true;
    home = home.homeDirectory;
    description = "Kento Ogata";
    extraGroups = [
      "wheel"
      "docker"
    ];
    shell = "${pkgs.fish}/bin/fish";
  };
}
