---
title: "Total Recall Plugin & Claude vs Ollama"
author: Adrian Balaban
data: 2026-07-16
layout: docs
---

# Total Recall Plugin & Claude vs Ollama

**Autor:** Adrian Balaban  
**Data:** 16 iulie 2026

Două subiecte practice despre cum extindem și alegem uneltele AI în workflow-ul de zi cu zi:
primul despre persistența memoriei în Claude Code printr-un plugin MCP; al doilea despre decizia
„cloud sau local" când lucrezi cu modele de limbaj mari.

---

## Slide 0 — Ce iei din această sesiune

> Nu teorie generică — decizii concrete pe care le poți lua mâine dimineață.

Cinci lucruri pe care le iei de aici:

1. **Cum funcționează total-recall** — arhitectura MCP, vaulturile, hook-urile și algoritmul de căutare cu Ebbinghaus decay.
2. **Cum îl instalezi și îl folosești** — de la `install.sh` până la skill-ul `/memory-workflow`.
3. **Ce este Ollama și de ce contează** — modele locale, zero cost-per-token, fără date trimise în cloud.
4. **Comparație directă Claude vs Ollama** — capabilități, confidențialitate, cost, viteză, integrare cu Claude Code.
5. **Când să alegi fiecare** — un ghid de decizie cu criterii clare.

---

## Slide 0b — Agendă (~55 de minute)

1. **Total Recall Plugin** (25 min)
   - Ce este și de ce există → *Slide 1–2*
   - Arhitectura și componentele → *Slide 3–5*
   - Cele 12 unelte MCP → *Slide 6*
   - Algoritmul de căutare → *Slide 7*
   - Hook-urile și ciclul de viață → *Slide 8*
   - Instalare și utilizare practică → *Slide 9*
   - Compatibilitate (Copilot / Codex) → *Slide 10*

2. **Claude vs Ollama** (25 min)
   - Ce este Ollama → *Slide 11–12*
   - Comparație directă → *Slide 13–15*
   - Cazuri de utilizare și decizie → *Slide 16–17*

3. **Q&A** (15 min)

---

## TEMA 1 — TOTAL RECALL PLUGIN

---

## Slide 1 — Problema: Claude uită tot după sesiune

> La sfârșitul fiecărei conversații, Claude pierde tot contextul acumulat.
> Decizii, preferințe, arhitecturi discutate — totul dispare.

**Simptomele:**
- Reexplici același context la fiecare sesiune nouă
- Preferințele tale de cod trebuie re-menționate de fiecare dată
- Deciziile de arhitectură nu se acumulează nicăieri
- Feedback-ul pe care l-ai dat modelului nu persistă

**Consecința:** Cu cât lucrezi mai mult cu Claude Code, cu atât pierzi mai mult timp re-explicând ceea ce ai deja explicat.

---

## Slide 2 — Soluția: total-recall

> Un plugin Claude Code care dă AI-ului memorie persistentă, căutabilă, între sesiuni.

**Ce este:**
- **Plugin Claude Code** instalat din marketplace
- **MCP server** cu 12 unelte (stdio, înregistrat via `claude mcp add`)
- **Vault de fișiere Markdown** stocat local la `~/.total-recall/`
- **Hook-uri automate** care injectează contextul la fiecare sesiune nouă
- **Skill `/memory-workflow`** pentru sesiuni structurate de recall/store

**Ce nu este:**
- Nu trimite date în cloud (vaultul personal este complet local)
- Nu folosește o bază de date opacă — fiecare memorie este un fișier `.md` citibil
- Nu suprascrie context — injectează, nu înlocuiește

---

## Slide 3 — Structura pe disk

```
~/.total-recall/
├── index.json               ← index plat: key → MemoryMetadata
├── invertedIndex.json       ← TF-IDF inverted index: token → {docs, idf}
├── .index-cache.txt         ← rezumat injectat la SessionStart (shell-readable)
├── personal-vault/
│   ├── architecture/
│   │   └── db-choice.md     ← memorie individuală: frontmatter YAML + corp Markdown
│   ├── feedback/
│   ├── knowledge/
│   ├── project/
│   └── vectors.db           ← embeddings sqlite-vec (opțional)
└── org/
    └── org-vault/
        └── architecture/
            └── team-decision.md   ← memorii partajate cu echipa, sync pe git
```

