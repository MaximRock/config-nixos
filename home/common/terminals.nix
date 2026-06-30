# home/common/terminals.nix
{ ... }:

{
  imports = [
    ../../modules/home/terminals/wezterm
    ../../modules/home/terminals/yazi
    ../../modules/home/terminals/fastfetch/fastfetch.nix
  ];

  modules.home.terminals.wezterm = {
    enable = true;
  };

  modules.home.terminals.yazi = {
    enable = true;
  };
}
