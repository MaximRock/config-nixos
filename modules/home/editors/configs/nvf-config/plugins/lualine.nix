# modules/home/editors/configs/nvf-config/plugins/lualine.nix

{ pkgs, ... }:

let
  theme = import ../nvf-var.nix { inherit pkgs; };
in

{
  enable = true;
  setupOpts = {
    options.theme = theme.luaLineTheme; # "material";
    sections.lualine_z = [
      (pkgs.lib.generators.mkLuaInline ''{ "datetime", style = "%Y-%m-%d | %H:%M" }'')
      "location"
      "progress"
    ];
  };
}
