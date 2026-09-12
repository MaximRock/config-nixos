{ config, lib, pkgs, unstable, ... }:

with lib;

let
  cfg = config.modules.home.terminals.herdr;
in

{
  options.modules.home.terminals.herdr = {
    enable = mkEnableOption "herdr";
  };

  config = mkIf cfg.enable {
    home.packages = [ unstable.herdr ];
  };
}