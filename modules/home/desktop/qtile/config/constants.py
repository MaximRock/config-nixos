from pathlib import Path

from settings.path import QtilePath

qp: QtilePath = QtilePath()

LOG_DIR: Path = Path("~/.local/state/qtile").expanduser()

POWER_MENU_SCRIPT: str = str(qp.get("modules/power_menu/main.py"))

# config.py
THEME_COLOR = "catppuccin"  # или "c" "catppuccin" "tokyonight" "gruvbox"
MOD_KEY = "mod4"

# приложения key_definitions.py
TERMINAL = "wezterm"
BROWSER = "yandex-browser-stable"
FILE_MANAGER = "thunar"
EDITOR = "code"
YAZI = f"{TERMINAL} start -- yazi"
ROFI = "rofi -show drun"
FLAMESHOT_GUI = "flameshot gui"
FLAMESHOT_FULL = "flameshot full"

# theme_controller.py
SETTINGS_JSON_PATH = "config_qtile/settings_json"
THEME_PRESETS_PATH = "config_qtile/theme/presets"
