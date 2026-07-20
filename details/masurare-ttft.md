# How to measure TTFT (Time To First Token) — local vs Claude

TTFT = the time from sending the request to the **first byte of the streaming response**. It is measured identically on any endpoint with streaming, using the script [scripts/ttft.sh](../scripts/ttft.sh):

```bash
#!/usr/bin/env bash
# ttft.sh <url> <json-payload> [curl headers...]
start=$(date +%s%N)
curl -sN "$url" -d "$payload" "$@" 2>/dev/null | head -c 1 > /dev/null || true
end=$(date +%s%N)
echo "TTFT: $(( (end - start) / 1000000 )) ms"
```

## Local model (Ollama)

```bash
./scripts/ttft.sh http://localhost:11434/api/generate \
  '{"model":"gemma3:4b","prompt":"Salut","stream":true}'
```

## Remote model via Ollama (:cloud)

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

## Correct measurement protocol

1. Run each endpoint **4–5 times**; discard the first local run (it includes loading the model into RAM/VRAM).
2. Same short prompt everywhere; `stream: true` mandatory.
3. Alternatively for local: `ollama run gemma3:4b --verbose` reports the timings itself (load, prompt eval, eval).

## Results measured on Dell Latitude 5521 (i7-11850H, MX450 2GB → CPU-only), 15–20 Jul 2026

| Endpoint                          | TTFT (after warm-up)        |
| --------------------------------- | --------------------------- |
| `gemma3:4b` local (CPU)           | ~0.8–1.8 s (varies a lot)   |
| `glm-5.2:cloud` (Ollama proxy)    | ~430–2800 ms (variable)     |
| Claude API (`claude-sonnet-5`)    | ~1.6 s (measured)           |

## ⚠️ Note for the "~120ms local vs ~650ms Claude" figure

The **~120ms** figure assumes an 8B model **fully loaded into VRAM** (dedicated GPU ≥8–12GB). On a CPU-only laptop (like the demo one), the real local TTFT is **~0.8–1.8 s (varies a lot between runs)** — comparable to the cloud API (~1.6 s measured), not 5× faster. The point that still holds locally: **$0/token, offline, zero egress** — not necessarily the latency.