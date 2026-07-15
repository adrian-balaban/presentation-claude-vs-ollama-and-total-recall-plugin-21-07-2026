#!/usr/bin/env bash
# ttft.sh — măsoară Time To First Token (TTFT) pe un endpoint LLM cu streaming.
# Utilizare: ttft.sh <url> <json-payload> [headere curl suplimentare...]
# Exemplu local:  ./ttft.sh http://localhost:11434/api/generate '{"model":"qwen3.5","prompt":"Salut","stream":true}'
set -euo pipefail
url=$1; payload=$2; shift 2
start=$(date +%s%N)
# curl iese cu 23 când head închide pipe-ul după primul byte — e comportamentul dorit
curl -sN "$url" -d "$payload" "$@" 2>/dev/null | head -c 1 > /dev/null || true
end=$(date +%s%N)
echo "TTFT: $(( (end - start) / 1000000 )) ms"
