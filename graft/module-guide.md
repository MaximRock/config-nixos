---
name: Module Guide — Home Manager Module Patterns
slug: module-guide
type: concept
sources:
  - path: AI-MODULE-GUIDE.md
    hash: 56bfdedb422d5fee5b891f689657938dc288ec6a0ec52b868a163da5788f7a4a
sources_digest: 56bfdedb422d5fee5b891f689657938dc288ec6a0ec52b868a163da5788f7a4a
links:
  - slug: AGENTS.md
links_anchors:
  - slug: AGENTS.md
    text: AGENTS.md → Module Guide
links_back:
  - slug: AGENTS.md
generator:
  version: 1
covers: []
---

# Module Guide — Home Manager Module Patterns

Полный reference по написанию home-manager модулей для `.dotfiles` репозитория.

## 5 типов модулей

| Тип | Описание | Примеры |
|-----|----------|---------|
| **Simple** | `enable` + `home.packages` | deadbeef, strawberry, fuzzel, swaybg |
| **Config-symlink** | Enable + `mkOutOfStoreSymlink` | dsh, aider, niri, qtile, wezterm |
| **Activation** | Enable + `home.activation` | koda, graft, opencode |
| **Submodule** | Только `imports` | wayland, qtile, firefox, editors |
| **Complex** | Много опций + логика | waybar, yazi, niri, vscode |

## Ключевые конвенции

- **Путь опций:** всегда `modules.home.<category>.<name>.enable`
- **Симлинки:** `config.lib.file.mkOutOfStoreSymlink` — не копировать в store
- **Импорт:** `${variables.basePathFilesDir}/modules/home/...` через `home/common/*.nix`
- **`with lib;`** в начале config-блока даёт `mkEnableOption`, `mkIf`, `mkOption`

См. `AI-MODULE-GUIDE.md` для полной документации с шаблонами copy-paste.
