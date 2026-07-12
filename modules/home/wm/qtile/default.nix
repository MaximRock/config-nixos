# modules/home/wm/qtile/default.nix
{ config, lib, variables, ... }:

with lib;

let
  cfg = config.modules.home.wm.qtile;
  qtileConfigDir = "${variables.basePathFilesDir}/modules/home/wm/qtile/config";
in

{
  options.modules.home.wm.qtile = {
    enable = mkEnableOption "Qtile WM";
  };

  imports = [
    ./power-menu
    ./qtile-help
  ];

  config = mkIf cfg.enable {
    modules.home = {
      power-menu.enable = true;
      qtile-help.enable = true;
    };

    xdg.configFile."qtile" = {
      source = config.lib.file.mkOutOfStoreSymlink qtileConfigDir;
      recursive = true;
    };

    home.sessionVariables.PYTHONPATH = "${config.xdg.configHome}/qtile:$HOME/.local/lib/python3.13/site-packages";
  };
}
