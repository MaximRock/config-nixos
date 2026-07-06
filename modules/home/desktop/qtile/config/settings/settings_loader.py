import json
from pathlib import Path

_SETTINGS_PATH = Path(__file__).resolve().parent / "settings.json"
_PRESETS_DIR = Path(__file__).resolve().parent.parent / "config_qtile" / "theme" / "presets"

_DEFAULT_COLORS = {
    "background": "#1e1e2e",
    "foreground": "#cdd6f4",
    "primary": "#89b4fa",
    "secondary": "#cba6f7",
    "tertiary": "#94e2d5",
    "success": "#a6e3a1",
    "warning": "#f9e2af",
    "error": "#f38ba8",
    "surface": "#181825",
    "hover": "#313244",
    "selected": "#585b70",
    "border_color": "#45475a",
    "separator_color": "#585b70",
    "accent": "#fab387",
    "active": "#f9e2af",
    "inactive": "#6c7086",
    "border_focus": "#fab387",
    "border_normal": "#313244",
}


def _load() -> dict:
    with open(_SETTINGS_PATH) as f:
        return json.load(f)


def get(section: str, key: str):
    return _load()[section][key]


def get_theme_name() -> str:
    return _load()["theme"]["active"]


def get_app(name: str) -> str:
    return _load()["apps"][name]


def get_qtile(key: str):
    return _load()["qtile"][key]


def get_wezterm(key: str):
    return _load()["wezterm"][key]


def resolve_theme() -> dict:
    settings = _load()
    theme = settings["theme"]
    active = theme["active"]
    overrides = theme.get("colors", {})

    preset_path = _PRESETS_DIR / f"{active}.json"
    if preset_path.exists():
        with open(preset_path) as f:
            data = json.load(f)
            base = data[0]["config"] if isinstance(data, list) and data else {}
    else:
        base = {}

    merged = {}
    merged.update(_DEFAULT_COLORS)
    merged.update(base)
    merged.update(overrides)
    return merged


def resolve_color(key: str) -> str:
    return resolve_theme().get(key, _DEFAULT_COLORS.get(key, "#000000"))
