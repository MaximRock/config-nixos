# AGENTS.md — `.dotfiles`

## Structure

Single-host NixOS flake + home-manager. User `max`, system `x86_64-linux`, stateVersion `25.11`.

- `flake.nix` → `lib/default.nix` (wiring: `mkNixosConfiguration`, overlays, nvfConfig, specialArgs)
- `hosts/nixos/default.nix` → `configuration.nix` → hardware-config + NixOS modules (`modules/nixos/`)
- `modules/nixos/home-manager.nix` wires HM, importing `home/common/default.nix` which imports `modules/home/`
- `modules/home/editors/` — custom editor abstractions (`lib.nix` with `mkCodeOptions`/`mkCodeConfig`)

## Build & Deploy

```sh
sudo nixos-rebuild switch --flake .#nixos
```

Alias: `nrs` (defined in `modules/home/shell/zsh.nix`). Others: `nrd` (dry-build), `nrlg` (list-generations), `nix-test` (flake check + test).

## Key Modules

| Area | Module |
|---|---|
| Secrets | sops-nix (age), `/var/lib/sops-nix/key.txt`, `modules/nixos/sops/secrets.yaml` |
| Editors | VSCodium + nvf (Neovim). Workspace-nix module shares Nix workspace config |
| GPU/LLM | ROCm + llama.cpp (AMD RX 6600, gfx1032→gfx1030 via `HSA_OVERRIDE_GFX_VERSION=10.3.0`) |
| WM | Qtile + SDDM (sddm), lxqt-policykit agent |
| Notifications | dunst (Catppuccin Mocha colors) |
| Browser | yandex-browser (external flake) + Firefox (custom chrome/css) |
| LLM Agents | `llm-agents.opencode`, `llm-agents.qwen-code` |

## Conventions

- Chinese Nix substituter mirrors set in `modules/nixos/common/base.nix`
- Comments in Russian and English throughout
- `modules/home/` modules use `variables.basePathFilesDir` + `mkOutOfStoreSymlink` for config files
- `11/` directory is experimental/staging — not imported in production config
- `.aider*` files are aider artifacts, gitignored
- Dotfiles are sourced via HM symlinks to the repo path, not copied

## Skills

- `nixos-rules` — автоматически загружать при написании или ревью Nix-кода (NixOS-модули, flakes, nixpkgs-пакеты, общие Nix-выражения).

## Git Commit Workflow

Перед коммитом всегда показывать пользователю:
1. 📊 Анализ изменений (файлы + суть)
2. 💬 Предлагаемое сообщение коммита
3. 💻 Команду для выполнения
4. ⚠️ Запрос явного согласия

Коммитить только после подтверждения ("Да", "Ок", "Подтверждаю").

<!-- graft:start -->
## Graft — repo context graph

This repo is indexed in `graft/`: small linked markdown nodes that explain each
system and carry exact file:line spans, kept in sync with the code through git.

For ANY task here — understanding how something works, finding where code lives,
or scoping a change — get context from the graph before grepping or opening
source files. Re-ask freely (it's cheap) and reuse literal identifiers you
already have (symbol, error string, file name) as the query. New to this repo?
Run `graft map` first — a token-budgeted orientation (dir clusters, hubs,
hotspots), no LLM, no key.

- Run `graft ask "<your question>" --source` → ranked nodes with the relevant
  code spans inlined (each hit's ≤8-line crux by default; `--full` for whole
  definitions when the crux isn't enough). Match the tool to the task shape:
  for understanding or editing, the top node IS the answer — cite its
  `covers:` file:line spans and edit straight from `--source`. For
  exhaustive tasks ("every occurrence / every caller of this pattern"), ranked
  results are top-N, not complete — run `graft grep "<literal>"` instead
  (exhaustive over indexed files, grouped by enclosing symbol), falling back
  to raw `grep -rn` only for unindexed files.
- `graft skeleton <file>` → every definition's signature + span, ~10× cheaper
  than reading the file; use it to skim an API surface.
- `graft callers <symbol>` gives precomputed, exact edges — who calls this.
  Add `--direction out` for what it calls, or `--depth N` to walk
  transitively for the full blast radius. For structural questions, skip
  ranking and use this directly.
- Or browse: `graft/INDEX.md` lists every node; follow the links.
- Monorepos and folders of multiple repos rank fairly across sub-projects —
  hits carry `[scope/]` labels naming which one they're from. Narrow with
  `graft ask "<task>" --in <scope>/` once you know where you're working.

If a returned span is truncated ("+N more lines"), open the file at that exact
range before finalizing. Only open source files when a node genuinely lacks a
needed detail, and then at the exact file:line the node points to — never
re-read whole files.

After big code changes, refresh the graph with `graft build` (deterministic,
no API key, $0).
<!-- graft:end -->
