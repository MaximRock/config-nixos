# FLUX — генерация изображений (ComfyUI)

Интерфейс: ComfyUI (GUI в браузере, порт 8188).
Backend: ROCm 7.1 (AMD RX 6600, 8GB VRAM).

## Быстрый старт (без правки системы)

```bash
nix run github:utensils/comfyui-nix
```

ComfyUI с ROCm + предустановленным **ComfyUI-GGUF** (нужен для GGUF-моделей).
GUI: http://127.0.0.1:8188. При первом запуске создаётся dataDir с подпапками
(`models/`, `custom_nodes/`, `output/`, `input/` и т.д.).

---

## 1. FLUX.2-klein-4B — СТАРТ ЗДЕСЬ

**Маленькая (7.8GB), Apache-2.0, дистиллированная (4 шага).**

```bash
hf download black-forest-labs/FLUX.2-klein-4B
```

Раскладка в dataDir ComfyUI:

| Файл | Откуда | Куда |
|---|---|---|
| `flux-2-klein-4b.safetensors` | 7.8GB | `models/unet` (или `models/diffusion_models`) |
| `vae/diffusion_pytorch_model.safetensors` | 0.2GB | `models/vae` |
| `text_encoder/model.safetensors` | 0.2GB | `models/clip` |

### Воркфлоу

```
Load Diffusion Model  →  CLIP (T5)  →  KSampler  →  VAEDecode  →  SaveImage
                        промпт ↑       4 шага
                                    CFG 1.0–1.5
```

- **Шагов**: 4 (дистиллят, больше не надо)
- **CFG**: 1.0–1.5 (выше = «deep-fried» артефакты)
- Сэмплер: `euler` или `dpmpp_2m`

---

## 2. FLUX.1-dev GGUF Q4_K_M

**Большая 12B (6.9GB GGUF), non-commercial, 20–50 шагов.**

```bash
hf download unsloth/FLUX.1-dev-GGUF flux1-dev-Q4_K_M.gguf
hf download city96/t5-v1_1-xxl-encoder-gguf
```

| Файл | Размер | Куда |
|---|---|---|
| `flux1-dev-Q4_K_M.gguf` | 6.9GB | `models/unet` |
| T5-XXL GGUF | ~2–5GB | `models/clip` (или `models/text_encoders`) |

### Воркфлоу

```
Unet Loader (GGUF)  →  DualCLIPLoader (GGUF)  →  KSampler  →  VAEDecode  →  SaveImage
                       промпт ↑                    20–50 шагов
                                                   CFG 3.5–5
```

- Узлы из **ComfyUI-GGUF** (встроен в utensils/comfyui-nix)
- **Шагов**: 20–50 (больше = детальнее, но медленнее)
- **CFG**: 3.5–5
- Сэмплер: `euler`, `dpmpp_2m`, `uni_pc`

---

## VRAM (RX 6600, 8GB)

| Модель | Вес | VRAM | Статус |
|---|---|---|---|
| Klein-4B (safetensors) | 7.8GB + T5 0.2GB | ~8.2GB | впритык, должен работать |
| FLUX.1-dev Q4 (GGUF) | 6.9GB + T5 GGUF ~2–5GB | ~9–12GB | **впритык**, при OOM → offload T5 на CPU |

При OOM: в ComfyUI-воркфлоу текст-энкодер (T5) можно offload'ить на CPU
через узел "Force/Set CLIP Device" (оставлять `cpu`, НЕ `cuda:0` при единственном GPU).

**Одновременно модели не загружаются** — загружай одну, используй, выгружай.

## Полезные ссылки

- [FLUX.2-klein Prompting Guide](https://docs.bfl.ai/guides/prompting_guide_flux2_klein)
- [ComfyUI-GGUF](https://github.com/city96/ComfyUI-GGUF)
- [utensils/comfyui-nix](https://github.com/NexRX/comfyui-nix-rocm) — ROCm + GGUF из коробки
