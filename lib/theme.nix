let
  settings = builtins.fromJSON (builtins.readFile ../modules/home/desktop/qtile/config/settings/settings.json);
  themeName = settings.theme.active;

  presetsDir = ../modules/home/desktop/qtile/config/config_qtile/theme/presets;
  readPreset = name: builtins.elemAt (builtins.fromJSON (builtins.readFile "${presetsDir}/${name}.json")) 0;

  themePresets = {
    catppuccin = readPreset "catppuccin";
    gruvbox = readPreset "gruvbox";
    tokyonight = readPreset "tokyonight";
  };

  activeTheme = themePresets.${themeName};
in
{
  inherit themeName themePresets activeTheme;
}
