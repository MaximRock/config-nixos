{ config, lib, pkgs, variables, ... }:

with lib;

let
  cfg = config.modules.home.desktop.wayland.waybar;
  niriConfigDir = "${variables.basePathFilesDir}/modules/home/wm/niri/config";
in {
  options.modules.home.desktop.wayland.waybar = {
    enable = mkEnableOption "waybar status bar";

    colors = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Color palette for waybar CSS";
    };
  };

  config = mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 30;
          modules-left = [ "niri/workspaces" ];
          modules-center = [ "clock" ];
          modules-right = [ "custom/layout" "pulseaudio" "network" "cpu" "memory" "temperature" "battery" "tray" ];

          "custom/layout" = {
            exec = "${niriConfigDir}/scripts/layout.sh";
            on-click = "niri msg action switch-layout next";
            interval = 1;
            return-type = "json";
          };

          "niri/workspaces" = {
            format = "{icon}";
            format-icons = {
              "1" = "1";
              "2" = "2";
              "3" = "3";
              "4" = "4";
              "5" = "5";
              "6" = "6";
              "7" = "7";
              "8" = "8";
              "9" = "9";
            };
          };

          clock = { format = "{:%H:%M}"; };

          pulseaudio = {
            format = "{icon} {volume}%";
            format-muted = "";
            format-icons = { default = [ "" "" "" ]; };
            on-click = "pamixer -t";
          };

          network = {
            format-wifi = "{essid} ({signalStrength}%)";
            format-ethernet = "";
            format-disconnected = "⚠";
          };

          cpu = { format = " {usage}%"; };
          memory = { format = " {}%"; };
          temperature = { format = "{temperatureC}°C"; };
          battery = {
            format = "{capacity}% {icon}";
            format-icons = [ "" "" "" "" "" ];
          };
          tray = { spacing = 10; };
        };
      };
      style = ''
        * {
          border: none;
          border-radius: 0;
          font-family: "JetBrainsMono Nerd Font";
          font-size: 13px;
          min-height: 0;
        }

        window#waybar {
          background: ${cfg.colors.background};
          color: ${cfg.colors.foreground};
        }

        #workspaces button {
          padding: 0 5px;
          color: ${cfg.colors.surface};
        }

        #workspaces button.active {
          color: ${cfg.colors.foreground};
        }

        #workspaces button:hover {
          background: ${cfg.colors.hover};
        }

        #custom-layout {
          color: ${cfg.colors.success};
          padding: 0 8px;
        }

        #clock { color: ${cfg.colors.primary}; }

        #pulseaudio {
          color: ${cfg.colors.secondary};
          padding: 0 8px;
        }

        #network {
          color: ${cfg.colors.tertiary};
          padding: 0 8px;
        }

        #cpu, #memory, #temperature {
          color: ${cfg.colors.accent};
          padding: 0 8px;
        }

        #battery {
          color: ${cfg.colors.success};
          padding: 0 8px;
        }
      '';
    };
  };
}
