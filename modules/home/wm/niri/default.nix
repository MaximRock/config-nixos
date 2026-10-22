{ config, lib, pkgs, variables, ... }:

with lib;

let
  cfg = config.modules.home.wm.niri;
  colors = cfg.theme.colors;
  # Палитра дашборда: отдельный блок "dashboard" в lib/niri/settings.json
  # (см. appBlocks в lib/niri/theme.nix). Фолбэк — активная тема niri.
  dashColors = cfg.theme.appColors.dashboard or colors;
  niriConfigDir = "${variables.basePathFilesDir}/modules/home/wm/niri/config";
  # Конфиг десктоп-шелла Noctalia (обои, бар и т.п.); правится через GUI → пишется в репо
  noctaliaConfigDir = "${variables.basePathFilesDir}/modules/home/wm/niri/noctalia";

  # ── Дашборд-«райдер» (eww) ──────────────────────────────────────────────
  # Единый конфиг: modules/home/wm/niri/dashboard/config.nix
  # Из него генерируются ~/.config/eww/{eww.yuck,eww.scss}.
  dash = import ./dashboard/config.nix;

  # ── Палитра дашборда: override из dash.colors, иначе цвет активной темы ─
  dashColor = key: fallback: if dash.colors.${key} == null then fallback else dash.colors.${key};
  dc = {
    background = dashColor "background" dashColors.surface_variant;
    border     = dashColor "border"     dashColors.border_normal;
    title      = dashColor "title"      dashColors.inactive;
    text       = dashColor "text"       dashColors.foreground;
    muted      = dashColor "muted"      dashColors.inactive;
    grid       = dashColor "grid"       dashColors.inactive;
    accent     = dashColor "accent"     dashColors.primary;
    cpu        = dashColor "cpu"        dashColors.error;
    ram        = dashColor "ram"        dashColors.success;
    disk       = dashColor "disk"       dashColors.warning;
    net        = dashColor "net"        dashColors.info;
    sys        = dashColor "sys"        dashColors.primary;
    clock      = dashColor "clock"      dashColors.secondary;
  };
  # "#RRGGBB" → { r, g, b } (компоненты 0..255)
  rgbOf = hex:
    let
      v = fromHexString (substring 0 6 (removePrefix "#" hex));
      r = v / 65536;
      g = (v - r * 65536) / 256;
      b = v - r * 65536 - g * 256;
    in { inherit r g b; };
  # Смешать цвета a и b в доле `ratio` (0..1) второго
  mixCol = a: b: ratio:
    let
      ca = rgbOf a;
      cb = rgbOf b;
      mix = x: y: builtins.floor (x + (y - x) * ratio);
    in { r = mix ca.r cb.r; g = mix ca.g cb.g; b = mix ca.b cb.b; };
  rgbaOf = { r, g, b }: alpha: "rgba(${toString r}, ${toString g}, ${toString b}, ${toString alpha})";
  hexToRgba = hex: alpha: rgbaOf (rgbOf hex) alpha;

  cardBg     = hexToRgba dc.background dash.opacity;
  tileBorder = hexToRgba dc.border dash.tile.borderAlpha;
  chartBg    = hexToRgba dc.background dash.chart.bgAlpha;
  gridLine   = hexToRgba dc.grid dash.chart.gridAlpha;
  fillOf     = col: hexToRgba col dash.chart.fillAlpha;

  # Цветная карточка: акцент подмешан в плотный фон (tint), рамка — акцент
  cardBgOf     = col: rgbaOf (mixCol dc.background col dash.tile.tint) dash.opacity;
  cardBorderOf = col: hexToRgba col dash.tile.borderAlpha;
  cardNames    = [ "cpu" "ram" "disk" "net" "sys" "clock" ];
  cardRules = concatMapStringsSep "\n    " (t:
    ".tile.${t} { background: ${cardBgOf dc.${t}}; border-color: ${cardBorderOf dc.${t}}; }"
  ) cardNames;

  # ── Шрифт: базовый size масштабирует размеры, null-ключи берут производное ─
  f = dash.font;
  fsz = key: ref: if f.${key} == null then builtins.floor (f.size * ref / 13) else f.${key};
  font = {
    title     = fsz "title" 12;
    num       = fsz "num" 22;
    dim       = fsz "dim" 16;
    clockDate = fsz "clockDate" 20;
    clockDay  = fsz "clockDay" 15;
    clockTime = fsz "clockTime" 30;
  };
  # family = null → оставляем системный шрифт GTK (строку не эмитим)
  fontFamilyCss = optionalString (f.family != null) ''font-family: "${f.family}"; '';

  # ── Формат чисел ─────────────────────────────────────────────────────────
  gbDiv = dash.format.gbBase;
  gbFactor = gbDiv * gbDiv * gbDiv; # байты → ГБ/GiB
  dec   = dash.format.decimals;
  boolStr = b: if b then "true" else "false";
  # Эмитит ":prop true|false" или пусто, когда значение null (→ дефолт eww).
  optBool = name: v: if v == null then "" else " :${name} ${boolStr v}";

  lang = {
    en = { cpu = "CPU"; ram = "RAM"; disk = "Disk"; net = "Net"; sys = "System"; locale = "C"; };
    ru = { cpu = "ЦП"; ram = "ОЗУ"; disk = "Диск"; net = "Сеть"; sys = "Система"; locale = "ru_RU.utf8"; };
  }.${dash.language};

  netIf = dash.network.interface;
  diskMount = dash.disk.mount;

  # Процент диска на плитке: свободно или занято (dash.format.diskPercent)
  diskPct = if dash.format.diskPercent == "used"
    then "floor(EWW_DISK[\"${diskMount}\"].used_perc)"
    else "floor(100 - EWW_DISK[\"${diskMount}\"].used_perc)";

  # Поле трафика для графика сети (dash.tiles.net.mode)
  netField = if dash.tiles.net.mode == "up" then "NET_UP" else "NET_DOWN";

  # Скорости сети цифрами (dash.tiles.net.rates): ↓ приём / ↑ отдача, SI-единицы
  netRates = optionalString dash.tiles.net.rates ''
        (box :class "nums" :orientation "h" :spacing 12
              (label :class "num dim" :text "↓ ''${formatbytes(floor(EWW_NET["${netIf}"].NET_DOWN), false, "si")}/s")
              (label :class "num dim" :text "↑ ''${formatbytes(floor(EWW_NET["${netIf}"].NET_UP), false, "si")}/s"))'';

  # Строки часов — только включённые в dash.clock.*
  clockLines = concatMapStringsSep "\n        "
    (l: "(label :class \"${l.cls}\" :text ${l.var})")
    (optional dash.clock.showDate  { cls = "clock-l1"; var = "clockdate"; }
      ++ optional dash.clock.showDay  { cls = "clock-l2"; var = "clockday"; }
      ++ optional dash.clock.showTime { cls = "clock-l3"; var = "clocktime"; });

  # CSS-сетка графика: слои по gridDir (both|x|y), толщина gridThickness
  gridGrad = to: "repeating-linear-gradient(to ${to}, ${gridLine} 0, ${gridLine} ${toString dash.chart.gridThickness}px, transparent ${toString dash.chart.gridThickness}px, transparent ${toString dash.chart.gridStep}px)";
  gridLayers = (optional (dash.chart.gridDir == "both" || dash.chart.gridDir == "x") (gridGrad "right"))
    ++ (optional (dash.chart.gridDir == "both" || dash.chart.gridDir == "y") (gridGrad "bottom"));
  gridCss = if gridLayers == [ ] then "none" else concatStringsSep ",\n        " gridLayers;

  # Плитка по имени → виджет
  tileWidget = name: {
    cpu   = "(stat-cpu)";
    ram   = "(stat-ram)";
    disk  = "(stat-disk)";
    net   = "(stat-net)";
    clock = "(stat-clock)";
    sys   = "(stat-sys)";
  }.${name};

  # Ряды плиток: каждый ряд — горизонтальный box с центрированием
  body = concatMapStringsSep "\n      " (row:
    "(box :class \"row\" :orientation \"h\" :spacing ${toString dash.spacing} :halign \"center\" :valign \"center\"\n        "
    + concatMapStringsSep "\n        " tileWidget row + ")"
  ) dash.rows;

  pos = {
    center = [ "center" "center" ];
    top = [ "center" "start" ];
    bottom = [ "center" "end" ];
    left = [ "start" "center" ];
    right = [ "end" "center" ];
    top-left = [ "start" "start" ];
    top-right = [ "end" "start" ];
    bottom-left = [ "start" "end" ];
    bottom-right = [ "end" "end" ];
  }.${dash.position} or [ "center" "center" ];
  halign = elemAt pos 0;
  valign = elemAt pos 1;

  ewwYuck = ''
    (defpoll focused_wsp :interval "300ms" :initial "" "niri-dash-stat wsp")
    (defpoll clockdate :interval "${dash.intervals.clockDate}" :initial "" "LC_TIME=${lang.locale} date '${dash.clock.dateFormat}'")
    (defpoll clockday  :interval "${dash.intervals.clockDay}"  :initial "" "LC_TIME=${lang.locale} date '${dash.clock.dayFormat}'")
    (defpoll clocktime :interval "${dash.intervals.clockTime}" :initial "" "LC_TIME=${lang.locale} date '${dash.clock.timeFormat}'")
    (defpoll cputemp   :interval "${dash.intervals.cpuTemp}" :initial "0" "niri-dash-stat cputemp")
    (defpoll diskio    :interval "${dash.intervals.diskIo}"  :initial "0" "niri-dash-stat diskio ${dash.disk.device} ${dash.tiles.disk.mode}")
    (defpoll uptime    :interval "${dash.intervals.uptime}"  :initial "" "niri-dash-stat uptime")
    (defpoll load1     :interval "${dash.intervals.load}"    :initial "0" "niri-dash-stat load ${toString dash.format.loadWindow}")

    (defwidget chart [cls value min max dyn]
      (box :class "chart ''${cls}" :vexpand true :hexpand true
        (graph :value value :min min :max max :dynamic dyn
               :time-range "${dash.chart.timeRange}"
               :thickness ${toString dash.chart.thickness}
               :line-style "${dash.chart.lineStyle}"${optBool "flip-x" dash.chart.flipX}${optBool "flip-y" dash.chart.flipY}${optBool "vertical" dash.chart.vertical}
               :vexpand true :hexpand true)))

    (defwidget stat-cpu []
      (box :class "tile cpu" :orientation "v" :spacing 8
        (label :class "tile-title" :text "${lang.cpu}")
        (box :class "nums" :orientation "h" :spacing 12
          (label :class "num" :text "''${floor(EWW_CPU.avg)}%")
          (label :class "num dim" :text "''${cputemp}°C"))
        (chart :cls "cpu" :value "''${EWW_CPU.avg}" :min 0 :max ${toString dash.tiles.cpu.max} :dyn ${boolStr dash.tiles.cpu.dynamic})))

    (defwidget stat-ram []
      (box :class "tile ram" :orientation "v" :spacing 8
        (label :class "tile-title" :text "${lang.ram}")
        (box :class "nums" :orientation "h" :spacing 12
          (label :class "num" :text "''${round(EWW_RAM.used_mem/${toString gbFactor},${toString dec})}/''${round(EWW_RAM.total_mem/${toString gbFactor},${toString dec})} GB")
          (label :class "num dim" :text "''${floor(EWW_RAM.used_mem_perc)}%"))
        (chart :cls "ram" :value "''${EWW_RAM.used_mem_perc}" :min 0 :max ${toString dash.tiles.ram.max} :dyn ${boolStr dash.tiles.ram.dynamic})))

    (defwidget stat-disk []
      (box :class "tile disk" :orientation "v" :spacing 8
        (label :class "tile-title" :text "${lang.disk}")
        (box :class "nums" :orientation "h" :spacing 12
          (label :class "num" :text "''${round(EWW_DISK["${diskMount}"].free/${toString gbFactor},${toString dec})}/''${round(EWW_DISK["${diskMount}"].total/${toString gbFactor},${toString dec})} GB")
          (label :class "num dim" :text "''${${diskPct}}%"))
        (chart :cls "disk" :value "''${diskio}" :min 0 :max ${toString dash.tiles.disk.max} :dyn ${boolStr dash.tiles.disk.dynamic})))

    (defwidget stat-net []
      (box :class "tile net" :orientation "v" :spacing 8
        (label :class "tile-title" :text "${lang.net}")
        ${netRates}
        (chart :cls "net" :value "''${EWW_NET["${netIf}"].${netField}}" :min 0 :max ${toString dash.tiles.net.max} :dyn ${boolStr dash.tiles.net.dynamic})))

    (defwidget stat-clock []
      (box :class "tile clock" :orientation "v" :spacing 2
        ${clockLines}))

    (defwidget stat-sys []
      (box :class "tile sys" :orientation "v" :spacing 8
        (label :class "tile-title" :text "${lang.sys}")
        (box :class "nums" :orientation "h" :spacing 12
          (label :class "num" :text "''${load1}")
          (label :class "num dim" :text "''${uptime}"))
        (chart :cls "load" :value "''${load1}" :min 0 :max ${toString dash.tiles.load.max} :dyn ${boolStr dash.tiles.load.dynamic})))

    (defwindow dashboard
      :monitor "${dash.output}"
      :geometry (geometry :x "0%" :y "0%" :width "100%" :height "100%" :anchor "top left")
      :stacking "${dash.window.stacking}"
      :focusable "${dash.window.focusable}"
      :namespace "${dash.window.namespace}"
      (box :class "root" :orientation "v" :spacing ${toString dash.spacing}
           :visible {focused_wsp == "${dash.workspace}"}
           :halign "${halign}" :valign "${valign}"
        ${body}))
  '';

  ewwScss = ''
    window, .root { background: transparent; }
    window { ${fontFamilyCss}font-size: ${toString f.size}px; }

    .root { margin: ${toString dash.window.margin}px; }

    .tile {
      background: ${cardBg};
      border: ${toString dash.tile.borderWidth}px solid ${tileBorder};
      border-radius: ${toString dash.tile.radius}px;
      padding: ${toString dash.tile.paddingY}px ${toString dash.tile.paddingX}px;
      min-width: ${toString dash.tileWidth}px;
    }

    /* Per-card color: background tint + border */
    ${cardRules}

    .tile-title { color: ${dc.title}; font-size: ${toString font.title}px; font-weight: bold; letter-spacing: ${toString f.titleTracking}px; }
    .num { color: ${dc.text}; font-size: ${toString font.num}px; font-weight: bold; }
    .num.dim { color: ${dc.muted}; font-size: ${toString font.dim}px; font-weight: normal; }

    .chart {
      min-height: ${toString dash.chart.height}px;
      border-radius: ${toString dash.chart.radius}px;
      background-color: ${chartBg};
      background-image: ${gridCss};
    }

    .chart.cpu  graph { color: ${dc.cpu};  background-color: ${fillOf dc.cpu}; }
    .chart.ram  graph { color: ${dc.ram};  background-color: ${fillOf dc.ram}; }
    .chart.disk graph { color: ${dc.disk}; background-color: ${fillOf dc.disk}; }
    .chart.net  graph { color: ${dc.net};  background-color: ${fillOf dc.net}; }
    .chart.load graph { color: ${dc.sys};  background-color: ${fillOf dc.sys}; }

    .clock label { font-weight: normal; }
    .clock .clock-l1 { color: ${dc.text};   font-size: ${toString font.clockDate}px; }
    .clock .clock-l2 { color: ${dc.accent}; font-size: ${toString font.clockDay}px; }
    .clock .clock-l3 { color: ${dc.text};   font-size: ${toString font.clockTime}px; }
  '';

  # Poll-хелперы дашборда: темп CPU (sysfs hwmon), скорость I/O диска (/proc/diskstats),
  # аптайм (/proc/uptime) и загрузка (/proc/loadavg).
  dashStat = pkgs.writeShellScriptBin "niri-dash-stat" ''
    set -u
    sensors="${concatStringsSep " " dash.temperature.sensors}"
    case "''${1:-}" in
      cputemp)
        for n in $sensors; do
          for h in /sys/class/hwmon/hwmon*; do
            [ "$(cat "$h/name" 2>/dev/null || true)" = "$n" ] || continue
            awk '{printf "%.0f\n", $1/1000}' "$h/temp1_input" 2>/dev/null && exit 0
          done
        done
        echo 0
        ;;
      diskio)
        dev="''${2:-sdb}"; mode="''${3:-write}"
        field=$([ "$mode" = read ] && echo 6 || echo 10)
        st="''${XDG_RUNTIME_DIR:-/tmp}/niri-dash-diskio-$dev-$mode"
        now=$(date +%s)
        sec=$(awk -v d="$dev" -v f="$field" '$3==d{print $f; exit}' /proc/diskstats)
        [ -n "''${sec:-}" ] || { echo 0; exit 0; }
        pt=$now; ps=$sec
        [ -r "$st" ] && read -r pt ps < "$st" 2>/dev/null || true
        dt=$(( now - pt )); [ "$dt" -gt 0 ] || dt=1
        ds=$(( sec - ps )); [ "$ds" -ge 0 ] || ds=0
        printf '%d\n' $(( ds * 512 / dt ))
        printf '%s %s\n' "$now" "$sec" > "$st"
        ;;
      uptime)
        awk '{ s=int($1); d=int(s/86400); h=int((s%86400)/3600); m=int((s%3600)/60);
               if (d>0) printf "%dd %dh %dm\n", d, h, m; else printf "%dh %dm\n", h, m }' /proc/uptime
        ;;
      load)
        case "''${2:-1}" in 5) f=2 ;; 15) f=3 ;; *) f=1 ;; esac
        awk -v f="$f" '{ print $f }' /proc/loadavg
        ;;
      wsp)
        ${pkgs.niri}/bin/niri msg --json workspaces 2>/dev/null \
          | ${pkgs.jq}/bin/jq -r '.[] | select(.is_focused) | .name'
        ;;
      *) echo 0 ;;
    esac
  '';
