# modules/home/editors/configs/nvf-config/plugins/rainbow-delimiters.nix

{ pkgs, ... }:

{
  package = pkgs.vimPlugins.rainbow-delimiters-nvim;
  # setup = ''
  #   require('rainbow-delimiters').setup({})
  # '';
}
