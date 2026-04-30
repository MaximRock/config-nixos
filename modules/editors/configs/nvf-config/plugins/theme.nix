{ pkgs, ... }:

let
  theme = import ../nvf-var.nix { inherit pkgs; };
in

{
  enable = true;
  name = theme.themeName; #"tokyonight";
  style = theme.themeStyle;
}