**Fiecare memorie** este un fișier `.md` cu frontmatter:

```markdown
---
title: "Preferă PostgreSQL pentru date relaționale"
tags: [architecture, database, feedback]
author: adrianb
importanceScore: 0.8
created: 2026-06-01T10:00:00Z
updated: 2026-06-15T14:30:00Z
---

## Executive Summary

Preferă PostgreSQL față de MySQL pentru proiecte noi...
```

---

## Slide 4 — Arhitectura: modulele principale

```
src/
├── index.ts          ← boot: signal handlers + main()
├── server.ts         ← MCP Server, 12 scheme tool, dispatch
├── state.ts          ← singletons partajate: memIndex, invertedIndex
├── paths.ts          ← căile vault, EXCLUDED_DIRS, ensureDir
├── types.ts          ← MemoryFrontmatter, MemoryMetadata, Index
├── lru-cache.ts      ← LRUCache (100 intrări, 30 min TTL)
├── persistence.ts    ← loadIndexes, scheduleSave (debounce 1s), flushPending
├── frontmatter.ts    ← parser YAML minimal (fără gray-matter, fără CVE-uri)
├── vault-scan.ts     ← reconcileIndex, slugify, tokenEstimate
├── tfidf.ts          ← tokenize, rebuildInvertedIndex, tfidfSearch
├── ebbinghaus.ts     ← computeRetentionStrength, daysSince
├── rrf.ts            ← Reciprocal Rank Fusion (k=60)
├── embeddings.ts     ← HuggingFace pipeline (opțional)
├── vectorStore.ts    ← sqlite-vec: upsert/search/delete
└── tools/
    ├── store.ts      ← store_memory
    ├── recall.ts     ← recall_memory, search_index
    ├── query.ts      ← list_memories, get_memories_by_keys, get_stats,
    │                    get_timeline, get_related_memories, prune_memories
    └── mutate.ts     ← update_memory, delete_memory, rebuild_index
```

---

## Slide 5 — Dual Vault: personal vs org

```
store_memory(tags=[...])
       │
       ├── conține "org"  ──►  ORG VAULT  (~/.total-recall/org/org-vault/)
       │                        key prefix: "org/"
       │                        scriere protejată de autor
       │                        sync automat → git repo echipă (branch org-vault)
       │                        filtru de confidențialitate înainte de push
       │
       └── altfel         ──►  PERSONAL VAULT  (~/.total-recall/personal-vault/)
                                key: cale relativă simplă
                                jurnal auto-adăugat la fiecare store
```

**Regulă cheie:** tagurile `personal` și `org` sunt mutual exclusive — `store_memory` aruncă eroare dacă ambele sunt prezente.

**Filtru de confidențialitate (org sync):**
- Blochează token-uri cu entropie ridicată (secrete, chei API)
- Blochează toate adresele email (cu excepția domeniilor din allowlist)
- Fail-closed: dacă filtrul nu poate analiza conținutul, NU face push

---

## Slide 6 — Cele 12 unelte MCP

### Scriere
| Unealtă | Ce face |
|---|---|
| `store_memory` | Creează o memorie nouă; `force=true` suprascrie |
| `update_memory` | Modifică titlu/conținut/taguri/importanceScore |
| `delete_memory` | Șterge fișierul + intrarea din index + vectorul |

### Căutare / Citire
| Unealtă | Ce face |
|---|---|
| `recall_memory` | TF-IDF + Ebbinghaus + opțional vector search via RRF |
| `search_index` | TF-IDF doar pe metadate (fără citire fișiere, fără bump accessCount) |
| `get_memories_by_keys` | Lookup direct după cheie; trece prin LRU cache |

### Listare / Interogare
| Unealtă | Ce face |
|---|---|
| `list_memories` | Inventar paginat cu filtre pe categorie/tag |
| `get_related_memories` | Similaritate Jaccard pe taguri + boost categorie (0.2) |
| `get_timeline` | Memorii ordonate după `updated` |
| `get_stats` | Contoare, statistici cache, percentile performanță, erori recente |

### Întreținere
| Unealtă | Ce face |
|---|---|
| `rebuild_index` | `reconcileIndex()` + rebuild TF-IDF; păstrează `accessCount`/`lastAccessed` |
| `prune_memories` | **Listează** candidații cu retenție scăzută (Ebbinghaus); NU șterge automat |

