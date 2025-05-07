{
  pkgs,
  config,
  ...
}:
let
  emacsPkg = pkgs.emacsWithPackagesFromUsePackage {
    config = ./init.el;
    defaultInitFile = false;
    alwaysEnsure = false;
    alwaysTangle = false;
    extraEmacsPackages =
      epkgs: with epkgs; [
        treesit-grammars.with-all-grammars
      ];
  };
in
{
  home.file = {
    "${config.xdg.configHome}/emacs/init.el" = {
      source = ./init.el;
    };
    "${config.xdg.configHome}/emacs/early-init.el" = {
      source = ./early-init.el;
    };
  };
  home.packages = with pkgs; [
    cmigemo
    emacs-lsp-booster
    emacsPkg
  ];
  services.emacs = {
    enable = true;
    package = emacsPkg;
  };
}
