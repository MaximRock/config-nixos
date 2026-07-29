# PLAN — Центральный конфиг приложений

> 📌 Текущее состояние сохранено тегом: `backup/pre-central-config`

## Проблема

Настройки размазаны по проекту — нет единого источника правды (SSOT):

| Что | Где | Формат | Дубликаты |
|---|---|---|---|
| `THEME_COLOR` | `constants.py:14` | Python (хардкод) | Nix парсил regex → хрупко |
| Цвета темы (36 ключей) | `config_qtile/theme/presets/*.json` | JSON | — |
| Цвета power-menu | `modules/power_menu/colors/*.py` | Python dict | ❌ дубль |
| Цвета qtile-help | `modules/qtile_help/colors.py` | Python dict | ❌ дубль (3-я копия) |
| App paths (терминал, браузер) | `constants.py:18-25` | Python | — |
| WezTerm (шрифт, opacity) | `wezterm.lua` | Lua хардкод | — |

## Решение

Центральный JSON-файл `settings/settings.json`, который читают Nix, Python и Lua.

### Почему JSON

- **Nix**: `builtins.fromJSON (builtins.readFile ...)`
- **Python**: `json.load()`
- **Lua** (WezTerm): `wezterm.json_parse()`
- Человекочитаем, легко расширяется

## Итоговая архитектура

```
settings/settings.json
  │
  ├── Nix:   lib/theme.nix ──→ specialArgs ──→ NixOS + HM модули
  │
  ├── Python: settings/settings_loader.py ──→ constants.py ──→ Qtile config
  │                                       ──→ power_menu/app.py
  │                                       ──→ qtile_help/app.py
  │
  └── Lua:   modules/home/terminals/wezterm/wezterm.lua
```

## Что изменилось

### NEW

| Файл | Описание |
|---|---|
| `modules/home/desktop/qtile/config/settings/settings.json` | Центральный конфиг (тема, приложения, qtile, wezterm) |
| `modules/home/desktop/qtile/config/settings/settings_loader.py` | Python-загрузчик с типизированными функциями |

### MODIFIED

| Файл | Что изменилось |
|---|---|
| `lib/theme.nix` | Вместо regex-парсинга `constants.py` читает `settings.json` |
| `modules/home/desktop/qtile/config/constants.py` | Импортирует из `settings_loader` вместо хардкода |
| `modules/home/desktop/qtile/config/modules/power_menu/app.py` | Читает `settings.json` + `presets/<theme>.json` вместо `colors/*.py` |
| `modules/home/desktop/qtile/config/modules/qtile_help/app.py` | Читает `settings.json` + `presets/<theme>.json` вместо `colors.py` |
| `modules/home/terminals/wezterm/wezterm.lua` | Читает `settings.json` (шрифт, opacity, padding, тема) |

### DELETED

| Файл | Причина |
|---|---|
| `modules/power_menu/colors/catpuccin.py` | Дубликат — цвета теперь читаются из `presets/*.json` |
| `modules/power_menu/colors/gruvbox.py` | То же |
| `modules/power_menu/colors/tokyonight.py` | То же |
| `modules/qtile_help/colors.py` | Дубликат — третья копия цветов |

### UNCHANGED

`config.py`, `key_definitions.py`, `theme_controller.py`, `logger.py`,
`modules/power-menu/package.nix`, `modules/qtile-help/package.nix`,
`config_qtile/theme/presets/*.json`, `wezterm/keys.lua`, `lib/default.nix`

Все эти файлы продолжают импортировать из `constants.py` или не зависят от изменений.

## Расширяемость

Добавить новый модуль в центральный конфиг:

```
1. Новая секция в settings.json
2. Загрузчик на стороне модуля
   - Nix:  builtins.fromJSON (builtins.readFile ...)
   - Python: json.load(open(...))
   - Lua:   io.open + wezterm.json_parse
3. Готово
```

### Примеры будущих секций

- `"dunst": { ... }` — тема уведомлений
- `"fonts": { "mono": "...", "size": 14 }` — шрифты для всех приложений
- `"gtk": { "theme": "...", "icons": "..." }` — GTK-тема

