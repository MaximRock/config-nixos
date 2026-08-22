# graft — repo map

Small markdown nodes summarising this repo. `grep` any term, symbol, or
filename here, or run `graft ask "<task>"`. Each node carries prose plus exact
`file:line`; open a source file only to edit the named span.

The same graph is queryable as MCP tools (`graft_find_code`, `graft_find_all`,
`graft_trace_calls`, `graft_file_api`, `graft_repo_map`) where a host exposes them, and
as the `graft` CLI everywhere else. Edges — who calls what — live only in the
graph, not in these files: `graft callers <symbol>` is the only way to read them.

## Concepts

- [dynamic-configuration-management](dynamic-configuration-management.md) — Dynamic Configuration Management · modules/home/wm/qtile/config/config.py, modules/home/wm/qtile/config/modules/power_menu/main.py, modules/home/wm/qtile/config/modules/qtile_help/controller.py
- [error-handling-strategy](error-handling-strategy.md) — Error Handling Strategy · modules/home/wm/qtile/config/exceptions/__init__.py, modules/home/wm/qtile/config/exceptions/base_exceptions.py, modules/home/wm/qtile/config/exceptions/key_exceptions.py
- [file-watching](file-watching.md) — File Watching · modules/home/wm/qtile/config/modules/qtile_help/watcher/__init__.py, modules/home/wm/qtile/config/modules/qtile_help/watcher/file_watcher.py
- [hotkey-parsing](hotkey-parsing.md) — Hotkey Parsing · modules/home/wm/qtile/config/modules/qtile_help/parser/hotkey_parser.py, modules/home/wm/qtile/config/modules/qtile_help/parser/hotkey_repository.py
- [key-binding-management](key-binding-management.md) — Key Binding Management · modules/home/wm/qtile/config/settings/groups.py, modules/home/wm/qtile/config/settings/key_manager.py, modules/home/wm/qtile/config/settings/layouts.py
- [layout-management](layout-management.md) — Layout Management · modules/home/wm/qtile/config/settings/layouts.py
- [mcp-dotfiles-helper](mcp-dotfiles-helper.md) — MCP Dotfiles Helper · modules/home/ai-agents/nixos-helper/server.py, modules/home/ai-agents/nixos-helper/setup.py
- [module-guide](module-guide.md) — Module Guide — Home Manager Module Patterns · AI-MODULE-GUIDE.md
- [mouse-management](mouse-management.md) — Mouse Management · modules/home/wm/qtile/config/settings/mouse.py
- [power-menu-module](power-menu-module.md) — Power Menu Module · modules/home/wm/qtile/config/modules/power_menu/__init__.py, modules/home/wm/qtile/config/modules/power_menu/app.py, modules/home/wm/qtile/config/modules/power_menu/config_pm/config_button.py
- [qtile-configuration](qtile-configuration.md) — Qtile Configuration · modules/home/wm/qtile/config/config_qtile/__init__.py, modules/home/wm/qtile/config/config_qtile/config_groups.py, modules/home/wm/qtile/config/config_qtile/key_definitions.py, modules/home/wm/qtile/config/config_qtile/theme/__init__.py, modules/home/wm/qtile/config/config.py
- [qtile-configuration-management](qtile-configuration-management.md) — Qtile Configuration Management · modules/home/wm/qtile/config/settings/__init__.py, modules/home/wm/qtile/config/settings/autostart.py, modules/home/wm/qtile/config/settings/bar.py, modules/home/wm/qtile/config/settings/base_factory.py, modules/home/wm/qtile/config/settings/behavior.py, modules/home/wm/qtile/config/settings/floating.py, modules/home/wm/qtile/config/settings/groups.py, modules/home/wm/qtile/config/settings/key_manager.py, modules/home/wm/qtile/config/settings/layouts.py, modules/home/wm/qtile/config/settings/logger.py, modules/home/wm/qtile/config/settings/mouse.py, modules/home/wm/qtile/config/settings/path.py, modules/home/wm/qtile/config/settings/screens.py, modules/home/wm/qtile/config/settings/settings_loader.py, modules/home/wm/qtile/config/settings/theme_controller.py, modules/home/wm/qtile/config/settings/widgets.py
- [qtile-exception-handling](qtile-exception-handling.md) — Qtile Exception Handling · modules/home/wm/qtile/config/exceptions/__init__.py, modules/home/wm/qtile/config/exceptions/base_exceptions.py, modules/home/wm/qtile/config/exceptions/key_exceptions.py, modules/home/wm/qtile/config/exceptions/layout_exceptions.py, modules/home/wm/qtile/config/exceptions/theme_exceptions.py
- [qtile-help-module](qtile-help-module.md) — Qtile Help Module · modules/home/wm/qtile/config/modules/qtile_help/__init__.py, modules/home/wm/qtile/config/modules/qtile_help/app.py, modules/home/wm/qtile/config/modules/qtile_help/controller.py
- [screen-management](screen-management.md) — Screen Management · modules/home/wm/qtile/config/settings/screens.py
- [theme-management](theme-management.md) — Theme Management · modules/home/wm/qtile/config/settings/theme_controller.py

## Files

66 per-file wiring cards mirror the source tree under `graft/` (53 carry extracted symbols). They are deliberately not enumerated here —
`grep` a symbol or `find`/`ls` a filename under `graft/` to land on the card for that file.
