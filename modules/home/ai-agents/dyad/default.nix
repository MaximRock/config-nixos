# modules/home/ai-agents/dyad/default.nix

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.modules.home.dyad;
in

{
  options.modules.home.dyad = {
    enable = mkEnableOption "Dyad AI app builder";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.dyad ];
  };
}
