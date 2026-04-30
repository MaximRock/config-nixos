{ pkgs, ... }:

let
  theme = import ../nvf-var.nix { inherit pkgs; };
in

{
  enable = true;
  theme = theme.luaLineTheme; # "material";
  activeSection.z = [
    ''
      {
        "datetime",
        style = "%Y-%m-%d | %H:%M"
      }
    ''
    ''
      {
        "",
        draw_empty = true,
        separator = { left = '', right = '' }
      }
    ''
    ''
      {
        "progress",
        separator = {left = ''}
      }
    ''
    ''
      {"location"}
    ''
    ''
      {
        "fileformat",
        color = {fg='black'},
        symbols = {
          unix = '', -- e712
          dos = '',  -- e70f
          mac = '',  -- e711
        }
      }
    ''
  ];
}
