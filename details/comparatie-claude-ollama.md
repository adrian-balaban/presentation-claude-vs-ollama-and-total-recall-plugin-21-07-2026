# Claude vs Ollama — the full 13-criterion comparison

> Supporting material for the "Direct comparison: Claude vs Ollama" section in `prezentare.ro.md`.

| Criterion                | Claude (Anthropic API)                     | Ollama (local)                                                                                      |
| ------------------------ | ------------------------------------------ | --------------------------------------------------------------------------------------------------- |
| **Available models**     | Claude Sonnet 4.6/5, Opus 4.8, Haiku 4.5   | Llama, Mistral, Gemma, Phi, Qwen, DeepSeek etc.                                                     |
| **Top-tier quality**     | ✅ Claude Opus 4.8 = state of the art      | Llama 3.3 70B ≈ GPT-4o, but below Opus                                                              |
| **Cost per token**       | $3–$15 / 1M tokens (input $3 / output $15) | $0 — own hardware                                                                                   |
| **Infrastructure cost**  | $0 (no own server)                         | Decent GPU: $500–$3000+                                                                             |
| **Privacy**              | Data sent to Anthropic                     | 100% local, zero egress                                                                             |
| **Latency**              | ~500ms–2s (~1.6 s measured)                | ~100–500 ms (local GPU); ~0.8–1.8 s (CPU-only, comparable to the API)                               |
| **Context window**       | 200K tokens (Sonnet/Opus)                  | 4K–128K (depends on model + VRAM)                                                                   |
| **Advanced reasoning**   | ✅ Excellent (extended thinking)           | Limited to small-to-medium models                                                                   |
| **Availability**         | Requires internet + API key                | Works offline                                                                                       |
| **Model updates**        | Automatic (Anthropic)                      | Manual (`ollama pull`)                                                                              |
| **Claude Code integration** | ✅ Native (it is the Anthropic product)   | ✅ Native via `ollama launch claude` (Ollama exposes an Anthropic-API-compatible endpoint, no proxy) |
| **Rate limit**           | Exists (API tier)                          | Unlimited (own hardware)                                                                            |
| **GDPR / compliance**    | Anthropic policies                         | Fully on-premise                                                                                    |