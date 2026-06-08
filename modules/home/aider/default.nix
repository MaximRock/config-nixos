# modules/home/aider/default.nix

{
  config,
  pkgs,
  username,
  ...
}:

{
  imports = [
    ./package.nix
    ./config.nix
    ./model-settings.nix
    ./model-metadata.nix
  ];
}
