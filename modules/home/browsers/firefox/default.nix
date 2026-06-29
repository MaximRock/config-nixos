# modules/home/browsers/firefox/default.nix
{ ... }:

{
  imports = [
    ./base.nix
    ./nighttab.nix
    ./chrome-css.nix
  ];
}
