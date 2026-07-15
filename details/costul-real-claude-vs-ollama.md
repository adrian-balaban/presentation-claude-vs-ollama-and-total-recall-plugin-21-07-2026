# Costul real: Claude API vs Ollama

> 💡 **WOW:** un 'agentic developer' ce lucreaza intens arde ~$400/lună pe API — un RTX 4090 de $2.000 se amortizează în ~5 luni. Dar dacă ești utilizator light ($30/lună), amortizarea durează ani.

> 📊 **WOW (datat):** 1 iunie 2026 — Copilot a mutat Claude Opus de la **3× la 27×** multiplicator și Sonnet de la **1× la 9×**; tier-ul gratuit GPT-4o a dispărut. „Era AI-ului cloud ieftin s-a terminat" (Mozilla.ai, _AI Got Expensive. Now What?_, mai 2026). Ăsta e forcing function-ul întregii discuții cloud-vs-local. Sursa numerelor: [blog.mozilla.ai/ai-got-expensive-now-what](https://blog.mozilla.ai/ai-got-expensive-now-what/) (Anushri Gupta, 26 mai 2026).

## Claude API (Sonnet 4.6 — prețuri verificate la 11 iul 2026)

```
Input:  $3.00 / 1M tokens
Output: $15.00 / 1M tokens

Sesiune agentică intensă (8h/zi, multe tool calls, context re-reads):
  Input:  ~3M tokens/zi    → $9/zi
  Output: ~600K tokens/zi  → $9/zi
  TOTAL:  ~$18/zi → ~$400/lună (22 zile lucrătoare)
```

## Ollama pe hardware local

```
GPU RTX 4090 (24GB VRAM): ~$2,000 hardware
  → rulează Llama 3.3 70B Q4, DeepSeek-Coder 33B
  → ROI față de API la nivel developer: ~5-6 luni de utilizare intensă

GPU RTX 3080 (10GB VRAM): ~$600 second-hand
  → rulează Llama 3.1 8B, Mistral 7B, Qwen 7B
  → calitate mai mică, dar zero cost operațional
  → ROI: ~1-2 luni

Fără GPU (CPU only):
  → Phi-3 mini 3.8B, Gemma 2B: lent (3-8 tok/s) dar funcțional
  → Hardware cost: $0
```

## Găsește-ți tier-ul

| Profil                | Cheltuială API tipică | Amortizare hardware local       |
| --------------------- | --------------------- | ------------------------------- |
| Indie / light         | ~$30/lună             | ani — rămâi pe API sau CPU-only |
| Daily driver          | ~$100/lună            | ~6 luni (RTX 3080 SH ~$600)     |
| **Agentic developer** | **~$400/lună**        | **~5 luni (RTX 4090 ~$2.000)**  |

**Concluzia:** ROI-ul în luni presupune utilizare agentică intensă; sub un GPU de ~$600, diferența de calitate poate să nu merite.

> **Notă (verificat 11 iul 2026):** Sonnet 5 (lansat 30 iun 2026): preț introductiv **$2/$10 per MTok până la 31 aug 2026**, apoi $3/$15 — profilul agentic scade la ~$265/lună în fereastra introductivă.
