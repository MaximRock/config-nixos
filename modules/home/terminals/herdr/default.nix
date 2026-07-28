{ config, lib, pkgs, herdr, ... }:

with lib;

let
  cfg = config.modules.home.terminals.herdr;
in

{
  options.modules.home.terminals.herdr = {
    enable = mkEnableOption "herdr";
  };

  config = mkIf cfg.enable {
    home.packages = [ herdr.packages.${pkgs.stdenv.hostPlatform.system}.herdr ];
  };
}