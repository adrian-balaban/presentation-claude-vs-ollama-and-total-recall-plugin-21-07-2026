# Alte notițe — Total Recall: embeddings & vectorizare

> Material de sprijin pentru prezentarea din 16 iulie 2026.
> Versiunea **nerezumată** a slide-ului *7b — Embeddings & vectorizare*.
> Răspunde detaliat la: folosește total-recall embeddings / vectorizare? **unde? de ce?**

---

## Întrebare de bază

Total-recall folosește embeddings și/sau vectorizare? **Da — dar opțional, lazy-load, complet local, și degradează curat când dependențele native nu sunt prezente.** Nu folosește niciun cloud embedding API.

---

## Unde — modulele implicate

### Tabelul 1 — pipeline-ul de retrieval

| Modul | Rol |
|---|---|
| `src/embeddings.ts` | Lazy-load `@huggingface/transformers`, apelează modelul, upsert-ează vectori, deține promisiunea de init. |
| `src/vectorStore.ts` | Lazy-load `sqlite-vec`, creează tabelul virtual `vec_memories` cu coloană `FLOAT[384]`, expune `upsertVector` / `searchVectors`. |
| `src/rrf.ts` | Reciprocal Rank Fusion — combină cele două liste ordonate într-una singură. |
| `src/server.ts` | Dispatch MCP + poarta "hybrid" (`recall_memory`): rulează TF-IDF + vector search în paralel și le fuzionează via `rrf.ts`; `hybrid: bool` default-ează la true când dependențele native sunt prezente. |
| `package.json` | Dependențe opționale `@huggingface/transformers ^3.8.1`, `sqlite-vec ^0.1.9` — ambele declarate `--external` la esbuild, deci nu sunt bundle-uite. |

### Tabelul 2 — modulele de scoring & storage

| Modul | Rol |
|---|---|
| `src/tfidf.ts` | Tokenize → inverted index → scorare TF-IDF cu Ebbinghaus retention decay per memorie. |
| `src/embeddings.ts` | Lazy-load `@huggingface/transformers` (`Xenova/all-MiniLM-L6-v2`, 384-dim), compute embeddings la write time. |
| `src/vectorStore.ts` | Lazy-load `sqlite-vec`, `vec0` virtual table, KNN la read time. |
| `src/rrf.ts` | Reciprocal Rank Fusion — merge-uiește cele două liste ordonate doar după poziția în rang (k=60). |
| `src/ebbinghaus.ts` | Retenție time-decayed: scorul fiecărei memorii e înmulțit cu `e^(-t/S)` unde `S` depinde de `importanceScore` + boost de `accessCount`. |
| `src/index.ts` | Lifecycle-ul inverted index, `getMemoriesByKeys` pentru lookup direct. |
| `src/server.ts` | Suprafața de unelte MCP — singurul API public. |

### Pipeline `recall_memory(hybrid=true)`

```
query
  │
  ├─► TF-IDF (tfidf.ts + Ebbinghaus decay)
  │
  └─► embed query ─► sqlite-vec KNN
              │
              ▼
        rrf.ts  (Reciprocal Rank Fusion, k=60)
              │
              ▼
        listă finală ordonată
```

---

## De ce — motivele reale de design

### 1. Calitatea recall-ului dincolo de suprapunerea de cuvinte

TF-IDF e exact-token. Un query precum "k8s pod OOM" ratează o memorie titlată "Kubernetes workload killed for memory pressure". Transformerul sentence-encoder pe 384 de dimensiuni captează similaritatea semantică, așa că parafrazele se potrivesc oricum.

### 2. Opțional / lazy / graceful-degrade

Tot punctul `optional-deps.d.ts` + `await import(...)` lazy este că pluginul merge pe mașini air-gapped / minimale unde `@huggingface/transformers` nu poate încărca modelul. Dacă modelul nu se încarcă, `get_stats.recentErrors` înregistrează eșecul — eșecul e observabil, nu tăcut.

### 3. Fuziune RRF, nu interpolare de scoruri

Scorurile TF-IDF și scorurile de similaritate vectorială nu sunt pe aceeași scară, deci media lor e lipsită de sens. RRF folosește **doar poziția în rang** (`Σ 1/(k + rank_i)`), care e scale-free și rețeta standard pentru combinarea retriever-elor eterogene.

### 4. Externalizat în esbuild

Config-ul esbuild marchează ambele dependențe ca `--external` — pluginul e bundle-uat, dependențele native grele NU. Astfel bundle-ul rămâne mic și utilizatorul poate instala/upgrade-a runtime-ul de model independent de plugin.

### 5. Write path conștient de race

`embedAndUpsert` e fire-and-forget pe write path-ul hot, dar `flushPending()` e cablat în handler-ul `SIGTERM`/`SIGINT` (`embeddings.ts:81`) ca ultimii vectori să ajungă pe disc înainte de `process.exit`. Blocul de comentariu din `embeddings.ts:13-25` e explicit: o versiune anterioară avea un race în care writer-ul pierzător își pierdea vectorul — counter-ul `pendingFlushes` e fix-ul.

---

## Ce NU face

- **Nu folosește niciun cloud embedding API** (HuggingFace Inference, OpenAI, Bedrock etc.). Modelul rulează local via runtime-ul ONNX on-device bundle-uit în `@huggingface/transformers`. Dacă utilizatorul e offline, importul reușește dar download-ul modelului pică la prima utilizare — pluginul revine la TF-IDF.
- **Nu re-embed la fiecare citire.** Vectorii se calculează o dată, la scriere, și se stochează în `vector.db`; citirile sunt KNN pur.
- **Nu cere nicio variabilă de mediu sau API key.**

---

## Suprafața de unelte (doar retriever-e; niciun LLM, niciun prompt-building)

| Unealtă | Ce face |
|---|---|
| `search_index` | Doar pe metadate (key, title, preview, score). Fără chunking, fără LLM. |
| `recall_memory` | Conținutul complet al top-K. Fără sinteză. Fără prompt-building. |
| `get_memories_by_keys` | Lookup direct. |
| `get_related_memories` | Jaccard pe tag-uri. |
| `get_timeline` | Felie cronologică. |
| `prune_memories` | Candidați pe bază de Ebbinghaus pentru curățare. |

---

## TL;DR

- **Unde:** `src/embeddings.ts` + `src/vectorStore.ts` + `src/rrf.ts`, suprafațat prin `recall_memory(hybrid: bool)` în `src/server.ts`.
- **De ce:** recall semantic (potrivire de parafraze) peste TF-IDF keyword, cu fuziune RRF; complet opțional, lazy-load, rulează local, degradează curat când dependențele native nu sunt instalate.
- **Ce nu:** niciun cloud API, niciun re-embed la citire, nicio cheie/API var.

---

## Referințe

- **Arhitectura completă:** `../total-recall/plugins/total-recall/ARCHITECTURE.md`
- **Cod sursă:** `../total-recall/plugins/total-recall/src/` (`embeddings.ts`, `vectorStore.ts`, `rrf.ts`, `tfidf.ts`, `ebbinghaus.ts`, `server.ts`)
- **Slide corespondent în prezentare:** `Slide 7b — Embeddings & vectorizare` în `prezentare.ro.md`