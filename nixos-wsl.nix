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
    defaultUser = "ogaken";
    docker-desktop.enable = false;
    interop = {
      includePath = false;
    };
  };

  system.stateVersion = "24.05";

  nix = {
    settings = {
      trusted-users = [
        "root"
        "@wheel"
      ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
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

  users.users.ogaken = {
    isNormalUser = true;
    home = "/home/ogaken";
    description = "Kento Ogata";
    extraGroups = [
      "wheel"
      "docker"
    ];
  };
}
