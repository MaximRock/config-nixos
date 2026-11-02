#!/usr/bin/env bash
set -euo pipefail

KIT_DIR="${UX_UI_KIT_DIR:-$HOME/projects/ux-ui-agent-skills}"
UUPM_DIR="${UI_UX_PRO_MAX_DIR:-$HOME/projects/ui-ux-pro-max-skill}"
SETUP_DIR="${OPENCODE_SKILLS_SETUP_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
TARGET_DIR="$PWD"
DRY_RUN=0
UPDATE=0
UPDATE_OK=0
BROWSER_PATH=""

JAKUB_SKILLS=(
  better-accessibility
  better-colors
  better-interface
  better-layout
  better-typography
  better-ui
  better-writing
  interface-review
)

ASK_JSON='{"*":"allow","brandkit":"ask","critique":"ask","gate":"ask","governance":"ask","grill-me":"ask","image-to-code":"ask","migrate-design-system":"ask","observe":"ask","prototype":"ask","redesign":"ask","scaffold-project":"ask","ship":"ask"}'

TEMP_FILES=()
cleanup() {
  if [ "${#TEMP_FILES[@]}" -gt 0 ]; then
    rm -f "${TEMP_FILES[@]}"
  fi
}
trap cleanup EXIT

usage() {
  cat <<'EOF'
Использование: opencode-skills-init [опции]

Подключает к проекту набор дизайнерских навыков:
  - 8 навыков jakubkrehel/skills в .agents/skills
  - 26 навыков ux-ui-agent-skills и MCP-сервер ux-ui-gates
  - английский блок доктрины в AGENTS.md
  - команду /gate

Опции:
  --dir <path>          каталог проекта (по умолчанию текущий)
  --dry-run             показать изменения, ничего не записывая
  --update              обновить навыки Jakub и проверить обновления кита
  --browser-path <dir>  каталог браузеров Playwright
  -h, --help            показать эту справку
EOF
}

die() {
  printf 'ошибка: %s\n' "$*" >&2
  exit 1
}

info() {
  printf '%s\n' "$*"
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dir)
      [ "$#" -ge 2 ] || die "--dir требует путь"
      TARGET_DIR="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --update)
      UPDATE=1
      shift
      ;;
    --browser-path)
      [ "$#" -ge 2 ] || die "--browser-path требует путь"
      BROWSER_PATH="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "неизвестная опция: $1"
      ;;
  esac
done

TARGET_DIR="$(cd "$TARGET_DIR" && pwd)" || die "не удалось перейти в $TARGET_DIR"
[ -d "$TARGET_DIR" ] || die "каталог не найден: $TARGET_DIR"
[ -w "$TARGET_DIR" ] || die "нет прав на запись в $TARGET_DIR"

[ -d "$KIT_DIR" ] || die "кит не найден: $KIT_DIR (задай UX_UI_KIT_DIR)"
[ -f "$KIT_DIR/.claude/skills/design-doctrine/SKILL.md" ] || die "кит неполный: $KIT_DIR/.claude/skills"
[ -f "$KIT_DIR/mcp/server.mjs" ] || die "MCP-сервер не найден: $KIT_DIR/mcp/server.mjs"
[ -f "$SETUP_DIR/AGENTS.block.md" ] || die "нет шаблона: $SETUP_DIR/AGENTS.block.md"

for cmd in node npx jq python3 git opencode sed grep timeout mktemp; do
  command -v "$cmd" >/dev/null 2>&1 || die "не найдена команда: $cmd"
done

UUPM_CONFIG=""
if [ -d "$UUPM_DIR" ]; then
  UUPM_CONFIG="$UUPM_DIR"
fi

info "Проект: $TARGET_DIR"
info "Кит:     $KIT_DIR"

if [ ! -f "$HOME/.config/opencode/skills/ui-ux-pro-max/SKILL.md" ]; then
  info "Предупреждение: глобальный навык ui-ux-pro-max не найден. Выполни nrs."
fi

if [ "$UPDATE" -eq 1 ]; then
  if [ "$DRY_RUN" -eq 1 ]; then
    info "Будет выполнено обновление навыков Jakub и проверка обновлений кита."
  else
    info "Обновляю навыки Jakub..."
    if (cd "$TARGET_DIR" && npx -y skills update -p -y); then
      UPDATE_OK=1
    else
      info "Предупреждение: не удалось обновить навыки Jakub."
    fi
    if git -C "$KIT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      if git -C "$KIT_DIR" fetch origin; then
        info "Новые коммиты в origin/main (кит не изменяется):"
        git -C "$KIT_DIR" log --oneline HEAD..origin/main | head -20 || true
        info "Обновление кита не применялось: ветка nixos локальная, смержи вручную."
      else
        info "Предупреждение: не удалось выполнить git fetch для кита."
      fi
    else
      info "Предупреждение: $KIT_DIR не git-репозиторий, проверка обновлений пропущена."
    fi
  fi
