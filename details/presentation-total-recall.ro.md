---
marp: true
paginate: true
title: "Total Recall Plugin — memorie persistentă pentru Claude Code"
author: Adrian Balaban
date: 2026-07-21
layout: docs
---

<!-- _paginate: false -->

## TOTAL RECALL PLUGIN (~22 min)

> **Puntea între teme:** ai ales runtime-ul (cloud sau local). Acum să-l faci să țină minte cine ești si ce ai facut — altfel fiecare sesiune o iei de la zero.

---

## Problema: Claude uită tot după sesiune

> La sfârșitul fiecărei conversații, Claude pierde tot contextul acumulat.
> Decizii, preferințe, arhitecturi discutate — totul dispare.

**Simptomele:**

- Reexplici același context la fiecare sesiune nouă
- Preferințele tale de cod trebuie re-menționate de fiecare dată
- Deciziile de arhitectură, info. de infra. si alte categorii de informatii nu se acumulează nicăieri

**Consecința:** Cu cât lucrezi mai mult cu un agent (Claude Code...), cu atât pierzi mai mult timp re-explicând ceea ce ai deja explicat.

---

## Problema · Cine mai vrea asta: cq (Mozilla.ai)

<!-- ✂️ tăiabil (3) — supapă de timp; cq revine oricum în sinteză și la întrebările deschise -->

