# total-recall — cele 17 unelte MCP, complet

> Material de sprijin pentru **Slide 20** din `prezentare.ro.md`.

## Scriere

| Unealtă           | Ce face                                                                           |
| ----------------- | --------------------------------------------------------------------------------- |
| `store_memory`    | Creează o memorie nouă; `force=true` suprascrie                                   |
| `update_memory`   | Modifică titlu/conținut/taguri/importanceScore (cu re-embed la orice schimbare)   |
| `delete_memory`   | Șterge fișierul + intrarea din index + vectorul                                   |
| `delete_memories` | Bulk delete cu confirmare explicită                                               |
| `confirm_memory`  | Bump `confirmations`/`flags` — feedback de calitate integrat în scorul Ebbinghaus |

## Căutare / Citire

| Unealtă                | Ce face                                                                                     |
| ---------------------- | ------------------------------------------------------------------------------------------- |
| `recall_memory`        | TF-IDF + Ebbinghaus + opțional vector search via RRF                                        |
| `search_index`         | TF-IDF doar pe metadate (fără citire fișiere, fără bump accessCount)                        |
| `get_memories_by_keys` | Lookup direct după cheie; trece prin LRU cache                                              |
| `rerank_memories`      | Semantic rerank local: re-embeddează query + candidați și sortează după scor cosine (fără apel LLM) |

## Listare / Interogare

| Unealtă                | Ce face                                                           |
| ---------------------- | ----------------------------------------------------------------- |
| `list_memories`        | Inventar paginat cu filtre pe categorie/tag                       |
| `get_related_memories` | Similaritate Jaccard pe taguri + boost categorie (0.2)            |
| `get_timeline`         | Memorii ordonate după `updated`                                   |
| `get_stats`            | Contoare, statistici cache, percentile performanță, erori recente |

## Întreținere

| Unealtă           | Ce face                                                                     |
| ----------------- | --------------------------------------------------------------------------- |
| `rebuild_index`   | `reconcileIndex()` + rebuild TF-IDF; păstrează `accessCount`/`lastAccessed` |
| `prune_memories`  | **Listează** candidații cu retenție scăzută (Ebbinghaus); NU șterge automat |
| `export_memories` | Export portabil al vault-ului (scenariul „schimb laptopul")                 |
| `import_memories` | Import dintr-un export, cu dedup                                            |
