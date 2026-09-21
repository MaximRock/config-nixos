# LLM — llama.cpp / llama-server

ROCm + llama.cpp для AMD RX 6600 (8GB VRAM, gfx1032 → gfx1030).
Модуль: `modules/nixos/llm/default.nix` (ROCm-окружение: драйвер, пакеты, /opt/rocm).

## Включение/выключение

Тумблер `modules.nixos.llm.enable` (по умолчанию `true`) в `modules/nixos/common/default.nix`:
при `false` конфигурация модуля отключается — ROCm и llama-cpp не ставятся в систему.

> Статус: модуль **выключен**, локальные модели не тестируются. Ниже — итоги
> испытаний и кандидаты на следующий круг.

## Итоги испытаний (сентябрь 2026)

Тест: составить план установки приложения как NixOS-модуль в этот репозиторий + работа в opencode-агенте.

- **Ornith-1.5-9B** — самая продвинутая из локалок: влезает в 8GB VRAM целиком
  (Q4_K_M 5.78GB), ~30 tok/s, tool calling работает. План-тест не прошла, но лучше
  всех остальных. Удалена из конфигов, GGUF удалён с диска.
- **Qwen3-Coder-30B-A3B** — работает, но медленно на CPU (~8-12 tok/s, полный
  offload). Ускорение не доведено (план был: `-c 32768`, `-fa`, q8-KV, `-ngl 10–15`,
  треды P-ядер — с замерами). GGUF удалён с диска, конфиги не менялись.
- **gpt-oss-20b** — очень быстрая, но тест не прошла + зацикливается в opencode-агентах.
  Удалена из конфигов и с диска, секция ниже оставлена для истории.
- **DeepSeek-R1-Distill-Qwen-14B** — удалена везде (конфиги, README, диск 8.4G).
- Вывод: в агенте реально работает только связка «влезает в VRAM целиком +
  нормальный tool calling». Всё большое на CPU проиграло по скорости.

## Кандидаты на следующий круг (dense 7–14B целиком в VRAM + живой tool calling)

1. **Qwen3-8B** (Q6_K/Q8, ~5–8GB) — сильнейшая в классе 8B: код, инструменты,
   русский. Thinking гасить для агента. Проверить отсутствие бага «infinite
   thinking» (был у 3.5-серии, см. ниже).
2. **Gemma-3-12B-it** (QAT Q4, ~7–8GB) — топ-качество на размер, отличный русский.
   Риск: function calling через llama.cpp капризный — тест обязателен.
3. **Qwen2.5-Coder-14B** (Q4_0 ~7.9GB) — чистый кодер, зрелый tool calling.
   На пределе VRAM, только младшие кванты.
4. **MiMo-7B-RL** (Xiaomi) — reasoning-7B, влезет даже в Q8. Проверить лицензию и
   tool calling.
5. **Phi-4 14B** (Q4 ~8.5GB) — сильные рассуждения, чуть больше VRAM, вероятен
   частичный offload.

Запасной вариант: Vikhr/Saiga-тюны ради русского — но у файнтюнов часто сломан
tool calling, лотерея.

Параллельно (не модели): ornith как бейзлайн со speed-рецептом; speculative
decoding (`--model-draft` Qwen3-0.6B/1.7B + target); ik_llama.cpp для CPU;
тяжёлое планирование — в облако (llm-router уже настроен).

## Ручной запуск моделей

Порт 8080 совпадает с провайдером `llama.cpp` в opencode
(`modules/home/ai-agents/opencode/config/opencode.jsonc` и `project/opencode.json`).
Первый запуск каждой модели скачивает GGUF в `~/.cache/llama.cpp`.

### Qwen3-Coder-30B-A3B — тестировалась, медленная на CPU (GGUF удалён с диска)

```bash
llama-server -hf unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:IQ4_XS --alias qwen3-coder-30b \
  --host 127.0.0.1 --port 8080 -c 65536 -np 1 --jinja
```

Полный CPU-offload (без `-ngl`): MoE A3B (~3.3B активных) на CPU i5-12600K ~8-12 tok/s,
RAM ~21GB (веса 16.4GB IQ4_XS + KV) — влезает в 32GB. Медленно: ускорение не доведено
(план: `-c 32768`, `-fa`, q8-KV, `-ngl 10–15`, см. «Итоги испытаний»).

### Qwen3.8-27B — плотная, качество кода (медленно на CPU)

```bash
llama-server -hf unsloth/Qwen3.8-27B-GGUF:UD-Q4_K_M --alias qwen3.8-27b \
  --host 127.0.0.1 --port 8080 -c 24576 -np 1 --jinja
```

> UD-Q4_K_M (16.5GB, imatrix) — лучший баланс качества и размера. Плотная 27B на CPU
> = **~1-2 tok/s**. RAM ~21.5GB —
> влезает, но **одновременно с другой RAM-тяжёлой моделью не поместится** (>32GB).
> Для агентной работы эта модель — когда важнее качество кода, а не скорость.
> Официальная квантизация Qwen3.8 (не RP-мерж) — tool calling должен работать.

### gpt-oss-20b — только чат (НЕ работает в opencode)

```bash
llama-server -hf ggml-org/gpt-oss-20b-GGUF --alias gpt-oss-20b \
  --host 127.0.0.1 --port 8080 -c 65536 -fa 1 -np 1 --jinja
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

Модели НЕ влезают частично в 8GB VRAM → `cudaMalloc failed: out of
memory`. Запускайте их без `-ngl` (авто-подбор = выгрузка на CPU).

### Лимиты opencode

В `opencode.jsonc` и `project/opencode.json` у локальных моделей должно быть:

```jsonc
"limit": { "context": 24576, "input": 24576, "output": 8192 }
```

Без явного `input` opencode считает бюджет входа как `context - output` (8192) — этого
меньше системного промпта репозитория (8-12K токенов) → бесконечная компакция
 (`agent=compaction` в логах). `input: 24576` возвращает полный бюджет.