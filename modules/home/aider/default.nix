# modules/home/aider/default.nix

{
  config,
  pkgs,
  ...
}:

{
  imports = [
    ./package.nix
    ./symlinks.nix
  ];
}
