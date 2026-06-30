# modules/home/editors/configs/nvf-config/plugins/indent-blankline.nix

{ pkgs, ... }:

{
  package = pkgs.vimPlugins.indent-blankline-nvim;
  setup = ''require("ibl").setup({})'';
}
