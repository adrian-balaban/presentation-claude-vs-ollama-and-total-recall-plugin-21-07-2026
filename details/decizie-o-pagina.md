# One-page decision guide — Claude API or Ollama? (+ first steps)

> The handout promised at the start of the presentation: print or save this page for your team.

## 1. The decision tree

## 2. Scenarios → choice

| Scenario                                                             | Choice                          | Recommended model                             |
| -------------------------------------------------------------------- | ------------------------------- | --------------------------------------------- |
| Project with sensitive data / NDA                                    | Ollama                          | DeepSeek Coder 33B or Qwen 2.5 Coder 32B      |
| Enterprise team with cloud restrictions                              | Ollama                          | Llama 3.3 70B (local server)                  |
| Rapid prototyping, maximum quality                                   | Claude API                      | Sonnet 4.6/5 or Opus 4.8                      |
| Indie developer, limited budget                                      | Ollama                          | Llama 3.1 8B or Qwen 2.5 7B                   |
| Critical reasoning tasks                                             | Claude API                      | Opus 4.8 with extended thinking               |
| Code with large context (>50K tokens)                                | Claude API                      | Sonnet (200K context)                         |
| Offline / air-gapped                                                 | Ollama                          | Any pre-downloaded model                      |
| Team with a shared GPU server                                        | Ollama                          | Llama 3.3 70B, central server                 |
| Team that wants Claude + local models + centralized budget control   | **Otari gateway** (self-hosted) | Real Claude + any provider, virtual keys      |

## 3. Find your cost tier (hardware amortization vs API)

| Profile          | Typical API spend      | Local GPU amortization                         |
| ---------------- | ---------------------- | ---------------------------------------------- |
| Indie / light    | ~$30/month             | years — stay on API or CPU-only                |
| Daily driver     | ~$100/month            | ~6 months (RTX 3080 SH ~$600)                  |
| Agentic developer | ~$400/month           | ~5 months (RTX 4090 ~$2,000)                   |

## 4. The short GDPR rule

- Non-sensitive code + small budget → `:cloud` models (note: GLM/Kimi inference runs in China).
- Romanian, sensitive data, critical reasoning → Claude (US, covered by the EU-US Data Privacy Framework; EU residency only via Bedrock/Vertex EU regions).
- Data that must not leave at all → Ollama local / air-gapped.

## 5. Tomorrow morning (checklist)

1. Install Ollama → `ollama pull gemma3:4b`
2. `ollama launch claude --model gemma3:4b` — the Claude Code harness on a local model
3. Add `total-recall` for persistent memory across sessions
4. First 10 minutes with total-recall: see [primele-10-minute.md](primele-10-minute.md)