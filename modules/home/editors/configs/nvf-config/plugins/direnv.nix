# modules/home/editors/configs/nvf-config/plugins/direnv.nix

{ pkgs, ... }:

{
  package = pkgs.vimPlugins.direnv-vim;
}
