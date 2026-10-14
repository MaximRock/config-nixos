# Единый конфиг дашборда-«райдера» (eww) на отдельном столе.
# Читается в modules/home/wm/niri/default.nix → оттуда генерируются eww.yuck и eww.scss.
# Меняешь здесь → nrs. Всё «на вид» дашборда управляется отсюда.
{
  # Язык подписей плиток и даты: "en" | "ru"
  language = "en";

  # Монитор и имя стола, на котором виден дашборд (см. workspace "3" в config.kdl)
  output = "HDMI-A-5";
  workspace = "3";

  # Раскладка: "row" (в строку) | "column" (в столбик)
  orientation = "row";

  # Положение блока на экране:
  # center|top|bottom|left|right|top-left|top-right|bottom-left|bottom-right
  position = "center";

  spacing = 14;      # отступ между плитками, px
  tileWidth = 220;   # минимальная ширина плитки, px

  # ── Внешний вид ────────────────────────────────────────────────────────
  # Прозрачность фона карточек: 0 (полностью прозрачно) .. 1 (сплошной цвет).
  opacity = 0.85;

  # Переопределения цветов. null → брать из активной темы (см. lib/niri/theme.nix).
  # Формат: "#RRGGBB" (для background — без альфы, её задаёт opacity).
  colors = {
    background = null;  # фон карточек
    border     = null;  # рамка карточек
    title      = null;  # подписи плиток (CPU/RAM/…)
    text       = null;  # значения (крупные цифры, дата)
    muted      = null;  # единицы и мелкий текст
    accent     = null;  # прогресс-бары, день недели, стрелки сети
    barTrack   = null;  # дорожка прогресс-бара
  };

  network = {
    interface = "enp7s0";
    unit = "MB/s";   # "MB/s" | "KB/s"
  };

  # Набор и порядок плиток (любой порядок из: cpu ram disk net clock)
  tiles = [ "cpu" "ram" "disk" "net" "clock" ];
}
