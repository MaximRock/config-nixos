# ComfyUI (ROCm)

Интерфейс: ComfyUI (GUI в браузере, порт 8188).
Backend: ROCm (AMD RX 6600, 8GB VRAM). Запуск ручной, без сервиса.

## Запуск

```bash
comfy-ui \
  --base-directory ~/.local/share/comfyui \
  --enable-manager \
  --listen 127.0.0.1 \
  --port 8188 \
  --use-pytorch-cross-attention \
  --lowvram            # или --novram для больших разрешений
```

GUI: http://127.0.0.1:8188

- `--use-pytorch-cross-attention` — **обязательно**: xformers-оператор (`ckF`) не собран для ROCm, без флага падает `No operator found for memory_efficient_attention_forward`.
- `--lowvram` — обычный режим для 9B: веса слоёв перекачиваются CPU↔GPU, умещается в 8GB VRAM. До ~1M px (768×768, 1024×768).
- `--novram` — полный оффлоадинг: каждый слой выгружается на CPU до шага. Почти не занимает VRAM → тянет большие разрешения (1344×768 и выше), где `--lowvram` падает `HIP out of memory`. Заметно медленнее.
- `HSA_OVERRIDE_GFX_VERSION` не нужен вручную — экспортируется глобально из `modules/nixos/llm/default.nix` (gfx1032→gfx1030).
- ComfyUI-GGUF встроен (нужен для GGUF-моделей — fp16 ~18GB не влезет в 8GB VRAM).

## Скачивание моделей

Все модели кладутся в `~/.local/share/comfyui/models/<тип>/`. Квантование `Q4_K_M` — баланс размер/качество. 9B — качество, 4B — вдвое легче и быстрее (влезает в 8GB VRAM спокойнее).

### FLUX.2 Klein 9B (полный, ~13 GB)

```bash
mkdir -p ~/.local/share/comfyui/models/{unet,text_encoders,vae}

# UNET (5.6GB)
curl -L -o ~/.local/share/comfyui/models/unet/flux-2-klein-base-9b-Q4_K_M.gguf \
  https://huggingface.co/unsloth/FLUX.2-klein-base-9B-GGUF/resolve/main/flux-2-klein-base-9b-Q4_K_M.gguf

# Text encoder: Qwen3-8B (6.8GB) — 9B требует 8B, НЕ 4B
curl -L -o ~/.local/share/comfyui/models/text_encoders/qwen_3_8b_fp4mixed.safetensors \
  https://huggingface.co/Comfy-Org/vae-text-encorder-for-flux-klein-9b/resolve/main/split_files/text_encoders/qwen_3_8b_fp4mixed.safetensors
```

### FLUX.2 Klein 4B (лёгкий, ~6 GB)

```bash
# UNET (2.6GB)
curl -L -o ~/.local/share/comfyui/models/unet/flux-2-klein-4b-Q4_K_M.gguf \
  https://huggingface.co/unsloth/FLUX.2-klein-4B-GGUF/resolve/main/flux-2-klein-4b-Q4_K_M.gguf

# Text encoder: Qwen3-4B (3.5GB) — 4B требует 4B-энкодер
curl -L -o ~/.local/share/comfyui/models/text_encoders/qwen_3_4b_fp4_mixed.safetensors \
  https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/text_encoders/qwen_3_4b_fp4_mixed.safetensors
```

### VAE (общий для 4B и 9B, 0.34 GB)

```bash
curl -L -o ~/.local/share/comfyui/models/vae/flux2-vae.safetensors \
  https://huggingface.co/Comfy-Org/flux2-dev/resolve/main/split_files/vae/flux2-vae.safetensors
```

## Проверено: FLUX.2 Klein (GGUF)

| Модель | UNET | Text encoder | VAE |
|---|---|---|---|
| **9B** | `unet/flux-2-klein-base-9b-Q4_K_M.gguf` (5.6GB) | `qwen_3_8b_fp4mixed.safetensors` | общий |
| **4B** | `unet/flux-2-klein-4b-Q4_K_M.gguf` (2.6GB) | `qwen_3_4b_fp4_mixed.safetensors` | общий |

Параметры воркфлоу: CLIPLoader `type=flux2`, CFGGuider cfg=5, Flux2Scheduler 20 steps, euler, SamplerCustomAdvanced.

Генерация 9B 768×768 (не 1024): 20 шагов ≈ 17 мин, ~37s/step. 1024→OOM, 768 влезает.

Известные проблемы:
- Klein 4B ↔ 9B используют разные энкодеры (Qwen3-4B / Qwen3-8B) — смешивание даёт `mat1 and mat2 shapes cannot be multiplied`.
- Модель под лицензией `flux-non-commercial-license`.