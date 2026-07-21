# GLM-5.2 and Kimi-K2.7-Code — the Chinese `:cloud` models in detail

> Support material for the "What is Ollama with GLM-5.2 and Kimi-K2.7-Code good for?" section in `prezentare.ro.md`.

## GLM-5.2 — Zhipu AI (Beijing)

- Z.ai's flagship (Tsinghua spin-off); context **~1M tokens** (976K — verified on [ollama.com/library/glm-5.2](https://ollama.com/library/glm-5.2)), 756B parameters, strong at reasoning, agentic tasks and code
- For a Romanian dev: weak Romanian (stay on Claude for RO), sensitive data → servers in China

> **Quick context:** GLM-5.2 (released Jun 2026) — close to Claude Opus 4.8 on Terminal-Bench 2.1 (**81.0 vs 85.0**, figures published by Ollama), at an API price roughly **3.6× lower on input and 5.7× lower on output** ($1.40/$4.40 per 1M tokens vs $5/$25 for Opus 4.8 — [source](https://llm-stats.com/blog/research/glm-5-2-vs-claude-opus-4-8)), open weights under the MIT license.

## Kimi-K2.7-Code — Moonshot AI (Beijing)

- Specialized in **code generation and analysis** (Python, TS, Java, Go, C++); a DeepSeek-Coder competitor
- Strengths: boilerplate/scaffolding, code review, explaining legacy code

## Quick comparison

| Model | Company | Best at | Cost vs Claude | GDPR risk |
|---|---|---|---|---|
| **GLM-5.2** | Zhipu AI 🇨🇳 | Chinese-English text, long documents | ~50–70% of Haiku | ⚠️ High |
| **Kimi-K2.7-Code** | Moonshot AI 🇨🇳 | Code review, code generation | ~50–60% of Haiku | ⚠️ High |
| **Claude Haiku** | Anthropic 🇺🇸 | Fast general tasks, Romanian | Reference | ⚠️ Medium (DPA+SCC, US processing) |
| **Claude Sonnet** | Anthropic 🇺🇸 | Reasoning, architecture, complex code | ~4–5× Haiku | ⚠️ Medium (DPA+SCC, US processing) |

## ⚠️ Warning: confidentiality and GDPR

- Both models process data on **servers in China** (Zhipu AI Beijing, Moonshot AI Beijing)
- China = a jurisdiction without a GDPR adequacy decision recognized by the EU (unlike the US, covered by the EU-US Data Privacy Framework — adequacy decision of 10 July 2023; Privacy Shield was invalidated by the CJEU in Schrems II, 2020)
- Note also for Claude: Anthropic has a DPA with SCCs, but processing is on US infrastructure; EU residency only via AWS Bedrock (eu-central-1 etc.) or Vertex AI EU regions
- **Do not send through these APIs:** code with personal data of customers, proprietary IP, credentials, contracts
- For EU enterprise teams: check the DPA (Data Processing Agreement) before use

## Can I run GLM-5.2 / Kimi-K2 locally? (Bonus)

> **Short answer: not on ordinary hardware.** Kimi-K2 = ~600 GB VRAM, GLM-5.x = 100–200 GB — datacenter clusters only. On Ollama, the entire GLM-5 family is `:cloud`-only; the only GLM runnable locally is `glm-4.7-flash` (30B, 12–24 GB VRAM). **"Open-weight" ≠ "fits on your hardware".**

**What you can realistically run on CPU:**

```bash
ollama pull qwen3:4b        # ~3 GB, ~3–8 tok/s
ollama pull llama3.2:3b     # ~2 GB
ollama pull gemma3:4b       # ~3 GB
```

**How to use the `:cloud` models:**

```bash
ollama signin                          # account on ollama.com
ollama run glm-5.2:cloud               # directly
ollama launch claude --model glm-5.2:cloud  # inside Claude Code
```