in

{
  imports = [
    ../../../../lib/niri/theme.nix
    ../../desktop/wayland
  ];

  options.modules.home.wm.niri = {
    enable = mkEnableOption "niri Wayland compositor";
  };

  config = mkIf cfg.enable {
    modules.home = {
      desktop.wayland = {
        common.enable = true;
        fuzzel.enable = true;
        # Noctalia v5 (модуль programs.noctalia в modules/nixos/desktop/niri.nix)
        # заменяет waybar/mako/swaybg/swaylock/swayidle/wlogout — их модули удалены.
      };

      terminals = {
        wezterm.themeName = cfg.theme.appThemeNames.wezterm;
        yazi = {
          themeName = cfg.theme.appThemeNames.yazi;
          colors = cfg.theme.appColors.yazi;
        };
        fastfetch.colors = cfg.theme.appColors.fastfetch;
      };
    };

    xdg.configFile."niri/config.kdl" = {
      source = config.lib.file.mkOutOfStoreSymlink "${niriConfigDir}/config.kdl";
    };
    xdg.configFile."niri/input.kdl" = {
      source = config.lib.file.mkOutOfStoreSymlink "${niriConfigDir}/input.kdl";
    };
    xdg.configFile."niri/binds.kdl" = {
      source = config.lib.file.mkOutOfStoreSymlink "${niriConfigDir}/binds.kdl";
    };

    xdg.configFile."niri/theme.kdl".text = ''
      layout {
          focus-ring {
              on
              width 2
              active-color "${colors.primary}"
              inactive-color "${colors.surface}"
          }
          border {
              on
              width 1
              active-color "${colors.primary}"
              inactive-color "${colors.border_normal}"
          }
          background-color "${colors.background}"
      }

      overview {
          backdrop-color "${colors.surface}"
      }
    '';

    # Конфиг Noctalia (обои, бар) — симлинк в репо, чтобы GUI-изменения сохранялись
    xdg.configFile."noctalia/settings.toml".source =
      config.lib.file.mkOutOfStoreSymlink "${noctaliaConfigDir}/settings.toml";

    # Дашборд-«райдер» (eww): пакет и сгенерированный из config.nix конфиг.
    # Видимость по столу реализована внутри eww (poll focused_wsp), отдельного вотчера нет.
    home.packages = [ pkgs.eww dashStat ];
    xdg.configFile."eww/eww.yuck".text = ewwYuck;
    xdg.configFile."eww/eww.scss".text = ewwScss;
  };
}
