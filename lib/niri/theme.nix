{ config, lib, ... }:

with lib;

let
  inherit (builtins) isAttrs fromJSON readFile;

  settings = fromJSON (readFile ./settings.json);
  themeName = settings.theme.active;

  presetsDir = ../theme/presets;
  readPreset = name: fromJSON (readFile "${presetsDir}/${name}.json");

  themePresets = {
    catppuccin = readPreset "catppuccin";
    gruvbox = readPreset "gruvbox";
    tokyonight = readPreset "tokyonight";
  };

  basePresetColors = (builtins.head (themePresets.${themeName} or [{}])).config or {};
  colors = basePresetColors // (settings.theme.colors or {});

  activeTheme = themePresets.${themeName} or {
    name = "custom";
    config = colors;
  };

  # ── Per-app theme overrides ──────────────────────────────────
  # Any top-level block with { enable, theme } is an app override.
  appBlocks = lib.filterAttrs (name: value:
    isAttrs value && value ? enable && value ? theme
  ) settings;

  resolveAppTheme = appName:
    let app = appBlocks.${appName} or {};
    in if app.enable or false then app.theme else themeName;

  appThemeNames = lib.mapAttrs (name: _: resolveAppTheme name) appBlocks;

  appColors = lib.mapAttrs (name: tName:
    (builtins.head (themePresets.${tName} or [{}])).config or {}
  ) appThemeNames;

  appActiveThemes = lib.mapAttrs (name: tName:
    themePresets.${tName} or {
      name = "custom";
      config = {};
    }
  ) appThemeNames;
in {
  options.modules.home.wm.niri.theme = {
    name = mkOption {
      type = types.str;
      description = "Active color theme name";
    };

    colors = mkOption {
      type = types.attrsOf types.str;
      description = "Color palette from active theme";
    };

    appColors = mkOption {
      type = types.attrsOf (types.attrsOf types.str);
      description = "Color palettes per app";
    };

    appThemeNames = mkOption {
      type = types.attrsOf types.str;
      description = "Theme names per app";
    };
  };

  config.modules.home.wm.niri.theme = {
    inherit colors appColors appThemeNames;
    name = themeName;
  };
}
