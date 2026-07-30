{ config, lib, pkgs, variables, ... }:

with lib;

let
  cfg = config.modules.home.wm.niri;
  colors = cfg.theme.colors;
  niriConfigDir = "${variables.basePathFilesDir}/modules/home/wm/niri/config";
in

{
  imports = [
    ../../../../lib/niri/theme.nix
    ../../desktop/wayland
  ];

  options.modules.home.wm.niri = {
    enable = mkEnableOption "niri Wayland compositor";
  };

  config = mkIf cfg.enable {
    modules.home = {
      desktop.wayland = {
        common.enable = true;
        fuzzel.enable = true;
        mako.enable = true;
        swaybg.enable = true;
        swaylock.enable = true;
        swayidle.enable = true;
        wlogout.enable = true;
        waybar = {
          enable = true;
          colors = cfg.theme.appColors.waybar;
        };
      };

      terminals = {
        wezterm.themeName = cfg.theme.appThemeNames.wezterm;
        yazi = {
          themeName = cfg.theme.appThemeNames.yazi;
          colors = cfg.theme.appColors.yazi;
        };
        fastfetch.colors = cfg.theme.appColors.fastfetch;
      };
    };

    xdg.configFile."niri/config.kdl" = {
      source = config.lib.file.mkOutOfStoreSymlink "${niriConfigDir}/config.kdl";
    };
    xdg.configFile."niri/input.kdl" = {
      source = config.lib.file.mkOutOfStoreSymlink "${niriConfigDir}/input.kdl";
    };
    xdg.configFile."niri/binds.kdl" = {
      source = config.lib.file.mkOutOfStoreSymlink "${niriConfigDir}/binds.kdl";
    };

    xdg.configFile."niri/theme.kdl".text = ''
      layout {
          focus-ring {
              on
              width 2
              active-color "${colors.primary}"
              inactive-color "${colors.surface}"
          }
          border {
              on
              width 1
              active-color "${colors.primary}"
              inactive-color "${colors.border_normal}"
          }
          background-color "${colors.background}"
      }

      overview {
          backdrop-color "${colors.surface}"
      }
    '';
  };
}
