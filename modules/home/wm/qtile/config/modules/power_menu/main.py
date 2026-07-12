#!/usr/bin/env python3

import sys
import os

# Добавляем путь к конфигурации Qtile в sys.path
# Добавляем путь к конфигурации Qtile только при запуске из исходников
if not os.environ.get("QTILE_POWER_MENU_INSTALLED"):
    qtile_config_path = os.path.expanduser("~/.config/qtile")
    if qtile_config_path not in sys.path:
        sys.path.insert(0, qtile_config_path)

from modules.power_menu.app import Application


def main():
    app = Application()
    app.mainloop()


if __name__ == "__main__":
    main()

# from modules.power_menu.app import Application


# def main():
#     app = Application()
#     app.mainloop()


# if __name__ == "__main__":
#     main()
