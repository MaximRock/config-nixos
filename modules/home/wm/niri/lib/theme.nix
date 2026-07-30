{ config, lib, ... }:

with lib;

let
  settings = builtins.fromJSON (builtins.readFile ./../../../lib/theme/settings.json);
  themeName = settings.active;

  presetFile = ./../../../lib/theme/presets/${themeName}.json;
  presetData = builtins.fromJSON (builtins.readFile presetFile);
  colors = (builtins.head presetData).config;
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
  };

  config.modules.home.wm.niri.theme = {
    name = themeName;
    inherit colors;
  };
}
