{ username, homeDirectory }:
{ pkgs, ... }:
let
  caskaydia-cove = pkgs.callPackage ./packages/caskaydia-cove/package.nix { };
in
{
  services = {
    tailscale = {
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

  system.stateVersion = "24.05";

  fonts.packages = with pkgs; [
    caskaydia-cove
    rounded-mgenplus
    noto-fonts-color-emoji
  ];
  environment = {
    systemPackages = with pkgs; [
      man-pages
      man-pages-posix
    ];
  };
  documentation = {
    dev = {
      enable = true;
    };
  };
  nix = {
    settings = {
      trusted-users = [
        "root"
        "@wheel"
      ];
    };
    extraOptions = ''
      extra-experimental-features = nix-command flakes pipe-operators
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
