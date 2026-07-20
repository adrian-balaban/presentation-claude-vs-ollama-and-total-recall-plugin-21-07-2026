---
marp: true
paginate: true
title: "Total Recall Plugin — persistent memory for Claude Code"
author: Adrian Balaban
date: 2026-07-21
layout: docs
---

<!-- _paginate: false -->

## TOTAL RECALL PLUGIN (~22 min)

> **The bridge between themes:** you've chosen the runtime (cloud or local). Now make it remember who you are and what you did — otherwise every session starts from zero.

---

## The problem: Claude forgets everything after a session

> At the end of every conversation, Claude loses all accumulated context.
> Decisions, preferences, discussed architectures — everything disappears.

**Symptoms:**

- You re-explain the same context at every new session
- Your code preferences must be re-stated every time
- Architecture decisions, infra info and other categories of knowledge never accumulate anywhere

**The consequence:** the more you work with an agent (Claude Code...), the more time you waste re-explaining what you've already explained.

---

## The problem · Who else wants this: cq (Mozilla.ai)

<!-- ✂️ cuttable (3) — time valve; cq comes back in the synthesis and during open Q&A anyway -->

> **Who else wants this:** Mozilla.ai launched [`cq`](https://github.com/mozilla-ai/cq) (1.2k ⭐) — an open standard for _shared agent learning_. **Complementary, not competing** with total-recall — the honest comparison comes at the end of the theme.

---

## Demo: the same question, with and without memory

<!--
🎬 Staging — the emotional payoff of the entire theme.
Lipsync: the primary version is the 20 s asciinema recording (casts/demo-cu-fara-memorie.cast); live only if the room allows.

Prep before the talk — store the memory:
  "store the following architecture memory for db-choice: we chose PostgreSQL over MySQL for JSONB"
  → Stored: architecture/db-choice (personal vault, importanceScore 0.7, tags: database, postgresql, mysql, jsonb, adr, decision).
  The plugin checks for duplicates with search_index and writes an Executive Summary with WHY/HOW; optional no-prune tag (immutable, like a formal ADR) or org tag (team decision → org vault).
-->

```

WITHOUT total-recall (new Claude session):       WITH total-recall (new session, same prompt):
──────────────────────────────────────            ──────────────────────────────────────────────
> which DB did we choose for the project?        > which DB did we choose for the project?

"I have no context about a previous              → recall_memory(query="project DB")
decision related to the database.                "Per memory architecture/db-choice (created today, July 13 2026): You chose PostgreSQL (rejected MySQL). Decisive reason: JSONB is binary storage of JSON documents with indexing ..."
```

The audience doesn't have to take it on faith — they see the difference on screen in 20 seconds.

---

## The solution: total-recall

> A Claude Code plugin that gives the AI persistent, searchable memory across sessions.

<!--
🎬 Staging: run on screen `claude -p "Remind yourself of our decision about the database"` and show the recall_memory call in the output. Lipsync: asciinema recording as a safety net (casts/demo-recall-cli.cast). For the audience, the command is the "homework" from the handout.
-->

---

## The solution: total-recall · What it is and what it is NOT

**What it is:**

- **Claude Code plugin** installed from the marketplace
- **MCP server** with 17 tools (stdio) + **automatic hooks** that inject context at every session
- **Vault of Markdown files** stored locally at `~/.total-recall/`
- **Skill `/total-recall:memory-workflow`** for structured recall/store sessions

**What it is NOT:**

- It does not send data to the cloud (the personal vault is fully local)
- It does not use an opaque database — every memory is a readable `.md` file
- It does not overwrite context — it injects, it doesn't replace (system prompt + CLAUDE.md + memory index + your message coexist)

---

## On-disk structure

> 💡 **WOW:** zero database — your AI's memory is a folder of `.md` files you can read, edit, version with git and open in Obsidian.

```
~/.total-recall/
├── index.json               ← flat index: key → MemoryMetadata
├── invertedIndex.json       ← TF-IDF inverted index: token → {docs, idf}
├── .index-cache.txt         ← summary injected at SessionStart (shell-readable)
├── personal-vault/
│   ├── architecture/
│   │   └── db-choice.md     ← individual memory: YAML frontmatter + Markdown body
│   ├── decisions/
│   ├── troubleshooting/
│   ├── meetings/
│   ├── knowledge/
│   ├── journal/
│   └── vectors.db           ← sqlite-vec embeddings (optional)
└── org/
    └── org-vault/
        └── architecture/
            └── team-decision.md   ← memories shared with the team, sync via git
```

---

## On-disk structure · Anatomy of a memory

<!-- ✂️ cuttable (4) — time valve; the frontmatter is also visible in the example on the "On-disk structure" slide -->

**Every memory** is a `.md` file with frontmatter:

```markdown
---
title: "Prefer PostgreSQL for relational data"
tags: [architecture, database, feedback]
author: adrianb
importanceScore: 0.8
created: 2026-06-01T10:00:00Z
updated: 2026-06-15T14:30:00Z
---

## Executive Summary

Prefer PostgreSQL over MySQL for new projects...
```

---

## Architecture: the main modules

> 💡 **WOW — the number on screen: `1`.** A complete hybrid search engine (TF-IDF + vector + forgetting curve) in ~24 TypeScript files, with **a single mandatory dependency** (`@modelcontextprotocol/sdk`). The rest — TF-IDF, Ebbinghaus, RRF, frontmatter parser — written from scratch.

```
┌──────────────────────────┐   ┌──────────────────────────┐
│  INDEX & PERSISTENCE     │   │  SEARCH                  │
│  index/state/persistence │   │  tfidf + ebbinghaus      │
│  vault-scan, frontmatter │   │  + rrf + embeddings      │
│  (own YAML parser)       │   │  (vector = optional)     │
└──────────────────────────┘   └──────────────────────────┘
┌──────────────────────────┐   ┌──────────────────────────┐
│  HOOKS & SAFETY          │   │  MCP TOOLS (17)          │
│  auto-reconcile, journal │   │  tools/: store, recall,  │
│  privacy-filter          │   │  query, mutate, bulk,    │
│  (fail-closed on push)   │   │  rerank                  │
└──────────────────────────┘   └──────────────────────────┘
```

📄 **Details** (the full tree of all 24 files, with what each does): [details/arhitectura-module.md](details/arhitectura-module.md)

---

## Why custom algorithms (no hard dependencies)

<!-- ✂️ cuttable (2) — time valve; the "single dependency" idea is already on the architecture slide -->

**What you gain:**

1. **Security:** no `gray-matter` → no `js-yaml` CVE (GHSA-h67p-54hq-rp68)
2. **Coherent scoring:** title-boost, tag-boost, Ebbinghaus = one formula, not three libraries
3. **Determinism:** zero LLM calls, zero cost, works offline / air-gapped
4. **Auditability:** every scoring decision is observable via `get_stats`

> **Philosophy:** heavy dependencies = CVE risk + breaking-change + black-box. Only ONNX and sqlite-vec remain external — and they're optional.

---

## Dual Vault: personal vs org

> 💡 **WOW:** a simple `org` tag turns personal memory into team knowledge — with a **fail-closed** privacy filter: if it can't guarantee no secrets leak, it doesn't push.

```
store_memory(tags=[...])
       │
       ├── contains "org"  ──►  ORG VAULT  (~/.total-recall/org/org-vault/)
       │                        key prefix: "org/"
       │                        author-protected writes
       │                        auto sync → team git repo (org-vault branch)
       │                        privacy filter before push
       │
       └── otherwise       ──►  PERSONAL VAULT  (~/.total-recall/personal-vault/)
                                key: simple relative path
                                journal auto-appended at every store
```

**Key rule:** the `personal` and `org` tags are mutually exclusive — `store_memory` throws an error if both are present.

---

## Dual Vault · The privacy filter

**Privacy filter (org sync):**

- Blocks secrets and API keys by known patterns (PEM keys, `sk-`, `ghp_`, `AKIA`, JWT, Slack/GitLab/Google tokens, etc.)
- Detects **labeled secrets** too — e.g. `aws_secret_access_key = …`: a `~/.aws/credentials` pasted by mistake is blocked before push
- Blocks all email addresses (except allowlisted domains)
- Fail-closed: if the filter cannot analyze the content, it does NOT push

---

## The 17 MCP tools

<!--
🎬 Staging — the sticky idea demonstrated, not stated: you say "remember that I prefer PostgreSQL" → the model picks store_memory on its own; you ask "what did we decide about the DB?" → it picks recall_memory. Lipsync: asciinema recording as a safety net (casts/demo-store-recall-natural.cast).
-->

> 💡 Full CRUD + search + maintenance, **in natural language** — you don't learn 17 tool names.

Four-quadrant map (with the hero tools):

```
┌── WRITE ──────────────────────┐  ┌── READ ───────────────────────────┐
│  store_memory  ★              │  │  recall_memory  ★                 │
│  (+ update, delete, confirm)  │  │  (+ search_index, rerank, keys)   │
└───────────────────────────────┘  └───────────────────────────────────┘
┌── LIST ───────────────────────┐  ┌── MAINTAIN ───────────────────────┐
│  list_memories                │  │  prune_memories  ★  (list only)   │
│  (+ timeline, related, stats) │  │  export_memories ★  (portable)    │
└───────────────────────────────┘  └───────────────────────────────────┘
```

- `rerank_memories` = semantic rerank **locally**: re-embeds query + candidates and sorts by cosine score — no LLM call whatsoever
- `confirm_memory` = confirm/flag feedback integrated directly into the Ebbinghaus score

📄 **Details** (all 17 tools, with a description of each): [details/unelte-mcp.md](details/unelte-mcp.md)

---

## The search algorithm: TF-IDF + Ebbinghaus

> 💡 **WOW:** the AI's memory **forgets like a human** — [Ebbinghaus's forgetting curve](https://en.wikipedia.org/wiki/Forgetting_curve) (1885) applied in code: unimportant and unaccessed memories fade from results, every access "refreshes" them by +20%.

---

## The search algorithm · The essence

**TF-IDF in short:** a word scores highly if it appears **often in that memory**, but **rarely across the rest of the collection** — the search reads only the index, not the files. On top of the textual score, forgetting is applied:

```
decay = importanceScore × exp(−λ × daysSince)
        × (1 + accessCount × 0.2 + confirmations × 0.1 − flags × 0.1)
```

| importanceScore | λ (forgetting rate) | Behavior                                        |
| --------------- | ------------------- | ----------------------------------------------- |
| 1.0 (critical)  | 0.032               | Slow decay — memory stays relevant for weeks    |
| 0.5 (normal)    | 0.096               | Medium decay                                    |
| 0.3 (low)       | 0.122               | Fast decay — drops from results in days         |

Every access +20% retention, confirmation +10%, flag −10% (`confirm_memory`) — memory doesn't just "age", it receives feedback.

📄 **Details** (the full `recall_memory` pipeline, TF-IDF & inverted index, RRF, the λ formula): [details/algoritm-cautare.md](details/algoritm-cautare.md)

---

## Embeddings and multilingual search (optional)

> Embeddings = optional, lazy-load, fully local (or via Ollama with a local model). Without them, the plugin downgrades to TF-IDF.

**Configurable providers** (in `~/.total-recall/config.json`): `huggingface` (default, local MiniLM), `ollama` (local API, `bge-m3`).

**Multilingual search:** the `enableMultilingualSearch: true` flag activates EN↔RO token expansion (e.g. "decizie" also finds "decision").

---

## Embeddings and multilingual · The EN↔RO demo

<!--
🎬 The climax of THEME 2 — the moment devs tell each other about afterwards.
Lipsync: the primary version is the asciinema recording (casts/demo-multilingv.cast); live only if the network and room allow.
-->

You store the memory in **English**, then in a new session you ask in **Romanian** — the "decizie"→"decision" expansion finds it:

```
# 1. Store (in English):
> "remember that we chose PostgreSQL over MySQL because of JSONB support"
→ store_memory(title="Database decision: PostgreSQL", tags=["architecture", "database"])

# 2. In a new session, ask in ROMANIAN:
> "care a fost decizia noastră despre baza de date?"
→ recall_memory(query="decizie baza de date")
→ the EN↔RO expansion maps "decizie"→"decision", "baza de date"→"database"
→ finds the English memory, TF-IDF score on expanded tokens ✅
```

📄 **Details** (how embeddings & vectorization work, the local ONNX pipeline, sqlite-vec): [details/embeddings-vectorizare.md](details/embeddings-vectorizare.md)

---

## Hooks: automatic integration (Claude Code / Copilot / Gemini)

> 💡 **WOW:** before context compaction (`PreCompact`), the plugin **automatically saves the session's learnings** — knowledge survives even when context is wiped.

| Hook           | What it does                                                                  |
| -------------- | ----------------------------------------------------------------------------- |
| `SessionStart` | pull org-vault → rebuild index → inject the memory summary into context       |
| `PostToolUse`  | on `store/update/delete_memory`: privacy filter + push org-vault              |
| `PreCompact`   | extract 0–3 learnings from the transcript → write them to personal-vault      |
| `SessionEnd`   | log the session, flush embeddings                                              |

Also runs on **Copilot CLI** and **Gemini CLI** (`hooks.copilot.json` / `hooks.gemini.json`) — but without context injection (the clients ignore stdout).

📄 **Details** (the steps of each hook, the scripts, graceful degradation on non-Claude): [details/hooks-lifecycle.md](details/hooks-lifecycle.md)

---

## Installation and practical usage

> 💡 **Useful:** the same plugin, 4 clients — Claude Code, Copilot CLI, Gemini CLI, standalone — with a single `install.sh`.

```bash
git clone https://github.com/adrian-balaban/my-claude-plugins-marketplace.git
cd my-claude-plugins-marketplace/plugins/total-recall && npm install && npm run build

claude plugin install "$(pwd)"    # Claude Code; Copilot/Gemini/standalone: ./install.sh --<client>
```

- **Org vault = optional, disabled by default** — `personal-vault` runs 100% local, no git
- In a session: "remember that..." → `store_memory`, "remind me of..." → `recall_memory`

📄 **Details** (the full steps per client, org vault, usage examples): [details/instalare-total-recall.md](details/instalare-total-recall.md)

---

## Compatibility: Claude Code vs Copilot vs Gemini vs Codex

**Three levels of integration** (the story behind the matrix):

1. **Full** — Claude Code: MCP tools + automatic context injection + skills
2. **Partial** — Copilot / Gemini CLI: tools and hooks work, but context doesn't auto-inject — the model has to ask
3. **Manual** — Codex CLI: MCP tools only, no hooks

---

## Compatibility · The matrix (1/2)

| Capability                    | Claude Code | GitHub Copilot CLI     | Gemini CLI             | OpenAI Codex CLI          |
| ----------------------------- | ----------- | ---------------------- | ---------------------- | ------------------------- |
| **MCP Server (17 tools)**     | ✅ Native   | ✅ stdio MCP supported | ✅ stdio MCP supported | ✅ `~/.codex/config.toml` |
| **Side Effects (Sync/Index)** | ✅ Yes      | ✅ Yes (auto hooks)    | ✅ Yes (auto hooks)    | ❌ No (manual)            |

📄 **Details** (the full matrix — context injection, skills; Obsidian; the comparison with `cq`): [details/compatibilitate-clienti.md](details/compatibilitate-clienti.md)