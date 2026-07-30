{ config, pkgs, lib, appColors, ... }:

let
  terminalLib = import ../lib.nix { inherit pkgs lib; };
  cfg = config.modules.home.terminals.fastfetch;
  colors = cfg.colors or appColors.fastfetch;

  logoFile = ./logo3.png;

  fastfetchConfig = {
    logo = {
      type = "kitty";
      source = "$HOME/.config/fastfetch/logo.png";
      width = 30;
      height = 15;
      padding = {
        top = 1;
        bottom = 1;
        left = 2;
        right = 4;
      };
    };

    color = {
      keys = colors.primary;
      title = colors.secondary;
      subtitle = colors.inactive;
      bar = colors.selected;
      separator = colors.separator_color;
    };

    modules = [
      { type = "title"; keyColor = colors.secondary; }
      "separator"
      { type = "os"; key = " "; keyColor = colors.primary; }
      { type = "host"; key = "󰍹 "; keyColor = colors.secondary; }
      { type = "kernel"; key = " "; keyColor = colors.tertiary; }
      { type = "uptime"; key = "󰔟 "; keyColor = colors.success; }
      { type = "shell"; key = " "; keyColor = colors.secondary; }
      { type = "display"; key = "󰍹 "; keyColor = colors.primary; }
      { type = "de"; key = " "; keyColor = colors.tertiary; }
      { type = "theme"; key = " "; keyColor = colors.warning; }
      { type = "terminal"; key = " "; keyColor = colors.success; }
      { type = "cpu"; key = " "; keyColor = colors.error; }
      { type = "gpu"; key = "󰢮 "; keyColor = colors.success; }
      { type = "memory"; key = " "; keyColor = colors.primary; }
      { type = "disk"; key = "󰋊 "; keyColor = colors.accent; }
      "colors"
    ];
  };
in

{
  options.modules.home.terminals.fastfetch =
    terminalLib.mkTerminalOptions "fastfetch" pkgs.fastfetch // {
      colors = lib.mkOption {
        type = lib.types.nullOr (lib.types.attrsOf lib.types.str);
        default = null;
        description = "Override color palette for fastfetch";
      };
    };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    programs.fastfetch.enable = false;

    xdg.configFile."fastfetch/logo.png".source = logoFile;

    xdg.configFile."fastfetch/config.jsonc".text = builtins.toJSON fastfetchConfig;
  };
}
