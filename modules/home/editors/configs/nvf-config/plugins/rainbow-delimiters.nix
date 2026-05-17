{ pkgs, ... }:

{
  package = pkgs.vimPlugins.rainbow-delimiters-nvim;
  # setup = ''
  #   require('rainbow-delimiters').setup({})
  # '';
}
