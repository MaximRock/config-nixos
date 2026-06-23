from __future__ import annotations

import logging
from pathlib import Path
from typing import TYPE_CHECKING, Callable

from modules.qtile_help.parser.hotkey_parser import HotkeyParser
from modules.qtile_help.parser.hotkey_repository import HotkeyEntry, HotkeyRepository
from modules.qtile_help.watcher.file_watcher import FileWatcher


if TYPE_CHECKING:
    from config_qtile.key_definitions import KeyBinding

logger: logging.Logger = logging.getLogger("qtile-help.controller")


class HelpController:
    def __init__(
        self,
        parser: HotkeyParser | None = None,
        repository: HotkeyRepository | None = None,
        watcher: FileWatcher | None = None,
    ) -> None:
        self._parser: HotkeyParser = parser or HotkeyParser()
        self._repository: HotkeyRepository = repository or HotkeyRepository()
        self._watcher: FileWatcher | None = watcher
        self._on_update: Callable[[list[HotkeyEntry]], None] | None = None

    def set_on_update(self, callback: Callable[[list[HotkeyEntry]], None]) -> None:
        self._on_update = callback

    def load(self) -> list[HotkeyEntry]:
        bindings: list[KeyBinding] = self._parser.parse()
        self._repository.update(bindings)
        entries: list[HotkeyEntry] = self._repository.get_entries()
        logger.info("Loaded %d hotkey entries", len(entries))
        return entries

    def refresh(self) -> None:
        entries: list[HotkeyEntry] = self.load()
        if self._on_update is not None:
            self._on_update(entries)

    def search(self, query: str) -> list[HotkeyEntry]:
        return self._repository.search(query)

    def start_watching(self) -> None:
        if self._watcher is not None:
            self._watcher.callback = self.refresh
            self._watcher.start()

    def stop_watching(self) -> None:
        if self._watcher is not None:
            self._watcher.stop()

    @classmethod
    def create_default(cls) -> HelpController:
        from modules.qtile_help.constants import KEY_DEFINITIONS_MODULE, POLL_INTERVAL_MS

        parser: HotkeyParser = HotkeyParser(module_path=KEY_DEFINITIONS_MODULE)
        repository: HotkeyRepository = HotkeyRepository()

        key_def_path: Path = _resolve_key_definitions_path()
        watcher: FileWatcher | None = None
        if key_def_path is not None:
            watcher = FileWatcher(
                file_path=key_def_path,
                callback=_noop,
                interval=POLL_INTERVAL_MS / 1000,
            )

        return cls(parser=parser, repository=repository, watcher=watcher)


def _noop() -> None:
    return None


def _resolve_key_definitions_path() -> Path | None:
    candidate: Path = Path.home() / ".config" / "qtile" / "config_qtile" / "key_definitions.py"
    if candidate.exists():
        return candidate.resolve()
    return None
