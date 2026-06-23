from __future__ import annotations

from dataclasses import dataclass, field
from typing import TYPE_CHECKING, Protocol


if TYPE_CHECKING:
    from config_qtile.key_definitions import KeyBinding


@dataclass(frozen=True)
class HotkeyEntry:
    combo: str
    description: str


_MOD_ALIASES: dict[str, str] = {
    "mod": "Mod4",
    "control": "Ctrl",
    "shift": "Shift",
    "alt": "Alt",
    "mod1": "Alt",
    "mod4": "Mod4",
}


class HotkeyRenderer(Protocol):
    def render(self, binding: KeyBinding) -> str: ...


@dataclass
class HotkeyRepository:
    bindings: list[KeyBinding] = field(default_factory=list)
    renderer: HotkeyRenderer | None = None

    def update(self, bindings: list[KeyBinding]) -> None:
        self.bindings = bindings

    def get_entries(self) -> list[HotkeyEntry]:
        renderer = self.renderer or _default_renderer
        return [
            HotkeyEntry(combo=renderer(b), description=b.desc)
            for b in self.bindings
        ]

    def search(self, query: str) -> list[HotkeyEntry]:
        q = query.lower()
        return [
            e for e in self.get_entries()
            if q in e.combo.lower() or q in e.description.lower()
        ]


def _default_renderer(binding: KeyBinding) -> str:
    parts: list[str] = [_MOD_ALIASES.get(m, m.capitalize()) for m in binding.modifiers]
    key: str = _format_key(binding.key)
    if parts:
        return " + ".join([*parts, key])
    return key


def _format_key(key: str) -> str:
    replacements: dict[str, str] = {
        "Return": "Enter",
        "space": "Space",
    }
    if key in replacements:
        return replacements[key]
    if key.startswith("XF86"):
        return key[4:]
    if len(key) == 1:
        return key.upper()
    return key.capitalize()
