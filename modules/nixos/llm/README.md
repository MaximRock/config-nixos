# LLM — llama.cpp / llama-server

ROCm + llama.cpp для AMD RX 6600 (8GB VRAM, gfx1032 → gfx1030).
Модуль: `modules/nixos/llm/default.nix` (ROCm-окружение: драйвер, пакеты, /opt/rocm).

## Включение/выключение

Тумблер `modules.nixos.llm.enable` (по умолчанию `true`) в `modules/nixos/common/default.nix`:
при `false` конфигурация модуля отключается — ROCm и llama-cpp не ставятся в систему.

## Ручной запуск моделей

Порт 8080 совпадает с провайдером `llama.cpp` в opencode
(`modules/home/ai-agents/opencode/config/opencode.jsonc` и `project/opencode.json`).
Первый запуск каждой модели скачивает GGUF в `~/.cache/llama.cpp`.

### Qwen3-Coder-30B-A3B — основная (агентная, работает в opencode)

```bash
llama-server -hf unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:IQ4_XS --alias qwen3-coder-30b \
  --host 127.0.0.1 --port 8080 -c 24576 -np 1 --jinja
```

Полный CPU-offload (без `-ngl`): MoE A3B (~3.3B активных) на CPU i5-12600K ~8-12 tok/s,
RAM ~21GB (веса 16.4GB IQ4_XS + KV 3.4GB) — влезает в 32GB. Контекст 24576 полный.

### Qwen3.8-27B — плотная, качество кода (медленно на CPU)

```bash
llama-server -hf unsloth/Qwen3.8-27B-GGUF:UD-Q4_K_M --alias qwen3.8-27b \
  --host 127.0.0.1 --port 8080 -c 24576 -np 1 --jinja
```

> UD-Q4_K_M (16.5GB, imatrix) — лучший баланс качества и размера. Плотная 27B на CPU
> = **~1-2 tok/s** (в 6-8× медленнее 30B-A3B). RAM ~21.5GB — влезает, но
> **одновременно с 30B не поместится** (~43GB > 32GB). Для агентной работы 30B-A3B
> (8-12 tok/s) быстрее; эта модель — когда важнее качество кода, а не скорость.
> Официальная квантизация Qwen3.8 (не RP-мерж) — tool calling должен работать.

### gpt-oss-20b — только чат (НЕ работает в opencode)

```bash
llama-server -hf ggml-org/gpt-oss-20b-GGUF --alias gpt-oss-20b \
  --host 127.0.0.1 --port 8080 -c 24576 -fa 1 -np 1 --jinja
```

> gpt-oss-20b — плотная 21B, в opencode-агентах зацикливается (парсер каналов
> `<|channel|>` в llama.cpp b10273 не отделяет analysis от ответа → сырые токены в
> content). Для обычного чата через `/v1/chat/completions` работает. Без `-ngl`:
> 12.1GB MXFP4 не влезает в 8GB VRAM — выгрузка на CPU, ~5-8 tok/s.

> Примечание: Qwen3.5-9B убран — известный баг «infinite thinking loop» в llama.cpp
> (зацикливается внутри `<thinking>`, см. ggml-org/llama.cpp#20837). Если новая модель
> начнёт повторяться — добавить `--repeat-penalty 1.1 --mirostat 2` или
> `--chat-template-kwargs '{"enable_thinking": false}'`.

## Переключение

`Ctrl+C` → запустить команду другой модели (порт тот же).
Проверка: `curl http://127.0.0.1:8080/v1/models`.

## Флаги для этого железа

- `-c 24576` — безопасно для 8GB VRAM, т.к. GPU делит память с десктопом
- `-np 1` — 1 слот. Контекст делится на число слотов: `-np 4` при `-c 24576` даёт по 6144 токенов на слот (запросы агента >6K падают с «exceeds the available context size»). `-np 1` отдаёт весь контекст одному слоту, остальные запросы ждут в очереди
- `--jinja` — chat-шаблон с tool calling (нужно для opencode)

### О выгрузке в VRAM (`-ngl`)

Три большие модели НЕ влезают в 8GB VRAM частично: `-ngl 40` для 30B пытается выделить
~10.4GB, `-ngl 50` для gpt-oss ~10.9GB, `-ngl` для 27B ~10GB → всё `cudaMalloc
failed: out of memory`. Запускайте без `-ngl` (авто-подбор = выгрузка на CPU).
`-fa 1` / `-ctk q8_0 -ctv q8_0` / `--n-cpu-moe` из старых команд больше не нужны.

### Лимиты opencode

В `opencode.jsonc` и `project/opencode.json` у локальных моделей должно быть:

```jsonc
"limit": { "context": 24576, "input": 24576, "output": 8192 }
```

Без явного `input` opencode считает бюджет входа как `context - output` (8192) — этого
меньше системного промпта репозитория (8-12K токенов) → бесконечная компакция
 (`agent=compaction` в логах). `input: 24576` возвращает полный бюджет.