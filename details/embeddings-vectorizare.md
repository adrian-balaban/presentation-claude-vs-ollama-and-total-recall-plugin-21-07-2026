# Alte notițe — Total Recall: embeddings & vectorizare

> Material de sprijin pentru prezentarea din 16 iulie 2026.
> Versiunea nerezumată a slide-ului despre Embeddings & vectorizare.

---

## Întrebare de bază

Total-recall folosește embeddings și/sau vectorizare? **Da — dar opțional, lazy-load, complet local și degradează curat la TF-IDF fără dependențele native.** Nu folosește cloud API-uri de embeddings.

---

## Unde — modulele implicate

### Pipeline-ul de Retrieval & Scoring

| Modul | Rol |
|---|---|
| `src/embeddings.ts` | Lazy-load `@huggingface/transformers` (`all-MiniLM-L6-v2`, 384-dim). |
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

1. **Calitate semantică:** TF-IDF caută exact-token ("k8s pod OOM" ratează "workload killed for memory pressure"). Modelul de embedding pe 384 dimensiuni rezolvă parafrazele.
2. **Graceful degradation:** Dacă `@huggingface/transformers` sau `sqlite-vec` nu pot fi încărcate (ex: mediu offline sau probleme de compilare a librăriilor native), pluginul revine automat la TF-IDF fără să crape.
3. **Fuziune RRF:** Scorurile lexicale (TF-IDF) și similatatea vectorială nu sunt comparabile direct ca valori absolute. RRF folosește doar poziția în rang (`Σ 1/(k + rank_i)`), fiind scale-free.
4. **Externalizat în esbuild:** Dependențele native grele sunt marked ca `--external` în configurarea esbuild, păstrând bundle-ul de bază foarte mic.
5. **Write path robust:** `embedAndUpsert` are buffering. `flushPending()` pe handler-ele de `SIGTERM`/`SIGINT` se asigură că vectorii sunt scriși pe disc la exit.

---

## Ce NU face

- **Nu folosește cloud APIs:** Modelul rulează 100% local via ONNX pe CPU/placă locală.
- **Fără re-embed la citire:** Vectorii nu sunt recalculați la citire — se recalculează la scriere și la actualizarea memoriei (inclusiv tags/importanceScore, din v recentă) și se stochează în `vectors.db`.
- **Fără chei API externe:** Nu sunt necesare chei API sau credențiale pentru servicii externe.