## Работа с git-тегами — шпаргалка

```sh
# создать тег на текущем HEAD
git tag backup/pre-central-config

# список тегов
git tag -l 'backup/*'

# вернуться к снапшоту (посмотреть)
git checkout backup/pre-central-config
git checkout main  # вернуться

# сравнить изменения после тега
git diff backup/pre-central-config..main
git log backup/pre-central-config..main --oneline

# удалить тег (когда миграция завершена)
git tag -d backup/pre-central-config
```

---

# Миграция приложений на SSOT (settings.json)

Прогресс миграции модулей с хардкода на центральный конфиг.

- [x] **Dunst** — `colors.*` + `settings.dunst.*`
- [x] **Picom** — `settings.picom.*` (backend, opacity, corner-radius...)
- [x] **GTK** — `settings.gtk.*` (theme, icon_theme, cursor_theme, cursor_size)
- [x] **Rofi** — `settings.rofi.*` + `colors.*`
- [x] **Fastfetch** — `colors.*` для keyColor, `settings.fastfetch.*`
- [x] **Yazi** — `colors.*` для theme.toml (cwd, hovered, preview_hovered)
- [x] **Wezterm** — расширить: tab_colors, status_bar, cursor, split_color
- [x] **Git** — user_name, user_email в settings.json
- [x] **Shell (zsh)** — oh-my-zsh theme, plugins в settings.json
```

---

## Architecture v2 — Minimal SSOT (only colors)

После переосмысления: `settings.json` раздут, настройки каждого приложения
должны жить в его Nix-модуле (Nix way). Единственный реально общий SSOT —
**цветовая схема**.

### Что изменилось

| Файл | Действие |
|---|---|
| `lib/settings.json` | **NEW** — только {theme, apps, qtile} |
| `config/settings/settings.json` | → symlink на `lib/settings.json` |
| `lib/theme.nix` | путь: `./settings.json`; убран экспорт `settings` |
| `lib/default.nix` | убран `settings` из specialArgs |
| `settings_loader.py` | удалены `get_wezterm`, `resolve_theme`, `resolve_color` |
| `dunst/settings.nix` | хардкод + комменты; цвета `colors.*` |
| `picom/default.nix` | полный хардкод |
| `gtk/default.nix` | полный хардкод |
| `rofi/default.nix` + `theme.nix` | хардкод font/modes; цвета `activeTheme.config` |
| `git/default.nix` | полный хардкод |
| `shell/zsh/default.nix` | полный хардкод |
| `yazi/default.nix` | хардкод ratio/editor; цвета `colors.*` |
| `fastfetch/default.nix` | хардкод logo width/height; цвета `colors.*` |
| `wezterm.lua` | полный хардкод (без JSON) |
| `PLAN.md` | добавлен этот раздел |

### Новая архитектура

```
lib/settings.json              ← только {theme, apps, qtile}
  │
  ├── Nix: lib/theme.nix ──→ specialArgs.colors ──→ модули (dunst, rofi, yazi, fastfetch)
  │         ↑ читает только theme.active + theme.colors
  │
  └── Python (Qtile runtime): symlink → ~/.config/qtile/settings/settings.json
                └─→ settings_loader.py ──→ constants.py (apps, qtile)
```

### Статус v2

- [x] `lib/settings.json` — только {theme, apps, qtile}
- [x] `lib/theme.nix` — читает `./settings.json`, экспортирует `colors`
- [x] `lib/default.nix` — `settings` убран из specialArgs
- [x] `config/settings/settings.json` — symlink на `lib/settings.json`
- [x] `settings_loader.py` — убраны лишние функции
- [x] `dunst/settings.nix` — хардкод + комменты, цвета из `colors.*`
- [x] `picom/default.nix` — полный хардкод
- [x] `gtk/default.nix` — полный хардкод
- [x] `rofi/default.nix` + `theme.nix` — хардкод, цвета из `activeTheme`
- [x] `git/default.nix` — полный хардкод
- [x] `shell/zsh/default.nix` — полный хардкод
- [x] `yazi/default.nix` — хардкод, цвета из `colors.*`
- [x] `fastfetch/default.nix` — хардкод, цвета из `colors.*`
- [x] `wezterm.lua` — полный хардкод (без JSON)
- [x] PLAN.md — обновлён
```