---

## Slide 7 — Algoritmul de căutare: TF-IDF + Ebbinghaus

### Pipeline `recall_memory`

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

### Curba Ebbinghaus (uitarea modelată matematic)

```
λ     = 0.16 × (1 − importanceScore × 0.8)
decay = importanceScore × exp(−λ × daysSince) × (1 + accessCount × 0.2)
```

| importanceScore | λ (viteza de uitare) | Comportament |
|---|---|---|
| 1.0 (critic) | 0.032 | Decay lent — memoria rămâne relevantă săptămâni |
| 0.5 (normal) | 0.096 | Decay mediu |
| 0.3 (scăzut) | 0.122 | Decay rapid — dispare din rezultate în zile |

Fiecare acces adaugă +20% forță de retenție (`accessCount × 0.2`).

---

## Slide 8 — Hook-urile: integrarea automată cu Claude Code

### `SessionStart` (4 pași, secvențiali)

```
1. pull-org-vault.sh       — git pull pe branch-ul org-vault (dacă e configurat)
2. build-memory-index.sh   — scanare awk a frontmatter-ului → .index-cache.txt
3. load-memory-index.sh    — cat .index-cache.txt → injectat în context
4. load-open-questions.sh  — cat open-questions.md → injectat în context
```

**Efect:** La fiecare nouă sesiune, Claude primește automat rezumatul tuturor memoriilor tale — fără să ceri explicit.

### `PostToolUse` (declanșator: `store_memory|update_memory|delete_memory`)

```
sync-org-memory.sh
  ├─ verifică dacă memoria are tag "org"
  ├─ aplică filtrul de confidențialitate
  └─ git add/commit/push → branch org-vault al echipei
  + rebuild .index-cache.txt
```

### `PreCompact` (când contextul e aproape de limită)

```
extract-and-store-memories.sh
  ├─ citește transcriptul sesiunii din stdin JSON (transcript_path)
  ├─ cere lui Claude să extragă 0–3 learnings cheie ca JSON lines
  └─ store-learning.mjs → scrie direct ca fișiere .md în personal-vault
       (fără round-trip MCP; nu suprascrie memorii existente)
```

---

## Slide 9 — Instalare și utilizare practică

### Instalare

```bash
# 1. Clonează marketplace-ul
git clone https://github.com/adrian-balaban/my-claude-plugins-marketplace.git

# 2. Rulează installerul
cd my-claude-plugins-marketplace/plugins/total-recall
./install.sh

# Optional: cu org vault
./install.sh --org-repo git@github.com:echipa/memories.git \
             --allowed-email-domain companie.ro
```

### Utilizare în sesiune Claude Code

```
# Caută memorii
> "reamintește-mi decizia despre baza de date"
→ recall_memory(query="decizie baza de date")

# Stochează o memorie
> "reține că preferăm PostgreSQL cu partitionare pe lună"
→ store_memory(title="...", content="...", tags=["architecture", "database"])

# Listează tot
> "arată-mi toate memoriile de arhitectură"
→ list_memories(category="architecture")

# Skill dedicat
> /total-recall:memory-workflow
```

### Ordinea de recuperare (din eficiență → completitudine)

1. Index injectat la SessionStart (gratuit — deja în context)
2. `get_memories_by_keys(summary=true)` — dacă știi cheia
3. `search_index(query=...)` — metadate rapid, fără citire fișiere
4. `recall_memory(query=..., full=false)` — TF-IDF + Ebbinghaus
5. `recall_memory(query=..., full=true)` — cu conținut complet

---

## Slide 10 — Compatibilitate: Claude Code vs Copilot vs Codex

| Componentă | Claude Code | GitHub Copilot | OpenAI Codex CLI |
|---|---|---|---|
| **MCP Server (12 unelte)** | ✅ Nativ | ✅ stdio MCP suportat | ✅ `~/.codex/config.toml` |
| **Hook-uri** (SessionStart/PostToolUse/PreCompact) | ✅ Nativ | ❌ Nu există echivalent | ❌ Nu există echivalent |
| **Skill `/memory-workflow`** | ✅ Nativ | ❌ Slash commands doar CC | ❌ Nu există |
| **Index auto-injectat** | ✅ Via hook | ❌ Manual `search_index` | ❌ Manual |
| **Org sync automat** | ✅ Via hook | ❌ Manual `sync-org-memory.cjs` | ❌ Manual |
| **Extragere learnings** | ✅ Via PreCompact | ❌ Nu | ❌ Nu |

