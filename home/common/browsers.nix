# home/common/browsers.nix
{ ... }:

{
  modules.home.browsers.firefox = {
    nighttab = true;
    chromeCss = false;
  };
}
