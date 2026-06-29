# modules/home/browsers/firefox/nighttab.nix
{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.home.browsers.firefox;
  nightTabId = "155368d7-558f-4bf6-95d3-80f5b1cefcd6";
in
{
  config = mkIf cfg.nighttab {
    programs.firefox = {
      policies.ExtensionSettings."${nightTabId}" = {
        installation_mode = "force_installed";
        install_url = "https://mozilla.org";
      };

      profiles.max.settings = {
        "browser.startup.page" = 1;
        "browser.startup.homepage" = "moz-extension://${nightTabId}/index.html";
        "browser.newtabpage.enabled" = true;
        "browser.newtab.url" = "moz-extension://${nightTabId}/index.html";
      };
    };
  };
}
