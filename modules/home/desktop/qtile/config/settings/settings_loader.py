import json
from pathlib import Path

_SETTINGS_PATH = Path(__file__).resolve().parent / "settings.json"


def _load() -> dict:
    with open(_SETTINGS_PATH) as f:
        return json.load(f)


def get(section: str, key: str):
    return _load()[section][key]


def get_theme_name() -> str:
    return _load()["theme"]["active"]


def get_qtile(key: str):
    return _load()["qtile"][key]
