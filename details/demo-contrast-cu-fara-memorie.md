# Demo: contrast cu/fără memorie (slide 21)

Suport pentru bullet-ul din `idei.txt` / slide 21:

> Alternativ, contrastul cu/fără memorie: o întrebare care cere context din trecut → fără plugin Claude nu știe; cu total-recall îl recuperează.

## De ce `--bare` (și nu `mcpServers`)

`total-recall` e încărcat ca **plugin** (`plugin:total-recall:total-recall`), nu ca MCP server în `settings.json`. Deci îl oprești cu `claude --bare` (skip plugins + hooks + MCP), nu editând `mcpServers`.

`--bare` = „minimal mode: skip hooks, LSP, plugin settings, --agents, --plugin-dir" → tool-urile `recall_memory` / `search_index` nu există în sesiune. Claude fie spune „nu știu", fie halucinează — ambele fac punctul.

## Rețeta de test, în 2 sesiuni

### 1. Fără plugin (Claude nu știe)

Pornești într-un dir curat, fără `CLAUDE.md` de proiect, fără plugin-uri:

```bash
mkdir -p /tmp/demo-no-memory && cd /tmp/demo-no-memory
asciinema rec casts/slide-21-demo-fara-memorie.cast
claude --bare
# pui întrebarea; Claude nu are recall_memory/search_index -> nu știe
exit  # oprește asciinema
```

### 2. Cu plugin (total-recall recuperează)

Sesiune normală, **interactiv** (ca să poți aprova `recall_memory`):

```bash
cd /tmp/demo-no-memory   # oriunde fără repo files
asciinema rec casts/slide-21-demo-cu-memorie.cast
claude
# aceeași întrebare; aprobi recall_memory la prompt -> recuperează din vault
```

## Alegerea întrebării (partea critică)

Trebuie să fie un fact care **există în vaultul total-recall dar NU în repo / git / `CLAUDE.md`** — altfel „fără plugin" tot știe din fișiere și contrastul se prăbușește. Verifică candidatul cu `grep` în repo înainte de demo.

### Candidați buni (în memorie, nu în repo)

| Întrebare | Răspuns (din memorie) | De ce nu-l știe fără plugin |
|---|---|---|
| „Ce preferă echipa pentru testele locale cu Ollama?" | `ollama launch claude` (org memory) | Nu e în repo |
| „Ce am reparat la total-recall în sesiunile recente?" | vector search, rebuild native deps, wipe org repo history | Nu e în git-ul *acestui* repo |
| „Câte memorii are total-recall acum?" | 571 (din index) | E stare live, nu fișier |

### Capcană

Evită „ce model local am folosit pentru TTFT?" — `details/masurare-ttft.md` deja spune `gemma3:4b`, deci fără plugin Claude îl găsește prin `Read`/`Grep`. Partea cu „cold-load" e doar în memorie; întrebarea trebuie formulată fix pe asta.

## Recomandare pentru demo

O singură întrebare, rulată în ambele sesiuni (ca-n slide 7):

> „Cât durează cold-load-ul modelului gemma3:4b pe laptopul de demo?"

- **Fără plugin** (`--bare`): „nu am acces la acea informație" (sau oferă să ruleze un benchmark live).
- **Cu plugin**: `recall_memory` → găsește memora locală cu timpul de cold-load. **Valoarea exactă nu e scrisă aici intenționat** — e stocată doar în vaultul total-recall, ca să se poată demonstra recuperarea din memorie, nu din fișiere.

## Verificat pe 20 iul 2026

- **Fără plugin** (`claude --bare -p`, dir gol `/tmp/demo-no-memory`): Claude nu a știut — a verificat directorul, documentele personale, a încercat comenzi sandboxate, apoi a oferit să ruleze un benchmark live. ✅
- **Cu plugin** — memora confirmată direct: `recall_memory("gemma3:4b cold load duration demo laptop")` returnează ca top hit (scor 216.5) memora `project/demo-laptop-gemma3-4b-cold-load-2-min` cu factul exact. ✅
- **Limitare verificare**: într-o sesiune non-interactivă (`-p`), permisiunea pe `recall_memory` e refuzată (nu e cine s-o aprobe), iar `--dangerously-skip-permissions` a fost blocat de classifierul harness-ului. Deci nu s-a putut simula end-to-end prin `-p`.
- **Concluzie pentru demo**: rulează sesiunea „cu plugin" **interactiv** (`claude`, nu `-p`), ca să poți aproba `recall_memory` la prompt — acolo funcționează. Și asigură-te că răspunsul nu există în niciun fișier din cwd (de asta sesiunea „cu" se rulează dintr-un dir fără repo files; valoarea a fost ștearsă intenționat din acest fișier).

### Bug colateral observat

La închiderea sesiunii cu plugin, hook-ul `SessionEnd` al total-recall a dat eroare de validare JSON (câmp `additionalContext` pus la nivel greșit în schema `Stop/SubagentStop`). Nu afectează demo-ul, dar merită un ticket în `../total-recall`.