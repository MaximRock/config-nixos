"""
    Текстовый парсинг key_definitions.py.

    Вместо динамического импорта модуля через importlib читает
    исходный файл напрямую, извлекая комментарии-группы (# Навигация)
    и вызовы KeyBinding через regex + eval.
"""

from __future__ import annotations

import logging
import re
from pathlib import Path
from typing import TYPE_CHECKING

from modules.qtile_help.parser.hotkey_repository import GroupHeader

if TYPE_CHECKING:
    from config_qtile.key_definitions import KeyBinding

logger: logging.Logger = logging.getLogger("qtile-help.parser")

_KEYBINDING_START_RE = re.compile(r"^\s*KeyBinding\s*\(")


class HotkeyParser:
    """Парсер файла key_definitions.py.

    Читает исходный файл, парсит комментарии как GroupHeader
    и KeyBinding-вызовы через regex + eval с подстановкой
    констант из модуля constants.

    Аргументы:
        module_path (str): путь к модулю через точки
            (по умолчанию "config_qtile.key_definitions")
    """
    def __init__(self, module_path: str = "config_qtile.key_definitions") -> None:
        self._module_path: str = module_path

    def parse(self) -> list[KeyBinding | GroupHeader]:
        source = self._read_source()
        if source is None:
            return []
        return self._parse_source(source)

    def _read_source(self) -> str | None:
        rel = self._module_path.replace(".", "/") + ".py"
        candidate: Path = Path.home() / ".config" / "qtile" / rel
        if not candidate.exists():
            logger.error("Key definitions file not found: %s", candidate)
            return None
        return candidate.read_text(encoding="utf-8")

    def _parse_source(self, source: str) -> list[KeyBinding | GroupHeader]:
        lines = source.splitlines()
        result: list[KeyBinding | GroupHeader] = []

        in_keys_config = False
        depth = 0
        pending_groups: list[str] = []
        buffer: list[str] = []

        for line in lines:
            if not in_keys_config:
                if re.match(r"^KEYS_CONFIG\s*:", line):
                    in_keys_config = True
                continue

            stripped = line.strip()

            if depth > 0:
                depth += line.count("(") - line.count(")")
                buffer.append(line)
                if depth <= 0:
                    entry = self._build_entry(buffer)
                    if entry is not None:
                        for g in pending_groups:
                            result.append(GroupHeader(name=g))
                        pending_groups.clear()
                        result.append(entry)
                    buffer.clear()
                    depth = 0
                continue

            if stripped.startswith("#") and not stripped.startswith("#!"):
                group_name = stripped.lstrip("#").strip()
                if group_name and not group_name.startswith("В файле") and not group_name.startswith("Все"):
                    pending_groups.append(group_name)
                continue

            if _KEYBINDING_START_RE.match(stripped):
                depth = line.count("(") - line.count(")")
                buffer.append(line)
                if depth <= 0:
                    entry = self._build_entry(buffer)
                    if entry is not None:
                        for g in pending_groups:
                            result.append(GroupHeader(name=g))
                        pending_groups.clear()
                        result.append(entry)
                    buffer.clear()
                    depth = 0
                continue

            if "]" in line and not stripped.startswith("]"):
                break

        return result

    def _build_entry(self, lines: list[str]) -> KeyBinding | None:
        block = "\n".join(lines).rstrip().rstrip(",")
        try:
            from config_qtile.key_definitions import KeyBinding
            import constants as _c

            ns: dict = {"KeyBinding": KeyBinding}
            for name in dir(_c):
                if not name.startswith("_"):
                    ns[name] = getattr(_c, name)
            value = eval(block, ns)
            if isinstance(value, KeyBinding):
                return value
        except Exception:
            logger.warning("Failed to parse KeyBinding: %s", block[:80])
        return None
