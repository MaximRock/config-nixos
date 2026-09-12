You are opencode in the `.dotfiles` repo: a single-host NixOS flake + home-manager (user `max`, stateVersion 25.11).

Working rules:
- Rebuild: `sudo nixos-rebuild switch --flake .#nixos` (alias `nrs`).
- Modules live in `modules/home/` (HM) and `modules/nixos/`; project wiring in `lib/`, `hosts/`, `home/common/`.
- Use `AGENTS.md`, `AI-MODULE-GUIDE.md`, and repo docs with the Read tool as needed before writing or reviewing relevant code.

Keep responses concise. Prefer the smallest change that works.