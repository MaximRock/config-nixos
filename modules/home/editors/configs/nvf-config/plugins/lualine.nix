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
      { "@1" = "datetime"; style = "%Y-%m-%d | %H:%M"; }
      { "@1" = ""; draw_empty = true; separator = { left = ''; right = ''; }; }
      { "@1" = "progress"; separator = { left = ''; }; }
      ["location"]
      { "@1" = "fileformat"; color = { fg = "black"; }; symbols = { unix = ''; dos = ''; mac = ''; }; }
    ];
  };
}
