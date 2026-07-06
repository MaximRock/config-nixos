import json
from pathlib import Path

_PATH = Path(__file__).resolve().parent / "settings.json"


def _load() -> dict:
    with open(_PATH) as f:
        return json.load(f)


def get_theme_name() -> str:
    return _load()["theme"]["active"]


def get_app(name: str) -> str:
    return _load()["apps"][name]


def get_qtile(key: str):
    return _load()["qtile"][key]


def get_wezterm(key: str):
    return _load()["wezterm"][key]
