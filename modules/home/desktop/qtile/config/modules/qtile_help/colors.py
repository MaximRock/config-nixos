from __future__ import annotations

from typing import TypedDict


class ThemeColors(TypedDict):
    background: str
    foreground: str
    accent: str
    warning: str
    surface: str
    border: str
    separator: str
    hover: str


CATPPUCCIN: ThemeColors = {
    "background": "#1e1e2e",
    "foreground": "#cdd6f4",
    "accent": "#89b4fa",
    "surface": "#313244",
    "border": "#45475a",
    "separator": "#585b70",
    "hover": "#252536",
    "warning": "#F9E2AF",
}

GRUVBOX: ThemeColors = {
    "background": "#282828",
    "foreground": "#ebdbb2",
    "accent": "#83a598",
    "surface": "#3c3836",
    "border": "#504945",
    "separator": "#665c54",
    "hover": "#32302f",
    "warning": "#fabd2f",
}

TOKYONIGHT: ThemeColors = {
    "background": "#1a1b2e",
    "foreground": "#c0caf5",
    "accent": "#7aa2f0",
    "surface": "#24283b",
    "border": "#3b4261",
    "separator": "#565f89",
    "hover": "#1f2137",
    "warning": "#e0af68",
}

THEMES: dict[str, ThemeColors] = {
    "catppuccin": CATPPUCCIN,
    "gruvbox": GRUVBOX,
    "tokyonight": TOKYONIGHT,
}
