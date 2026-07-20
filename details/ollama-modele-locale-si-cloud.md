# Ollama — local and `:cloud` models: what exists and what doesn't

> Support material for the "What is Ollama?" section in `prezentare.ro.md`.

## Official sources

**Site:** [ollama.com](https://ollama.com)

![ollama.com — homepage](../images/ollama-com-homepage.png)

**Repo:** [github.com/ollama/ollama](https://github.com/ollama/ollama) — 176k stars, 17k forks

![ollama/ollama on GitHub](../images/ollama-github-repo.png)

## Popular models available locally (verified on ollama.com/library)

| Model | Size | Required VRAM | Quality |
|---|---|---|---|
| `llama3.2:3b` | ~2 GB | 4 GB | Good for simple tasks |
| `llama3.1:8b` | ~5 GB | 8 GB | Good balance |
| `llama3.3:70b` | ~40 GB | 48+ GB | Close to GPT-4o |
| `mistral:7b` | ~4 GB | 8 GB | Good for code |
| `deepseek-coder:33b` | ~19 GB | 24+ GB | Code-specialized |
| `qwen2.5-coder:32b` | ~18 GB | 24+ GB | Code, multilingual |

Plus `:cloud` models (proxy, not local — verified on ollama.com/search?c=cloud): `glm-5.2`, `kimi-k2.7-code`, `minimax-m3`, `deepseek-v4-pro`, `gemma4`, `gpt-oss:120b-cloud` etc. (locally, `gpt-oss:120b` remains available, without the suffix)

```bash
# Proprietary/large models — NOT downloaded; run via the :cloud proxy (ollama.com account)
ollama signin
ollama run gemma-4:cloud  
ollama run glm-5.2:cloud  
```

## ⚠️ Where are Claude, Gemini and GPT? (verified on ollama.com, July 2026)

- **Locally (`ollama pull`) only open-weight models run.** Claude, Gemini and frontier GPT are proprietary — they cannot be run locally, no matter how much hardware you have.
- **Gemini:** there is however `gemma4:cloud` — the Google Gemini 3 Flash Preview model served via Ollama Cloud (Ollama Cloud's policy applies to hosting and data handling). The first crack in the "open-weight only" rule.
- **GPT:** only `gpt-oss` (20B/120B) — OpenAI's *open-weight* models; the proprietary GPT-5.x does not exist in Ollama.
- **Claude:** not available officially, neither locally nor `:cloud` — only community imitations ("claude-style" fine-tunes on Qwen/Gemma, avoid). For real Claude: the Anthropic API or `ollama launch claude` with another model behind it.

## The common confusion: Gemini ≠ Gemma

Both are from Google, but:

- **Gemini** = closed model, API only (Google AI Studio / Vertex AI) → ❌ does not enter Ollama
- **Gemma** = Gemini's open-weight sibling (Gemma 2, **Gemma 3** with multimodal) → ✅ runs in Ollama: `ollama run gemma3`, `ollama run gemma3:27b`

So the only Google family you can run **locally** through Ollama is **Gemma** (open-weight); frontier Gemini exists only as the `gemma4:cloud` proxy. Want the full Gemini experience? Use the Google API or **Antigravity IDE** — Google's agentic platform (IDE + CLI + SDK): download from [antigravity.google](https://antigravity.google/) (Linux/macOS/Windows).

![Antigravity — download page](../images/antigravity-google-homepage.png)