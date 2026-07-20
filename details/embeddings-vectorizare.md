# Other notes — Total Recall: embeddings & vectorization

> Support material for the 21 July 2026 presentation (the total-recall slide).
> The unsummarized version of the slide about Embeddings & vectorization.

---

## Core question

Does total-recall use embeddings and/or vectorization? **Yes — but optional, lazy-load, and it degrades cleanly to TF-IDF without the native dependencies.** It does not use cloud embedding APIs.

Two embedding backends, both **local** (air-gapped), selected via `embeddingProvider` in `~/.total-recall/config.json`:

- **`ollama` (used in the demo)** — embeddings run by **local Ollama**, model **`bge-m3`** (1024-dim, **multilingual**). Enables **RO↔EN** semantic search (store in Romanian, search in English). Requires `ollama pull bge-m3` and Ollama running.
- **`huggingface` (default, self-contained)** — `@huggingface/transformers` with `all-MiniLM-L6-v2` (384-dim, EN-oriented) via ONNX on local CPU/GPU. Zero external dependencies — the plugin works without Ollama.

---

## Where — the modules involved

### The Retrieval & Scoring pipeline

| Module | Role |
|---|---|
| `src/embeddings.ts` | Embeddings: `ollama` provider → `bge-m3` (1024-dim, multilingual) via `POST /api/embeddings`; `huggingface` (default) → `@huggingface/transformers` (`all-MiniLM-L6-v2`, 384-dim) via ONNX. Both lazy-load + degrade to `null` (TF-IDF only) if the backend is missing. |
| `src/vectorStore.ts` | Lazy-load `sqlite-vec`, virtual table `vec_memories`, KNN search. |
| `src/tfidf.ts` | Tokenization, inverted index, TF-IDF score + Ebbinghaus decay. |
| `src/rrf.ts` | Reciprocal Rank Fusion (k=60) — combines the TF-IDF and vector lists. |
| `src/ebbinghaus.ts` | Time-decayed retention: `e^(-t/S)` (decay based on importance and accesses). |
| `src/tools/recall.ts` | Runs the hybrid search (TF-IDF + vector in parallel) fused via RRF. |

```
query
  │
  ├─► TF-IDF (tfidf.ts + Ebbinghaus decay)
  │
  └─► embed query ─► sqlite-vec KNN
              │
              ▼
        rrf.ts (Reciprocal Rank Fusion, k=60) ──► Final list
```

---

## Why — the real design reasons

1. **Semantic quality:** TF-IDF matches exact tokens ("k8s pod OOM" misses "workload killed for memory pressure"). Embeddings solve paraphrasing; with `bge-m3` (1024-dim, multilingual) they also solve **cross-language** — store in Romanian, search in English (the slide demo). `all-MiniLM-L6-v2` (384-dim) only covers English paraphrases.
2. **Graceful degradation:** If `@huggingface/transformers` or `sqlite-vec` can't be loaded (e.g. offline environment or native library compilation issues), the plugin automatically falls back to TF-IDF without crashing.
3. **RRF fusion:** Lexical scores (TF-IDF) and vector similarity aren't directly comparable as absolute values. RRF uses only rank position (`Σ 1/(k + rank_i)`), being scale-free.
4. **Externalized in esbuild:** Heavy native dependencies are marked as `--external` in the esbuild config, keeping the core bundle very small.
5. **Robust write path:** `embedAndUpsert` has buffering. `flushPending()` on `SIGTERM`/`SIGINT` handlers ensures vectors are written to disk on exit.

---

## What it does NOT do

- **Does not use cloud embedding APIs:** both backends are **100% local** (air-gapped) — `ollama` runs `bge-m3` in Ollama on your machine, `huggingface` runs `all-MiniLM-L6-v2` via ONNX on CPU/GPU. No vector ever leaves the machine.
- **No re-embed on read:** Vectors are not recomputed on read — they are recomputed on write and on memory update (including tags/importanceScore, from recent v) and stored in `vectors.db`.
- **No external API keys:** No API keys or credentials for external services are required.