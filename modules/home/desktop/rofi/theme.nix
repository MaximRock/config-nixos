{
  config,
  lib,
  pkgs,
  themeName,
  themePresets,
  activeTheme,
  ...
}:

let
  cfg = config.custom.rofi;
  c = activeTheme.config;

  colorsRasi = pkgs.writeText "colors-${themeName}.rasi" ''
    * {
      background:      ${c.background};
      background-alt:  ${c.surface};
      border:          ${c.border_focus};
      foreground:      ${c.foreground};
      selected:        ${c.selected};
      active:          ${c.primary};
      urgent:          ${c.error};
    }
  '';

  configRasi = pkgs.writeText "config-${themeName}.rasi" ''
    @import "colors.rasi"

    window {
      transparency:       "real";
      location:            center;
      anchor:              center;
      fullscreen:          false;
      width:               800px;
      border:              2px solid;
      border-radius:       15px;
      border-color:        @border;
      background-color:    @background;
      cursor:              "default";
    }

    mainbox {
      spacing:            10px;
      padding:            30px;
      background-color:   transparent;
      children:           [inputbar, message, listview, mode-switcher];
    }

    inputbar {
      spacing:            10px;
      padding:            10px;
      border:             0 2px 2px 0;
      border-radius:      10px;
      border-color:       @selected;
      background-color:   @background-alt;
      text-color:         @foreground;
      children:           [textbox-prompt-colon, entry];
    }

    prompt {
      background-color:   inherit;
      text-color:         inherit;
    }

    textbox-prompt-colon {
      padding:            0;
      expand:             false;
      str:                " ";
      background-color:   inherit;
      text-color:         inherit;
    }

    entry {
      padding:            0;
      background-color:   inherit;
      text-color:         inherit;
      cursor:             text;
      placeholder:        "Search...";
      placeholder-color:  inherit;
    }

    listview {
      columns:            2;
      lines:              7;
      cycle:              true;
      dynamic:            true;
      scrollbar:          false;
      layout:             vertical;
      spacing:            5px;
      background-color:   transparent;
      text-color:         @foreground;
    }

    scrollbar {
      handle-width:       5px;
      handle-color:       @selected;
      border-radius:      10px;
      background-color:   @background-alt;
    }

    element {
      spacing:            10px;
      padding:            6px;
      background-color:   transparent;
      text-color:         @foreground;
      cursor:             pointer;
      children:           [element-icon, element-text];
    }

    element normal.normal,
    element alternate.normal {
      background-color:   @background;
      text-color:         @foreground;
    }

    element normal.urgent,
    element alternate.urgent {
      background-color:   @background;
      text-color:         @foreground;
      border:             0 2px 2px 0;
      border-radius:      10px;
      border-color:       @selected;
    }

    element normal.active,
    element alternate.active {
      background-color:   @background;
      text-color:         @foreground;
      border:             2px;
      border-color:       @urgent;
    }

    element selected.normal {
      background-color:   @background;
      text-color:         @selected;
      border:             0 2px 2px 0;
      border-radius:      10px;
      border-color:       @selected;
    }

    element-icon {
      background-color:   transparent;
      text-color:         inherit;
      size:               24px;
      cursor:             inherit;
    }

    element-text {
      background-color:   transparent;
      text-color:         inherit;
      cursor:             inherit;
      vertical-align:     0.5;
      horizontal-align:   0.0;
    }

    mode-switcher {
      spacing:            10px;
      padding:            0 250px;
      background-color:   transparent;
      text-color:         @foreground;
    }

    button {
      padding:            10px;
      background-color:   @background;
      text-color:         inherit;
      cursor:             pointer;
      border:             0;
    }

    button selected {
      background-color:   @background-alt;
      text-color:         @selected;
      border:             0 2px 2px 0;
      border-radius:      10px;
      border-color:       @selected;
    }

    message {
      padding:            10px;
      background-color:   @background-alt;
      text-color:         @foreground;
    }

    textbox {
      background-color:   transparent;
      text-color:         @foreground;
    }

    error-message {
      padding:            30px;
      background-color:   @background;
      text-color:         @foreground;
    }
  '';

  rasiDir = pkgs.linkFarm "rofi-${themeName}" [
    {
      name = "config.rasi";
      path = configRasi;
    }
    {
      name = "colors.rasi";
      path = colorsRasi;
    }
  ];
in

{
  options.custom.rofi = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable themed rofi with colors from Qtile preset";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.rofi.theme = "${rasiDir}/config.rasi";
  };
}
