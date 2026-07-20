# The search algorithm: TF-IDF + Ebbinghaus, in detail

> Support material for the "The search algorithm" section in `prezentare.ro.md`.

## What is TF-IDF?

**Term Frequency × Inverse Document Frequency** — the classic text search algorithm: a word scores highly if it appears **often in the given document** (TF) but **rarely in the rest of the collection** (IDF). "postgresql" appearing 5 times in one memory and almost nowhere else = high score; "project", which appears everywhere = near-zero score.

**Inverted index** = the reverse map `word → list of documents that contain it`, like the index at the end of a book — this is why search does not read the files, only the index.

## `recall_memory` pipeline

```
query (free text)
  │
  ├─ tfidfSearch(query)
  │    ├─ tokenize(query) → tokens
  │    ├─ for each token: lookup in invertedIndex
  │    ├─ score = TF × IDF × title-boost(2×) × tag-boost(1.5×)
  │    └─ × computeRetentionStrength(importance, daysSince, accessCount)
  │
  ├─ [optional: hybrid=true + dependencies installed]
  │    ├─ embed(query) → query vector
  │    ├─ searchVector(db, qvec, 50) → vector results
  │    └─ Reciprocal Rank Fusion([tfidf, vector], k=60)
  │              score(d) = Σ 1/(60 + rank(d)) over both lists
  │
  └─ slice at `limit`, bump accessCount, return with/without full content
```

## The Ebbinghaus curve (forgetting modeled mathematically)

```
λ     = 0.16 × (1 − importanceScore × 0.8)
decay = importanceScore × exp(−λ × daysSince)
        × (1 + accessCount × 0.2 + confirmations × 0.1 − flags × 0.1)
        — result clamped to [0, 1]
```

| importanceScore | λ (forgetting rate) | Behavior                                        |
| --------------- | -------------------- | ----------------------------------------------- |
| 1.0 (critical)  | 0.032                | Slow decay — the memory stays relevant for weeks |
| 0.5 (normal)    | 0.096                | Medium decay                                    |
| 0.3 (low)       | 0.122                | Fast decay — disappears from results within days |

## Feedback reinforces the memory

Each access adds +20% retention strength (`accessCount × 0.2`); each confirmation +10%, each flag −10% (`confirm_memory`) — the memory does not just "age", it receives feedback.

The boosts in the TF-IDF score: a match in the **title** counts double (title-boost 2×), a match in **tags** 1.5× (tag-boost) — a term found in the memory's title is a much stronger signal than one found in the body.