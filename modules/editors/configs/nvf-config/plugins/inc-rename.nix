{ pkgs, ... }:

{
  package = pkgs.vimPlugins.inc-rename-nvim;
  setup = ''require("inc_rename").setup({})'';
}
