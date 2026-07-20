# A third path: Otari from Mozilla, an Anthropic-compatible gateway

> 💡 **WOW:** the same `ANTHROPIC_BASE_URL` trick, but with **budget enforcement BEFORE the request, not after the invoice.**

**Otari** (Mozilla.ai, open-source, released May 2026, built on top of `any-llm`) is a self-hosted LLM gateway that also exposes the Anthropic endpoint (`POST /v1/messages`) — so Claude Code can run through it exactly like through Ollama, but with the operational layer that Ollama lacks:

- **Budgets** per user / per key, applied _before_ the request runs
- **Virtual keys** — the client never sees the real Anthropic/OpenAI key; you can revoke them at any time
- **Usage & spend tracking** in real time, across all models (40+ providers via any-llm)
- You run real Claude, GPT, Mistral or local models through **the same endpoint**