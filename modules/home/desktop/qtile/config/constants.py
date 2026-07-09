from pathlib import Path

from settings.path import QtilePath
from settings.settings_loader import get_qtile, get_theme_name

qp: QtilePath = QtilePath()

LOG_DIR: Path = Path("~/.local/state/qtile").expanduser()

POWER_MENU_SCRIPT: str = "qtile-power-menu"
QTILE_HELP_SCRIPT: str = "qtile-help"

THEME_COLOR = get_theme_name()
MOD_KEY = get_qtile("mod_key")

TERMINAL = "wezterm"
BROWSER = "yandex-browser-stable"
FILE_MANAGER = "thunar"
EDITOR = "codium"
YAZI = f"{TERMINAL} start -- yazi"
ROFI = "rofi -show drun"
FLAMESHOT_GUI = "flameshot gui"
FLAMESHOT_FULL = "flameshot full"

SETTINGS_JSON_PATH = "config_qtile/settings_json"
THEME_PRESETS_PATH = "config_qtile/theme/presets"