**Concluzie:** Cele 12 unelte MCP funcționează oriunde există un client MCP stdio.
Magia automată (injecție context, sync org, extragere learnings) este exclusivă Claude Code.

---

## TEMA 2 — CLAUDE vs OLLAMA

---

## Slide 11 — Ce este Ollama?

> Ollama este un tool open-source care îți permite să rulezi modele LLM mari **local**,
> pe propriul hardware, fără nicio conexiune la internet și fără cost per token.

**Ce face Ollama:**
- Descarcă și rulează modele quantizate local (Llama, Mistral, Gemma, Phi, Qwen, etc.)
- Expune o **API REST compatibilă cu OpenAI** pe `http://localhost:11434`
- Gestionează memoria GPU/CPU, contextul și concurența
- Funcționează pe macOS, Linux, Windows (cu/fără GPU)

**Instalare:**

```bash
# Linux / macOS
curl -fsSL https://ollama.ai/install.sh | sh

# Descarcă și pornește un model
ollama pull llama3.2
ollama run llama3.2
# sau direct via API:
curl http://localhost:11434/api/generate \
  -d '{"model":"llama3.2","prompt":"Salut!"}'
```

**Modele populare disponibile:**

| Model | Dimensiune | VRAM necesar | Calitate |
|---|---|---|---|
| `llama3.2:3b` | ~2 GB | 4 GB | Bun pentru sarcini simple |
| `llama3.1:8b` | ~5 GB | 8 GB | Echilibru bun |
| `llama3.3:70b` | ~40 GB | 48+ GB | Aproape de GPT-4o |
| `mistral:7b` | ~4 GB | 8 GB | Bun pentru cod |
| `deepseek-coder:33b` | ~19 GB | 24+ GB | Specializat cod |
| `qwen2.5-coder:32b` | ~18 GB | 24+ GB | Cod, multilingual |

---

## Slide 12 — Cum funcționează Ollama intern

```
Cerere utilizator
       │
       ▼
┌─────────────────────────────────────────────────────────────┐
│                    Ollama daemon (local)                     │
│                                                             │
│   ┌─────────────┐     ┌──────────────┐    ┌─────────────┐  │
│   │  API REST   │────►│  Model mgr   │───►│  llama.cpp  │  │
│   │ :11434      │     │  (GGUF/Q4)   │    │  inference  │  │
│   └─────────────┘     └──────────────┘    └──────┬──────┘  │
│                                                   │         │
│                                          GPU (CUDA/Metal)   │
│                                          sau CPU fallback   │
└───────────────────────────────────────────────────┼─────────┘
                                                    │
                                               Răspuns tokenizat
```

**Quantizare** (de ce modelele de 70B încap pe 48GB VRAM):
- Parametrii modelului sunt comprimate de la float32 (4 bytes/param) la int4 (0.5 bytes/param)
- Pierdere de calitate: ~2-5% față de versiunea completă
- Format standard: **GGUF** (GPT-Generated Unified Format)

**Context window:** limitat de VRAM disponibil — un model de 8B pe 8GB VRAM poate susține context de ~8K tokens; Llama 3.1 70B pe 48GB poate susține 128K tokens.

---

## Slide 13 — Comparație directă: Claude vs Ollama

