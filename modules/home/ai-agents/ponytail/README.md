# Ponytail — lazy senior dev mode

Ponytail — режим «ленивого сеньора» для AI-агентов. Перед написанием кода агент проходит лестницу:

```
1. Это вообще нужно?          → нет: skip (YAGNI)
2. Уже есть в этом коде?      → переиспользуй
3. Стандартная библиотека?    → используй
4. Нативная фича платформы?   → используй
5. Уже установленная зависимость? → используй
6. Можно одной строкой?       → одна строка
7. Только потом: минимум, который работает
```

Не жертвует никогда: валидацией на границах доверия, обработкой ошибок, безопасностью, доступностью.

## Статус в этом репо

Уже работает. `modules/home/ai-agents/ponytail` включён в `home/common/ai-agents.nix` (`ponytail.enable = true`) и:

- блок правил `<!-- ponytail:start -->` в `AGENTS.md` инжектится в любого агента на каждом промпте (OpenCode автозагружает `AGENTS.md`, работает даже без плагина)
- `home.activation` ставит npm-пакет `@dietrichgebert/ponytail` (skills + plugin) в `~/.npm-global`
- `~/.config/ponytail/config.json` — симлинк на `config.json` (default level)

## Как пользоваться

### Без плагина (уже активно)

Ничего делать не нужно — лестница применяется к каждому запросу.

Переключить уровень фразой в чате:
- `ponytail lite` / `ponytail full` / `ponytail ultra`
- `stop ponytail` / `normal mode` — выключить

### Slash-команды OpenCode (нужен плагин)

Сейчас плагин в `opencode.jsonc` не прописан, поэтому `/ponytail` не активен. Включить:

1. В `modules/home/ai-agents/opencode/config/opencode.jsonc` добавить:
   ```json
   { "plugin": ["@dietrichgebert/ponytail"] }
   ```
2. `nrs` (`sudo nixos-rebuild switch --flake .#nixos`)
3. В OpenCode:
   - `/ponytail lite|full|ultra|off` — переключить уровень
   - `/ponytail-review` — ревью на over-engineering (теги `delete:` / `stdlib:` / `native:` / `yagni:` / `shrink:` + `net: -N lines`)
   - `/ponytail-audit` — аудит всего репо на bloat
   - `/ponytail-debt` — собрать все `ponytail:` комментарии в долговую ведомость
   - `/ponytail-gain` — скорборд метрик (loc/tokens/cost/time)
   - `/ponytail-help` — шпаргалка

Без `/` можно и словами: «сделай ponytail-review файла X» / «review for over-engineering».

## Уровни

| Уровень | Что меняется |
|---|---|
| `lite` | Делай как просят, но назови ленивую альтернативу в одну строку. Выбирает юзер |
| `full` | Лестница применяется строго. Короткий diff, короткое объяснение. **Дефолт** |
| `ultra` | YAGNI-экстремист. Удаление до добавления. Одна строка + вызов всего остального в том же запросе |

Уровень по умолчанию — `"defaultMode": "full"` в `config.json`. Сменить: отредактировать `modules/home/ai-agents/ponytail/config.json` → `nrs`.

## Файлы модуля

| Файл | Назначение |
|---|---|
| `default.nix` | npm install + symlink конфига + sessionPath |
| `config.json` | `defaultMode` (по умолчанию `full`) |
| `README.md` | этот файл |

## Ссылки

- Upstream: https://github.com/DietrichGebert/ponytail
- Правила в этом репо: `AGENTS.md` → `<!-- ponytail:start -->`
- Локальный пакет: `~/.npm-global/lib/node_modules/@dietrichgebert/ponytail/` (README, skills, hooks)