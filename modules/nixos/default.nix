# Системные настройки nixpkgs: overlays и разрешение unfree.
# Вынесено отдельно, чтобы не засорять flake.nix
{
  config,
  pkgs,
  lib,
  overlays,
  ...
}:

{
  nixpkgs.overlays = overlays;
  nixpkgs.config.allowUnfree = true;
}