| Criteriu | Claude (API Anthropic) | Ollama (local) |
|---|---|---|
| **Modele disponibile** | Claude Sonnet 4.6, Opus 4.8, Haiku 4.5 | Llama, Mistral, Gemma, Phi, Qwen, DeepSeek etc. |
| **Calitate top-tier** | ✅ Claude Opus 4.8 = state of the art | Llama 3.3 70B ≈ GPT-4o, dar sub Opus |
| **Cost per token** | $3–$15 / 1M tokens (input) | $0 — hardware propriu |
| **Cost infrastructură** | $0 (fără server propriu) | GPU bun: $500–$3000+ |
| **Confidențialitate** | Date trimise la Anthropic | 100% local, zero egress |
| **Latență** | ~500ms–2s primul token | ~100ms–500ms (GPU local) |
| **Context window** | 200K tokens (Sonnet/Opus) | 4K–128K (depinde de model+VRAM) |
| **Raționament avansat** | ✅ Excelent (extended thinking) | Limitat la modele mici-medii |
| **Disponibilitate** | Necesită internet + API key | Funcționează offline |
| **Actualizări model** | Automate (Anthropic) | Manual (`ollama pull`) |
| **Integrare Claude Code** | ✅ Nativă (este produsul Anthropic) | ⚠️ Prin proxy OpenAI-compat |
| **Limită rate** | Există (nivel API) | Nelimitată (hardware propriu) |
| **GDPR / compliante** | Politici Anthropic | On-premise complet |

---

## Slide 14 — Costul real: Claude API vs Ollama

### Claude API (Sonnet 4.6)

```
Input:  $3.00 / 1M tokens
Output: $15.00 / 1M tokens

Sesiune tipică de cod (8h/zi, developer activ):
  Input:  ~200K tokens/zi  → $0.60/zi
  Output: ~50K tokens/zi   → $0.75/zi
  TOTAL:  ~$1.35/zi → ~$30/lună
```

### Ollama pe hardware local

```
GPU RTX 4090 (24GB VRAM): ~$2,000 hardware
  → rulează Llama 3.3 70B Q4, DeepSeek-Coder 33B
  → ROI față de API la nivel developer: ~5-6 luni de utilizare intensă

GPU RTX 3080 (10GB VRAM): ~$600 second-hand
  → rulează Llama 3.1 8B, Mistral 7B, Qwen 7B
  → calitate mai mică, dar zero cost operațional
  → ROI: ~1-2 luni

Fără GPU (CPU only):
  → Phi-3 mini 3.8B, Gemma 2B: lent (3-8 tok/s) dar funcțional
  → Hardware cost: $0
```

**Concluzie financiară:** Ollama devine mai ieftin decât API-ul Claude în 2-6 luni dacă ai sau cumperi un GPU decent. Sub un GPU de ~$600, diferența de calitate poate să nu merite.

---

## Slide 15 — Confidențialitate și date: diferența crucială

### Claude API

```
Cerere utilizator
       │  (HTTPS la api.anthropic.com)
       ▼
Serverele Anthropic (US)
       │
       ├── Procesare → răspuns
       ├── Logging (audit, safety) — politici Anthropic
       └── Training data? → Implicit NU, dar citiți ToS
```

**Ce înseamnă practic:**
- Codul tău (parțial sau complet) este trimis la Anthropic
- Secretele din prompt ajung pe servere externe
- GDPR: Anthropic are DPA disponibil, dar datele ies din EU
- Contracte enterprise pot restricționa utilizarea API-ului cloud

### Ollama (local)

```
Cerere utilizator
       │
       ▼
localhost:11434
       │
       ▼
Model GGUF în RAM/VRAM — NICIODATĂ în afara mașinii
```

**Ce înseamnă practic:**
- Codul tău, secretele, datele clientului — rămân pe mașina ta
- Zero egress de date
- Funcționează în rețele izolate (air-gapped)
- Util în: finance, healthcare, proiecte cu NDA strict, codebases proprietare

---

## Slide 16 — Ollama cu Claude Code: integrarea practică

Claude Code acceptă servere OpenAI-compatibile prin variabila de mediu:

```bash
# Pornește Ollama cu modelul dorit
ollama pull qwen2.5-coder:32b

# Configurează Claude Code să folosească Ollama
export ANTHROPIC_BASE_URL=http://localhost:11434/v1
export ANTHROPIC_API_KEY=ollama   # orice string non-gol

# Pornește Claude Code cu modelul Ollama
claude --model qwen2.5-coder:32b
```

