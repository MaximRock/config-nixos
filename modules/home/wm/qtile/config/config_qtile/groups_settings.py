"""Настройки групп (рабочих пространств) для Qtile.

Модуль определяет:
- `COUNT`: общее количество групп;
- `DEFAULT_OVERRIDES`: переопределения для профиля по умолчанию;
- `WORK_OVERRIDES`: переопределения для рабочего профиля.

Каждое переопределение сопоставляет номер группы с правилами `Match`
для автоматического размещения окон определённых приложений.
"""

from libqtile.config import Match

from constants import BROWSER, TERMINAL

DEFAULT_OVERRIDES: dict[str, dict[str, object]] = {
    "9": {"matches": [Match(wm_class="Throne")]}
}

WORK_OVERRIDES: dict[str, dict[str, object]] = {
    "1": {"matches": [Match(wm_class=TERMINAL)]},
    "2": {"matches": [Match(wm_class="VSCodium"), Match(wm_class="Code")]},
    "3": {"matches": [Match(wm_class=BROWSER)]},
    "4": {"matches": [Match(wm_class="firefox")]},
    "9": {"matches": [Match(wm_class="Throne")]},
}

COUNT: int = 9
