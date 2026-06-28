let
  constantsContent = builtins.readFile ../modules/home/desktop/qtile/config/constants.py;
  themeMatch = builtins.match
    ".*\n?THEME_COLOR = \"([^\"]+)\".*" constantsContent;
  themeName = if themeMatch == null
    then builtins.throw "Cannot parse THEME_COLOR from constants.py"
    else builtins.head themeMatch;

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