**Sau permanent în `~/.claude/settings.json`:**

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "http://localhost:11434/v1",
    "ANTHROPIC_API_KEY": "ollama"
  }
}
```

**Limitări cunoscute când folosești Ollama cu Claude Code:**
- Anumite funcții Claude Code avansate (extended thinking, computer use) nu funcționează cu modele non-Anthropic
- Calitatea output-ului depinde complet de modelul ales
- Tool use / function calling: funcționează cu modele care suportă (Llama 3.x, Mistral, Qwen 2.5)
- Context window mai mic poate trunchia fișiere mari

---

## Slide 17 — Ghid de decizie: Claude API sau Ollama?

```
┌─────────────────────────────────────────────────────────────────┐
│                     Întrebare de pornire                        │
│           Datele tale pot ieși din infrastructura ta?           │
└─────────────────────────┬───────────────┬───────────────────────┘
                          │ NU            │ DA
                          ▼               ▼
              ┌────────────────────┐  ┌──────────────────────────┐
              │   Ollama (local)   │  │  Alege după alte criterii │
              │   obligatoriu      │  └──────────┬───────────────┘
              └────────────────────┘             │
                                    ┌────────────▼────────────────┐
                                    │  Ai nevoie de calitate      │
                                    │  top-tier (raționament      │
                                    │  complex, cod avansat)?     │
                                    └────────────┬────────────────┘
                                         NU │         │ DA
                                            ▼         ▼
                                     Ollama cu   Claude API
                                     model 7-8B  (Sonnet/Opus)
                                     + cost $0   + calitate max
```

**Scenarii recomandate:**

| Scenariu | Alegere | Model recomandat |
|---|---|---|
| Proiect cu date sensibile / NDA | Ollama | DeepSeek Coder 33B sau Qwen 2.5 Coder 32B |
| Echipă enterprise cu restricții cloud | Ollama | Llama 3.3 70B (server local) |
| Prototipare rapidă, calitate maximă | Claude API | Sonnet 4.6 sau Opus 4.8 |
| Developer indie, buget limitat | Ollama | Llama 3.1 8B sau Qwen 2.5 7B |
| Sarcini critice de raționament | Claude API | Opus 4.8 cu extended thinking |
| Cod cu context mare (>50K tokens) | Claude API | Sonnet 4.6 (200K context) |
| Offline / air-gapped | Ollama | Orice model descărcat prealabil |
| Echipă cu GPU server partajat | Ollama | Llama 3.3 70B, server central |

---

## Slide 18 — Sinteza finală și întrebări deschise

### Ce am acoperit

**Total Recall:**
- Plugin MCP cu 12 unelte pentru memorie persistentă în Claude Code
- Vault dual: personal (local) + org (sync git cu privacy filter)
- Căutare: TF-IDF + Ebbinghaus decay + opțional vector hybrid
- Hook-uri automate: injecție context, sync, extragere learnings
- Portabil pe Copilot/Codex (MCP), fără automatizări (hooks)

**Claude vs Ollama:**
- Claude API: calitate maximă, cost per token, date în cloud
- Ollama: gratuit pe hardware propriu, 100% local, offline capabil
- Integrare Ollama cu Claude Code: posibilă via OpenAI-compat endpoint
- Decizia cheie: confidențialitate > calitate > cost

### Întrebări deschise pentru discuție

1. Cum integrezi total-recall într-o echipă? (org vault, drepturi de scriere)
2. Ce modele Ollama ați testat pe hardware de lucru real?
3. Există scenarii unde ați combina ambele: Ollama pentru cod, Claude pentru analiză?
4. Cum gestionezi actualizările de model în Ollama față de API (fără breaking changes)?
5. Strategii de backup pentru vaultul total-recall?

---

## Slide 19 — Resurse

### Total Recall
- **Repo:** `github/claude-plugins-total-recall/`
- **Arhitectura detaliată:** `plugins/total-recall/ARCHITECTURE.md`
- **Instalare:** `plugins/total-recall/install.sh --help`
- **README:** `plugins/total-recall/README.md`

### Ollama
- **Site oficial:** ollama.com
- **Hub modele:** ollama.com/library
- **API reference:** ollama.com/docs (compatibilă OpenAI)
- **Integrare Claude Code:** variabila `ANTHROPIC_BASE_URL`

### Claude API
- **Documentație:** docs.anthropic.com
- **Modele curente:** claude-sonnet-4-6, claude-opus-4-8, claude-haiku-4-5
- **Prețuri:** anthropic.com/pricing
- **DPA / GDPR:** anthropic.com/legal

---

**Q&A — 15 minute**

> Mulțumesc pentru participare. Cod, arhitecturi și întrebări — le abordăm pe toate.
