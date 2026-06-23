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
