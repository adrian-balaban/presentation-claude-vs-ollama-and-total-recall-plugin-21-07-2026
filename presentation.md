---
marp: true
paginate: true
title: "Claude vs Ollama"
author: Adrian Balaban
date: 2026-07-21
layout: docs
---

<!-- _paginate: false -->

# Claude vs Ollama

**Proprietary cloud vs local open-source** · bonus: persistent memory with total-recall

**Author:** Adrian Balaban
**Date:** 21 July 2026

---

## What you'll take away from this session

1. **What Ollama is**
2. **Claude vs Ollama**
3. **Integrating Ollama with Claude**
4. **Persistent memory with total-recall**

---

## Agenda (~45 minutes)

1. **Claude vs Ollama** (~26 min, includes the ~2 min intro)
2. **Bonus: total-recall** — persistent memory (~5 min)
3. **Synthesis** (~5 min)
4. **Questions (Q&A)** (~7 min)

<!-- ✂️ Time vents (cuttable if the demos derail): GDPR, cq (Mozilla.ai). -->

---

## The throughline

> Cloud AI has become **expensive** and **lock-in-heavy**; Ollama enables **open** alternatives, with real advantages — **cost, offline, privacy**.

---

## What is Claude?

> **Claude** = **remote proprietary LLMs** (Fable, Sonnet, Opus, Haiku — run on Anthropic's servers or in managed cloud: AWS Bedrock, Google Vertex) + a **local proprietary agent** (Claude Code — the CLI on your machine that calls the remote models).

```bash
claude       # starts the agent (claude.ai account or API key)

/status      # which model, which endpoint, which account — the source of truth
/models      # available models
/effort      # reasoning level
```

Web interface: <https://claude.ai>

---

## What is Ollama?

> **Open-source runtime** for running LLMs **locally**, on your own hardware — **zero internet connection, zero cost per token** (for local models).
>
> Models too large to fit on your hardware don't run locally — Ollama **proxies** to its cloud.

> 💡 **WOW:** over **100M downloads** on [Docker Hub](https://hub.docker.com/r/ollama/ollama) and **176k stars** on [GitHub](https://github.com/ollama/ollama) _(Jul 2026)_. The most popular local runtime for LLMs.

![Docker Hub — ollama/ollama, 100M+ downloads](images/ollama-dockerhub.png)
![GitHub — ollama/ollama, 176k stars](images/ollama-github.png)

Interfaces: <https://ollama.com> · <https://docs.ollama.com> · [github.com/ollama/ollama](https://github.com/ollama/ollama)

---

## Claude and Ollama face to face in the console (remote model)

Two clients in parallel, **the same verification commands**:

| Client                 | Start                                        | Check                          |
| ---------------------- | -------------------------------------------- | ------------------------------ |
| Claude Code            | `claude`                                     | `/status`, `/model`, `/effort` |
| Claude Code via Ollama | `ollama launch claude --model glm-5.2:cloud` | `/status`, `/model`, `/effort` |

Then **the same simple prompt** on both (e.g. "explain this repo in 3 bullets") — compare the **result** AND **the response time**.

Fallback (if the live demo derails): `asciinema play casts/slide-7-claude.cast` · `casts/slide-7-ollama.cast`

---

## Ollama demo (local model)

```bash
ollama run ornith:9b                                              # directly in the console
ollama launch claude --model ornith:9b                            # Claude Code on a local model
```

The same simple prompt ("what day is today") in both — the local model answers **offline**, without an API key.

Fallback: `asciinema play casts/slide-8-demo-model-local.cast`

---

## Ollama's advantage: one interface, local and remote models, multiple integrations

- **The same CLI** for all models (`ollama run <model>` local, `ollama run <model>:cloud` remote)
- **Endpoints compatible** with existing APIs: **OpenAI**, **Anthropic**…
- The full integrations list: [docs.ollama.com/integrations](https://docs.ollama.com/integrations)

![Ollama Integrations — Claude Code, OpenCode, OpenClaw, Hermes Agent](images/ollama-integrations.png)

---

## Ollama models: catalog, local vs remote, what's on the laptop

**The catalog:** [ollama.com/library](https://ollama.com/library)

- **Local** (pick by VRAM/RAM): Llama, Mistral, Gemma, Phi, Qwen…
- **Remote** (`:cloud`, ollama.com account): `glm-5.2:cloud`, `kimi-k2.7-code:cloud` (details in "Top remote models")

**On the demo laptop** (`ollama list`, Dell Latitude 5521 / MX450 2GB):

```
NAME                          ID              SIZE      MODIFIED     
gemma3:4b                     a2af6cc3eb7f    3.3 GB    25 hours ago    
bge-m3:latest                 790764642607    1.2 GB    26 hours ago    
nemotron-3-nano:30b           b725f1117407    24 GB     2 weeks ago     
mistral-medium-3.5:latest     0341632adb05    80 GB     2 weeks ago     
qwen3.6:latest                07d35212591f    23 GB     2 weeks ago     
qwen3.5:latest                6488c96fa5fa    6.6 GB    2 weeks ago     
gemma4:latest                 c6eb396dbd59    9.6 GB    2 weeks ago     
kimi-k2.7-code:cloud          eda07a659237    -         2 weeks ago     
ornith:9b                     a75697c14589    5.6 GB    2 weeks ago     
glm-5.2:cloud                 ce8fd6f94793    -         3 weeks ago     
north-mini-code-1.0:latest    d8b269ad5c7c    18 GB     3 weeks ago     
```

**Conclusion:** here the Claude API remains the right choice; local = offline experiments. Live test: `ollama launch claude --model gemma3:4b`

📄 **Details** (hardware limits, eGPU, costs): [details/modele-locale-limitari.md](details/modele-locale-limitari.md)

---

## Ollama · Commands

```bash
ollama list                    # installed models
ollama pull llama3.2           # download only
ollama run llama3.2            # download + run, ready to chat

# Remote models (:cloud) — nothing to download, ollama.com account:
ollama signin
ollama run glm-5.2:cloud
```

---

## Integrating Ollama with Claude and Gemini

> - **Claude doesn't exist in Ollama** — only community imitations, to be avoided. For real Claude: the Anthropic API or `ollama launch claude` (Claude Code with another model behind it).
> - **Gemini** (Google's proprietary) is **NOT** in Ollama; Google's open-weight alternative is **Gemma**: `ollama run gemma3:4b`.

---

## Top remote models in Ollama

Filter: [ollama.com/search?c=cloud&c=tools&c=thinking](https://ollama.com/search?c=cloud&c=tools&c=thinking)

![Ollama search — cloud models with tools & thinking](images/ollama-search-cloud-tools-thinking.png)

- **GLM-5.2** — context ~1M tokens (976K), 756B params, ~**3.6–5.7× cheaper** vs Claude Opus 4.8 ([source](https://llm-stats.com/blog/research/glm-5-2-vs-claude-opus-4-8)); Claude-compatible API, Terminal-Bench 2.1 **81.0 vs 85.0** (Opus 4.8) — [ollama.com/library/glm-5.2](https://ollama.com/library/glm-5.2)
- **Kimi-K2.7-Code** — specialized in code: code review, legacy code explanation — [ollama.com/library/kimi-k2.7-code](https://ollama.com/library/kimi-k2.7-code)

---

## Direct comparison: Claude vs Ollama (optional)

> 💡 **Key point:** it's not "which is better", but **what you optimize** — max quality (Claude) vs sovereignty (Ollama) vs cost vs speed.

**Measured TTFT** on the demo laptop (`gemma3:4b` CPU warm vs `claude-sonnet-5`):

| Endpoint                       | TTFT (after warm-up)      |
| ------------------------------ | ------------------------- |
| `gemma3:4b` local (CPU)        | ~0.8–1.8 s (varies a lot) |
| Claude API (`claude-sonnet-5`) | ~1.6 s (measured)         |

→ **comparable**. On weak hardware Ollama's advantage is **NOT** speed, but **cost / offline / privacy**.

Measurement: [scripts/ttft.sh](scripts/ttft.sh) (or [scripts/demo-ttft.sh](scripts/demo-ttft.sh)) on both endpoints — run it 4–5 times, it varies.
Fallback: `asciinema play casts/slide-14-demo-ttft.cast` · 📄 [details/masurare-ttft.md](details/masurare-ttft.md)

<!-- ✂️ cuttable — first time vent -->

---

## GDPR: where the data goes (optional)

<!-- ✂️ cuttable (time vent) -->

- The `:cloud` models **GLM-5.2**, **Kimi-K2.7-Code** process data on **servers in China** — a jurisdiction without GDPR
- **Claude**: for EU residency, requires **AWS Bedrock / Vertex AI** on EU regions (the full nuances are in the handout)

---

## The real cost: Claude API vs Ollama (optional)

> 💡 **WOW:** an **agentic developer** working intensively burns **~$400/month** on the API — a **$2,000 RTX 4090** amortizes in **~5 months**. But if you're a light user ($30/month), amortization takes years.

| Profile               | Typical API spend | Local hardware amortization         |
| --------------------- | ----------------- | ----------------------------------- |
| Indie / light         | ~$30/month        | years — stay on the API or CPU-only |
| Daily driver          | ~$100/month       | ~6 months (RTX 3080 SH ~$600)       |
| **Agentic developer** | **~$400/month**   | **~5 months (RTX 4090 ~$2,000)**    |

📄 **Details** (the $400/month calculation, hardware tiers, the Sonnet 5 note): [details/costul-real-claude-vs-ollama.md](details/costul-real-claude-vs-ollama.md)

---

## Privacy and data: the crucial difference

> 💡 **WOW:** with Ollama + a local model, the prompt and data **never leave** the machine — it works even with the network cable unplugged (**air-gapped**). For **finance / healthcare / NDA**, this isn't "nice to have", it's **the only legal option**.

**The Claude API flow:**

```
User request
       │  (HTTPS to api.anthropic.com)
       ▼
Anthropic servers (US)
       ├── Processing → response
       ├── Logging (audit, safety) — Anthropic policies
       └── Training data? → No by default, but read the ToS
```

---

## Privacy and data · In practice, with Claude (optional)

- **Your code** (partial or complete) is sent to Anthropic
- **Secrets in the prompt** reach external servers
- **GDPR:** Anthropic has a DPA available, but the data **leaves the EU**
- Enterprise contracts can restrict use of the cloud API

> In short, Ollama: **local** = zero egress, works air-gapped; `:cloud` = data goes to the provider, like any API.

📄 **Details** (full local vs `:cloud` flows, diagrams): [details/confidentialitate-fluxuri.md](details/confidentialitate-fluxuri.md)

---

## Ollama with Claude Code · integration & limits

> **Official integration:** `ollama launch claude` — Ollama speaks **the Anthropic API format directly**, without a proxy.

```bash
ollama launch claude --model qwen3.5           # local model
ollama launch claude --model glm-5.2:cloud     # cloud model, no download
```

**Limits:** supports **tool calling** and **extended thinking** (`budget_tokens` accepted but **not applied**); does **NOT** support **prompt caching**; quality = the quality of the chosen model.

📄 **Details** (what `launch` does under the hood, the manual method with env vars, full capabilities): [details/integrare-claude-code-ollama.md](details/integrare-claude-code-ollama.md)

---

## Decision guide: Claude or Ollama? (optional)

```
Can your data leave your infrastructure?
 ├── NO  → Ollama (local) — mandatory
 └── YES → Do you need top-tier quality (complex reasoning, advanced code)?
            ├── YES → Claude API (Sonnet/Opus)
            └── NO  → Ollama with a remote model
```

📄 **A third path — Otari (Mozilla.ai):** an Anthropic-compatible gateway with **budgets enforced before the request** → [details/otari-gateway.md](details/otari-gateway.md)
📄 **A one-page decision guide (printable):** [details/decizie-o-pagina.md](details/decizie-o-pagina.md)

---

## Bonus: total-recall (persistent memory) + Ollama's role

> **What it answers:** **persistent memory between sessions**, shareable across a team. Clients: **Claude Code** + **Gemini CLI**; **Copilot CLI** — to be decided.

**How you store** a memory: **local** (personal) / **organizational** (team vault on git).
**How you search:** simple search + **multilingual semantic search** (embeddings via Ollama — a tie-in with the Ollama part).

> 💡 **WOW (demo):** you store in **Romanian**, search in **English** (or vice versa) → semantic match via **bge-m3** embeddings run in **local Ollama**.

Alternatively, **the with/without-memory contrast**: a question that needs past context → without the plugin Claude doesn't know; with total-recall it recovers it.

📄 [details/total-recall-pe-scurt.md](details/total-recall-pe-scurt.md) · [details/demo-contrast-cu-fara-memorie.md](details/demo-contrast-cu-fara-memorie.md)

Fallback: `asciinema play casts/slide-21-demo-total-recall.cast`

---

## Synthesis · Claude vs Ollama

- **Claude API:** max quality, cost per token, data in the cloud
- **Ollama:** free, 100% local, offline; `ollama launch claude` = Claude Code on a local model
- **The key decision:** **privacy > quality > cost**

---

## Synthesis · Open questions

1. How do you integrate **total-recall** in a team? (org vault, write permissions) — vs **cq.exchange** (a shared store with human review)?
2. Which **Ollama models** have you tested on real work hardware?
3. Scenarios with **both**: Ollama for code, Claude for analysis?
4. How do you handle **model updates** in Ollama vs the API (without breaking changes)?
5. **Privacy:** what code should **never** leave the machine?

---

## Resources

**Ollama** — ollama.com · [ollama.com/library](https://ollama.com/library) · ollama.com/docs · [docs.ollama.com/integrations](https://docs.ollama.com/integrations)

**Claude API** — [docs.anthropic.com](https://docs.anthropic.com) · [anthropic.com/pricing](https://anthropic.com/pricing) · [anthropic.com/legal](https://anthropic.com/legal) (DPA/GDPR)

**Claude Code ↔ Ollama integration** — `ollama launch claude` · [docs.ollama.com/api/anthropic-compatibility](https://docs.ollama.com/api/anthropic-compatibility) · env vars `ANTHROPIC_BASE_URL`, `ANTHROPIC_AUTH_TOKEN`

**Mozilla.ai ecosystem** — [Otari](https://github.com/mozilla-ai/otari) · [llamafile](https://github.com/mozilla-ai/llamafile) · [any-llm](https://github.com/mozilla-ai/any-llm) · [cq](https://github.com/mozilla-ai/cq) · "AI Got Expensive. Now What?" — blog.mozilla.ai

**Handouts** — [details/decizie-o-pagina.md](details/decizie-o-pagina.md) (printable decision guide) · [details/primele-10-minute.md](details/primele-10-minute.md) (the first 10 minutes with total-recall)

**Total Recall (bonus)** — [github.com/adrian-balaban/total-recall](https://github.com/adrian-balaban/total-recall) · [details/total-recall-pe-scurt.md](details/total-recall-pe-scurt.md)

---

## Q&A — ~7 minutes

> Thanks for attending. Code, architectures and questions — we'll cover them all.

<!--
Q&A stage direction:
- Echo Chamber: repeat each question before you answer — confirms you heard it and buys thinking time.
- Seeding: ask a colleague to open with "when is it worth switching from the Claude API to local Ollama?"
-->
