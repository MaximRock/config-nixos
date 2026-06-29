# modules/home/browsers/firefox/chrome-css.nix
{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.home.browsers.firefox;
in
{
  config = mkIf cfg.chromeCss {
    programs.firefox.profiles.max = {
      settings."toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      userChrome = builtins.readFile ./userChrome.css;
      userContent = builtins.readFile ./userContent.css;
    };
  };
}
