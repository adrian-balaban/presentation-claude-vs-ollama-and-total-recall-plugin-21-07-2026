# total-recall — the 17 MCP tools, in full

> Support material for the "The 17 MCP tools" section in `prezentare.ro.md`.

## Write

| Tool              | What it does                                                                        |
| ----------------- | ----------------------------------------------------------------------------------- |
| `store_memory`    | Creates a new memory; `force=true` overwrites                                       |
| `update_memory`   | Modifies title/content/tags/importanceScore (with re-embed on any change)           |
| `delete_memory`   | Deletes the file + the index entry + the vector                                     |
| `delete_memories` | Bulk delete with explicit confirmation                                              |
| `confirm_memory`  | Bumps `confirmations`/`flags` — quality feedback integrated into the Ebbinghaus score |

## Search / Read

| Tool                   | What it does                                                                                |
| ---------------------- | ------------------------------------------------------------------------------------------- |
| `recall_memory`        | TF-IDF + Ebbinghaus + optional vector search via RRF                                        |
| `search_index`         | TF-IDF on metadata only (no file reads, no accessCount bump)                                |
| `get_memories_by_keys` | Direct lookup by key; goes through the LRU cache                                            |
| `rerank_memories`      | Local semantic rerank: re-embeds query + candidates and sorts by cosine score (no LLM call) |

## List / Query

| Tool                   | What it does                                                       |
| ---------------------- | ------------------------------------------------------------------ |
| `list_memories`        | Paginated inventory with category/tag filters                      |
| `get_related_memories` | Jaccard similarity on tags + category boost (0.2)                  |
| `get_timeline`         | Memories ordered by `updated`                                      |
| `get_stats`            | Counters, cache stats, performance percentiles, recent errors      |

## Maintenance

| Tool              | What it does                                                                |
| ----------------- | --------------------------------------------------------------------------- |
| `rebuild_index`   | `reconcileIndex()` + TF-IDF rebuild; preserves `accessCount`/`lastAccessed` |
| `prune_memories`  | **Lists** low-retention candidates (Ebbinghaus); does NOT auto-delete       |
| `export_memories` | Portable export of the vault (the "I'm changing laptops" scenario)          |
| `import_memories` | Import from an export, with dedup                                           |