fi

install_jakub() {
  local missing=0
  local skill
  for skill in "${JAKUB_SKILLS[@]}"; do
    if [ ! -f "$TARGET_DIR/.agents/skills/$skill/SKILL.md" ]; then
      missing=1
      break
    fi
  done
  if [ "$missing" -eq 0 ] && { [ "$UPDATE" -eq 0 ] || [ "$UPDATE_OK" -eq 1 ]; }; then
    info "Навыки Jakub уже установлены; пропускаю."
    return
  fi
  if [ "$DRY_RUN" -eq 1 ]; then
    info "Будут установлены навыки Jakub: ${JAKUB_SKILLS[*]}"
    return
  fi
  info "Устанавливаю навыки Jakub..."
  local args=()
  for skill in "${JAKUB_SKILLS[@]}"; do
    args+=(--skill "$skill")
  done
  (cd "$TARGET_DIR" && npx -y skills add jakubkrehel/skills -a opencode --copy -y "${args[@]}")
}
install_jakub

if [ -z "$BROWSER_PATH" ] && [ -n "${PLAYWRIGHT_BROWSERS_PATH:-}" ]; then
  BROWSER_PATH="$PLAYWRIGHT_BROWSERS_PATH"
fi

if [ -z "$BROWSER_PATH" ] && [ "$DRY_RUN" -eq 0 ] && command -v nix >/dev/null 2>&1 && [ -f "$KIT_DIR/flake.nix" ]; then
  info "Определяю браузеры Playwright из dev shell кита..."
  BROWSER_PATH="$(timeout 180 nix develop "$KIT_DIR" --command printenv PLAYWRIGHT_BROWSERS_PATH 2>/dev/null | tail -n 1 || true)"
fi

if [ -z "$BROWSER_PATH" ] && [ -d "$HOME/.cache/ms-playwright" ]; then
  BROWSER_PATH="$HOME/.cache/ms-playwright"
fi

if [ -n "$BROWSER_PATH" ] && [ ! -d "$BROWSER_PATH" ]; then
  info "Предупреждение: каталог браузеров Playwright не существует: $BROWSER_PATH"
fi

CONFIG="$TARGET_DIR/opencode.json"

JQ_PROGRAM=$(cat <<'JQ'
  ($kit + "/.claude/skills") as $kitdir
  | .["$schema"] //= "https://opencode.ai/config.json"
  | (if (.skills | type) == "array" then
       .skills = { paths: ((.skills + [$kitdir]) | unique) }
     elif (.skills | type) == "object" then
       .skills = (.skills | .paths = (((if (.paths | type) == "array" then .paths else [] end) + [$kitdir]) | unique))
     else
       .skills = { paths: [$kitdir] }
     end)
  | .mcp = (if (.mcp | type) == "object" then .mcp else {} end)
  | .mcp["ux-ui-gates"] = ({
      type: "local",
      command: ["node", ($kit + "/mcp/server.mjs")],
      enabled: true,
      timeout: 600000
    } + (if $pw != "" then { environment: { PLAYWRIGHT_BROWSERS_PATH: $pw } } else {} end))
  | .permission = (if (.permission | type) == "object" then .permission else {} end)
  | .permission.skill = (if (.permission.skill | type) == "object" then .permission.skill else {} end)
  | .permission.skill += $ask
  | .permission.external_directory = (if (.permission.external_directory | type) == "object" then .permission.external_directory else {} end)
  | .permission.external_directory += ({ ($kit + "/**"): "allow" } + (if $uupm != "" then { ($uupm + "/**"): "allow" } else {} end))
JQ
)

write_merged() {
  if [ -f "$CONFIG" ]; then
    jq --arg kit "$KIT_DIR" --arg uupm "$UUPM_CONFIG" --arg pw "$BROWSER_PATH" --argjson ask "$ASK_JSON" "$JQ_PROGRAM" "$CONFIG"
  else
    printf '{}' | jq --arg kit "$KIT_DIR" --arg uupm "$UUPM_CONFIG" --arg pw "$BROWSER_PATH" --argjson ask "$ASK_JSON" "$JQ_PROGRAM"
  fi
}

if [ "$DRY_RUN" -eq 1 ]; then
  info "opencode.json будет таким:"
  write_merged
