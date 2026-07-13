---
marp: true
title: "Claude vs Ollama & Total Recall Plugin"
author: Adrian Balaban
date: 2026-07-16
layout: docs
---

# Claude vs Ollama & Total Recall Plugin

**Autor:** Adrian Balaban  
**Data:** 16 iulie 2026

Două subiecte practice despre cum alegem / extindem uneltele AI:

- primul despre decizia „model cloud proprietar" (Claude Code) sau "model cloud cat si local de tip proprietar sau open" 
- al doilea despre persistența memoriei în Claude/Copilot/Gemini printr-un plugin MCP

---

## Slide 0 — Ce iei din această sesiune

> Informatii pe care le poți folosi astazi

Cinci lucruri pe care le iei de aici:

1. **Ce este Ollama** — LLM-uri locale ( zero cost-per-token, zero date în cloud) si remote
2. **Claude vs Ollama** — comparație directă
3. **Integrarea Ollama cu Claude/Copilot/Gemini** — ce ofera
4. **La ce nevoi raspunde si cum funcționează total-recall** — MCP, vault-uri, hook-uri, căutare hibridă cu curbă de uitare.
5. **Cum îl instalezi** — Claude Code, Copilot CLI, Gemini CLI.

---

## Slide 1 — Agendă (~65 de minute)

1. **Claude vs Ollama** (25 min) 
2. **Total Recall Plugin** (25 min) 
3. **Sinteză & Întrebări (Q&A)** (10 min)

---

## TEMA 1 — CLAUDE vs OLLAMA

> **Firul roșu:** AI-ul a devenit scump și cu 'lock-in'; Ollama este unul dintre proiectele ce construiește o alternativa 'open'.

---

## Slide 2 — Ce este Ollama?

> Ollama este un tool open-source care îți permite să rulezi modele LLM mari **local**,
> pe propriul hardware, fără nicio conexiune la internet și fără cost per token.
>
> Pentru modelele **proprietare** (Gemini, GPT-oss mari) sau prea mari ca să încapă pe hardware-ul tău, Ollama nu rulează local — face **proxy** către infrastructura sa cloud, prin aceleași comenzi CLI/API (`ollama run <model>:cloud`).

---

## Slide 2 — Ce este Ollama? (continuare)

