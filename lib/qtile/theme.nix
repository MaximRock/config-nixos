{ lib }:

let
  inherit (builtins) isAttrs readFile fromJSON elemAt;

  settings = fromJSON (readFile ./settings.json);
  themeName = settings.theme.active;

  presetsDir = ../theme/presets;
  readPreset = name: elemAt (fromJSON (readFile "${presetsDir}/${name}.json")) 0;

  themePresets = {
    catppuccin = readPreset "catppuccin";
    gruvbox = readPreset "gruvbox";
    tokyonight = readPreset "tokyonight";
  };

  basePresetColors = (themePresets.${themeName} or {}).config or {};
  colors = basePresetColors // (settings.theme.colors or {});

  activeTheme = themePresets.${themeName} or {
    name = "custom";
    inherit colors;
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
    (themePresets.${tName} or {}).config or {}
  ) appThemeNames;

  appActiveThemes = lib.mapAttrs (name: tName:
    themePresets.${tName} or {
      name = "custom";
      config = {};
    }
  ) appThemeNames;
in
{
  inherit
    themeName
    themePresets
    activeTheme
    colors
    appThemeNames
    appColors
    appActiveThemes
    ;
}