else
  if [ -f "$CONFIG" ]; then
    CONFIG_MODE="$(stat -c '%a' "$CONFIG")"
    BACKUP="$CONFIG.bak.$(date +%Y%m%d-%H%M%S)"
    cp -p "$CONFIG" "$BACKUP"
    info "Бэкап: $BACKUP"
  else
    CONFIG_MODE="644"
  fi
  TMP_CONFIG="$(mktemp "$TARGET_DIR/.opencode.json.XXXXXX")"
  TEMP_FILES+=("$TMP_CONFIG")
  write_merged > "$TMP_CONFIG"
  jq empty "$TMP_CONFIG"
  chmod "$CONFIG_MODE" "$TMP_CONFIG"
  mv "$TMP_CONFIG" "$CONFIG"
  info "Обновлён $CONFIG"
fi

AGENTS_FILE="$TARGET_DIR/AGENTS.md"

if [ "$DRY_RUN" -eq 1 ]; then
  info "AGENTS.md получит управляемый блок design-skills."
else
  BLOCK_TMP="$(mktemp)"
  TEMP_FILES+=("$BLOCK_TMP")
  sed "s|@KIT_DIR@|$KIT_DIR|g" "$SETUP_DIR/AGENTS.block.md" > "$BLOCK_TMP"
  python3 - "$AGENTS_FILE" "$BLOCK_TMP" <<'PY'
import pathlib
import re
import sys

agents = pathlib.Path(sys.argv[1])
block = pathlib.Path(sys.argv[2]).read_text().strip()
start = "<!-- design-skills:start -->"
end = "<!-- design-skills:end -->"
managed = f"{start}\n{block}\n{end}\n"
text = agents.read_text() if agents.exists() else ""
if start in text and end in text:
    text = re.sub(re.escape(start) + r".*?" + re.escape(end) + r"\n?", lambda _: managed, text, flags=re.S)
else:
    text = (text.rstrip() + "\n\n" if text.strip() else "") + managed
agents.write_text(text)
PY
  info "Обновлён $AGENTS_FILE"
fi

GATE_CMD="$TARGET_DIR/.opencode/commands/gate.md"

if [ -f "$GATE_CMD" ]; then
  info "Команда /gate уже существует; пропускаю."
elif [ "$DRY_RUN" -eq 1 ]; then
  info "Будет создана $GATE_CMD"
else
  mkdir -p "$(dirname "$GATE_CMD")"
  cat > "$GATE_CMD" <<'MD'
---
description: Run the project design gates and report the exact output
---

Load the `gate` skill. Replace `${CLAUDE_SKILL_DIR}` with the skill's absolute directory. Run the project gates against this project's files, not the kit's tests or examples; `accuracy_report.mjs` is the kit's self-test. Report the exact output, no paraphrase.
MD
  info "Создана $GATE_CMD"
fi

if [ "$DRY_RUN" -eq 1 ]; then
  info "Dry-run завершён; файлы не изменялись."
  exit 0
fi

info "Проверяю результат..."

jq empty "$CONFIG"

MCP_LOG="$(mktemp)"
TEMP_FILES+=("$MCP_LOG")
if (cd "$KIT_DIR" && node mcp/server.mjs --selftest) >"$MCP_LOG" 2>&1; then
  info "MCP-сервер: PASS ($(tail -n 1 "$MCP_LOG"))"
else
  info "MCP-сервер: FAIL"
  cat "$MCP_LOG"
  die "selftest MCP-сервера не прошёл"
fi

if ! (cd "$TARGET_DIR" && opencode debug config >/dev/null 2>&1); then
  die "opencode не принял итоговый конфиг; проверь: cd $TARGET_DIR && opencode debug config"
fi

SKILLS_JSON="$(mktemp)"
TEMP_FILES+=("$SKILLS_JSON")
if ! (cd "$TARGET_DIR" && opencode debug skill) >"$SKILLS_JSON" 2>/dev/null; then
  die "opencode debug skill завершился ошибкой"
fi
NAMES="$(jq -r '.[].name' "$SKILLS_JSON")" || die "не удалось разобрать opencode debug skill"

for expected in design-screen design-doctrine better-ui interface-review; do
  if ! printf '%s\n' "$NAMES" | grep -qx "$expected"; then
    die "навык не загрузился: $expected"
  fi
done

if ! printf '%s\n' "$NAMES" | grep -qx "ui-ux-pro-max"; then
  info "Предупреждение: глобальный ui-ux-pro-max не загружен. Выполни nrs."
fi

info "Загружено навыков: $(printf '%s\n' "$NAMES" | wc -l)"
info ""
info "Готово. Перезапусти opencode, чтобы конфиг применился."
info "  проект: $TARGET_DIR"
info "  кит:    $KIT_DIR"
info "  браузеры: ${BROWSER_PATH:-не заданы}"