> 💡 **WOW:** peste **100 de milioane de descărcări** pe [Docker Hub](https://hub.docker.com/r/ollama/ollama) (imaginea `ollama/ollama`) și **176k stars** pe [GitHub](https://github.com/ollama/ollama) *(verificat iul 2026)*. Este cel mai popular runtime local pentru LLM-uri.

---

## Slide 2 — Ce este Ollama? (continuare)

**Ce face Ollama:**

- Descarcă și rulează modele in local (Llama, Mistral, Gemma, Phi, Qwen, etc.)
- Modelele `:cloud` (ex. `glm-5.2:cloud`, `gemini-3-flash-preview:cloud`) — inferența rulează la furnizor, nu pe hardware-ul tău
- Expune API REST pe `http://localhost:11434`, compatibilă atât cu formatul **OpenAI**, cât și cu formatul **Anthropic** (`/v1/messages` — de asta merge `ollama launch claude`)

**Site:** [ollama.com](https://ollama.com) · **Repo:** [github.com/ollama/ollama](https://github.com/ollama/ollama) (176k stars)

---

## Slide 2 — Ce este Ollama? (continuare)

**Instalare — o singură comandă după download** (ollama.com/download):

```bash
ollama run llama3.2          # pull + run, gata de conversație

# Modele proprietare/mari — NU se descarcă; rulează prin proxy :cloud (cont ollama.com)
ollama signin
ollama run gemini-3-flash-preview:cloud   # Gemini, servit prin Ollama Cloud
```

---

## Slide 2 — Ce este Ollama? (continuare)

> **⚠️ Unde sunt Claude, Gemini și GPT?** Local rulează doar modele **open-weight**. Gemini frontier există doar ca `gemini-3-flash-preview:cloud`; GPT doar ca `gpt-oss` open-weight (varianta cloud: `gpt-oss:120b-cloud`); **Claude nu există în Ollama deloc** — doar imitații comunitare, de evitat. Pentru Claude real: API-ul Anthropic sau `ollama launch claude` cu alt model în spate.

📄 **Detalii** (tabelul modelelor locale cu VRAM, lista `:cloud` completă, confuzia Gemini ≠ Gemma, Antigravity IDE, screenshot-uri): [details/ollama-modele-locale-si-cloud.md](details/ollama-modele-locale-si-cloud.md)

---

## Slide 3 — Cum funcționează Ollama intern

> 💡 **WOW:** quantizarea Q4 comprimă un model de 8× — un 70B care „cere" 280 GB încape în 48 GB VRAM (GPU), cu doar ~2–5% pierdere de calitate.

---

## Slide 3 — Cum funcționează Ollama intern (continuare)

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

---

## Slide 4 — Modele instalate local: cazul real (`ollama list`)

> 🎬 **Beat live:** rulează `ollama list` pe ecran (10 secunde de energie reală — coloana SIZE face punctul singură); output-ul de mai jos e fallback-ul dacă demo-ul eșuează. Mașina: **Dell Latitude 5521** (i7-11850H, MX450 2GB GDDR6).

---

## Slide 4 — Modele instalate local: cazul real (continuare)

```
$ ollama list
NAME                          SIZE      MODIFIED
nemotron-3-nano:30b           24 GB     8 days ago
mistral-medium-3.5:latest     80 GB     8 days ago
qwen3.6:latest                23 GB     8 days ago
qwen3.5:latest                6.6 GB    8 days ago
gemma4:latest                 9.6 GB    8 days ago
kimi-k2.7-code:cloud          —         8 days ago
ornith:9b                     5.6 GB    8 days ago
glm-5.2:cloud                 —         10 days ago
north-mini-code-1.0:latest    18 GB     12 days ago
```

---

## Slide 4 — Modele instalate local (continuare)

**Concluzia practică:**

- MX450 (2GB VRAM) nu poate ține niciun model în VRAM — toate rulează pe CPU via RAM
- `qwen3.5` (6.6 GB) și `ornith:9b` (5.6 GB) sunt singurele care intră confortabil în 16 GB RAM → ~3–8 tok/s
- Modelele cu tag `:cloud` (kimi-k2.7-code, glm-5.2) sunt **API-uri externe proxiate prin Ollama** — nu rulează local
- **Pe acest laptop, Claude API rămâne alegerea corectă.** Modelele locale = experimente offline sau eGPU extern (Thunderbolt 4)

---

## Slide 5 — Pot adăuga GPU pe laptop? (Bonus)

> **TL;DR:** Teoretic: GPU-ul intern e soldat — singura opțiune e **eGPU extern via Thunderbolt 4**. Cu un enclosure + RTX 3060 12GB nou (minim ~3.500 lei), rulezi modele de 7–13B complet pe GPU la 20–50 tok/s. Bottleneck-ul TB4 e irelevant pentru inference LLM (contează VRAM-ul, nu banda).

![Razer Core X V2 — enclosure eGPU second-hand pe OLX](images/razer-core-x-v2-egpu-olx.png)

---

## Slide 6 — La ce e util Ollama cu GLM-5.2 și Kimi-K2.7-Code?

> Ambele apar în `ollama list` cu `SIZE=—` și suffix `:cloud` — **nu sunt modele locale**.
> Sunt API-uri externe proxiate prin Ollama; inferența rulează pe serverele Zhipu AI / Moonshot AI din China.

### Ce înseamnă `:cloud` în Ollama?

```
kimi-k2.7-code:cloud    —     ← niciun fișier GGUF descarcat
glm-5.2:cloud           —     ← niciun fișier GGUF descarcat
```

---

## Slide 6 — La ce e util Ollama cu GLM-5.2 și Kimi-K2.7-Code? (continuare)

- `SIZE=—` = nu există model local; Ollama trimite cererea la API-ul extern
- Tokenizarea și inferența se fac **pe serverele furnizorului**, nu pe CPU/GPU-ul tău
- Avantaj față de API-ul direct: aceeași interfață CLI (`ollama run <model>:cloud`) pentru toate modelele `:cloud`, cu endpoint-uri atât **OpenAI-compatible**, cât și **Anthropic-compatible** — verificat: pagina fiecărui model listează direct comenzile `ollama launch claude/codex/opencode/copilot --model <model>:cloud`

---

## Slide 6 — La ce e util Ollama cu GLM-5.2 și Kimi-K2.7-Code? (continuare)

- Claude oficial NU există în Ollama (doar prin API Anthropic: [docs.anthropic.com](https://docs.anthropic.com)); Gemini există doar ca [gemini-3-flash-preview:cloud](https://ollama.com/library/gemini-3-flash-preview), iar experiența completă Gemini o dă [Antigravity IDE](https://antigravity.google/)

---

### Ce sunt cele două modele

- **GLM-5.2** (Zhipu AI, Beijing) — flagship-ul Z.ai; context ~1M tokens (976K), 756B parametri. Aproape de Claude Opus 4.8 pe Terminal-Bench 2.1 (**81.0 vs 85.0** — re-verificat pe ollama.com/library/glm-5.2 la 11 iul 2026), la preț API de **~12–20× mai mic**, greutăți deschise MIT. Română slabă — rămâi pe Claude pentru RO.
- **Kimi-K2.7-Code** (Moonshot AI, Beijing) — specializat pe generare și analiză de cod; puncte forte: code review, explicare cod legacy.

---

## Slide 6 — La ce e util Ollama cu GLM-5.2 și Kimi-K2.7-Code? (continuare)

### ⚠️ Regula GDPR (partea cu adevărat utilă)

- Ambele procesează datele pe **servere în China** — jurisdicție fără decizie de adecvare GDPR (spre deosebire de US, acoperit de **EU-US Data Privacy Framework**, decizie de adecvare din 10 iulie 2023)
- Nici Claude nu e „gratuit" GDPR: Anthropic are DPA+SCC, dar procesarea via API direct e pe infrastructură non-EU; pentru rezidență EU calea uzuală e AWS Bedrock / Vertex AI pe regiuni EU (verificați DPA-ul și subprocesatorii pentru cazul vostru concret)

---

## Slide 6 — La ce e util Ollama cu GLM-5.2 și Kimi-K2.7-Code? (continuare)

- **Nu trimite prin API-urile chinezești:** cod cu date personale ale clienților, IP proprietar, credențiale, contracte

---

## Slide 6 — La ce e util Ollama cu GLM-5.2 și Kimi-K2.7-Code? (continuare)

**Regula scurtă:** cod ne-sensibil + buget → `:cloud` chinezesc; română, date sensibile, raționament critic → Claude.

```bash
ollama signin                          # cont pe ollama.com
ollama launch claude --model glm-5.2:cloud  # în Claude Code
```

📄 **Detalii** (comparația pe 4 modele, riscul GDPR pe larg, ce poți rula local pe CPU): [details/glm-kimi-cloud.md](details/glm-kimi-cloud.md)

---

## Slide 7 — Comparație directă: Claude vs Ollama

> 💡 **Punctul-cheie:** nu e „care e mai bun", ci **ce optimizezi** — inteligență maximă (Claude) vs suveranitate totală: $0/token, offline, zero egress (Ollama).

> 📊 **WOW Metric:** Latența la primul token (TTFT) pe Ollama cu un model 8B pe GPU local este de **~120ms**, în timp ce prin API-ul Claude este de **~650ms** (de ~5 ori mai rapid local).

---

## Slide 7 — Comparație directă: Claude vs Ollama (continuare)

Cele 5 axe care contează (cifre orientative, iul 2026 — depind de model, hardware și quantizare):

| Criteriu                  | Claude (API Anthropic)         | Ollama (local)                                     |
| ------------------------- | ------------------------------ | -------------------------------------------------- |
| **Calitate top-tier**     | ✅ Opus 4.8 = state of the art | Llama 3.3 70B ≈ GPT-4o, dar sub Opus               |
| **Cost**                  | $3–$15 / 1M tokens             | $0/token — dar GPU bun: $500–$3000+                |

---

## Slide 7 — Comparație directă: Claude vs Ollama (continuare)

| Criteriu                  | Claude (API Anthropic)         | Ollama (local)                                     |
| ------------------------- | ------------------------------ | -------------------------------------------------- |
| **Confidențialitate**     | Date trimise la Anthropic (US) | 100% local, zero egress, merge air-gapped          |

---

## Slide 7 — Comparație directă: Claude vs Ollama (continuare)

| Criteriu                  | Claude (API Anthropic)         | Ollama (local)                                     |
| ------------------------- | ------------------------------ | -------------------------------------------------- |
| **Latență (TTFT)**        | ~500ms–2s                      | ~100–500ms pe GPU local                            |
| **Integrare Claude Code** | ✅ Nativă                      | ✅ Nativă prin `ollama launch claude` (fără proxy) |

📄 **Detalii** (comparația completă pe 13 criterii — context window, rate limits, actualizări, GDPR): [details/comparatie-claude-ollama.md](details/comparatie-claude-ollama.md)

---

## Slide 8 — Costul real: Claude API vs Ollama

> 💡 **WOW:** un 'agentic developer' ce lucreaza intens arde ~$400/lună pe API — un RTX 4090 de $2.000 se amortizează în ~5 luni. Dar dacă ești utilizator light ($30/lună), amortizarea durează ani.

> 📊 **WOW (datat):** 1 iunie 2026 — Copilot a mutat Claude Opus de la **3× la 27×** multiplicator și Sonnet de la **1× la 9×**; tier-ul gratuit GPT-4o a dispărut. „Era AI-ului cloud ieftin s-a terminat" (Mozilla.ai, _AI Got Expensive. Now What?_, mai 2026). Ăsta e forcing function-ul întregii discuții cloud-vs-local. Sursa numerelor: [blog.mozilla.ai/ai-got-expensive-now-what](https://blog.mozilla.ai/ai-got-expensive-now-what/) (Anushri Gupta, 26 mai 2026).

---

## Slide 8 — Costul real: Claude API vs Ollama (continuare)

### Claude API (Sonnet 4.6 — prețuri verificate la 11 iul 2026)

```
Input:  $3.00 / 1M tokens
Output: $15.00 / 1M tokens

Sesiune agentică intensă (8h/zi, multe tool calls, context re-reads):
  Input:  ~3M tokens/zi    → $9/zi
  Output: ~600K tokens/zi  → $9/zi
  TOTAL:  ~$18/zi → ~$400/lună (22 zile lucrătoare)
```

---

## Slide 8 — Costul real: Claude API vs Ollama (continuare)

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

---

## Slide 8 — Costul real: Claude API vs Ollama (continuare)

### Găsește-ți tier-ul

| Profil                | Cheltuială API tipică | Amortizare hardware local       |
| --------------------- | --------------------- | ------------------------------- |
| Indie / light         | ~$30/lună             | ani — rămâi pe API sau CPU-only |
| Daily driver          | ~$100/lună            | ~6 luni (RTX 3080 SH ~$600)     |
| **Agentic developer** | **~$400/lună**        | **~5 luni (RTX 4090 ~$2.000)**  |

---

## Slide 8 — Costul real: Claude API vs Ollama (continuare)

**Concluzie financiară:** Pentru un developer cu utilizare agentică intensă (~$400/lună API), Ollama devine mai ieftin decât API-ul Claude în 2-6 luni cu un GPU decent. Utilizatorii light (~$30/lună) recuperează hardware-ul în câțiva ani, nu luni — ROI-ul în luni presupune utilizare intensă. Sub un GPU de ~$600, diferența de calitate poate să nu merite.

> **Notă (verificat 11 iul 2026):** Sonnet 5 (lansat 30 iun 2026) are preț introductiv **$2/$10 per MTok până la 31 aug 2026**, apoi revine la standard $3/$15 (același nivel ca Sonnet 4.6). În fereastra introductivă, calculul de mai sus scade de la ~$18/zi la ~$12/zi (~$265/lună) pentru același profil agentic.

---

## Slide 9 — Confidențialitate și date: diferența crucială

> 💡 **WOW:** cu Ollama, promptul tău nu părăsește **niciodată** mașina — funcționează și cu cablul de rețea scos (air-gapped). Pentru finance/healthcare/NDA, asta nu e un „nice to have", e singura opțiune legală.

---

## Slide 9 — Confidențialitate și date: diferența crucială (continuare)

### Claude API

```
Cerere utilizator
       │  (HTTPS la api.anthropic.com)
       ▼
Serverele Anthropic (US)
       │
       ├── Procesare → răspuns
       ├── Logging (audit, safety) — politici Anthropic
       └── Training data? → Implicit NU, dar citiți ToS (Terms of Service —
           condițiile de utilizare Anthropic; ele definesc ce are voie
           furnizorul să facă cu datele trimise: logging, retenție, training)
```

---

## Slide 9 — Confidențialitate și date: diferența crucială (continuare)

**Ce înseamnă practic:**

- Codul tău (parțial sau complet) este trimis la Anthropic
- Secretele din prompt ajung pe servere externe
- GDPR: Anthropic are DPA disponibil, dar datele ies din EU
- Contracte enterprise pot restricționa utilizarea API-ului cloud

---

## Slide 9 — Confidențialitate și date (continuare)

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

---

## Slide 9 — Confidențialitate și date (continuare)

**Ce înseamnă practic:**

- Codul tău, secretele, datele clientului — rămân pe mașina ta
- Zero egress de date
- Funcționează în rețele izolate (air-gapped)
- Util în: finance, healthcare, proiecte cu NDA strict, codebases proprietare

---

## Slide 10 — Ollama cu Claude Code: integrarea practică

> 💡 **WOW — gotcha-ul „subscription hijack":** configurezi manual Claude Code pe Ollama, totul pare OK… dar cu abonament Claude Max/Pro cererile pleacă **silențios pe OAuth la api.anthropic.com**, nu la Ollama. Cauza: `ANTHROPIC_API_KEY=""` — șirul gol înseamnă „nu e setat". Fix-ul pe o linie: setează doar `ANTHROPIC_AUTH_TOKEN=ollama` și verifică cu `/status` că base URL-ul e `localhost:11434`.

---

## Slide 10 — Ollama cu Claude Code: integrarea practică (continuare)

**Metoda oficială: `ollama launch claude`** — pornește clientul Claude Code cu Ollama ca backend, nativ (fără proxy):

```bash
# Model local (pe GPU propriu, ex. RTX 3060)
ollama launch claude --model qwen3.5

# Model cloud (fără download local)
ollama launch claude --model glm-5.2:cloud

# Non-interactiv / scriptat
ollama launch claude --model glm-5.2:cloud --yes -- -p "how does this repo work?"
```

---

## Slide 10 — Ollama cu Claude Code (continuare)

Ce face comanda automat:

- instalează/pornește **clientul Claude Code**
- setează `ANTHROPIC_BASE_URL=http://localhost:11434`, `ANTHROPIC_AUTH_TOKEN=ollama`, `ANTHROPIC_API_KEY=""`
- Ollama expune **endpoint compatibil API Anthropic** la `localhost:11434` → cerere în format Anthropic → model Ollama răspunde → răspuns re-ambalat în format Anthropic

---

## Slide 10 — Ollama cu Claude Code (continuare)

### Distincția cheie: formatul e Anthropic, inteligența e Ollama

Ollama vorbește **nativ** formatul API Anthropic la `localhost:11434` — **nu există proxy separat**. Clientul Claude Code „crede" că vorbește cu Anthropic; de fapt răspunde modelul ales cu `--model`:

```
cerere în format Anthropic → Ollama traduce intern → modelul Ollama răspunde
      → răspuns re-ambalat în format Anthropic → clientul Claude Code îl consumă
```

---

## Slide 10 — Ollama cu Claude Code (continuare)

**Metoda manuală (alternativă, fără `launch`):**

```bash
ollama pull qwen3.5
export ANTHROPIC_BASE_URL=http://localhost:11434
export ANTHROPIC_AUTH_TOKEN=ollama
claude --model qwen3.5
```

---

## Slide 10 — Ollama cu Claude Code (continuare)

Sau permanent în `~/.claude/settings.json`:

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "http://localhost:11434",
    "ANTHROPIC_AUTH_TOKEN": "ollama"
  }
}
```

---

## Slide 10 — Ollama cu Claude Code (continuare)

**Esențialul limitărilor:** endpoint-ul Anthropic-compatibil suportă tool calling și extended thinking (suport basic — `budget_tokens` acceptat dar **neaplicat**), dar **nu** prompt caching; calitatea = calitatea modelului local ales.

📄 **Detalii** (mecanica `x-api-key` vs `Bearer`, lista completă de capabilități și limitări, modele cu tool calling): [details/integrare-claude-code-ollama.md](details/integrare-claude-code-ollama.md)

---

## Slide 10b — A treia cale: Otari, gateway Anthropic-compatibil (Bonus)

> 💡 **WOW:** același truc `ANTHROPIC_BASE_URL`, dar cu **buget enforcement ÎNAINTE de request, nu după factură.**

**Otari** (Mozilla.ai, open-source, lansat mai 2026, construit peste `any-llm`) e un gateway LLM self-hosted care expune și endpoint-ul Anthropic (`POST /v1/messages`) — deci Claude Code poate rula prin el exact ca prin Ollama, dar cu stratul operațional pe care Ollama nu-l are:

---

## Slide 10b — A treia cale: Otari, gateway Anthropic-compatibil (continuare)

- **Bugete** per user / per cheie, aplicate _înainte_ ca cererea să ruleze
- **Chei virtuale** — clientul nu vede niciodată cheia reală Anthropic/OpenAI; le poți revoca oricând
- **Usage & spend tracking** în timp real, pe toate modelele (40+ provideri prin any-llm)
- Rulezi Claude real, GPT, Mistral sau modele locale prin **același endpoint**

---

## Slide 10b — A treia cale: Otari, gateway Anthropic-compatibil (continuare)

```bash
docker run --rm -p 8000:8000 \
  -e OTARI_MASTER_KEY=... -e ANTHROPIC_API_KEY=... \
  mzdotai/otari:latest otari serve

export ANTHROPIC_BASE_URL=http://localhost:8000   # root, fără /v1
export ANTHROPIC_AUTH_TOKEN=<cheia-ta-otari>      # Bearer, nu x-api-key
export ANTHROPIC_MODEL="anthropic:claude-sonnet-4-6"
claude
```

**Când are sens:** echipă care vrea Claude real + modele alternative + control central de buget și chei — fără să dea fiecărui developer cheia API brută.

---

## Slide 11 — Ghid de decizie: Claude API sau Ollama?

> 💡 **UTIL:** arborele de decizie, scenariile și tier-urile de cost sunt în ghidul printabil promis la început. Rulează direct `ollama launch claude` pentru a testa local înainte de a decide implementarea în producție.

📄 **Detalii:** [details/decizie-o-pagina.md](details/decizie-o-pagina.md)

---

## Slide 12 — Agent Claude vs agent LangChain

> Confuzia vine din faptul că „agent Claude" și „agent LangChain" trăiesc la **niveluri diferite de stivă**: unul e _model + harness_, celălalt e _framework model-agnostic_. Diferența e **cine deține loop-ul**, nu dacă pot rula local — ambele pot rula pe Ollama.

📄 **Detalii** (comparația pe 7 axe, cele 3 forme de „agent Claude", regula de decizie, tabelul pe hardware real): [details/agent-claude-vs-langchain.md](details/agent-claude-vs-langchain.md)

---

## TEMA 2 — TOTAL RECALL PLUGIN

> **Puntea între teme:** ai ales runtime-ul (cloud sau local). Acum să-l faci să țină minte cine ești si ce ai facut — altfel fiecare sesiune o iei de la zero.

---

## Slide 13 — Problema: Claude uită tot după sesiune

> La sfârșitul fiecărei conversații, Claude pierde tot contextul acumulat.
> Decizii, preferințe, arhitecturi discutate — totul dispare.

**Simptomele:**

- Reexplici același context la fiecare sesiune nouă
- Preferințele tale de cod trebuie re-menționate de fiecare dată
- Deciziile de arhitectură, info. de infra. si alte categorii de informatii nu se acumulează nicăieri

**Consecința:** Cu cât lucrezi mai mult cu un agent (Claude Code...), cu atât pierzi mai mult timp re-explicând ceea ce ai deja explicat.

---

## Slide 13 — Problema: Claude uită tot după sesiune (continuare)

> **Cine mai vrea aceasta:** Mozilla.ai a lansat [`cq`](https://github.com/mozilla-ai/cq) (1.2k ⭐) — un standard deschis pentru _shared agent learning_: agenții propun «knowledge units» (workaround-uri, API-uri nedocumentate) într-un store comun, cu review uman. **Complementar, nu concurent:** cq = lecții operaționale partajate între agenți; total-recall = memoria (TA si A ECHIPEI TALE) de context (decizii, preferințe, arhitectură) — fișiere `.md` + git, fără server și fără review pipeline.

---

## Slide 13b — Demo: aceeași întrebare, cu și fără memorie

> 🎬 **Beat live** (sau clip pre-înregistrat de 20 de secunde, dacă live e riscant) — payoff-ul emoțional al întregii teme.
>
> _Pregătire înainte de prezentare:_ stochează memoria ca mai jos.

stochează memoria urmatoare  de architecture pentru db-choice:  am ales PostgreSQL față de MySQL pentru JSONB

Stocat: architecture/db-choice (personal vault, importanceScore: 0.7, taguri: database, postgresql, mysql, jsonb, adr, decision).

---

## Slide 13b — Demo: aceeași întrebare, cu și fără memorie (continuare)

Am verificat întâi duplicatele cu search_index — nu exista nimic similar. Memoria include Executive Summary cu WHY (interogări eficiente pe date semi-structurate) și HOW (orice discuție viitoare de schemă/ORM pornește de la PostgreSQL + JSONB).

Dacă vrei să fie imutabilă ca un ADR formal (protejată de prune și ștergere accidentală), pot să-i adaug tagul no-prune. Și dacă e o decizie de echipă, spune-mi și o mut în org vault (tag org).

---

## Slide 13b — Demo: aceeași întrebare, cu și fără memorie (continuare)

```

FĂRĂ total-recall (sesiune Claude nouă):          CU total-recall (sesiune nouă, același prompt):
──────────────────────────────────────            ──────────────────────────────────────────────
> care DB am ales pentru proiect?                 > care DB am ales pentru proiect?

„Nu am context despre o decizie                   → recall_memory(query="DB proiect")
anterioară legată de baza de date.                „Conform memoriei architecture/db-choice (creatÄ azi, 13 iulie 2026):Ai ales PostgreSQL (respins MySQL). Motivul decisiv: JSONB e stocare binarÄ a documentelor JSON cu indexare ... 
```

Publicul nu trebuie să creadă pe cuvânt — vede diferența pe ecran în 20 de secunde.

---

## Slide 14 — Soluția: total-recall

> Un plugin Claude Code care dă AI-ului memorie persistentă, căutabilă, între sesiuni.

> 🎬 **Beat live:** rulează pe ecran `claude -p "Reaminteste-ti decizia noastra despre baza de date"` și arată apelul `recall_memory` în output. (Pentru public, comanda e și „tema de acasă" din handout.)

---

## Slide 14 — Soluția: total-recall (continuare)

**Ce este:**

- **Plugin Claude Code** instalat din marketplace
- **MCP server** cu 17 unelte (stdio, înregistrat via `claude mcp add`)
- **Vault de fișiere Markdown** stocat local la `~/.total-recall/`
- **Hook-uri automate** care injectează contextul la fiecare sesiune nouă
- **Skill `/total-recall:memory-workflow`** pentru sesiuni structurate de recall/store

---

## Slide 14 — Soluția: total-recall (continuare)

**Ce nu este:**

- Nu trimite date în cloud (vaultul personal este complet local)
- Nu folosește o bază de date opacă — fiecare memorie este un fișier `.md` citibil
- Nu suprascrie context — injectează, nu înlocuiește (Modelul vede: system prompt + CLAUDE.md + memoriile tale (index) + mesajul tău — toate coexistă.)

---

## Slide 15 — Structura pe disc

> 💡 **WOW:** zero bază de date — memoria AI-ului tău e un folder de fișiere `.md` pe care le poți citi, edita, versiona cu git și deschide în Obsidian.

```
~/.total-recall/
├── index.json               ← index plat: key → MemoryMetadata
├── invertedIndex.json       ← TF-IDF inverted index: token → {docs, idf}
├── .index-cache.txt         ← rezumat injectat la SessionStart (shell-readable)
```

---

## Slide 15 — Structura pe disc (continuare)

```
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

## Slide 15 — Structura pe disc (continuare)

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

## Slide 16 — Arhitectura: modulele principale

> 💡 **WOW — cifra de pe ecran: `1`.** Un motor de căutare hibrid complet (TF-IDF + vector + curbă de uitare) în ~24 de fișiere TypeScript, cu **o singură dependență obligatorie** (`@modelcontextprotocol/sdk`). Restul — TF-IDF, Ebbinghaus, RRF, parser frontmatter — scris de la zero.

---

## Slide 16 — Arhitectura: modulele principale (continuare)

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

## Slide 17 — De ce algoritmi proprii (fără hard dependencies)


**Ce câștigi:**

1. **Securitate:** fără `gray-matter` → fără CVE-ul `js-yaml` (GHSA-h67p-54hq-rp68)
2. **Scoring coerent:** title-boost, tag-boost, Ebbinghaus = o singură formulă, nu trei librării
3. **Determinism:** zero apeluri LLM, zero cost, merge offline / air-gapped
4. **Auditabilitate:** fiecare decizie de scoring e observabilă prin `get_stats`

> **Filozofia:** dependențele grele = risc de CVE + breaking-change + black-box. Doar ONNX și sqlite-vec rămân externe — și ele opționale.

---

## Slide 18 — Dual Vault: personal vs org

> 💡 **WOW:** un simplu tag `org` transformă memoria personală în cunoaștere de echipă — cu filtru de confidențialitate **fail-closed**: dacă nu poate garanta că nu scapă secrete, nu face push.

---

## Slide 18 — Dual Vault: personal vs org (continuare)

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

## Slide 18 — Dual Vault: personal vs org (continuare)

**Filtru de confidențialitate (org sync):**

- Blochează secrete și chei API după tipare cunoscute (chei PEM, `sk-`, `ghp_`, `AKIA`, JWT, Slack/GitLab/Google tokens etc.)
- Detectează și **secrete etichetate** — ex. `aws_secret_access_key = …`: un `~/.aws/credentials` lipit din greșeală e blocat înainte de push
- Blochează toate adresele email (cu excepția domeniilor din allowlist)
- Fail-closed: dacă filtrul nu poate analiza conținutul, NU face push

---

## Slide 19 — Cele 17 unelte MCP

> 🎬 **Beat live — ideea sticky demonstrată, nu enunțată:** spui „reține că prefer PostgreSQL" → modelul alege singur `store_memory`; întrebi „ce am decis despre DB?" → alege `recall_memory`. CRUD complet + căutare + întreținere, **în limbaj natural** — nu înveți 17 nume de unelte.

---

## Slide 19 — Cele 17 unelte MCP (continuare)

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

---

## Slide 19 — Cele 17 unelte MCP (continuare)

- `rerank_memories` = semantic rerank **local**: re-embeddează query + candidați și sortează după scor cosine — fără niciun apel LLM
- `confirm_memory` = feedback confirm/flag integrat direct în scorul Ebbinghaus

📄 **Detalii** (toate cele 17 unelte, cu descrierea fiecăreia): [details/unelte-mcp.md](details/unelte-mcp.md)

---

## Slide 20 — Algoritmul de căutare: TF-IDF + Ebbinghaus

> 💡 **WOW:** memoria AI-ului **uită ca un om** — [curba uitării lui Ebbinghaus](https://en.wikipedia.org/wiki/Forgetting_curve) (1885) aplicată în cod: memoriile neimportante și neaccesate se estompează din rezultate, fiecare accesare le „reîmprospătează" cu +20%.

---

## Slide 20 — Algoritmul de căutare: TF-IDF + Ebbinghaus (continuare)

> **Ce e TF-IDF?** Term Frequency × Inverse Document Frequency — algoritmul clasic de căutare text: un cuvânt punctează mult dacă apare **des în documentul respectiv** (TF) dar **rar în restul colecției** (IDF). „postgresql" care apare de 5 ori într-o memorie și aproape nicăieri altundeva = scor mare; „proiect", care apare peste tot = scor aproape zero. _Inverted index_ = harta inversă `cuvânt → lista documentelor care îl conțin`, ca indexul de la finalul unei cărți — de asta căutarea nu citește fișierele, doar indexul.

---

## Slide 20 — Algoritmul de căutare: TF-IDF + Ebbinghaus (continuare)

### Pipeline `recall_memory`

```
query (text liber)
  │
  ├─ tfidfSearch(query)
  │    ├─ tokenize(query) → tokens
  │    ├─ pentru fiecare token: lookup în invertedIndex
  │    ├─ scor = TF × IDF × title-boost(2×) × tag-boost(1.5×)
  │    └─ × computeRetentionStrength(importance, daysSince, accessCount)
```

---

## Slide 20 — Algoritmul de căutare: TF-IDF + Ebbinghaus (continuare)

```
  ├─ [opțional: hybrid=true + dependențe instalate]
  │    ├─ embed(query) → vector query
  │    ├─ searchVector(db, qvec, 50) → rezultate vectoriale
  │    └─ Reciprocal Rank Fusion([tfidf, vector], k=60)
  │              scor(d) = Σ 1/(60 + rank(d)) pe ambele liste
  │
  └─ slice la `limit`, bump accessCount, returnează cu/fără conținut complet
```

---

## Slide 20 — Algoritmul de căutare: TF-IDF + Ebbinghaus (continuare)

### Curba Ebbinghaus (uitarea modelată matematic)

```
λ     = 0.16 × (1 − importanceScore × 0.8)
decay = importanceScore × exp(−λ × daysSince)
        × (1 + accessCount × 0.2 + confirmations × 0.1 − flags × 0.1)
        — rezultat limitat (clamp) la [0, 1]
```

---

## Slide 20 — Algoritmul de căutare: TF-IDF + Ebbinghaus (continuare)

| importanceScore | λ (viteza de uitare) | Comportament                                    |
| --------------- | -------------------- | ----------------------------------------------- |
| 1.0 (critic)    | 0.032                | Decay lent — memoria rămâne relevantă săptămâni |
| 0.5 (normal)    | 0.096                | Decay mediu                                     |
| 0.3 (scăzut)    | 0.122                | Decay rapid — dispare din rezultate în zile     |

---

## Slide 20 — Algoritmul de căutare: TF-IDF + Ebbinghaus (continuare)

Fiecare acces adaugă +20% forță de retenție (`accessCount × 0.2`); fiecare confirmare +10%, fiecare flag −10% (`confirm_memory`) — memoria nu doar „îmbătrânește", ci primește feedback.

---

## Slide 21 — Embeddings și căutare multilinguală (opționale)

> Embeddings = opționale, lazy-load, complet locale (sau via Ollama cu model local). Fără ele, pluginul downgrades la TF-IDF.

**Provideri configurabili** (în `~/.total-recall/config.json`): `huggingface` (implicit, local MiniLM), `ollama` (API local, `bge-m3`).

**Căutare multilinguală:** flag-ul `enableMultilingualSearch: true` activează expansiune de tokeni EN↔RO (ex. „decizie" găsește și „decision").

---

## Slide 21 — Embeddings și căutare multilinguală (continuare)

🎬 **Climaxul live al TEMEI 2** — stochează memoria în **engleză**, apoi într-o sesiune nouă întreabă în **română** și urmărește pe ecran cum expansiunea „decizie"→"decision" o găsește. Ăsta e momentul pe care dev-ii îl povestesc mai departe:

---

## Slide 21 — Embeddings și căutare multilinguală (continuare)

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

## Slide 22 — Hook-urile: integrarea automată (Claude Code / Copilot / Gemini)

> 💡 **WOW:** înainte de compactarea contextului (`PreCompact`), pluginul **salvează automat learnings-urile sesiunii** — cunoașterea supraviețuiește chiar și când contextul e șters.

> Deși inițial create exclusiv pentru Claude Code, hook-urile de lifecycle rulează acum și pe **GitHub Copilot CLI** și **Gemini CLI** (prin `hooks.copilot.json` și `hooks.gemini.json`).

---

## Slide 22 — Hook-urile: integrarea automată (continuare)

### Execuția pe clienți non-Claude (Copilot și Gemini CLI)

- **Cum funcționează:** La pornirea sau pe parcursul sesiunii, clientul Copilot sau Gemini apelează hook-ul corespunzător.
- **Side-effects executate:** Hook-urile de fundal rulează normal (trag ultimele memorii din git, reconstruiesc cache-ul indexului local, execută push/sync automat în org-vault).

---

## Slide 22 — Hook-urile: integrarea automată (continuare)

- **Limitare (graceful degradation):** Deoarece acești clienți drops/ignoră output-ul stdout al hook-urilor, **injectarea automată a indexului de context (`additionalContext`) în memoria de conversație este dezactivată**. Modelul nu vede rezumatul memoriilor la pornire, însă le poate interoga oricând manual prin uneltele MCP.

---

## Slide 22 — Hook-urile (continuare)

### `SessionStart` (4 pași, secvențiali)

```
1. pull-org-vault.sh       — git pull pe branch-ul org-vault (dacă e configurat)
2. build-memory-index.sh   — scanare awk a frontmatter-ului → .index-cache.txt
3. load-memory-index.sh    — cat .index-cache.txt → injectat în context (doar Claude Code)
4. load-open-questions.sh  — cat open-questions.md → injectat în context (doar Claude Code)
```

**Efect:** La fiecare nouă sesiune Claude, modelul primește automat rezumatul tuturor memoriilor tale — fără să ceri explicit.

---

## Slide 22 — Hook-urile (continuare)

### `PostToolUse` (declanșator: `store_memory|update_memory|delete_memory`)

```
sync-org-memory.sh
  ├─ verifică dacă memoria are tag "org"
  ├─ aplică filtrul de confidențialitate
  └─ git add/commit/push → branch org-vault al echipei
  + rebuild .index-cache.txt
```

---

## Slide 22 — Hook-urile (continuare)

### `PreCompact` (când contextul e aproape de limită)

```
extract-and-store-memories.sh
  ├─ citește transcriptul sesiunii din stdin JSON (transcript_path)
  ├─ cere lui Claude să extragă 0–3 learnings cheie ca JSON lines
  └─ store-learning.mjs → scrie direct ca fișiere .md în personal-vault
       (fără round-trip MCP; nu suprascrie memorii existente)
```

### `SessionEnd` — cleanup: loghează sesiunea și asigură flush-ul embeddings-urilor înainte de exit.

---

## Slide 23 — Instalare și utilizare practică

> 💡 **Util:** același plugin, 4 clienți — Claude Code, Copilot CLI, Gemini CLI, standalone — cu un singur `install.sh`.

---

## Slide 23 — Instalare și utilizare practică (continuare)

### Instalare bazată pe client

Scriptul `install.sh` este acum conștient de starea clientului și acceptă argumente specifice:

```bash
# 1. Clonează marketplace-ul și construiește pluginul
git clone https://github.com/adrian-balaban/my-claude-plugins-marketplace.git
cd my-claude-plugins-marketplace/plugins/total-recall
npm install && npm run build
```

---

## Slide 23 — Instalare și utilizare practică (continuare)

```bash
# 2. Înregistrează în funcție de clientul tău:

# Pentru Claude Code (nativ):
claude plugin install "$(pwd)"

# Pentru GitHub Copilot CLI (MCP + hooks.copilot.json):
./install.sh --copilot

# Pentru Gemini CLI (MCP + hooks.gemini.json):
./install.sh --gemini

# Pentru instalare Standalone (scrie căi absolute în settings.json):
./install.sh --standalone
```

---

## Slide 23 — Instalare și utilizare practică (continuare)

> **Org vault = opțional, dezactivat implicit** (pasul 6 din `install.sh`, default „n"). Cine instalează doar pentru uz personal poate ignora complet acest pas — memoria locală (`personal-vault`) funcționează 100% de la prima rulare, fără git. Vaultul org e strict pentru cine vrea memorie partajată de echipă pe git (necesită `gh` CLI autentificat, cerut **doar** la acest pas).

---

## Slide 23 — Instalare și utilizare practică (continuare)

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

---

## Slide 24 — Compatibilitate: Claude Code vs Copilot vs Gemini vs Codex

**Trei niveluri de integrare** (povestea din spatele matricei):

1. **Full** — Claude Code: unelte MCP + context injection automat + skills
2. **Parțial** — Copilot / Gemini CLI: uneltele și hooks merg, dar contextul nu se auto-injectează — modelul trebuie să întrebe
3. **Manual** — Codex CLI: doar unelte MCP, fără hooks

---

## Slide 24 — Compatibilitate: Claude Code vs Copilot vs Gemini vs Codex (continuare)

| Capabilitate                  | Claude Code                 | GitHub Copilot CLI        | Gemini CLI                | OpenAI Codex CLI          |
| ----------------------------- | --------------------------- | ------------------------- | ------------------------- | ------------------------- |
| **MCP Server (17 unelte)**    | ✅ Nativ                    | ✅ stdio MCP suportat     | ✅ stdio MCP suportat     | ✅ `~/.codex/config.toml` |
| **Side Effects (Sync/Index)** | ✅ Da                       | ✅ Da (hooks automate)    | ✅ Da (hooks automate)    | ❌ Nu (manual)            |

---

## Slide 24 — Compatibilitate: Claude Code vs Copilot vs Gemini vs Codex (continuare)

| Capabilitate                  | Claude Code                 | GitHub Copilot CLI        | Gemini CLI                | OpenAI Codex CLI          |
| ----------------------------- | --------------------------- | ------------------------- | ------------------------- | ------------------------- |
| **Context Injection**         | ✅ Da (`additionalContext`) | ❌ Nu (ignorat de client) | ❌ Nu (ignorat de client) | ❌ Nu                     |
| **Playbook Skills**           | ✅ Da (nativ)               | ❌ Nu                     | ❌ Nu                     | ❌ Nu                     |

---

## Slide 24 — Compatibilitate (continuare)

> **Bonus:** vault-urile total-recall se deschid nativ în **Obsidian** (fișiere `.md` cu frontmatter YAML). Nu folosi Obsidian Sync pe `org-vault` — sync-ul trebuie să treacă prin git-ul total-recall.

> **„De ce nu folosiți cq?"** — comparație onestă: `cq` (Mozilla.ai) acoperă **7 host-uri** (Claude, Codex, Copilot, Cursor, OpenCode, Pi, Windsurf), dar **fără context injection** — agentul trebuie să interogheze explicit store-ul. total-recall acoperă 3 clienți cu hooks automate (+ context injection nativ în Claude Code) și obiect partial similar: memorie de context, nu knowledge units partajate.

---

## Slide 25 — Sinteza finală și întrebări deschise

> 💡 **UTIL Takeaway — 3 lucruri de făcut mâine dimineață:** (1) Instalează Ollama, (2) rulează `ollama launch claude --model gemma3:4b` pentru teste locale rapide, (3) adaugă `total-recall` pentru memorie persistentă între sesiuni. Primele 10 minute cu total-recall, pas cu pas: [details/primele-10-minute.md](details/primele-10-minute.md) · Ghidul de decizie printabil: [details/decizie-o-pagina.md](details/decizie-o-pagina.md)

---

## Slide 25 — Sinteza finală și întrebări deschise (continuare)

### Ce am acoperit

**Claude vs Ollama:**

- Claude API: calitate maximă, cost per token, date în cloud · Ollama: gratuit, 100% local, offline
- `ollama launch claude`: harness-ul Claude Code pe model local — fără proxy
- Agent Claude vs LangChain: diferența e **cine deține loop-ul**, nu dacă pot rula local
- Decizia cheie: **confidențialitate > calitate > cost**

---

## Slide 25 — Sinteza finală și întrebări deschise (continuare)

**Total Recall:**

- Plugin MCP (17 unelte) pentru memorie persistentă — Claude Code, Copilot, Gemini CLI
- Vault dual (personal local + org pe git cu privacy filter), căutare hibridă cu Ebbinghaus decay
- Memoria = fișiere Markdown: git-abile, Obsidian-abile, ale tale

**Firul Mozilla.ai, recapitulat ca un kit de suveranitate:** llamafile = portabilitate totală · any-llm = multi-provider fără framework · Otari = gateway cu bugete · cq = shared agent learning. Le-am întâlnit pe parcurs; împreună sunt răspunsul open-source la „AI-ul cloud s-a scumpit".

---

## Slide 25 — Sinteza finală și întrebări deschise (continuare)

### Întrebări deschise pentru discuție

1. Cum integrezi total-recall într-o echipă? (org vault, drepturi de scriere) — și unde trage linia față de un standard extern: cq.exchange (store partajat cu review uman) vs git-ul echipei (total-recall org-vault)?
2. Ce modele Ollama ați testat pe hardware de lucru real?
3. Există scenarii unde ați combina ambele: Ollama pentru cod, Claude pentru analiză?
4. Cum gestionezi actualizările de model în Ollama față de API (fără breaking changes)?
5. Strategii de backup pentru vaultul total-recall?

---

## Slide 26 — Resurse

### Ollama

- **Site oficial:** ollama.com
- **Hub modele:** ollama.com/library
- **API reference:** ollama.com/docs (compatibilă OpenAI)

---

## Slide 26 — Resurse (continuare)

### Claude API

- **Documentație:** docs.anthropic.com
- **Modele curente:** claude-sonnet-5 (preț introductiv $2/$10 per MTok până la 31 aug 2026, apoi $3/$15 — verificat 11 iul 2026), claude-opus-4-8, claude-haiku-4-5 (ID canonic: `claude-haiku-4-5-20251001`), claude-fable-5, claude-sonnet-4-6
- **Prețuri:** anthropic.com/pricing
- **DPA / GDPR:** anthropic.com/legal

---

## Slide 26 — Resurse (continuare)

### Integrare Claude Code ↔ Ollama

- **Comandă oficială:** `ollama launch claude` (docs.ollama.com/integrations/claude-code)
- **Compatibilitate API Anthropic:** docs.ollama.com/api/anthropic-compatibility
- **Variabile de mediu:** `ANTHROPIC_BASE_URL`, `ANTHROPIC_AUTH_TOKEN` (nu seta `ANTHROPIC_API_KEY` pe calea manuală — v. Slide 10)

---

## Slide 26 — Resurse (continuare)

### Ecosistemul Mozilla.ai (Slide 8, 10b, 12, 13)

- **Otari gateway:** github.com/mozilla-ai/otari (+ `docs/use-with-claude-code.md`)
- **llamafile:** github.com/mozilla-ai/llamafile · docs.mozilla.ai/llamafile
- **any-llm:** github.com/mozilla-ai/any-llm
- **cq (shared agent learning):** github.com/mozilla-ai/cq
- **Articolul „AI Got Expensive. Now What?":** blog.mozilla.ai/ai-got-expensive-now-what

---

## Slide 26 — Resurse (continuare)

### Total Recall

- **Repo:** `github/total-recall/`
- **Arhitectura detaliată:** `plugins/total-recall/ARCHITECTURE.md`
- **Instalare:** `plugins/total-recall/install.sh --help`
- **README:** `plugins/total-recall/README.md`

---

## Slide 26 — Resurse (continuare)

### Handout-uri (folderul `details/` din acest repo)

- **Ghidul de decizie pe o pagină (printabil):** [details/decizie-o-pagina.md](details/decizie-o-pagina.md)
- **Primele 10 minute cu total-recall:** [details/primele-10-minute.md](details/primele-10-minute.md)
- Restul materialelor de sprijin sunt linkate din fiecare slide (📄 **Detalii**)

---

**Q&A — 15 minute**

> Mulțumesc pentru participare. Cod, arhitecturi și întrebări — le abordăm pe toate.
