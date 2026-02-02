{ pkgs }:
let
  caskaydia-cove = pkgs.callPackage ../pkgs/caskaydia-cove/package.nix { };
in
[
  caskaydia-cove
  pkgs.rounded-mgenplus
  pkgs.noto-fonts-color-emoji
]
