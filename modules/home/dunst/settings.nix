# modules/home/dunst/settings.nix
#
# Конфигурация dunst (уведомления).
# Параметры берутся из центрального settings.json (секция `dunst`),
# цвета — из lib/theme.nix (preset + overrides в theme.colors).
#
# Доступные цвета (из catppuccin/gruvbox/tokyonight или кастомные):
#   primary (frame_color), surface (фон), foreground (текст), error (critical-фон)
#
{ colors, settings }:

let
  d = settings.dunst;
in {
  global = {
    font = "${d.font} ${toString d.font_size}";
    width = d.width;
    height = d.height;
    origin = d.origin;
    offset = d.offset;
    transparency = d.transparency;
    corner_radius = d.corner_radius;
    frame_width = d.frame_width;
    frame_color = colors.primary;
    padding = d.padding;
    horizontal_padding = d.horizontal_padding;
    text_icon_padding = d.text_icon_padding;
    icon_position = d.icon_position;
    max_icon_size = d.max_icon_size;
    follow = d.follow;
    notification_limit = d.notification_limit;
    word_wrap = d.word_wrap;
    ellipsize = d.ellipsize;
    format = d.format;
    stack_duplicates = d.stack_duplicates;
    hide_duplicate_count = d.hide_duplicate_count;
    show_indicators = d.show_indicators;
    separator_color = d.separator_color;
    separator_height = d.separator_height;
    progress_bar = d.progress_bar;
    progress_bar_height = d.progress_bar_height;
    progress_bar_frame_width = d.progress_bar_frame_width;
    sticky_history = d.sticky_history;
    history_length = d.history_length;
    alignment = d.alignment;
    vertical_alignment = d.vertical_alignment;
    log_level = d.log_level;
    log_file = d.log_file;
  };

  urgency_low = {
    background = colors.surface;
    foreground = colors.foreground;
    timeout = d.timeout_low;
  };

  urgency_normal = {
    background = colors.surface;
    foreground = colors.foreground;
    timeout = d.timeout_normal;
  };

  urgency_critical = {
    background = colors.error;
    foreground = colors.surface;
    timeout = d.timeout_critical;
  };
}