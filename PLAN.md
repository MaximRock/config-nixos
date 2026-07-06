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
