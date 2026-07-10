{ colors }:

{
  global = {
    # --- Шрифт ---
    font = "JetBrainsMonoNL Nerd Font 10";

    # --- Размеры и позиция ---
    width = 300;                     # px, ширина окна
    height = 100;                    # px, высота окна
    origin = "top-right";            # угол появления на экране
    offset = "10x10";                # смещение от края (XxY)

    # --- Внешний вид ---
    transparency = 10;               # прозрачность фона (0-100)
    corner_radius = 8;               # скругление углов (px)
    frame_width = 3;                 # толщина рамки (px)
    frame_color = colors.primary;    # цвет рамки
    padding = 8;                     # внутренний отступ (px)
    horizontal_padding = 12;         # горизонтальный отступ (px)
    text_icon_padding = 8;           # отступ между текстом и иконкой
    icon_position = "left";          # позиция иконки: left/right/off
    max_icon_size = 64;              # макс. размер иконки (px)

    # --- Поведение ---
    follow = "mouse";                # монитор для показа: mouse/none/keyboard
    notification_limit = 5;          # макс. число уведомлений на экране
    word_wrap = true;                # переносить длинные строки
    ellipsize = "middle";            # обрезка длинного заголовка: start/middle/end
    format = "<b>%s</b>\n%b";        # формат сообщения (%s=summary, %b=body)
    stack_duplicates = true;         # группировать одинаковые уведомления
    hide_duplicate_count = false;    # показывать счётчик (>2) у дубликатов
    show_indicators = false;         # индикаторы режимов (DND и т.п.)
    separator_color = "frame";       # цвет разделителя: frame/auto/foreground
    separator_height = 2;            # толщина разделителя (px)
    progress_bar = true;             # полоса прогресса
    progress_bar_height = 6;         # высота полосы (px)
    progress_bar_frame_width = 1;    # рамка вокруг полосы (px)
    sticky_history = true;           # не удалять из истории по клику
    history_length = 20;             # размер истории уведомлений

    # --- Выравнивание ---
    alignment = "left";              # выравнивание текста: left/center/right
    vertical_alignment = "center";   # вертикаль: top/center/bottom

    # --- Логирование ---
    log_level = "warn";              # уровень: warn/info/debug
    log_file = "~/.local/share/dunst/dunst.log";
  };

  urgency_low = {
    background = colors.surface;
    foreground = colors.foreground;
    timeout = 5;                     # сек, автозакрытие
  };

  urgency_normal = {
    background = colors.surface;
    foreground = colors.foreground;
    timeout = 10;
  };

  urgency_critical = {
    background = colors.error;
    foreground = colors.surface;
    timeout = 0;                     # 0 = не закрывать автоматически
  };
}
