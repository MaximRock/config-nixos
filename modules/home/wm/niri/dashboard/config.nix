# Единый конфиг дашборда-«райдера» (eww) на отдельном столе.
# Читается в modules/home/wm/niri/default.nix → оттуда генерируются eww.yuck и eww.scss.
# Меняешь здесь → nrs. Всё «на вид» дашборда управляется отсюда.
{
  # Язык подписей плиток и даты: "en" | "ru"
  language = "en";

  # Монитор и имя стола, на котором виден дашборд (см. workspace "3" в config.kdl)
  output = "HDMI-A-5";
  workspace = "3";

  # Положение блока на экране:
  # center|top|bottom|left|right|top-left|top-right|bottom-left|bottom-right
  position = "center";

  spacing = 14;      # отступ между плитками и рядами, px
  tileWidth = 220;   # минимальная ширина плитки, px

  # ── Шрифт ──────────────────────────────────────────────────────────────
  font = {
    family = "JetBrainsMono Nerd Font"; # null → системный шрифт GTK
    size   = 13;                        # базовый размер, px (масштабирует все размеры)
    # Переопределения размеров (null → производное от size). Ориентир при size=13:
    title     = null;  # 12  подписи плиток
    num       = null;  # 22  крупные значения
    dim       = null;  # 16  второстепенные значения
    clockDate = null;  # 20
    clockDay  = null;  # 15
    clockTime = null;  # 30
    titleTracking = 1; # letter-spacing заголовков, px
  };

  # ── Окно eww ───────────────────────────────────────────────────────────
  window = {
    stacking  = "bottom";        # foreground|background|bottom|overlay
    focusable = "none";          # none|exclusive|ondemand
    namespace = "eww-dashboard"; # сюда же смотрит blur-правило niri в config.kdl
    margin    = 0;               # внешний отступ контента, px
  };

  # ── Плитки ─────────────────────────────────────────────────────────────
  # Прозрачность фона карточек: 0 (полностью прозрачно) .. 1 (сплошной цвет).
  opacity = 0.85;

  tile = {
    radius      = 14;   # border-radius, px
    paddingY    = 14;   # вертикальный padding, px
    paddingX    = 18;   # горизонтальный padding, px
    borderWidth = 1;    # толщина рамки, px
    borderAlpha = 1.0;  # прозрачность рамки (цвет берётся из colors.border)
  };

  # Графики (eww graph + CSS-сетка)
  chart = {
    timeRange     = "90s";   # окно истории на графике
    height        = 46;      # высота графика, px
    radius        = 8;       # border-radius графика, px
    gridStep      = 22;      # шаг сетки, px
    gridAlpha     = 0.6;     # прозрачность линий сетки
    gridThickness = 1;       # толщина линий сетки, px
    gridDir       = "both";  # both | x | y
    bgAlpha       = 0.25;    # лёгкая подложка-фон под графиком (0 = без)
    thickness     = 2;       # толщина линии графика
    fillAlpha     = 0.25;    # заливка под линией (0 = без)
    lineStyle     = "round"; # miter | round | bevel
    # null → дефолт eww (flip-x/y = true, vertical = false). true/false — задать явно.
    flipX         = null;    # x-ось справа налево
    flipY         = null;    # y-ось сверху вниз
    vertical      = null;    # поменять оси местами
  };

  # ── Формат чисел ───────────────────────────────────────────────────────
  format = {
    gbBase      = 1024;   # 1024 (GiB) | 1000 (GB)
    decimals    = 1;      # знаков после запятой для объёмов
    diskPercent = "free"; # показывать на плитке диска: free | used
    loadWindow  = 1;      # какую загрузку брать: 1 | 5 | 15 (минут)
  };

  # ── Интервалы опроса (формат eww: "5s", "1m"…) ─────────────────────────
  intervals = {
    clockDate = "60s";
    clockDay  = "60s";
    clockTime = "5s";
    cpuTemp   = "3s";
    diskIo    = "2s";
    uptime    = "30s";
    load      = "3s";
  };

  # ── Часы ───────────────────────────────────────────────────────────────
  clock = {
    dateFormat = "+%d %B %Y"; # формат даты для `date`
    dayFormat  = "+%A";       # день недели
    timeFormat = "+%H:%M";    # время (12ч → "%I:%M %p")
    showDate = true;
    showDay  = true;
    showTime = true;
  };

  # ── Источник температуры CPU ───────────────────────────────────────────
  temperature = {
    sensors = [ "coretemp" "k10temp" ]; # имена hwmon; берётся первый найденный
  };

  # Переопределения цветов. null → брать из активной темы (см. lib/niri/theme.nix).
  # Формат: "#RRGGBB" (для background — без альфы, её задаёт opacity).
  colors = {
    background = null;  # фон карточек
    border     = null;  # рамка карточек
    title      = null;  # подписи плиток (CPU/RAM/…)
    text       = null;  # значения (крупные цифры, время)
    muted      = null;  # единицы и мелкий текст
    grid       = null;  # линии сетки графиков
    accent     = null;  # базовый акцент (fallback для графиков)
    # Цвета графиков (null → цвет темы: cpu=error, ram=success, disk=warning, net=info, sys=accent)
    cpu  = null;
    ram  = null;
    disk = null;
    net  = null;
    sys  = null;
  };

  # Диск: точка монтирования (для места) и устройство (для графика I/O, /proc/diskstats)
  disk = {
    mount  = "/";
    device = "sdb";
  };

  network = {
    interface = "enp7s0";
  };

  # ── Раскладка плиток по рядам (3×2) ────────────────────────────────────
  # Порядок строк/плиток произвольный: доступны cpu ram disk net clock sys.
  rows = [
    [ "cpu" "ram" ]
    [ "disk" "net" ]
    [ "clock" "sys" ]
  ];

  # Параметры конкретных плиток (переопределяют глобальные значения chart)
  tiles = {
    cpu  = { max = 100; dynamic = false; };
    ram  = { max = 100; dynamic = false; };
    disk = { mode = "write"; max = 1; dynamic = true; }; # write | read
    net  = { mode = "down";  max = 1; dynamic = true; }; # down | up
    load = { max = 1; dynamic = true; };
  };
}
