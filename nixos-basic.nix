{ username, homeDirectory }:
{ pkgs, ... }:
let
  caskaydia-cove = pkgs.callPackage ./packages/caskaydia-cove/package.nix { };
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
    defaultUser = username;
    docker-desktop.enable = false;
    interop = {
      includePath = false;
    };
  };

  system.stateVersion = "24.05";

  fonts.packages = with pkgs; [
    caskaydia-cove
    rounded-mgenplus
    noto-fonts-color-emoji
  ];

  nix = {
    settings = {
      trusted-users = [
        "root"
        "@wheel"
      ];
    };
    extraOptions = ''
      extra-experimental-features = nix-command flakes
    '';
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

  programs.nix-ld.enable = true;

  time.timeZone = "Asia/Tokyo";

  users.users.${username} = {
    isNormalUser = true;
    home = homeDirectory;
    description = "Kento Ogata";
    extraGroups = [
      "wheel"
      "docker"
    ];
    shell = "${pkgs.fish}/bin/fish";
  };
}