---

# Niri (Wayland compositor) — ветка `feat/niri-wayland`

Добавление niri как второго WM на ту же машину, переключение через SDDM.

## Файлы (только изменения)

### NEW

| Файл | Описание |
|---|---|
| `modules/nixos/desktop/niri.nix` | Системный модуль niri (programs.niri, xdg.portal, Wayland-пакеты) |
| `modules/home/wm/niri/default.nix` | HM-модуль niri (опция enable, symlink конфига, пакеты) |
| `modules/home/wm/niri/config/config.kdl` | Конфиг niri (layout, input, binds, autostart) |
| `modules/home/wm/niri/config/scripts/layout.sh` | Скрипт текущей раскладки для waybar (JSON) |

### MODIFIED

| Файл | Что изменилось |
|---|---|
| `configuration.nix` | Добавлен импорт `./modules/nixos/desktop/niri.nix` |
| `home/common/wm.nix` | Добавлен импорт niri HM-модуля + `modules.home.wm.niri.enable = true` |

### UNCHANGED

`flake.nix`, `hosts/`, `lib/`, все остальные модули — новый хост не создаётся, niri работает на той же машине.

## Структура

```
modules/
├── nixos/
│   └── desktop/
│       ├── qtile.nix         ← без изменений
│       └── niri.nix          ← NEW: programs.niri + portals
└── home/
    └── wm/
        ├── qtile/            ← без изменений
        └── niri/
            ├── default.nix   ← NEW: HM-модуль
            └── config/
                ├── config.kdl ← NEW: niri (layout, input, binds, autostart)
                └── scripts/
                    └── layout.sh ← NEW: раскладка для waybar
configuration.nix             ← +import niri.nix
home/common/wm.nix            ← +import niri HM
```

## Пакеты

### Системные (niri.nix)
- `programs.niri.enable = true` — сам compositor
- `xdg.portal.enable = true` + `xdg.portal.extraPortals = [ xdg-desktop-portal-gtk xdg-desktop-portal-wlr ]`

### Пользовательские (niri/default.nix)
- `waybar` — статус-бар
- `fuzzel` — лаунчер
- `grim` + `slurp` — скриншоты
- `wl-clipboard` — буфер обмена
- `swaybg` — обои
- `swaylock` — блокировка
- `swayidle` — idle/power
- `mako` — уведомления (либо dunst)
- `wlogout` — меню выхода
- `brightnessctl` — яркость
- `playerctl` — MPRIS
- `pamixer` — звук
- `polkit_gnome` — polkit-агент для Wayland

## Раскладка клавиатуры

**Раскладка:** us,ru, переключение **Ctrl+Shift**.

**Способ:** Option 1 — явно в `config.kdl`:
```kdl
input {
    keyboard {
        xkb {
            layout "us,ru"
            options "grp:ctrl_shift_toggle"
        }
        repeat-delay 200
        repeat-rate 35
        numlock
        track-layout "global"
    }
}
```

**Переключение:**
- `Ctrl+Shift` — xkb-опция `grp:ctrl_shift_toggle` (аппаратное, работает всегда)
- Мышь — `on-click` на виджете waybar → `niri msg action switch-layout next`
- `switch-layout` в binds НЕ добавляем — xkb уже переключает, иначе двойное срабатывание

**Виджет waybar:**
- `custom/layout` — `exec: scripts/layout.sh`
- Возвращает `{"text": "US", "tooltip": "English | Русская"}`
- `return-type: json`, `interval: 1`
- `on-click: niri msg action switch-layout next`

**Скрипт `layout.sh`:**
- Читает `/proc/bus/input/leds` или через `niri msg` — запрашивает текущий xkb-индекс
- Выводит либо "US" (индекс 0), либо "RU" (индекс 1)

**Base.nix:** `services.xserver.xkb` остаётся без изменений — это для Qtile/X11. niri использует свою настройку из config.kdl, не пересекаясь.
```
