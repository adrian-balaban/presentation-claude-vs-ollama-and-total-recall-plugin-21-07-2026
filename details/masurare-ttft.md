# Cum măsori TTFT (Time To First Token) — local vs Claude

TTFT = timpul de la trimiterea cererii până la **primul byte din răspunsul streaming**. Se măsoară identic pe orice endpoint cu streaming, cu scriptul [scripts/ttft.sh](../scripts/ttft.sh):

```bash
#!/usr/bin/env bash
# ttft.sh <url> <json-payload> [headere curl...]
start=$(date +%s%N)
curl -sN "$url" -d "$payload" "$@" 2>/dev/null | head -c 1 > /dev/null || true
end=$(date +%s%N)
echo "TTFT: $(( (end - start) / 1000000 )) ms"
```

## Model local (Ollama)

```bash
./scripts/ttft.sh http://localhost:11434/api/generate \
  '{"model":"gemma3:4b","prompt":"Salut","stream":true}'
```

## Model remote prin Ollama (:cloud)

```bash
./scripts/ttft.sh http://localhost:11434/api/generate \
  '{"model":"glm-5.2:cloud","prompt":"Salut","stream":true}'
```

## Claude API (streaming)

```bash
export ANTHROPIC_API_KEY=sk-ant-...
./scripts/ttft.sh https://api.anthropic.com/v1/messages \
  '{"model":"claude-sonnet-5","max_tokens":20,"stream":true,"messages":[{"role":"user","content":"Salut"}]}' \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json"
```

## Protocol de măsurare corect

1. Rulează fiecare endpoint de **4–5 ori**; aruncă prima rulare locală (include încărcarea modelului în RAM/VRAM).
2. Același prompt scurt peste tot; `stream: true` obligatoriu.
3. Alternativ pentru local: `ollama run gemma3:4b --verbose` raportează singur timpii (load, prompt eval, eval).

## Rezultate măsurate pe Dell Latitude 5521 (i7-11850H, MX450 2GB → CPU-only), 15–20 iul 2026

| Endpoint                          | TTFT (după warm-up)         |
| --------------------------------- | --------------------------- |
| `gemma3:4b` local (CPU)           | ~0.8–1.8 s (variază mult)   |
| `glm-5.2:cloud` (proxy Ollama)    | ~430–2800 ms (variabil)     |
| Claude API (`claude-sonnet-5`)    | ~1.6 s (măsurat)            |

## ⚠️ Nota pentru cifra „~120ms local vs ~650ms Claude"

Cifra de **~120ms** presupune un model 8B **încărcat complet în VRAM** (GPU dedicat ≥8–12GB). Pe un laptop CPU-only (ca cel de demo), TTFT-ul local real e **~0.8–1.8 s (variază mult între rulări)** — comparabil cu API-ul cloud (~1.6 s măsurat), nu de 5× mai rapid. Punctul care rămâne valabil local: **$0/token, offline, zero egress** — nu neapărat latența.
