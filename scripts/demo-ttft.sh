#!/usr/bin/env bash
# demo-ttft.sh — demo TTFT (Time To First Token) pentru înregistrare asciinema:
# preîncarcă modelul local, apoi măsoară primul token pe Ollama local vs Claude API.
#
# Cheia Claude NU se pune în acest fișier (e tracked în git). Se ia din mediu:
#   export ANTHROPIC_API_KEY=sk-ant-...
# apoi rulează/înregistrează (asciinema -c moștenește mediul):
#   asciinema rec casts/slide-14-demo-ttft.cast -c 'bash scripts/demo-ttft.sh' \
#            --overwrite --idle-time-limit 2 -t "TTFT: Ollama vs Claude"
# Redare:
#   asciinema play casts/slide-14-demo-ttft.cast
#
# Variabile opționale: LOCAL_MODEL, CLAUDE_MODEL, PROMPT, OLLAMA_URL.
set -uo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ttft="$here/ttft.sh"

LOCAL_MODEL="${LOCAL_MODEL:-gemma3:4b}"
CLAUDE_MODEL="${CLAUDE_MODEL:-claude-sonnet-5}"
PROMPT="${PROMPT:-Salut}"
OLLAMA_URL="${OLLAMA_URL:-http://localhost:11434}"

echo "========================================================"
echo " TTFT — Time To First Token: Ollama local vs Claude API"
echo "========================================================"
echo

echo "▶ (1) LOCAL — Ollama ($LOCAL_MODEL) @ ${OLLAMA_URL#http://}"
echo "  … preîncarc modelul în RAM (o singură dată; pe CPU cold-load poate dura ~1–2 min) …"
curl -s "$OLLAMA_URL/api/generate" \
  -d "{\"model\":\"$LOCAL_MODEL\",\"prompt\":\"hi\",\"stream\":false,\"keep_alive\":\"5m\",\"options\":{\"num_predict\":1}}" \
  -o /dev/null
echo "  model cald — măsor TTFT (model deja încărcat):"
bash "$ttft" "$OLLAMA_URL/api/generate" \
  "{\"model\":\"$LOCAL_MODEL\",\"prompt\":\"$PROMPT\",\"stream\":true}"
echo

echo "▶ (2) CLAUDE API — $CLAUDE_MODEL @ api.anthropic.com"
if [[ -z "${ANTHROPIC_API_KEY:-}" ]]; then
  echo "  ⚠ ANTHROPIC_API_KEY nesetat — sar peste."
  echo "    (rulează: export ANTHROPIC_API_KEY=sk-ant-...  apoi reia)"
else
  bash "$ttft" https://api.anthropic.com/v1/messages \
    "{\"model\":\"$CLAUDE_MODEL\",\"max_tokens\":16,\"messages\":[{\"role\":\"user\",\"content\":\"$PROMPT\"}],\"stream\":true}" \
    -H "x-api-key: $ANTHROPIC_API_KEY" \
    -H "anthropic-version: 2023-06-01" \
    -H "content-type: application/json"
fi
echo
echo "gata."
