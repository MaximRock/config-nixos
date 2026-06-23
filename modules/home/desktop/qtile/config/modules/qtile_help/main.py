#!/usr/bin/env python3

from __future__ import annotations

import logging
import sys


def main() -> None:
    logging.basicConfig(
        level=logging.WARNING,
        format="%(levelname)s | %(name)s | %(message)s",
    )

    _ensure_qtile_config_path()

    from modules.qtile_help.app import Application
    from modules.qtile_help.controller import HelpController

    controller: HelpController = HelpController.create_default()
    app: Application = Application(controller=controller)
    app.mainloop()


def _ensure_qtile_config_path() -> None:
    from pathlib import Path

    candidate: Path = Path.home() / ".config" / "qtile"
    if candidate.exists() and str(candidate) not in sys.path:
        sys.path.insert(0, str(candidate))


if __name__ == "__main__":
    main()
