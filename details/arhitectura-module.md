# total-recall — the complete module tree (src/)

> Support material for the "Architecture: the main modules" section of `prezentare.ro.md`.


```
src/
├── index.ts             ← boot: signal handlers + main()
├── server.ts            ← MCP Server, 17 tool schemas, dispatch
├── state.ts             ← shared singletons: memIndex, invertedIndex
├── paths.ts             ← vault paths, DEFAULT_CATEGORIES, EXCLUDED_DIRS, ensureDir
├── types.ts             ← MemoryFrontmatter, MemoryMetadata, Index
├── dates.ts             ← date parsing/normalization utilities
├── lru-cache.ts         ← LRUCache class + shared contentCache instance (100 entries, 30 min TTL)
├── persistence.ts       ← loadIndexes, scheduleSave (debounce 1s), flushPending
├── frontmatter.ts       ← minimal YAML parser (no gray-matter, no CVEs)
├── vault-scan.ts        ← reconcileIndex, slugify, tokenEstimate
├── auto-reconcile.ts    ← automatic index reconciliation (e.g. after git pull on org-vault)
├── journal.ts           ← auto-appended journal on every store in personal-vault
├── privacy-filter.ts    ← SECRET_TOKEN_RE + fail-closed filter for org sync
├── tfidf.ts             ← tokenize, rebuildInvertedIndex, tfidfSearch
├── ebbinghaus.ts        ← computeRetentionStrength (with confirmations/flags), daysSince
├── rrf.ts               ← Reciprocal Rank Fusion (k=60)
├── embeddings.ts        ← HuggingFace pipeline (optional)
├── vectorStore.ts       ← sqlite-vec: upsert/search/delete
├── optional-deps.d.ts   ← type declarations for optional dependencies
└── tools/
    ├── store.ts         ← store_memory
    ├── recall.ts        ← recall_memory, search_index
    ├── rerank.ts        ← rerank_memories (embeddings + cosine score, local, no LLM)
    ├── query.ts         ← list_memories, get_memories_by_keys, get_stats,
    │                       get_timeline, get_related_memories, prune_memories
    ├── mutate.ts        ← update_memory, delete_memory, rebuild_index, confirm_memory
    └── bulk.ts          ← export_memories, import_memories, delete_memories
```