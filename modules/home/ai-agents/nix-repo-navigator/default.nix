# modules/home/ai-agents/nix-repo-navigator/default.nix

{
  config,
  lib,
  pkgs,
  nix-repo-navigator,
  ...
}:

with lib;

let
  cfg = config.modules.home.nix-repo-navigator;
in

{
  options.modules.home.nix-repo-navigator = {
    enable = mkEnableOption "nix-repo-navigator";
  };

  config = mkIf cfg.enable {
    home.packages = [
      nix-repo-navigator.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
