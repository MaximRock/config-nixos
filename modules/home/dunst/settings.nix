# modules/home/dunst/settings.nix
#
# Конфигурация уведомлений dunst в стиле Catppuccin Mocha.

{
  global = {
    # === Внешний вид ===
    font = "JetBrainsMonoNL Nerd Font 10";
    width = 300;
    height = 100;
    origin = "top-right";
    offset = "10x10";
    transparency = 10;
    corner_radius = 8;
    frame_width = 2;
    frame_color = "#89b4fa";           # Catppuccin Blue

    # === Отступы и иконки ===
    padding = 8;
    horizontal_padding = 12;
    text_icon_padding = 8;
    icon_position = "left";
    max_icon_size = 64;

    # === Поведение ===
    follow = "mouse";
    notification_limit = 5;
    word_wrap = true;
    ellipsize = "middle";
    format = "<b>%s</b>\n%b";
    stack_duplicates = true;
    hide_duplicate_count = false;
    show_indicators = false;
    separator_color = "frame";
    separator_height = 2;
    progress_bar = true;
    progress_bar_height = 6;
    progress_bar_frame_width = 1;
    sticky_history = true;
    history_length = 20;
    alignment = "left";
    vertical_alignment = "center";

    # === Логирование ===
    log_level = "warn";
    log_file = "~/.local/share/dunst/dunst.log";
  };

  urgency_low = {
    background = "#1e1e2e";   # Base
    foreground = "#cdd6f4";   # Text
    timeout = 5;
  };

  urgency_normal = {
    background = "#1e1e2e";
    foreground = "#cdd6f4";
    timeout = 10;
  };

  urgency_critical = {
    background = "#f38ba8";   # Red
    foreground = "#1e1e2e";   # Base
    timeout = 0;              # Не скрывать автоматически
  };
}
