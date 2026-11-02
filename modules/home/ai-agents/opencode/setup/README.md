# opencode-skills-init

Настройка дизайнерских навыков для проекта: 8 навыков `jakubkrehel/skills`, 26 навыков кита `ux-ui-agent-skills`, MCP-сервер `ux-ui-gates`, блок доктрины в `AGENTS.md` и команда `/gate`.

## Быстрый запуск без пересборки

Из любого каталога:

```bash
bash ~/.dotfiles/modules/home/ai-agents/opencode/setup/init.sh --dir ~/projects/bakery-shop --dry-run
bash ~/.dotfiles/modules/home/ai-agents/opencode/setup/init.sh --dir ~/projects/bakery-shop
```

`--dry-run` печатает будущий `opencode.json` и список действий, но ничего не пишет.

## Запуск после nrs

Один раз пересобери dotfiles:

```bash
nrs
```

После этого команда доступна в `PATH`:

```bash
opencode-skills-init --dir ~/projects/bakery-shop
```

## Флаги

| Флаг | Действие |
|---|---|
| `--dir <path>` | Каталог проекта. По умолчанию текущий. |
| `--dry-run` | Показать изменения, ничего не записывая. |
| `--update` | Обновить навыки Jakub и сделать `git fetch` кита. Кит не мержится. |
| `--browser-path <path>` | Каталог браузеров Playwright для MCP. |
| `-h`, `--help` | Справка. |

## Что появляется в проекте

- `.agents/skills/` и `skills-lock.json` — 8 навыков Jakub.
- `opencode.json` — `skills.paths` на `~/projects/ux-ui-agent-skills/.claude/skills`, MCP `ux-ui-gates`, права на внешние каталоги и `permission.skill`.
- `AGENTS.md` — управляемый блок между `<!-- design-skills:start -->` и `<!-- design-skills:end -->`.
- `.opencode/commands/gate.md` — команда `/gate`.

Существующий `opencode.json` сохраняется как `opencode.json.bak.<timestamp>`. Скрипт обновляет управляемые ключи (`skills.paths`, `mcp.ux-ui-gates`, `permission`), остальные ключи не трогает.

## Переменные окружения

- `UX_UI_KIT_DIR` — путь к киту. По умолчанию `~/projects/ux-ui-agent-skills`.
- `UI_UX_PRO_MAX_DIR` — путь к UI/UX Pro Max. По умолчанию `~/projects/ui-ux-pro-max-skill`.
- `PLAYWRIGHT_BROWSERS_PATH` — используется, если не передан `--browser-path`.

## Важно

- UI/UX Pro Max уже установлен глобально через Home Manager. В проект его копировать не нужно.
- Ветка `nixos` кита локальная. `--update` только делает `git fetch` и показывает новые коммиты; автоматического мержа нет.
- Без `--update` скрипт ничего не обновляет: только ставит отсутствующие навыки.
- MCP-сервер и браузерные гейты требуют `node` и браузеры Playwright. Путь к ним скрипт определяет сам.
- opencode не раскрывает `${CLAUDE_SKILL_DIR}`. Управляемый блок в `AGENTS.md` объясняет агенту, что вместо него нужно подставлять абсолютный путь каталога навыка.
- После настройки перезапусти opencode, чтобы он перечитал конфиг.

## Откат

```bash
cd ~/projects/bakery-shop
rm -rf .agents/skills skills-lock.json .opencode/commands/gate.md
mv opencode.json.bak.* opencode.json
```

Блок `design-skills` в `AGENTS.md` удаляется вручную вместе с маркерами.
