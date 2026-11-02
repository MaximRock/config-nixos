## Design Skills

This block is managed by `opencode-skills-init`. Re-running the script replaces it; do not edit manually.

### Sources

- **Design kit** — 26 skills from `@KIT_DIR@/.claude/skills`. Kit root: `@KIT_DIR@`.
- **Craft skills** — 8 skills from `jakubkrehel/skills` in `.agents/skills`.
- **UI/UX Pro Max** — installed globally by Home Manager. Never copy it into this project.

### Paths in kit skills

Kit skills use `${CLAUDE_SKILL_DIR}` literally. The shell does not expand it. Before running a command from a kit skill, replace `${CLAUDE_SKILL_DIR}` with that skill's absolute directory, for example `@KIT_DIR@/.claude/skills/design-screen`. From there, `../../../` is the kit root.

### Hard rules

1. Read the kit's `AGENTS.md` before any design or code change. It is the doctrine.
2. Write the kit's Taste block into your reply before any markup, screen, or file.
3. Use `design-screen` for screens and `image-to-code` for screenshots or mockups. Do not freehand a screen from a screenshot.
4. Run the project gates from the kit's `AGENTS.md` Verification section against your own files, using the kit's absolute `scripts/` paths. Report the exact output, including `SKIPPED`. `accuracy_report.mjs` is the kit's self-test, not a project gate.
5. Use `design-doctrine` for tokens, typography, spacing, and color. Do not improvise values.
6. Follow the kit's non-negotiables: zero emoji, token by intent, one theme, eight states on every interactive element, one thing leads, mobile first, no native `<select>`, no one-sided colored border.
7. The 12 skills `brandkit`, `critique`, `gate`, `governance`, `grill-me`, `image-to-code`, `migrate-design-system`, `observe`, `prototype`, `redesign`, `scaffold-project`, and `ship` are user-invoked by convention. Do not load them unless the user asks; opencode only asks through `permission.skill`.
8. Kit skills load through `skills.paths` in `opencode.json`. The MCP server `ux-ui-gates` is optional; if it is unavailable, run the kit's `scripts/` commands directly.
9. Do not copy kit files into `.claude/`, `.agents/`, or any dot-directory unless the user asks. Reference the kit by its absolute path.
10. Keep project-specific `AGENTS.md` content outside the `design-skills` markers.

### Commands

- `/gate` — run the project design gates and report the exact output.
