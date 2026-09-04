{ ... }:
{
  imports = [ ./module.nix ];
  programs.ov = {
    enable = false;
    manIntegration.enable = false;
    psqlIntegration.enable = true;
  };
}
