# Alte notițe — Total Recall: embeddings & vectorizare

> Material de sprijin pentru prezentarea din 21 iulie 2026 (slide-ul total-recall).
> Versiunea nerezumată a slide-ului despre Embeddings & vectorizare.

---

## Întrebare de bază

Total-recall folosește embeddings și/sau vectorizare? **Da — dar opțional, lazy-load, și degradează curat la TF-IDF fără dependențele native.** Nu folosește cloud API-uri de embeddings.

Două backends de embeddings, ambele **locale** (air-gapped), alese prin `embeddingProvider` în `~/.total-recall/config.json`:

- **`ollama` (folosit în demo)** — embeddings rulate de **Ollama local**, model **`bge-m3`** (1024-dim, **multilingual**). Permite căutarea semantică **RO↔EN** (stochezi în română, cauți în engleză). Necesită `ollama pull bge-m3` și Ollama pornit.
- **`huggingface` (default, self-contained)** — `@huggingface/transformers` cu `all-MiniLM-L6-v2` (384-dim, orientat EN) via ONNX pe CPU/placă locală. Zero dependențe externe — pluginul merge și fără Ollama.

---

## Unde — modulele implicate

### Pipeline-ul de Retrieval & Scoring

| Modul | Rol |
|---|---|
| `src/embeddings.ts` | Embeddings: `ollama` provider → `bge-m3` (1024-dim, multilingual) via `POST /api/embeddings`; `huggingface` (default) → `@huggingface/transformers` (`all-MiniLM-L6-v2`, 384-dim) via ONNX. Ambele lazy-load + degradează la `null` (TF-IDF only) dacă backend-ul lipsește. |
| `src/vectorStore.ts` | Lazy-load `sqlite-vec`, tabel virtual `vec_memories`, KNN search. |
| `src/tfidf.ts` | Tokenizare, inverted index, scor TF-IDF + Ebbinghaus decay. |
| `src/rrf.ts` | Reciprocal Rank Fusion (k=60) — combină listele TF-IDF și vectoriale. |
| `src/ebbinghaus.ts` | Retenție time-decayed: `e^(-t/S)` (decay bazat pe importanță și accesări). |
| `src/tools/recall.ts` | Rulează căutarea hibridă (TF-IDF + vector în paralel) fuzionată prin RRF. |

```
query
  │
  ├─► TF-IDF (tfidf.ts + Ebbinghaus decay)
  │
  └─► embed query ─► sqlite-vec KNN
              │
              ▼
        rrf.ts (Reciprocal Rank Fusion, k=60) ──► Listă finală
```

---

## De ce — motivele reale de design

1. **Calitate semantică:** TF-IDF caută exact-token ("k8s pod OOM" ratează "workload killed for memory pressure"). Embedding-urile rezolvă parafrazele; cu `bge-m3` (1024-dim, multilingual) rezolvă și **cross-language** — stochezi în română, cauți în engleză (demo-ul de pe slide). `all-MiniLM-L6-v2` (384-dim) acoperă doar parafraze în engleză.
2. **Graceful degradation:** Dacă `@huggingface/transformers` sau `sqlite-vec` nu pot fi încărcate (ex: mediu offline sau probleme de compilare a librăriilor native), pluginul revine automat la TF-IDF fără să crape.
3. **Fuziune RRF:** Scorurile lexicale (TF-IDF) și similatatea vectorială nu sunt comparabile direct ca valori absolute. RRF folosește doar poziția în rang (`Σ 1/(k + rank_i)`), fiind scale-free.
4. **Externalizat în esbuild:** Dependențele native grele sunt marked ca `--external` în configurarea esbuild, păstrând bundle-ul de bază foarte mic.
5. **Write path robust:** `embedAndUpsert` are buffering. `flushPending()` pe handler-ele de `SIGTERM`/`SIGINT` se asigură că vectorii sunt scriși pe disc la exit.

---

## Ce NU face

- **Nu folosește cloud APIs de embeddings:** ambele backends sunt **100% locale** (air-gapped) — `ollama` rulează `bge-m3` în Ollama pe mașina ta, `huggingface` rulează `all-MiniLM-L6-v2` via ONNX pe CPU/placă. Niciun vector nu părăsește mașina.
- **Fără re-embed la citire:** Vectorii nu sunt recalculați la citire — se recalculează la scriere și la actualizarea memoriei (inclusiv tags/importanceScore, din v recentă) și se stochează în `vectors.db`.
- **Fără chei API externe:** Nu sunt necesare chei API sau credențiale pentru servicii externe.