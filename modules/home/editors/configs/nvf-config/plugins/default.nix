{ pkgs, ... }:

{
  blinkCmp = import ./blink-cmp.nix { inherit pkgs; };
  incRename = import ./inc-rename.nix { inherit pkgs; };
  indentBlankline = import ./indent-blankline.nix { inherit pkgs; };
  neoTree = import ./neo-tree.nix { inherit pkgs; };
  rainbowDelimiters = import ./rainbow-delimiters.nix { inherit pkgs; };
  newWebDevicon = import ./new-web-devicon.nix { inherit pkgs; };
  cursorLine = import ./cursorline.nix { inherit pkgs; };
  treeSitter = import ./treesitter.nix { inherit pkgs; };
  themeNvim = import ./theme.nix { inherit pkgs; };
  luaLine = import ./lualine.nix { inherit pkgs; };
  conForm = import ./conform.nix { inherit pkgs; };
  teleScope = import ./telescope.nix { inherit pkgs; };
  bufferLine = import ./bufferline.nix { inherit pkgs; };
  noIce = import ./noice.nix { inherit pkgs; };
  dashboardAlpha = import ./dashboard-alpha.nix { inherit pkgs; };
}
