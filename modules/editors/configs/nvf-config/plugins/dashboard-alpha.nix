{ pkgs, ... }:

let
  theme = import ../nvf-var.nix { inherit pkgs; };
in

{
  enable = true;
  theme = theme.themeAlpha; # "dashboard";
}
