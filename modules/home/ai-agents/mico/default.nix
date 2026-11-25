# modules/home/ai-agents/mico/default.nix

{
  config,
  lib,
  pkgs,
  mico,
  ...
}:

with lib;

let
  cfg = config.modules.home.mico;
  package = mico.packages.${pkgs.stdenv.hostPlatform.system}.default;
in

{
  options.modules.home.mico = {
    enable = mkEnableOption "mico";
  };

  config = mkIf cfg.enable {
    home.packages = [ package ];
  };
}
