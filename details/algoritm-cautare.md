# Algoritmul de căutare: TF-IDF + Ebbinghaus, în detaliu

> Material de sprijin pentru secțiunea „Algoritmul de căutare" din `prezentare.ro.md`.

## Ce e TF-IDF?

**Term Frequency × Inverse Document Frequency** — algoritmul clasic de căutare text: un cuvânt punctează mult dacă apare **des în documentul respectiv** (TF) dar **rar în restul colecției** (IDF). „postgresql" care apare de 5 ori într-o memorie și aproape nicăieri altundeva = scor mare; „proiect", care apare peste tot = scor aproape zero.

**Inverted index** = harta inversă `cuvânt → lista documentelor care îl conțin`, ca indexul de la finalul unei cărți — de asta căutarea nu citește fișierele, doar indexul.

## Pipeline `recall_memory`

```
query (text liber)
  │
  ├─ tfidfSearch(query)
  │    ├─ tokenize(query) → tokens
  │    ├─ pentru fiecare token: lookup în invertedIndex
  │    ├─ scor = TF × IDF × title-boost(2×) × tag-boost(1.5×)
  │    └─ × computeRetentionStrength(importance, daysSince, accessCount)
  │
  ├─ [opțional: hybrid=true + dependențe instalate]
  │    ├─ embed(query) → vector query
  │    ├─ searchVector(db, qvec, 50) → rezultate vectoriale
  │    └─ Reciprocal Rank Fusion([tfidf, vector], k=60)
  │              scor(d) = Σ 1/(60 + rank(d)) pe ambele liste
  │
  └─ slice la `limit`, bump accessCount, returnează cu/fără conținut complet
```

## Curba Ebbinghaus (uitarea modelată matematic)

```
λ     = 0.16 × (1 − importanceScore × 0.8)
decay = importanceScore × exp(−λ × daysSince)
        × (1 + accessCount × 0.2 + confirmations × 0.1 − flags × 0.1)
        — rezultat limitat (clamp) la [0, 1]
```

| importanceScore | λ (viteza de uitare) | Comportament                                    |
| --------------- | -------------------- | ----------------------------------------------- |
| 1.0 (critic)    | 0.032                | Decay lent — memoria rămâne relevantă săptămâni |
| 0.5 (normal)    | 0.096                | Decay mediu                                     |
| 0.3 (scăzut)    | 0.122                | Decay rapid — dispare din rezultate în zile     |

## Feedback-ul întărește memoria

Fiecare acces adaugă +20% forță de retenție (`accessCount × 0.2`); fiecare confirmare +10%, fiecare flag −10% (`confirm_memory`) — memoria nu doar „îmbătrânește", ci primește feedback.

Boost-urile din scorul TF-IDF: potrivirea în **titlu** contează dublu (title-boost 2×), potrivirea în **taguri** de 1,5× (tag-boost) — un termen găsit în titlul memoriei e un semnal mult mai puternic decât unul găsit în corp.
