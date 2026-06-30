# home/common/terminals.nix
{ ... }:

{
  imports = [
    ../../modules/home/terminals/wezterm
    ../../modules/home/terminals/yazi
    ../../modules/home/terminals/fastfetch
  ];

  modules.home.terminals.wezterm = {
    enable = true;
  };

  modules.home.terminals.yazi = {
    enable = true;
  };

  modules.home.terminals.fastfetch = {
    enable = true;
  };
}
