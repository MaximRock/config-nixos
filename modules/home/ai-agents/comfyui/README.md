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
  --lowvram
```

GUI: http://127.0.0.1:8188

- `--use-pytorch-cross-attention` — **обязательно**: xformers-оператор (`ckF`) не собран для ROCm, без флага падает `No operator found for memory_efficient_attention_forward`.
- `--lowvram` — **обязательно** для 9B-моделей: слои перекачиваются CPU↔GPU, умещается в 8GB VRAM.
- `HSA_OVERRIDE_GFX_VERSION` не нужен вручную — экспортируется глобально из `modules/nixos/llm/default.nix` (gfx1032→gfx1030).
- ComfyUI-GGUF встроен (нужен для GGUF-моделей — fp16 ~18GB не влезет в 8GB VRAM).

## Проверено: FLUX.2 Klein Base 9B (GGUF)

Рабочие модели в `~/.local/share/comfyui/models/`:

| Файл | Куда | Замечания |
|---|---|---|
| `flux-2-klein-base-9b-Q4_K_M.gguf` | `unet/` | 5.6GB, arch="flux" |
| `qwen_3_8b_fp4mixed.safetensors` | `text_encoders/` | **8B** — Klein 9B требует Qwen3-8B, НЕ 4B |
| `flux2-vae.safetensors` | `vae/` | для FLUX.2 |

Параметры воркфлоу: CLIPLoader `type=flux2`, CFGGuider cfg=5, Flux2Scheduler 20 steps, euler, SamplerCustomAdvanced.

Генерация 768×768 (не 1024): 20 шагов ≈ 17 мин, ~37s/step. 1024→OOM, 768 влезает.

Известные проблемы:
- Klein 4B ↔ 9B используют разные энкодеры (Qwen3-4B / Qwen3-8B) — смешивание даёт `mat1 and mat2 shapes cannot be multiplied`.
- Модель под лицензией `flux-non-commercial-license`.