from __future__ import annotations

from dataclasses import dataclass, field
from typing import TYPE_CHECKING, Protocol, Union


if TYPE_CHECKING:
    from config_qtile.key_definitions import KeyBinding


@dataclass(frozen=True)
class GroupHeader:
    name: str


@dataclass(frozen=True)
class HotkeyEntry:
    combo: str
    description: str


ListEntry = Union[HotkeyEntry, GroupHeader]


_MOD_ALIASES: dict[str, str] = {
    "mod": "Mod",
    "control": "Ctrl",
    "shift": "Shift",
    "alt": "Alt",
    "mod1": "Alt",
    "mod4": "Mod",
}


class HotkeyRenderer(Protocol):
    def render(self, binding: KeyBinding) -> str: ...


@dataclass
class HotkeyRepository:
    entries: list[ListEntry] = field(default_factory=list)
    renderer: HotkeyRenderer | None = None

    def update(self, raw_entries: list[KeyBinding | GroupHeader]) -> None:
        renderer = self.renderer or _default_renderer
        self.entries = []
        for entry in raw_entries:
            if isinstance(entry, GroupHeader):
                self.entries.append(entry)
            else:
                self.entries.append(HotkeyEntry(combo=renderer(entry), description=entry.desc))

    def get_entries(self) -> list[ListEntry]:
        return list(self.entries)

    def search(self, query: str) -> list[ListEntry]:
        q = query.lower()
        result: list[ListEntry] = []
        for entry in self.entries:
            if isinstance(entry, GroupHeader):
                continue
            if q in entry.combo.lower() or q in entry.description.lower():
                result.append(entry)
        return result


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
