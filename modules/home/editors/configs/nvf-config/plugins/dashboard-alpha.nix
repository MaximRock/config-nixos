# modules/home/editors/configs/nvf-config/plugins/dashboard-alpha.nix

{ pkgs, ... }:

let
  theme = import ../nvf-var.nix { inherit pkgs; };
in

{
  enable = true;
  theme = theme.themeAlpha; # "dashboard";
}