> **Cine mai vrea aceasta:** Mozilla.ai a lansat [`cq`](https://github.com/mozilla-ai/cq) (1.2k ⭐) — standard deschis pentru _shared agent learning_. **Complementar, nu concurent** cu total-recall — comparația onestă vine la finalul temei.

---

## Demo: aceeași întrebare, cu și fără memorie

<!--
🎬 Regie — payoff-ul emoțional al întregii teme.
Lipsync: varianta primară e înregistrarea asciinema de 20 s (casts/demo-cu-fara-memorie.cast); live doar dacă sala permite.

Pregătire înainte de prezentare — stochează memoria:
  „stochează memoria urmatoare de architecture pentru db-choice: am ales PostgreSQL față de MySQL pentru JSONB"
  → Stocat: architecture/db-choice (personal vault, importanceScore 0.7, taguri: database, postgresql, mysql, jsonb, adr, decision).
  Pluginul verifică duplicatele cu search_index și scrie Executive Summary cu WHY/HOW; opțional tag no-prune (imutabil, ca un ADR formal) sau tag org (decizie de echipă → org vault).
-->

```

FĂRĂ total-recall (sesiune Claude nouă):          CU total-recall (sesiune nouă, același prompt):
──────────────────────────────────────            ──────────────────────────────────────────────
> care DB am ales pentru proiect?                 > care DB am ales pentru proiect?

„Nu am context despre o decizie                   → recall_memory(query="DB proiect")
anterioară legată de baza de date.                „Conform memoriei architecture/db-choice (creată azi, 13 iulie 2026):Ai ales PostgreSQL (respins MySQL). Motivul decisiv: JSONB e stocare binară a documentelor JSON cu indexare ...
```

Publicul nu trebuie să creadă pe cuvânt — vede diferența pe ecran în 20 de secunde.

---

## Soluția: total-recall

> Un plugin Claude Code care dă AI-ului memorie persistentă, căutabilă, între sesiuni.

<!--
🎬 Regie: rulează pe ecran `claude -p "Reaminteste-ti decizia noastra despre baza de date"` și arată apelul recall_memory în output. Lipsync: înregistrare asciinema ca plasă de siguranță (casts/demo-recall-cli.cast). Pentru public, comanda e „tema de acasă" din handout.
-->

---

## Soluția: total-recall · Ce este și ce NU este

**Ce este:**

- **Plugin Claude Code** instalat din marketplace
- **MCP server** cu 17 unelte (stdio) + **hook-uri automate** care injectează contextul la fiecare sesiune
- **Vault de fișiere Markdown** stocat local la `~/.total-recall/`
- **Skill `/total-recall:memory-workflow`** pentru sesiuni structurate de recall/store

**Ce NU este:**

- Nu trimite date în cloud (vaultul personal este complet local)
- Nu folosește o bază de date opacă — fiecare memorie e un fișier `.md` citibil
- Nu suprascrie context — injectează, nu înlocuiește (system prompt + CLAUDE.md + index memorii + mesajul tău coexistă)

---

## Structura pe disc

> 💡 **WOW:** zero bază de date — memoria AI-ului tău e un folder de fișiere `.md` pe care le poți citi, edita, versiona cu git și deschide în Obsidian.

```
~/.total-recall/
├── index.json               ← index plat: key → MemoryMetadata
├── invertedIndex.json       ← TF-IDF inverted index: token → {docs, idf}
├── .index-cache.txt         ← rezumat injectat la SessionStart (shell-readable)
├── personal-vault/
│   ├── architecture/
│   │   └── db-choice.md     ← memorie individuală: frontmatter YAML + corp Markdown
│   ├── decisions/
│   ├── troubleshooting/
│   ├── meetings/
│   ├── knowledge/
│   ├── journal/
│   └── vectors.db           ← embeddings sqlite-vec (opțional)
└── org/
    └── org-vault/
        └── architecture/
            └── team-decision.md   ← memorii partajate cu echipa, sync pe git
```

---

## Structura pe disc · Anatomia unei memorii

<!-- ✂️ tăiabil (4) — supapă de timp; frontmatter-ul e vizibil și în exemplul din slide-ul „Structura pe disc" -->

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

## Arhitectura: modulele principale

> 💡 **WOW — cifra de pe ecran: `1`.** Un motor de căutare hibrid complet (TF-IDF + vector + curbă de uitare) în ~24 de fișiere TypeScript, cu **o singură dependență obligatorie** (`@modelcontextprotocol/sdk`). Restul — TF-IDF, Ebbinghaus, RRF, parser frontmatter — scris de la zero.

```
┌──────────────────────────┐   ┌──────────────────────────┐
│  INDEX & PERSISTENȚĂ     │   │  CĂUTARE                 │
│  index/state/persistence │   │  tfidf + ebbinghaus      │
│  vault-scan, frontmatter │   │  + rrf + embeddings      │
│  (parser YAML propriu)   │   │  (vector = opțional)     │
└──────────────────────────┘   └──────────────────────────┘
┌──────────────────────────┐   ┌──────────────────────────┐
│  HOOKS & SIGURANȚĂ       │   │  UNELTE MCP (17)         │
│  auto-reconcile, journal │   │  tools/: store, recall,  │
│  privacy-filter          │   │  query, mutate, bulk,    │
│  (fail-closed la push)   │   │  rerank                  │
└──────────────────────────┘   └──────────────────────────┘
```

📄 **Detalii** (arborele complet al celor 24 de fișiere, cu ce face fiecare): [details/arhitectura-module.md](details/arhitectura-module.md)

---

## De ce algoritmi proprii (fără hard dependencies)

<!-- ✂️ tăiabil (2) — supapă de timp; ideea „o singură dependență" e deja pe slide-ul de arhitectură -->

**Ce câștigi:**

1. **Securitate:** fără `gray-matter` → fără CVE-ul `js-yaml` (GHSA-h67p-54hq-rp68)
2. **Scoring coerent:** title-boost, tag-boost, Ebbinghaus = o singură formulă, nu trei librării
3. **Determinism:** zero apeluri LLM, zero cost, merge offline / air-gapped
4. **Auditabilitate:** fiecare decizie de scoring e observabilă prin `get_stats`

> **Filozofia:** dependențele grele = risc de CVE + breaking-change + black-box. Doar ONNX și sqlite-vec rămân externe — și ele opționale.

---

## Dual Vault: personal vs org

> 💡 **WOW:** un simplu tag `org` transformă memoria personală în cunoaștere de echipă — cu filtru de confidențialitate **fail-closed**: dacă nu poate garanta că nu scapă secrete, nu face push.

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

---

## Dual Vault · Filtrul de confidențialitate

**Filtru de confidențialitate (org sync):**

- Blochează secrete și chei API după tipare cunoscute (chei PEM, `sk-`, `ghp_`, `AKIA`, JWT, Slack/GitLab/Google tokens etc.)
- Detectează și **secrete etichetate** — ex. `aws_secret_access_key = …`: un `~/.aws/credentials` lipit din greșeală e blocat înainte de push
- Blochează toate adresele email (cu excepția domeniilor din allowlist)
- Fail-closed: dacă filtrul nu poate analiza conținutul, NU face push

---

## Cele 17 unelte MCP

<!--
🎬 Regie — ideea sticky demonstrată, nu enunțată: spui „reține că prefer PostgreSQL" → modelul alege singur store_memory; întrebi „ce am decis despre DB?" → alege recall_memory. Lipsync: înregistrare asciinema ca plasă de siguranță (casts/demo-store-recall-natural.cast).
-->

> 💡 CRUD complet + căutare + întreținere, **în limbaj natural** — nu înveți 17 nume de unelte.

Harta pe 4 cadrane (cu uneltele-erou):

```
┌── SCRIE ──────────────────────┐  ┌── CITEȘTE ───────────────────────┐
│  store_memory  ★              │  │  recall_memory  ★                │
│  (+ update, delete, confirm)  │  │  (+ search_index, rerank, keys)  │
└───────────────────────────────┘  └──────────────────────────────────┘
┌── LISTEAZĂ ───────────────────┐  ┌── ÎNTREȚINE ─────────────────────┐
│  list_memories                │  │  prune_memories  ★  (doar listă) │
│  (+ timeline, related, stats) │  │  export_memories ★  (portabil)   │
└───────────────────────────────┘  └──────────────────────────────────┘
```

- `rerank_memories` = semantic rerank **local**: re-embeddează query + candidați și sortează după scor cosine — fără niciun apel LLM
- `confirm_memory` = feedback confirm/flag integrat direct în scorul Ebbinghaus

📄 **Detalii** (toate cele 17 unelte, cu descrierea fiecăreia): [details/unelte-mcp.md](details/unelte-mcp.md)

---

## Algoritmul de căutare: TF-IDF + Ebbinghaus

> 💡 **WOW:** memoria AI-ului **uită ca un om** — [curba uitării lui Ebbinghaus](https://en.wikipedia.org/wiki/Forgetting_curve) (1885) aplicată în cod: memoriile neimportante și neaccesate se estompează din rezultate, fiecare accesare le „reîmprospătează" cu +20%.

---

## Algoritmul de căutare · Esența

**TF-IDF pe scurt:** un cuvânt punctează mult dacă apare **des în memoria respectivă**, dar **rar în restul colecției** — căutarea citește doar indexul, nu fișierele. Peste scorul textual se aplică uitarea:

```
decay = importanceScore × exp(−λ × daysSince)
        × (1 + accessCount × 0.2 + confirmations × 0.1 − flags × 0.1)
```

| importanceScore | λ (viteza de uitare) | Comportament                                    |
| --------------- | -------------------- | ----------------------------------------------- |
| 1.0 (critic)    | 0.032                | Decay lent — memoria rămâne relevantă săptămâni |
| 0.5 (normal)    | 0.096                | Decay mediu                                     |
| 0.3 (scăzut)    | 0.122                | Decay rapid — dispare din rezultate în zile     |

Fiecare acces +20% retenție, confirmare +10%, flag −10% (`confirm_memory`) — memoria nu doar „îmbătrânește", ci primește feedback.

📄 **Detalii** (pipeline-ul complet `recall_memory`, TF-IDF & inverted index, RRF, formula λ): [details/algoritm-cautare.md](details/algoritm-cautare.md)

---

## Embeddings și căutare multilinguală (opționale)

> Embeddings = opționale, lazy-load, complet locale (sau via Ollama cu model local). Fără ele, pluginul downgrades la TF-IDF.

**Provideri configurabili** (în `~/.total-recall/config.json`): `huggingface` (implicit, local MiniLM), `ollama` (API local, `bge-m3`).

**Căutare multilinguală:** flag-ul `enableMultilingualSearch: true` activează expansiune de tokeni EN↔RO (ex. „decizie" găsește și „decision").

---

## Embeddings și multilingual · Demo-ul EN↔RO

<!--
🎬 Climaxul TEMEI 2 — momentul pe care dev-ii îl povestesc mai departe.
Lipsync: varianta primară e înregistrarea asciinema (casts/demo-multilingv.cast); live doar dacă rețeaua și sala permit.
-->

Stochezi memoria în **engleză**, apoi într-o sesiune nouă întrebi în **română** — expansiunea „decizie"→„decision" o găsește:

```
# 1. Stochează (în engleză):
> "remember that we chose PostgreSQL over MySQL because of JSONB support"
→ store_memory(title="Database decision: PostgreSQL", tags=["architecture", "database"])

# 2. Într-o sesiune nouă, întreabă în ROMÂNĂ:
> "care a fost decizia noastră despre baza de date?"
→ recall_memory(query="decizie baza de date")
→ expansiunea EN↔RO mapează „decizie"→"decision", „baza de date"→"database"
→ găsește memoria englezească, scor TF-IDF pe tokenii expandați ✅
```

📄 **Detalii** (cum funcționează embeddings & vectorizarea, pipeline-ul ONNX local, sqlite-vec): [details/embeddings-vectorizare.md](details/embeddings-vectorizare.md)

---

## Hook-urile: integrarea automată (Claude Code / Copilot / Gemini)

> 💡 **WOW:** înainte de compactarea contextului (`PreCompact`), pluginul **salvează automat learnings-urile sesiunii** — cunoașterea supraviețuiește chiar și când contextul e șters.

| Hook           | Ce face                                                                     |
| -------------- | --------------------------------------------------------------------------- |
| `SessionStart` | pull org-vault → rebuild index → injectează rezumatul memoriilor în context |
| `PostToolUse`  | la `store/update/delete_memory`: filtru confidențialitate + push org-vault  |
| `PreCompact`   | extrage 0–3 learnings din transcript → le scrie în personal-vault           |
| `SessionEnd`   | loghează sesiunea, flush embeddings                                         |

Rulează și pe **Copilot CLI** și **Gemini CLI** (`hooks.copilot.json` / `hooks.gemini.json`) — dar fără injectarea contextului (clienții ignoră stdout-ul).

📄 **Detalii** (pașii fiecărui hook, scripturile, graceful degradation pe non-Claude): [details/hooks-lifecycle.md](details/hooks-lifecycle.md)

---

## Instalare și utilizare practică

> 💡 **Util:** același plugin, 4 clienți — Claude Code, Copilot CLI, Gemini CLI, standalone — cu un singur `install.sh`.

```bash
git clone https://github.com/adrian-balaban/my-claude-plugins-marketplace.git
cd my-claude-plugins-marketplace/plugins/total-recall && npm install && npm run build

claude plugin install "$(pwd)"    # Claude Code; Copilot/Gemini/standalone: ./install.sh --<client>
```

- **Org vault = opțional, dezactivat implicit** — `personal-vault` merge 100% local, fără git
- În sesiune: „reține că…" → `store_memory`, „reamintește-mi…" → `recall_memory`

📄 **Detalii** (pașii compleți per client, org vault, exemple de utilizare): [details/instalare-total-recall.md](details/instalare-total-recall.md)

---

## Compatibilitate: Claude Code vs Copilot vs Gemini vs Codex

**Trei niveluri de integrare** (povestea din spatele matricei):

1. **Full** — Claude Code: unelte MCP + context injection automat + skills
2. **Parțial** — Copilot / Gemini CLI: uneltele și hooks merg, dar contextul nu se auto-injectează — modelul trebuie să întrebe
3. **Manual** — Codex CLI: doar unelte MCP, fără hooks

---

## Compatibilitate · Matricea (1/2)

| Capabilitate                  | Claude Code | GitHub Copilot CLI     | Gemini CLI             | OpenAI Codex CLI          |
| ----------------------------- | ----------- | ---------------------- | ---------------------- | ------------------------- |
| **MCP Server (17 unelte)**    | ✅ Nativ    | ✅ stdio MCP suportat  | ✅ stdio MCP suportat  | ✅ `~/.codex/config.toml` |
| **Side Effects (Sync/Index)** | ✅ Da       | ✅ Da (hooks automate) | ✅ Da (hooks automate) | ❌ Nu (manual)            |

📄 **Detalii** (matricea completă — context injection, skills; Obsidian; comparația cu `cq`): [details/compatibilitate-clienti.md](details/compatibilitate-clienti.md)
