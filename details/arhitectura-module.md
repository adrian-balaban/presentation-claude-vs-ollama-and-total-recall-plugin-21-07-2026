# total-recall — arborele complet al modulelor (src/)

> Material de sprijin pentru **Slide 17** din `prezentare.ro.md`.
> ~24 de fișiere TypeScript (fără `__tests__`), o singură dependență obligatorie (`@modelcontextprotocol/sdk`).

```
src/
├── index.ts             ← boot: signal handlers + main()
├── server.ts            ← MCP Server, 17 scheme tool, dispatch
├── state.ts             ← singletons partajate: memIndex, invertedIndex
├── paths.ts             ← căile vault, DEFAULT_CATEGORIES, EXCLUDED_DIRS, ensureDir
├── types.ts             ← MemoryFrontmatter, MemoryMetadata, Index
├── dates.ts             ← utilitare de parsare/normalizare date
├── lru-cache.ts         ← LRUCache class + shared contentCache instance (100 entries, 30 min TTL)
├── persistence.ts       ← loadIndexes, scheduleSave (debounce 1s), flushPending
├── frontmatter.ts       ← parser YAML minimal (fără gray-matter, fără CVE-uri)
├── vault-scan.ts        ← reconcileIndex, slugify, tokenEstimate
├── auto-reconcile.ts    ← reconcile automat al indexului (ex. după git pull pe org-vault)
├── journal.ts           ← jurnalul auto-adăugat la fiecare store în personal-vault
├── privacy-filter.ts    ← SECRET_TOKEN_RE + filtrul fail-closed pentru org sync
├── tfidf.ts             ← tokenize, rebuildInvertedIndex, tfidfSearch
├── ebbinghaus.ts        ← computeRetentionStrength (cu confirmations/flags), daysSince
├── rrf.ts               ← Reciprocal Rank Fusion (k=60)
├── embeddings.ts        ← HuggingFace pipeline (opțional)
├── vectorStore.ts       ← sqlite-vec: upsert/search/delete
├── optional-deps.d.ts   ← declarații de tipuri pentru dependențele opționale
└── tools/
    ├── store.ts         ← store_memory
    ├── recall.ts        ← recall_memory, search_index
    ├── rerank.ts        ← rerank_memories (embeddings + scor cosine, local, fără LLM)
    ├── query.ts         ← list_memories, get_memories_by_keys, get_stats,
    │                       get_timeline, get_related_memories, prune_memories
    ├── mutate.ts        ← update_memory, delete_memory, rebuild_index, confirm_memory
    └── bulk.ts          ← export_memories, import_memories, delete_memories
```
