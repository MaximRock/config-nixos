{ ... }:

{
  themeName = "catppuccin"; # catppuccin tokyonight
  themeStyle = "mocha";      # moon mocha
  luaLineTheme = "material";
  formatters = {
    lua = [ "stylua" ];
    nix = [ "nixfmt" ];
    json = [ "jq" ];
    ruff = [ "ruff" ];
  };
  themeAlpha = "dashboard";
    treesitterGrammars = [
    "regex"
    "kdl" 
    "lua"
    "nix"
    "json"
  ];
}
