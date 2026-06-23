from __future__ import annotations

import importlib
import logging
import sys
from typing import TYPE_CHECKING


if TYPE_CHECKING:
    from config_qtile.key_definitions import KeyBinding

logger: logging.Logger = logging.getLogger("qtile-help.parser")


class HotkeyParser:
    def __init__(self, module_path: str = "config_qtile.key_definitions") -> None:
        self._module_path: str = module_path

    def parse(self) -> list[KeyBinding]:
        self._ensure_sys_path()
        module = self._import_module()
        bindings: list[KeyBinding] = getattr(module, "KEYS_CONFIG", [])
        logger.info("Loaded %d key bindings", len(bindings))
        return bindings

    def _ensure_sys_path(self) -> None:
        from pathlib import Path

        candidate: Path = Path.home() / ".config" / "qtile"
        if candidate.exists() and str(candidate) not in sys.path:
            sys.path.insert(0, str(candidate))
            logger.debug("Added %s to sys.path", candidate)

    def _import_module(self):
        importlib.invalidate_caches()
        return importlib.import_module(self._module_path)
