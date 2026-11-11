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
  position = "top-left";

  spacing = 14; # отступ между плитками и рядами, px
  tileWidth = 190; # минимальная ширина плитки, px

  # ── Шрифт ──────────────────────────────────────────────────────────────
  font = {
    family = "Noto Sans"; # null → системный шрифт GTK
    numFamily = "JetBrainsMono Nerd Font"; # шрифт цифр и часов (null → family)
    size = 13; # базовый размер, px (масштабирует все размеры)
    # Переопределения размеров (null → производное от size). Ориентир при size=13:
    title = 10; # подписи плиток
    num = 24; # крупные значения
    dim = 12; # второстепенные значения
    clockDate = 12;
    clockDay = 12;
    clockTime = 64;
    clockWeight = 300; # толщина шрифта часов
    titleTracking = 1.5; # letter-spacing заголовков, px
  };

  # ── Окно eww ───────────────────────────────────────────────────────────
  window = {
    stacking = "bottom"; # foreground|background|bottom|overlay
    focusable = "none"; # none|exclusive|ondemand
    namespace = "eww-dashboard"; # сюда же смотрит blur-правило niri в config.kdl
    margin = 48; # внешний отступ контента, px
  };

  # ── Общая панель ───────────────────────────────────────────────────────
  # Светлая матовая плашка под всем дашбордом.
  panel = {
    enable = true;
    radius = 22; # border-radius панели, px
    padding = 22; # внутренний отступ панели, px
    borderAlpha = 0.45; # прозрачность светлой рамки
    sepAlpha = 0.12; # прозрачность разделителей (цвет текста)
    shadowAlpha = 0.18; # мягкая тень под панелью
  };

  # ── Плитки ─────────────────────────────────────────────────────────────
  # Плотность фона панели: 0 (полностью прозрачно) .. 1 (сплошной цвет).
  opacity = 1.0;

  tile = {
    radius = 14; # border-radius, px
    paddingY = 0; # вертикальный padding, px
    paddingX = 12; # горизонтальный padding, px
    borderWidth = 0; # толщина рамки, px
    borderAlpha = 0.0; # прозрачность рамки
    # Доля цвета карточки, подмешиваемого в фон (0 = без подложки).
    tint = 0.0;
  };

  # Графики (eww graph + CSS-сетка)
  chart = {
    timeRange = "90s"; # окно истории на графике
    height = 30; # высота графика, px
    radius = 8; # border-radius графика, px
    gridStep = 22; # шаг сетки, px
    gridAlpha = 0.0; # прозрачность линий сетки
    gridThickness = 1; # толщина линий сетки, px
    gridDir = "both"; # both | x | y
    bgAlpha = 0.0; # подложка-фон под графиком (0 = без)
    thickness = 2; # толщина линии графика
    fillAlpha = 0.08; # заливка под линией (0 = без)
    lineStyle = "round"; # miter | round | bevel
    # null → дефолт eww (flip-x/y = true, vertical = false). true/false — задать явно.
    flipX = null; # x-ось справа налево
    flipY = null; # y-ось сверху вниз
    vertical = null; # поменять оси местами
  };

  # ── Формат чисел ───────────────────────────────────────────────────────
  format = {
    gbBase = 1024; # 1024 (GiB) | 1000 (GB)
    decimals = 1; # знаков после запятой для объёмов
    diskPercent = "free"; # показывать на плитке диска: free | used
    loadWindow = 1; # какую загрузку брать: 1 | 5 | 15 (минут)
  };

  # ── Интервалы опроса (формат eww: "5s", "1m"…) ─────────────────────────
  intervals = {
    clockDate = "60s";
    clockDay = "60s";
    clockTime = "5s";
    cpuTemp = "3s";
    diskIo = "2s";
    uptime = "30s";
    load = "3s";
  };

  # ── Часы ───────────────────────────────────────────────────────────────
  clock = {
    dateFormat = "+%d %B %Y"; # формат даты для `date`
    dayFormat = "+%A"; # день недели
    timeFormat = "+%H:%M"; # время (12ч → "%I:%M %p")
    showDate = true;
    showDay = true;
    showTime = true;
  };

  # ── Источник температуры CPU ───────────────────────────────────────────
  temperature = {
    sensors = [
      "coretemp"
      "k10temp"
    ]; # имена hwmon; берётся первый найденный
  };

  # Переопределения цветов. null → брать из активной темы (см. lib/niri/theme.nix).
  # Формат: "#RRGGBB" (для background — без альфы, её задаёт opacity).
  colors = {
    background = "#F6EFE3"; # тёплый крем (панель)
    border = "#FFFFFF"; # светлая рамка панели
    title = "#7B7468"; # подписи плиток
    text = "#32302B"; # значения (графит)
    muted = "#7B7468"; # единицы и мелкий текст
    grid = "#32302B"; # линии сетки графиков
    accent = "#B8891F"; # золото (точки, акценты)
    # Цвет карточки: красит её подложку (tile.tintAlpha) и рамку (tile.borderAlpha).
    # Он же — цвет соответствующего графика.
    cpu = "#C0603C"; # терракота
    ram = "#6E8B4A"; # олива
    disk = "#B8891F"; # золото
    net = "#4A7FA5"; # небо
    sys = null;
    clock = null;
  };

  # Диск: точка монтирования (для места) и устройство (для графика I/O, /proc/diskstats)
  disk = {
    mount = "/";
    device = "sdb";
  };

  network = {
    interface = "enp7s0";
  };

  # ── Раскладка: часы сверху, четыре метрики в ряд ──────────────────────
  # Порядок строк/плиток произвольный: доступны cpu ram disk net clock sys.
  # tiles.<имя>.span задаёт ширину плитки в колонках.
  rows = [
    [
      "clock"
    ]
    [
      "cpu"
      "ram"
      "disk"
      "net"
    ]
  ];

  # Параметры конкретных плиток (переопределяют глобальные значения chart)
  tiles = {
    cpu = {
      max = 100;
      dynamic = false;
      chart = true;
    };
    ram = {
      max = 100;
      dynamic = false;
      chart = true;
    };
    disk = {
      mode = "write";
      max = 1;
      dynamic = true;
      chart = false;
    }; # write | read
    net = {
      mode = "down";
      max = 1;
      dynamic = true;
      chart = false;
    }; # down | up
    sys = {
      chart = false;
    };
    clock = {
      span = 4;
    };
    load = {
      max = 1;
      dynamic = true;
    };
  };
}
