{ username, homeDirectory }:
{ pkgs, ... }:
let
  userInfo = import ./lib/user.nix;
  fonts = import ./lib/fonts.nix { inherit pkgs; };
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

  fonts.packages = fonts;
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

  programs.nix-ld = {
    enable = true;
    libraries =
      with pkgs;
      let
        vscode-deps = [
          alsa-lib
          at-spi2-core
          cairo
          cups
          dbus
          expat
          glib
          gtk3
          libXcomposite
          libXdamage
          libXext
          libXfixes
          libXrandr
          libgbm
          libxcb
          libxkbcommon
          nspr
          nss
          pango
          systemdLibs
          xorg.libX11
        ];
      in
      [ ] ++ vscode-deps;
  };

  time.timeZone = "Asia/Tokyo";

  users.users.${username} = {
    isNormalUser = true;
    home = homeDirectory;
    description = userInfo.fullName;
    extraGroups = [
      "wheel"
      "docker"
    ];
    shell = "${pkgs.fish}/bin/fish";
  };
}
