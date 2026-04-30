{ pkgs, ... }:

{
  package = pkgs.vimPlugins.indent-blankline-nvim;
  setup = ''require("ibl").setup({})'';
}
