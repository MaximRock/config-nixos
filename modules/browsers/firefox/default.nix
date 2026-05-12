{ pkgs, ... }:

let
  addons = pkgs.nur.repos.rycee.firefox-addons;
  userChromePath = ./userChrome.css;
  userContentPath = ./userContent.css;
  # Фиксированный ID расширения nightTab из NUR
  # nightTabId = "155368d7-558f-4bf6-95d3-80f5b1cefcd6";
in
{
  # Прокидываем бэкап настроек в домашнюю папку (чтобы легко импортировать)
  # home.file.".config/firefox/nighttab-backup.json".source = ./nightTab.json;

  # home.file.".mozilla/firefox/max/chrome/icons" = {
  #   source = ./icons; # Путь к вашей локальной папке с иконками
  #   recursive = true; # Копировать всё содержимое папки
  # };

  programs.firefox = {
    enable = true;

    policies = {
      SearchEngines.Default = "DuckDuckGo";
      # Запрещаем Firefox спрашивать "вы уверены, что хотите изменить новую вкладку?"
      # ExtensionSettings."${nightTabId}" = {
      #   installation_mode = "force_installed";
      #   install_url = "https://mozilla.org";
      # };
    };

    profiles.max = {
      isDefault = true;
      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "toolkit.cosmeticAnimations.enabled" = false;
        "privacy.resistFingerprinting" = false;
        "browser.tabs.warnOnClose" = false;
        "devtools.chrome.enabled" = true;
        "devtools.debugger.remote-enabled" = true;
        "extensions.autoDisableScopes" = 0;
        "browser.newtabpage.activity-stream.topSitesRows" = 3; # 3 ряда ярлыков

        # --- СТАНДАРТНАЯ ДОМАШНЯЯ СТРАНИЦА ---
        # Открывать домашнюю страницу при запуске
        "browser.startup.page" = 1;
        # Стандартная домашняя страница (Firefox Activity Stream)
        "browser.startup.homepage" = "about:home";

        # Включить стандартную страницу новой вкладки
        "browser.newtabpage.enabled" = true;
        "browser.newtabpage.enhanced" = true; # Activity Stream с топ-сайтами
        "browser.newtab.preload" = true;

        # Убрать переопределение URL новой вкладки
        "browser.newtab.url" = null; # или просто не указывать

        # --- НАСТРОЙКИ ДОМАШНЕЙ СТРАНИЦЫ ---
        # Устанавливаем адрес расширения как домашнюю страницу
        # "browser.startup.homepage" = "moz-extension://${nightTabId}/index.html";
        # # Указываем, что при запуске нужно открывать домашнюю страницу
        # "browser.startup.page" = 1;
        # # Настройка новой вкладки (чтобы открывался nightTab)
        # "browser.newtabpage.enabled" = true;
        # "browser.newtab.url" = "moz-extension://${nightTabId}/index.html";
      };

      extensions.packages = [
        addons.ublock-origin
        addons.adblocker-ultimate
        addons.gemini-in-sidebar
        addons.simple-translate
        # addons.nighttab
      ];

      userChrome = builtins.readFile userChromePath;
      userContent = builtins.readFile userContentPath;
    };
  };
}
