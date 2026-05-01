{ config, pkgs, ... }:

# let
#   # Путь к вашей домашней директории (автоматически подставится HM)
#   homeDir = config.home.homeDirectory;

#   # Опционально: если вы храните css файлы отдельно в репозитории
#   # Предположим, что вы положили файлы в ~/.config/nixos/assets/firefox/
#   userChromePath = "${homeDir}/.config/nixos/assets/firefox/userChrome.css";
#   userContentPath = "${homeDir}/.config/nixos/assets/firefox/userContent.css";
# in
{
  programs.firefox = {
    enable = true;

    # Важно: создаем профиль. Если профиль уже есть, используйте его имя.
    profiles."max" = {
      id = 0;
      name = "max";
      isDefault = true;

      settings = {
        # 1. Включаем поддержку пользовательских стилей (КРИТИЧНО ВАЖНО)
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

        # 2. Настройки темы
        # 0 - светлая, 1 - темная, 2 - системная
        "browser.theme.content-theme" = 1;
        "browser.theme.toolbar-theme" = 1;

        # 3. Убираем лишние элементы интерфейса (опционально, для минимализма)
        "browser.uidensity" = 1; # Компактный режим

        # 4. Отключаем автоматические обновления расширений, если нужно стабильности
        "extensions.update.enabled" = false;
      };

      # 5. Внедряем CSS стили
      # Вариант А: Прямая вставка текста (если стилей мало)
      userChrome = ''
        /* Пример минимальной темной темы */
        :root {
          --toolbar-bgcolor: #1a1b26 !important; /* Tokyo Night Background */
          --toolbar-color: #a9b1d6 !important;   /* Tokyo Night Foreground */
          --lwt-sidebar-background-color: #1a1b26 !important;
        }

        #nav-bar {
          background-color: var(--toolbar-bgcolor) !important;
        }

        .tab-background {
          background-color: #16161e !important; /* Darker tab bg */
          color: #a9b1d6 !important;
        }

        .tab-background[selected="true"] {
          background-color: #1a1b26 !important; /* Active tab bg */
          border-top: 2px solid #7aa2f7 !important; /* Accent color */
        }
      '';

      # Вариант Б (Рекомендуемый): Импорт внешних файлов
      # Мы используем @import, чтобы подключить файлы из файловой системы
      # userChrome = ''
      #   @import url("file://${userChromePath}");
      # '';

      # userContent = ''
      #   @import url("file://${userContentPath}");
      # '';

      # 6. Расширения (опционально)
      # Если вы используете Dark Reader или другие темы, их можно добавить сюда
      # extensions = {
      #   packages = [
      #     # pkgs.firefox-addons.darkreader
      #   ];
      # };
    };
  };
}
