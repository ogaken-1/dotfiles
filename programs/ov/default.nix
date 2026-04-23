{ ... }:
{
  imports = [ ./module.nix ];
  programs.ov = {
    enable = true;
    manIntegration.enable = false;
    psqlIntegration.enable = true;
  };
}
