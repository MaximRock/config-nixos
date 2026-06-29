# modules/home/browsers/firefox/base.nix
{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  addons = pkgs.nur.repos.rycee.firefox-addons;
  cfg = config.modules.home.browsers.firefox;
in
{
  options.modules.home.browsers.firefox = {
    nighttab = mkEnableOption "nightTab as homepage/newtab in Firefox";
    chromeCss = mkEnableOption "custom userChrome.css/userContent.css for Firefox";
  };

  config = {
    programs.firefox = {
      enable = true;
      configPath = ".mozilla/firefox";

      policies.SearchEngines.Default = "DuckDuckGo";

      profiles.max = {
        isDefault = true;
        settings = {
          "toolkit.cosmeticAnimations.enabled" = false;
          "privacy.resistFingerprinting" = false;
          "browser.tabs.warnOnClose" = false;
          "devtools.chrome.enabled" = true;
          "devtools.debugger.remote-enabled" = true;
          "extensions.autoDisableScopes" = 0;
          "browser.newtabpage.activity-stream.topSitesRows" = 3;
        };

        extensions.packages =
          with addons;
          [
            ublock-origin
            adblocker-ultimate
            gemini-in-sidebar
            simple-translate
          ]
          ++ optional cfg.nighttab nighttab;
      };
    };
  };
}
