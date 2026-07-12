from __future__ import annotations

import logging
import os
from pathlib import Path
from threading import Event, Thread
from typing import Callable


logger: logging.Logger = logging.getLogger("qtile-help.watcher")


class FileWatcher:
    def __init__(
        self,
        file_path: Path,
        callback: Callable[[], None],
        interval: float = 2.0,
    ) -> None:
        self._file_path: Path = file_path
        self._callback: Callable[[], None] = callback
        self._interval: float = interval
        self._stop_event: Event = Event()
        self._thread: Thread | None = None
        self._last_mtime: float = 0.0

    @property
    def callback(self) -> Callable[[], None]:
        return self._callback

    @callback.setter
    def callback(self, callback: Callable[[], None]) -> None:
        self._callback = callback

    def start(self) -> None:
        if self._thread is not None:
            return
        self._last_mtime = self._get_mtime()
        self._thread = Thread(target=self._poll, daemon=True)
        self._thread.start()
        logger.info("FileWatcher started for %s", self._file_path)

    def stop(self) -> None:
        self._stop_event.set()
        if self._thread is not None:
            self._thread.join(timeout=3)
            self._thread = None
        logger.info("FileWatcher stopped")

    def _poll(self) -> None:
        while not self._stop_event.is_set():
            current_mtime: float = self._get_mtime()
            if current_mtime != self._last_mtime and self._last_mtime != 0.0:
                self._last_mtime = current_mtime
                logger.info("File changed: %s", self._file_path)
                self._callback()
            self._stop_event.wait(self._interval)

    def _get_mtime(self) -> float:
        try:
            return os.path.getmtime(self._file_path)
        except OSError:
            return 0.0
