{ config, lib, pkgs, variables, ... }:

with lib;

let
  cfg = config.modules.home.wm.niri;
  colors = cfg.theme.colors;
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
    background = dashColor "background" colors.surface_variant;
    border     = dashColor "border"     colors.border_normal;
    title      = dashColor "title"      colors.inactive;
    text       = dashColor "text"       colors.foreground;
    muted      = dashColor "muted"      colors.inactive;
    accent     = dashColor "accent"     colors.primary;
    barTrack   = dashColor "barTrack"   colors.border_normal;
  };
  # "#RRGGBB" → "rgba(r, g, b, alpha)" для прозрачного фона карточек
  hexToRgba = hex: alpha:
    let
      v = fromHexString (substring 0 6 (removePrefix "#" hex));
      r = v / 65536;
      g = (v / 256) - r * 256;
      b = v - r * 65536 - g * 256;
    in "rgba(${toString r}, ${toString g}, ${toString b}, ${toString alpha})";
  cardBg = hexToRgba dc.background dash.opacity;

  lang = {
    en = { cpu = "CPU"; ram = "RAM"; disk = "Disk"; net = "Net"; locale = "C"; };
    ru = { cpu = "ЦП"; ram = "ОЗУ"; disk = "Диск"; net = "Сеть"; locale = "ru_RU.utf8"; };
  }.${dash.language};

  netIf = dash.network.interface;
  netDiv = if dash.network.unit == "MB/s" then 1048576 else 1024;
  # выражение eww: байт/сек → выбранные единицы, 1 знак после точки
  netVal = dir: ''round(EWW_NET["${netIf}"].NET_${dir}/${toString netDiv}, 1)'';

  # Содержимое окна — выбранные плитки по порядку из конфига
  body = concatMapStringsSep "\n      " (name: {
    cpu = ''(metric :title "${lang.cpu}" :value "''${floor(EWW_CPU.avg)}" :unit "%")'';
    ram = ''(metric :title "${lang.ram}" :value "''${floor(EWW_RAM.used_mem_perc)}" :unit "%")'';
    disk = ''(metric :title "${lang.disk}" :value "''${floor(EWW_DISK["/"].used_perc)}" :unit "%")'';
    net = ''(net :title "${lang.net}" :down "''${${netVal "DOWN"}}" :up "''${${netVal "UP"}}" :unit "${dash.network.unit}")'';
    clock = ''(clock :day clock-day :date clock-date)'';
  }.${name}) dash.tiles;

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
  orient = if dash.orientation == "column" then "v" else "h";
  halign = elemAt pos 0;
  valign = elemAt pos 1;

  ewwYuck = ''
    (defpoll clock-day  :interval "30s"  :initial ""  `LC_TIME=${lang.locale} date '+%A'`)
    (defpoll clock-date :interval "120s" :initial ""  `LC_TIME=${lang.locale} date '+%d %B'`)

    (defwidget metric [title value unit]
      (box :class "tile" :orientation "v" :spacing 6
        (label :class "tile-title" :text title)
        (box :class "tile-row" :orientation "h" :spacing 4
          (label :class "tile-value" :text value)
          (label :class "tile-unit" :text unit))
        (progress :class "tile-bar" :value value)))

    (defwidget net [title down up unit]
      (box :class "tile" :orientation "v" :spacing 6
        (label :class "tile-title" :text title)
        (box :class "net-rows" :orientation "v" :spacing 2
          (box :class "net-row" :orientation "h" :spacing 6
            (label :class "net-arrow" :text "↓")
            (label :class "tile-value" :text down)
            (label :class "tile-unit" :text unit))
          (box :class "net-row" :orientation "h" :spacing 6
            (label :class "net-arrow" :text "↑")
            (label :class "tile-value" :text up)
            (label :class "tile-unit" :text unit)))))

    (defwidget clock [day date]
      (box :class "tile clock" :orientation "v" :spacing 4
        (label :class "clock-day" :text day)
        (label :class "clock-date" :text date)))

    (defwindow dashboard
      :monitor "${dash.output}"
      :geometry (geometry :x "0%" :y "0%" :width "100%" :height "100%" :anchor "top left")
      :stacking "bottom"
      :focusable "none"
      :namespace "eww-dashboard"
      (box :class "root" :orientation "${orient}" :spacing ${toString dash.spacing}
           :halign "${halign}" :valign "${valign}"
        ${body}))
  '';

  ewwScss = ''
    window, .root { background: transparent; }

    .tile {
      background: ${cardBg};
      border: 1px solid ${dc.border};
      border-radius: 14px;
      padding: 14px 18px;
      min-width: ${toString dash.tileWidth}px;
    }

    .tile-title { color: ${dc.title}; font-size: 12px; font-weight: bold; }
    .tile-value { color: ${dc.text}; font-size: 30px; font-weight: bold; }
    .tile-unit  { color: ${dc.muted}; font-size: 13px; }
    .net-row .tile-value { font-size: 20px; }
    .net-arrow  { color: ${dc.accent}; font-size: 18px; }

    .tile-bar trough   { background: ${dc.barTrack}; border-radius: 5px; min-height: 6px; }
    .tile-bar progress { background: ${dc.accent};   border-radius: 5px; min-height: 6px; }

    .clock .clock-day  { color: ${dc.accent}; font-size: 26px; font-weight: bold; }
    .clock .clock-date { color: ${dc.text};   font-size: 16px; }
  '';

  # Показывает дашборд только на нужном столе: следит за фокусом niri и дёргает eww.
  dashWatch = pkgs.writeShellScriptBin "niri-dash-watch" ''
    target="${dash.workspace}"
    last=""
    until eww ping >/dev/null 2>&1; do sleep 0.2; done
    while sleep 0.3; do
      cur=$(niri msg --json workspaces 2>/dev/null | jq -r '.[] | select(.is_focused) | .name')
      [ "$cur" = "$last" ] && continue
      last="$cur"
      if [ "$cur" = "$target" ]; then
        eww open dashboard >/dev/null 2>&1
      else
        eww close dashboard >/dev/null 2>&1
      fi
    done
    # ponytail: poll 0.3s (дёшево); апгрейд → niri msg --json event-stream
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
        wlogout.enable = true;
        # Noctalia v5 (модуль programs.noctalia в modules/nixos/desktop/niri.nix)
        # заменяет waybar, mako, swaybg, swaylock и swayidle — они здесь выключены.
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

    # Дашборд-«райдер» (eww): пакет, вотчер и сгенерированный из config.nix конфиг
    home.packages = [ pkgs.eww dashWatch ];
    xdg.configFile."eww/eww.yuck".text = ewwYuck;
    xdg.configFile."eww/eww.scss".text = ewwScss;
  };
}
