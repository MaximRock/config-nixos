from __future__ import annotations

import logging

import customtkinter as ctk

from modules.qtile_help.colors import THEMES, ThemeColors
from modules.qtile_help.constants import (
    SEPARATOR_COLUMN_WIDTH,
    WINDOW_GEOMETRY,
    WINDOW_RESIZABLE,
    WINDOW_TITLE,
    _WINDOW_HEIGHT,
    _WINDOW_WIDTH,
)
from modules.qtile_help.controller import HelpController
from modules.qtile_help.parser.hotkey_repository import HotkeyEntry

logger: logging.Logger = logging.getLogger("qtile-help.app")


class Application(ctk.CTk):
    def __init__(self, controller: HelpController) -> None:
        super().__init__()
        self.overrideredirect(True)
        self._controller: HelpController = controller
        self._controller.set_on_update(self._on_data_update)

        self._theme_name: str = self._resolve_theme()
        self._colors: ThemeColors = THEMES.get(self._theme_name, THEMES["catppuccin"])

        self._setup_window()
        self._create_widgets()

        self._entries: list[HotkeyEntry] = self._controller.load()
        self._render_entries(self._entries)

        self._make_floating()

        self._controller.start_watching()

    def _resolve_theme(self) -> str:
        try:
            from constants import THEME_COLOR

            return THEME_COLOR
        except ImportError:
            return "catppuccin"

    def _setup_window(self) -> None:
        self.title(WINDOW_TITLE)
        self.resizable(*WINDOW_RESIZABLE)
        self.configure(fg_color=self._colors["background"])
        self.protocol("WM_DELETE_WINDOW", self._safe_destroy)

        screen_width: int = self.winfo_screenwidth()
        screen_height: int = self.winfo_screenheight()
        x: int = (screen_width - _WINDOW_WIDTH) // 2
        y: int = (screen_height - _WINDOW_HEIGHT) // 2
        self.geometry(f"{_WINDOW_WIDTH}x{_WINDOW_HEIGHT}+{x}+{y}")

        self._border_frame: ctk.CTkFrame = ctk.CTkFrame(
            master=self,
            fg_color=self._colors["background"],
            border_color=self._colors["border"],
            border_width=2,
        )
        self._border_frame.pack(fill="both", expand=True, padx=3, pady=3)

    def _make_floating(self) -> None:
        self.bind_all("<Escape>", lambda _: self._safe_destroy())
        self.bind_all("<Button-4>", self._on_global_scroll_up, add="+")
        self.bind_all("<Button-5>", self._on_global_scroll_down, add="+")
        self.bind_all("j", self._on_scroll_down_key, add="+")
        self.bind_all("k", self._on_scroll_up_key, add="+")
        self.attributes("-topmost", True)
        self.focus_set()
        self.focus_force()
        self.grab_set_global()
        self.bind("<Enter>", self._on_enter)
        self.bind("<Leave>", self._on_leave_window)
        self.bind("<FocusIn>", self._on_focus_in)
        self.bind("<FocusOut>", self._on_focus_out)
        self._set_active(True)

    def _bind_hover(self, widget: ctk.CTkBaseClass) -> None:
        widget.bind("<Enter>", self._on_enter, add="+")
        widget.bind("<Leave>", self._on_leave_window, add="+")

    def _on_leave_window(self, _event: object) -> None:
        self.after(50, self._check_pointer)

    def _check_pointer(self) -> None:
        try:
            x, y = self.winfo_pointerxy()
            widget = self.winfo_containing(x, y)
            if widget is None or widget.winfo_toplevel() != self:
                self._set_active(False)
        except Exception:
            self._set_active(False)

    def _on_enter(self, _event: object) -> None:
        self.focus_set()
        self.focus_force()
        self._set_active(True)

    def _on_focus_in(self, _event: object) -> None:
        self._set_active(True)

    def _on_focus_out(self, _event: object) -> None:
        self._set_active(False)

    def _set_active(self, active: bool) -> None:
        self.configure(fg_color=self._colors["hover"] if active else self._colors["background"])
        self._border_frame.configure(
            border_color=self._colors["accent"] if active else self._colors["border"],
        )

    def _create_widgets(self) -> None:
        self._search_var: ctk.StringVar = ctk.StringVar()
        self._search_var.trace_add("write", self._on_search)

        self._search_entry: ctk.CTkEntry = ctk.CTkEntry(
            master=self._border_frame,
            placeholder_text="Поиск...",
            textvariable=self._search_var,
            fg_color=self._colors["surface"],
            text_color=self._colors["foreground"],
            border_color=self._colors["border"],
            placeholder_text_color=self._colors["border"],
        )
        self._search_entry.pack(fill="x", padx=10, pady=(10, 5))
        self._bind_hover(self._search_entry)

        self._column_width: int = 280

        header_frame: ctk.CTkFrame = ctk.CTkFrame(
            master=self._border_frame,
            fg_color="transparent",
        )
        header_frame.pack(fill="x", padx=10, pady=(0, 5))
        self._bind_hover(header_frame)
        header_frame.grid_columnconfigure(0, minsize=self._column_width, weight=0)
        header_frame.grid_columnconfigure(1, weight=1)

        hotkey_header: ctk.CTkLabel = ctk.CTkLabel(
            master=header_frame,
            text="Hotkey",
            font=ctk.CTkFont(size=14, weight="bold"),
            text_color=self._colors["accent"],
            anchor="w",
        )
        hotkey_header.grid(row=0, column=0, sticky="w", padx=(15, 0))
        self._bind_hover(hotkey_header)

        desc_header: ctk.CTkLabel = ctk.CTkLabel(
            master=header_frame,
            text="Description",
            font=ctk.CTkFont(size=14, weight="bold"),
            text_color=self._colors["accent"],
            anchor="w",
        )
        desc_header.grid(row=0, column=1, sticky="w", padx=(25, 0))
        self._bind_hover(desc_header)

        self._scroll_frame: ctk.CTkScrollableFrame = ctk.CTkScrollableFrame(
            master=self._border_frame,
            fg_color=self._colors["surface"],
            border_color=self._colors["border"],
            border_width=1,
        )
        self._scroll_frame.pack(fill="both", expand=True, padx=10, pady=(0, 10))
        self._bind_hover(self._scroll_frame)

    def _render_entries(self, entries: list[HotkeyEntry]) -> None:
        for widget in self._scroll_frame.winfo_children():
            widget.destroy()

        if not entries:
            empty_label: ctk.CTkLabel = ctk.CTkLabel(
                master=self._scroll_frame,
                text="Нет горячих клавиш",
                text_color=self._colors["border"],
            )
            empty_label.pack(pady=20)
            return

        content: ctk.CTkFrame = ctk.CTkFrame(
            master=self._scroll_frame,
            fg_color="transparent",
        )
        content.pack(fill="x", padx=5)

        content.grid_columnconfigure(0, minsize=self._column_width, weight=0)
        content.grid_columnconfigure(1, weight=0)
        content.grid_columnconfigure(2, weight=1)

        total_rows: int = len(entries) * 2

        vertical_sep: ctk.CTkFrame = ctk.CTkFrame(
            master=content,
            width=SEPARATOR_COLUMN_WIDTH,
            fg_color=self._colors["separator"],
        )
        vertical_sep.grid(
            row=0, column=1,
            rowspan=total_rows,
            sticky="ns",
            padx=4,
        )

        for i, entry in enumerate(entries):
            combo_label: ctk.CTkLabel = ctk.CTkLabel(
                master=content,
                text=entry.combo,
                font=ctk.CTkFont(size=12, weight="bold"),
                text_color=self._colors["accent"],
                anchor="w",
            )
            combo_label.grid(row=i * 2, column=0, sticky="w", padx=5, pady=0)

            desc_label: ctk.CTkLabel = ctk.CTkLabel(
                master=content,
                text=entry.description,
                font=ctk.CTkFont(size=12),
                text_color=self._colors["foreground"],
                anchor="w",
            )
            desc_label.grid(row=i * 2, column=2, sticky="w", padx=5, pady=0)

            separator: ctk.CTkFrame = ctk.CTkFrame(
                master=content,
                height=1,
                fg_color=self._colors["border"],
            )
            separator.grid(
                row=i * 2 + 1, column=0, columnspan=3, sticky="ew",
            )

        vertical_sep.tkraise()

    def _on_global_scroll_up(self, event: object) -> None:
        if self._is_scroll_event_for_us(event):
            self._scroll_frame._parent_canvas.yview_scroll(-3, "units")

    def _on_global_scroll_down(self, event: object) -> None:
        if self._is_scroll_event_for_us(event):
            self._scroll_frame._parent_canvas.yview_scroll(3, "units")

    def _on_scroll_up_key(self, event: object) -> None:
        if self._is_search_focused(event):
            return
        self._scroll_frame._parent_canvas.yview_scroll(-3, "units")

    def _on_scroll_down_key(self, event: object) -> None:
        if self._is_search_focused(event):
            return
        self._scroll_frame._parent_canvas.yview_scroll(3, "units")

    def _is_search_focused(self, _event: object) -> bool:
        try:
            return self.focus_get() == self._search_entry
        except Exception:
            return False

    def _is_scroll_event_for_us(self, event: object) -> bool:
        try:
            widget = event.widget
            while widget is not None:
                if widget == self._scroll_frame._parent_canvas:
                    return True
                widget = widget.master
            return False
        except AttributeError:
            return False

    def _on_search(self, *_args: object) -> None:
        query: str = self._search_var.get()
        if not query:
            self._render_entries(self._entries)
            return
        results: list[HotkeyEntry] = self._controller.search(query)
        self._render_entries(results)

    def _on_data_update(self, entries: list[HotkeyEntry]) -> None:
        self._entries = entries
        self._on_search()

    def _safe_destroy(self) -> None:
        self._controller.stop_watching()
        self.unbind_all("<Button-4>")
        self.unbind_all("<Button-5>")
        self.unbind_all("j")
        self.unbind_all("k")
        self.unbind_all("<Escape>")
        try:
            self.grab_release()
        except RuntimeError:
            ...
        self.destroy()

    def mainloop(self, *args: object, **kwargs: object) -> None:
        try:
            super().mainloop(*args, **kwargs)
        except KeyboardInterrupt:
            self._safe_destroy()
