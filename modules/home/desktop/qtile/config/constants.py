from pathlib import Path

from settings.path import QtilePath
from settings.settings_loader import get_app, get_qtile, get_theme_name

qp: QtilePath = QtilePath()

LOG_DIR: Path = Path("~/.local/state/qtile").expanduser()

POWER_MENU_SCRIPT: str = "qtile-power-menu"
QTILE_HELP_SCRIPT: str = "qtile-help"

THEME_COLOR = get_theme_name()
MOD_KEY = get_qtile("mod_key")

TERMINAL = get_app("terminal")
BROWSER = get_app("browser")
FILE_MANAGER = get_app("file_manager")
EDITOR = get_app("editor")
YAZI = f"{TERMINAL} start -- yazi"
ROFI = get_app("rofi")
FLAMESHOT_GUI = get_app("flameshot_gui")
FLAMESHOT_FULL = get_app("flameshot_full")

SETTINGS_JSON_PATH = "config_qtile/settings_json"
THEME_PRESETS_PATH = "config_qtile/theme/presets"
