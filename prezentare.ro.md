---
title: "Claude vs Ollama & Total Recall Plugin"
author: Adrian Balaban
date: 2026-07-16
layout: docs
---

# Claude vs Ollama & Total Recall Plugin

**Autor:** Adrian Balaban  
**Data:** 16 iulie 2026

Două subiecte practice despre cum extindem și alegem uneltele AI în workflow-ul de zi cu zi:

- primul despre decizia „cloud sau local" când lucrezi cu LLM-uri
- al doilea despre persistența memoriei în Claude/Copilot/Gemini printr-un plugin MCP

---

## Slide 0 — Ce iei din această sesiune

> Nu teorie generică — decizii concrete pe care le poți folosi azi.

Cinci lucruri pe care le iei de aici:

1. **Ce este Ollama** — LLM-uri local, zero cost-per-token, zero date în cloud.
2. **Claude vs Ollama** — comparație directă + integrarea `ollama launch claude`.
3. **Când alegi fiecare** — ghid de decizie cu criterii clare.
4. **Cum funcționează total-recall** — MCP, vault-uri, hook-uri, căutare hibridă cu curbă de uitare.
5. **Cum îl instalezi** — Claude Code, Copilot CLI, Gemini CLI.

> 💡 **UTIL:** La finalul sesiunii ai un **ghid de decizie pe o singură pagină** pe care îl poți printa sau salva pentru echipă: [details/decizie-o-pagina.md](details/decizie-o-pagina.md) (link și pe slide-ul de resurse).

---

## Slide 1 — Agendă (~65 de minute)

1. **Claude vs Ollama** (25 min)
   - Ce este Ollama și cum funcționează → _Slide 2 & 6_
   - Cazul real (modele instalate local, eGPU, modele `:cloud`) → _Slide 3, 4, 5_
   - Compararea motorului: Ollama vs llama.cpp vs llamafile → _Slide 7_
   - Comparație directă: performanță, costuri, confidențialitate → _Slide 8, 9, 10_
   - Integrare practică cu Claude Code și ghid de decizie → _Slide 11 & 12_ (+ Bonus: gateway-ul Otari → _Slide 11b_)
   - Tipuri de agenți: Claude vs LangChain → _Slide 13_
2. **Total Recall Plugin** (25 min)
   - Problema, demo before/after și soluția → _Slide 14, 14b, 15_
   - Structura pe disc și arhitectura → _Slide 16 & 17_
   - De ce algoritmi proprii (securitate, determinism) → _Slide 18_
   - Managementul vault-ului dual și cele 17 unelte MCP → _Slide 19 & 20_
   - Algoritmul de căutare hibridă (TF-IDF + Ebbinghaus + vectori) → _Slide 21 & 22_
   - Hook-uri de sistem, instalare și compatibilitate → _Slide 23, 24, 25_ (+ Bonus: noutățile din plugin → _Slide 25b_)
3. **Sinteză & Întrebări (Q&A)** (15 min) → _Slide 26 & 27_

---

## TEMA 1 — CLAUDE vs OLLAMA

> **Firul roșu al temei:** AI-ul cloud a devenit scump și cu lock-in; Mozilla.ai construiește alternativele deschise — le vom întâlni pe parcurs (llamafile, any-llm, Otari, cq) ca piese ale aceluiași kit de suveranitate.

---

## Slide 2 — Ce este Ollama?

> Ollama este un tool open-source care îți permite să rulezi modele LLM mari **local**,
> pe propriul hardware, fără nicio conexiune la internet și fără cost per token.

> 💡 **WOW:** peste **100 de milioane de descărcări** pe Docker Hub (imaginea `ollama/ollama`) și ~175k stars pe GitHub. Este cel mai popular runtime local pentru LLM-uri (dar nu singurul — v. Slide 7 pentru llama.cpp și llamafile).

**Ce face Ollama:**

- Descarcă și rulează modele quantizate local (Llama, Mistral, Gemma, Phi, Qwen, etc.)
- Pentru modele care nu încap local sau sunt proprietare, oferă **modele `:cloud`** — proxy prin infrastructura Ollama (ex. `glm-5.2:cloud`, `gemini-3-flash-preview:cloud`); aceeași interfață CLI/API, inferența rulează la furnizor
- Expune API REST pe `http://localhost:11434`, compatibilă atât cu formatul **OpenAI**, cât și cu formatul **Anthropic** (`/v1/messages` — de asta merge `ollama launch claude`)

**Instalare — o singură comandă după download** (ollama.com/download):

```bash
ollama run llama3.2          # pull + run, gata de conversație

# Modele proprietare/mari — NU se descarcă; rulează prin proxy :cloud (cont ollama.com)
ollama signin
ollama run gemini-3-flash-preview:cloud   # Gemini, servit prin Ollama Cloud
```

> **⚠️ Unde sunt Claude, Gemini și GPT?** Local rulează doar modele **open-weight**. Gemini frontier există doar ca `gemini-3-flash-preview:cloud`; GPT doar ca `gpt-oss` open-weight (varianta cloud: `gpt-oss:120b-cloud`); **Claude nu există în Ollama deloc** — doar imitații comunitare, de evitat. Pentru Claude real: API-ul Anthropic sau `ollama launch claude` cu alt model în spate.

📄 **Detalii** (tabelul modelelor locale cu VRAM, lista `:cloud` completă, confuzia Gemini ≠ Gemma, Antigravity IDE): [details/ollama-modele-locale-si-cloud.md](details/ollama-modele-locale-si-cloud.md)

---

## Slide 3 — Modele instalate local: cazul real (`ollama list`)

> 🎬 **Beat live:** rulează `ollama list` pe ecran (10 secunde de energie reală — coloana SIZE face punctul singură); output-ul de mai jos e fallback-ul dacă demo-ul eșuează. Mașina: **Dell Latitude 5521** (i7-11850H, MX450 2GB GDDR6).

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

**Concluzia practică:**

- MX450 (2GB VRAM) nu poate ține niciun model în VRAM — toate rulează pe CPU via RAM
- `qwen3.5` (6.6 GB) și `ornith:9b` (5.6 GB) sunt singurele care intră confortabil în 16 GB RAM → ~3–8 tok/s
- Modelele cu tag `:cloud` (kimi-k2.7-code, glm-5.2) sunt **API-uri externe proxiate prin Ollama** — nu rulează local
- **Pe acest laptop, Claude API rămâne alegerea corectă.** Modelele locale = experimente offline sau eGPU extern (Thunderbolt 4)

---

## Slide 4 — Pot adăuga GPU pe laptop? (Bonus)

> **TL;DR:** GPU-ul intern e soldat — singura opțiune e **eGPU extern via Thunderbolt 4**. Cu un enclosure SH + RTX 3060 12GB nou (~3.500 lei), rulezi modele de 7–13B complet pe GPU la 20–50 tok/s. Bottleneck-ul TB4 e irelevant pentru inference LLM (contează VRAM-ul, nu banda).

![Razer Core X V2 — enclosure eGPU second-hand pe OLX](images/razer-core-x-v2-egpu-olx.png)

**Ce înseamnă „banda" aici:** lățimea de bandă a legăturii Thunderbolt 4 (~40 Gbps, echivalent PCIe x4) față de un slot PCIe x16 din desktop (de ~4× mai rapid). Banda contează doar când muți date **între** RAM/CPU și GPU. La inference LLM, greutățile modelului se copiază în VRAM **o singură dată, la încărcare** (câteva secunde în plus prin TB4); după aceea totul rulează în interiorul GPU-ului, iar prin cablu circulă doar promptul și tokenii generați — kilobytes. De asta TB4 „mai lent" nu-ți taie tok/s: bottleneck-ul real e dacă modelul **încape în VRAM**, nu cât de gros e cablul. Excepție: dacă modelul NU încape în VRAM și straturile se plimbă permanent între RAM și GPU — atunci banda devine exact bottleneck-ul, iar eGPU-ul suferă mai mult decât un GPU intern.

📄 **Detalii** (lane-uri PCIe, calculul 40 Gbps vs 256 Gbps, de ce gaming-ul pierde dar LLM-urile nu): [details/pcie-vs-tb4.md](details/pcie-vs-tb4.md)

---

## Slide 5 — La ce e util Ollama cu GLM-5.2 și Kimi-K2.7-Code?

> Ambele apar în `ollama list` cu `SIZE=—` și suffix `:cloud` — **nu sunt modele locale**.
> Sunt API-uri externe proxiate prin Ollama; inferența rulează pe serverele Zhipu AI / Moonshot AI din China.

### Ce înseamnă `:cloud` în Ollama?

```
kimi-k2.7-code:cloud    —     ← niciun fișier GGUF descarcat
glm-5.2:cloud           —     ← niciun fișier GGUF descarcat
```

- `SIZE=—` = nu există model local; Ollama trimite cererea la API-ul extern
- Tokenizarea și inferența se fac **pe serverele furnizorului**, nu pe CPU/GPU-ul tău
- Avantaj față de API-ul direct: aceeași interfață CLI (`ollama run <model>:cloud`) pentru toate modelele `:cloud`, cu endpoint-uri atât **OpenAI-compatible**, cât și **Anthropic-compatible** — verificat: pagina fiecărui model listează direct comenzile `ollama launch claude/codex/opencode/copilot --model <model>:cloud`
- Claude oficial NU există în Ollama (doar prin API Anthropic: [docs.anthropic.com](https://docs.anthropic.com)); Gemini există doar ca [gemini-3-flash-preview:cloud](https://ollama.com/library/gemini-3-flash-preview), iar experiența completă Gemini o dă [Antigravity IDE](https://antigravity.google/)

---

### Cine sunt cele două modele

- **GLM-5.2** (Zhipu AI, Beijing) — flagship-ul Z.ai; context ~1M tokens (976K), 756B parametri. Aproape de Claude Opus 4.8 pe Terminal-Bench 2.1 (**81.0 vs 85.0** — re-verificat pe ollama.com/library/glm-5.2 la 11 iul 2026), la preț API de **~12–20× mai mic**, greutăți deschise MIT. Română slabă — rămâi pe Claude pentru RO.
- **Kimi-K2.7-Code** (Moonshot AI, Beijing) — specializat pe generare și analiză de cod; puncte forte: boilerplate, code review, explicare cod legacy.

> **„Open-weight" ≠ „încape pe hardware-ul tău":** Kimi-K2 = ~600 GB VRAM, GLM-5.x = 100–200 GB — doar clustere datacenter. Pe Ollama, familia GLM-5 e `:cloud`-only.

### ⚠️ Regula GDPR (partea cu adevărat utilă)

- Ambele procesează datele pe **servere în China** — jurisdicție fără decizie de adecvare GDPR (spre deosebire de US, acoperit de **EU-US Data Privacy Framework**, decizie de adecvare din 10 iulie 2023)
- Nici Claude nu e „gratuit" GDPR: Anthropic are DPA+SCC, dar procesarea via API direct e pe infrastructură non-EU; pentru rezidență EU calea uzuală e AWS Bedrock / Vertex AI pe regiuni EU (verificați DPA-ul și subprocesatorii pentru cazul vostru concret)
- **Nu trimite prin API-urile chinezești:** cod cu date personale ale clienților, IP proprietar, credențiale, contracte

**Regula scurtă:** cod ne-sensibil + buget → `:cloud` chinezesc; română, date sensibile, raționament critic → Claude.

```bash
ollama signin                          # cont pe ollama.com
ollama launch claude --model glm-5.2:cloud  # în Claude Code
```

📄 **Detalii** (comparația pe 4 modele, riscul GDPR pe larg, ce poți rula local pe CPU): [details/glm-kimi-cloud.md](details/glm-kimi-cloud.md)

---

## Slide 6 — Cum funcționează Ollama intern

> 💡 **WOW:** quantizarea Q4 comprimă un model de 8× — un 70B care „cere" 280 GB încape în 48 GB VRAM, cu doar ~2–5% pierdere de calitate.

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

- Parametrii modelului sunt comprimați de la float32 (4 bytes/param) la int4 (0.5 bytes/param)
- Pierdere de calitate: ~2-5% față de versiunea completă
- Format standard: **GGUF** (GPT-Generated Unified Format)

**Context window:** limitat de VRAM disponibil (model + KV cache asociat) — un model de 8B pe 8GB VRAM susține context de ~8K tokens; Llama 3.1 70B Q4 pe 48GB poate ajunge **la limită** la 128K tokens doar cu KV cache quantizat (modelul ~40GB lasă puțin spațiu; practic, 32–64K e mai realist pe 48GB).

---

## Slide 7 — Ollama vs llama.cpp vs llamafile: relația și când alegi care

> **Relația:** Ollama e construit **peste llama.cpp** — îl folosește ca motor de inference sub capotă, prin propriul wrapper în Go + un fork al nucleului GGML/llama.cpp. Deci nu sunt concurenți: Ollama = strat prietenos peste llama.cpp.

### Comparație directă

| Axa                   | **llama.cpp** (motorul, low-level)                                                                                           | **Ollama** (wrapper/runtime prietenos)                                                 |
| --------------------- | ---------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| **Nivel**             | Motor de inference C/C++                                                                                                     | Wrapper peste llama.cpp (Go + fork GGML)                                               |
| **Control**           | **Maxim** — flag-uri CLI directe, quantizare custom, `llama-server`, grammar-constrained decoding, tuning fin de GPU offload | Mai restrâns — expune ce consideră util                                                |
| **Management modele** | **Manual** — aduci/convertezi tu fișierele GGUF                                                                              | **Automat** — registry, versioning, `Modelfile`-uri pentru customizare                 |
| **UX**                | `./llama-server -m model.gguf ...` (curbă de învățare mai abruptă)                                                           | `ollama pull` / `ollama run` (drag-and-start)                                          |
| **API**               | `llama-server` (HTTP, mai brut)                                                                                              | **REST API la `:11434`** + endpoint **compatibil OpenAI**                              |
| **Caz tipic**         | Inference înglobat direct în altă aplicație; build-uri custom                                                                | Integrare API rapidă local (LangChain, agenți, Claude Code via `ollama launch claude`) |

### A treia opțiune: llamafile — „modelul E un fișier"

> 💡 **WOW:** un llamafile e **un singur executabil** care rulează pe Windows, macOS, Linux și BSD **fără instalare** — modelul, llama.cpp și runtime-ul într-un fișier pe care îl poți pune pe stick USB, arhiva sau șterge cu un simplu delete. (mozilla-ai/llamafile, 25k+ ⭐, revitalizat de Mozilla.ai)

**Trade-off-uri oneste** (recunoscute chiar de Mozilla.ai): binarele sunt mari (runtime-ul se livrează cu fiecare model), swap-ul de modele e mai greoi decât `ollama pull`, iar pe Apple Silicon stack-urile MLX sunt mai rapide. llamafile e pentru cazul în care AI-ul trebuie să fie **portabil, vendor-free și cu adevărat al tău**.

### Critica de suveranitate: Ollama = „managed service wearing a hoodie"

> Formularea aparține Mozilla.ai — **parte interesată** (dezvoltă llamafile), nu arbitru neutru. Mecanismele invocate sunt însă factuale: **registry centralizat** (model Docker Hub) + **blob-uri cu metadate proprii** (GGUF-ul rămâne recuperabil, dar workflow-ul e al vendorului) + **daemon obligatoriu**.

> **Formularea pentru slide:** „Ollama e open source, dar distribuția e a vendorului. Nu e lacăt — e gravitație."

📄 **Detalii** (quick-start llamafile cu verificare de checksum, cele 3 mecanisme de soft lock-in pe larg): [details/ollama-vs-llamacpp-vs-llamafile.md](details/ollama-vs-llamacpp-vs-llamafile.md)

### Când alegi care

| Vrei…                                                                  | Alegi         |
| ---------------------------------------------------------------------- | ------------- |
| Setup rapid, swap între modele, API-first (agenți, Claude Code)        | **Ollama**    |
| Control maxim (cuantizare, offload, build custom)                      | **llama.cpp** |
| Portabilitate totală: un fișier, zero install, zero daemon, air-gapped | **llamafile** |

---

## Slide 8 — Comparație directă: Claude vs Ollama

> 💡 **Punctul-cheie:** nu e „care e mai bun", ci **ce optimizezi** — inteligență maximă (Claude) vs suveranitate totală: $0/token, offline, zero egress (Ollama).

> 📊 **WOW Metric:** Latența la primul token (TTFT) pe Ollama cu un model 8B pe GPU local este de **~120ms**, în timp ce prin API-ul Claude este de **~650ms** (de ~5 ori mai rapid local).

Cele 5 axe care contează (cifre orientative, iul 2026 — depind de model, hardware și quantizare):

| Criteriu                  | Claude (API Anthropic)                | Ollama (local)                                       |
| ------------------------- | ------------------------------------- | ----------------------------------------------------- |
| **Calitate top-tier**     | ✅ Opus 4.8 = state of the art        | Llama 3.3 70B ≈ GPT-4o, dar sub Opus                 |
| **Cost**                  | $3–$15 / 1M tokens                    | $0/token — dar GPU bun: $500–$3000+                  |
| **Confidențialitate**     | Date trimise la Anthropic (US)        | 100% local, zero egress, merge air-gapped            |
| **Latență (TTFT)**        | ~500ms–2s                             | ~100–500ms pe GPU local                              |
| **Integrare Claude Code** | ✅ Nativă                             | ✅ Nativă prin `ollama launch claude` (fără proxy)   |

📄 **Detalii** (comparația completă pe 13 criterii — context window, rate limits, actualizări, GDPR): [details/comparatie-claude-ollama.md](details/comparatie-claude-ollama.md)

---

## Slide 9 — Costul real: Claude API vs Ollama

> 💡 **WOW:** un 'agentic developer' ce lucreaza intens arde ~$400/lună pe API — un RTX 4090 de $2.000 se amortizează în ~5 luni. Dar dacă ești utilizator light ($30/lună), amortizarea durează ani.

> 📊 **WOW (datat):** 1 iunie 2026 — Copilot a mutat Claude Opus de la **3× la 27×** multiplicator și Sonnet de la **1× la 9×**; tier-ul gratuit GPT-4o a dispărut. „Era AI-ului cloud ieftin s-a terminat" (Mozilla.ai, _AI Got Expensive. Now What?_, mai 2026). Ăsta e forcing function-ul întregii discuții cloud-vs-local. Sursa numerelor: [blog.mozilla.ai/ai-got-expensive-now-what](https://blog.mozilla.ai/ai-got-expensive-now-what/) (Anushri Gupta, 26 mai 2026).

### Claude API (Sonnet 4.6 — prețuri verificate la 11 iul 2026)

```
Input:  $3.00 / 1M tokens
Output: $15.00 / 1M tokens

Sesiune agentică intensă (8h/zi, multe tool calls, context re-reads):
  Input:  ~3M tokens/zi    → $9/zi
  Output: ~600K tokens/zi  → $9/zi
  TOTAL:  ~$18/zi → ~$400/lună (22 zile lucrătoare)
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

### Găsește-ți tier-ul

| Profil                | Cheltuială API tipică | Amortizare hardware local           |
| --------------------- | --------------------- | ------------------------------------ |
| Indie / light         | ~$30/lună             | ani — rămâi pe API sau CPU-only     |
| Daily driver          | ~$100/lună            | ~6 luni (RTX 3080 SH ~$600)         |
| **Agentic developer** | **~$400/lună**        | **~5 luni (RTX 4090 ~$2.000)**      |

**Concluzie financiară:** Pentru un developer cu utilizare agentică intensă (~$400/lună API), Ollama devine mai ieftin decât API-ul Claude în 2-6 luni cu un GPU decent. Utilizatorii light (~$30/lună) recuperează hardware-ul în câțiva ani, nu luni — ROI-ul în luni presupune utilizare intensă. Sub un GPU de ~$600, diferența de calitate poate să nu merite.

> **Notă (verificat 11 iul 2026):** Sonnet 5 (lansat 30 iun 2026) are preț introductiv **$2/$10 per MTok până la 31 aug 2026**, apoi revine la standard $3/$15 (același nivel ca Sonnet 4.6). În fereastra introductivă, calculul de mai sus scade de la ~$18/zi la ~$12/zi (~$265/lună) pentru același profil agentic.

---

## Slide 10 — Confidențialitate și date: diferența crucială

> 💡 **WOW:** cu Ollama, promptul tău nu părăsește **niciodată** mașina — funcționează și cu cablul de rețea scos (air-gapped). Pentru finance/healthcare/NDA, asta nu e un „nice to have", e singura opțiune legală.

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

## Slide 11 — Ollama cu Claude Code: integrarea practică

> 💡 **WOW — gotcha-ul „subscription hijack":** configurezi manual Claude Code pe Ollama, totul pare OK… dar cu abonament Claude Max/Pro cererile pleacă **silențios pe OAuth la api.anthropic.com**, nu la Ollama. Cauza: `ANTHROPIC_API_KEY=""` — șirul gol înseamnă „nu e setat". Fix-ul pe o linie: setează doar `ANTHROPIC_AUTH_TOKEN=ollama` și verifică cu `/status` că base URL-ul e `localhost:11434`.

**Metoda oficială: `ollama launch claude`** — pornește clientul Claude Code cu Ollama ca backend, nativ (fără proxy):

```bash
# Model local (pe GPU propriu, ex. RTX 3060)
ollama launch claude --model qwen3.5

# Model cloud (fără download local)
ollama launch claude --model glm-5.2:cloud

# Non-interactiv / scriptat
ollama launch claude --model glm-5.2:cloud --yes -- -p "how does this repo work?"
```

Ce face comanda automat:

- instalează/pornește **clientul Claude Code**
- setează `ANTHROPIC_BASE_URL=http://localhost:11434`, `ANTHROPIC_AUTH_TOKEN=ollama`, `ANTHROPIC_API_KEY=""`
- Ollama expune **endpoint compatibil API Anthropic** la `localhost:11434` → cerere în format Anthropic → model Ollama răspunde → răspuns re-ambalat în format Anthropic

### Distincția cheie: formatul e Anthropic, inteligența e Ollama

Ollama vorbește **nativ** formatul API Anthropic la `localhost:11434` — **nu există proxy separat**. Clientul Claude Code „crede" că vorbește cu Anthropic; de fapt răspunde modelul ales cu `--model`:

```
cerere în format Anthropic → Ollama traduce intern → modelul Ollama răspunde
      → răspuns re-ambalat în format Anthropic → clientul Claude Code îl consumă
```

**Metoda manuală (alternativă, fără `launch`):**

```bash
ollama pull qwen3.5
export ANTHROPIC_BASE_URL=http://localhost:11434
export ANTHROPIC_AUTH_TOKEN=ollama
claude --model qwen3.5
```

Sau permanent în `~/.claude/settings.json`:

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "http://localhost:11434",
    "ANTHROPIC_AUTH_TOKEN": "ollama"
  }
}
```

**Esențialul limitărilor:** endpoint-ul Anthropic-compatibil suportă tool calling și extended thinking (suport basic — `budget_tokens` acceptat dar **neaplicat**), dar **nu** prompt caching; calitatea = calitatea modelului local ales.

📄 **Detalii** (mecanica `x-api-key` vs `Bearer`, lista completă de capabilități și limitări, modele cu tool calling): [details/integrare-claude-code-ollama.md](details/integrare-claude-code-ollama.md)

---

## Slide 11b — A treia cale: Otari, gateway Anthropic-compatibil (Bonus)

> 💡 **WOW:** același truc `ANTHROPIC_BASE_URL`, dar cu **buget enforcement ÎNAINTE de request, nu după factură.**

**Otari** (Mozilla.ai, open-source, lansat mai 2026, construit peste `any-llm`) e un gateway LLM self-hosted care expune și endpoint-ul Anthropic (`POST /v1/messages`) — deci Claude Code poate rula prin el exact ca prin Ollama, dar cu stratul operațional pe care Ollama nu-l are:

- **Bugete** per user / per cheie, aplicate _înainte_ ca cererea să ruleze
- **Chei virtuale** — clientul nu vede niciodată cheia reală Anthropic/OpenAI; le poți revoca oricând
- **Usage & spend tracking** în timp real, pe toate modelele (40+ provideri prin any-llm)
- Rulezi Claude real, GPT, Mistral sau modele locale prin **același endpoint**

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

## Slide 12 — Ghid de decizie: Claude API sau Ollama?

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

> 💡 **UTIL:** schema + scenariile + tier-urile de cost sunt în ghidul printabil promis la început: [details/decizie-o-pagina.md](details/decizie-o-pagina.md). Sau rulează direct `ollama launch claude` pentru a testa local înainte de a decide implementarea în producție.

**Scenarii recomandate:**

| Scenariu                                                            | Alegere                         | Model recomandat                                             |
| ------------------------------------------------------------------- | ------------------------------- | ------------------------------------------------------------ |
| Proiect cu date sensibile / NDA                                     | Ollama                          | DeepSeek Coder 33B sau Qwen 2.5 Coder 32B                    |
| Echipă enterprise cu restricții cloud                               | Ollama                          | Llama 3.3 70B (server local)                                 |
| Prototipare rapidă, calitate maximă                                 | Claude API                      | Sonnet 4.6 sau Opus 4.8                                      |
| Developer indie, buget limitat                                      | Ollama                          | Llama 3.1 8B sau Qwen 2.5 7B                                 |
| Sarcini critice de raționament                                      | Claude API                      | Opus 4.8 cu extended thinking                                |
| Cod cu context mare (>50K tokens)                                   | Claude API                      | Sonnet 4.6 (200K context)                                    |
| Offline / air-gapped                                                | Ollama                          | Orice model descărcat prealabil                              |
| Echipă cu GPU server partajat                                       | Ollama                          | Llama 3.3 70B, server central                                |
| Echipă care vrea Claude + modele locale + control buget centralizat | **Otari gateway** (self-hosted) | Claude real + orice provider, chei virtuale, bugete per user |

---

## Slide 13 — Agent Claude vs agent LangChain

> Confuzia vine din faptul că „agent Claude" și „agent LangChain" trăiesc la **niveluri diferite de stivă**:
> unul e _model + harness_, celălalt e _framework model-agnostic_.

### Ideea sticky

> **Diferența e cine deține loop-ul, nu dacă pot rula local.** Agent Claude = harness opinat al Anthropic (configurezi, nu scrii loop-ul); LangChain/LangGraph = tu scrii graful. Ambele pot rula pe Ollama: „Claude agent e lipit de Anthropic" nu mai e adevărat (`ollama launch claude`) — limitarea reală e **calitatea modelului local ales**. Iar `total-recall` funcționează ca memorie persistentă **pentru ambele runtime-uri** — același vault, indiferent de backend.

> **Alternativa „subțire" la LangChain pentru multi-provider:** **any-llm** (Mozilla.ai, 2.1k ⭐) — un singur `completion()` peste 40+ provideri, fără taxa de abstracție LangChain. Dacă tot ce vrei e „schimb providerul dintr-un string", nu-ți trebuie un framework de agenți.

📄 **Detalii** (comparația pe 7 axe, cele 3 forme de „agent Claude", tabelul pe hardware real): [details/agent-claude-vs-langchain.md](details/agent-claude-vs-langchain.md)

### Regulă de decizie

| Vrei…                                                                     | Alegi                                                       |
| ------------------------------------------------------------------------- | ----------------------------------------------------------- |
| Cod / inginerie în repo, calitate maximă, accept cloud                    | **Claude Code** (cu Claude real)                            |
| Agent custom cu Claude ca creier, tool-uri proprii                        | **Claude Agent SDK**                                        |
| **Harness-ul Claude Code, dar pe model local** (offline, zero cost)       | **`ollama launch claude`** (client Claude + backend Ollama) |
| Control flow explicit, stare durabilă, sau agent model-agnostic pe Ollama | **LangGraph** (nu LangChain clasic)                         |

---

## TEMA 2 — TOTAL RECALL PLUGIN

> **Puntea între teme:** ai ales runtime-ul (cloud sau local). Acum să-l faci să țină minte cine ești — altfel fiecare sesiune o iei de la zero.

---

## Slide 14 — Problema: Claude uită tot după sesiune

> La sfârșitul fiecărei conversații, Claude pierde tot contextul acumulat.
> Decizii, preferințe, arhitecturi discutate — totul dispare.

> 📊 **WOW Stat:** În medie, un 'agentic developer' **re-explică aceleași preferințe și detalii de proiect de ~15 ori pe lună** în sesiuni noi, pierzând peste 2 ore de productivitate.

**Simptomele:**

- Reexplici același context la fiecare sesiune nouă
- Preferințele tale de cod trebuie re-menționate de fiecare dată
- Deciziile de arhitectură nu se acumulează nicăieri
- Feedback-ul pe care l-ai dat modelului nu persistă

**Consecința:** Cu cât lucrezi mai mult cu Claude Code, cu atât pierzi mai mult timp re-explicând ceea ce ai deja explicat.

> **Nu ești singurul care vrea asta:** Mozilla.ai a lansat `cq` (1.2k ⭐) — un standard deschis pentru _shared agent learning_: agenții propun «knowledge units» (workaround-uri, API-uri nedocumentate) într-un store comun, cu review uman. **Complementar, nu concurent:** cq = lecții operaționale partajate între agenți; total-recall = memoria TA de context (decizii, preferințe, arhitectură) cu curbă de uitare Ebbinghaus — fișiere `.md` + git, fără server și fără review pipeline.

---

## Slide 14b — Demo: aceeași întrebare, cu și fără memorie

> 🎬 **Beat live** (sau clip pre-înregistrat de 20 de secunde, dacă live e riscant) — payoff-ul emoțional al întregii teme.
>
> _Pregătire înainte de prezentare:_ stochează memoria-fixture („reține că am ales PostgreSQL față de MySQL pentru JSONB" → `architecture/db-choice.md`) într-o sesiune cu total-recall, ca recall-ul din panoul drept să aibă ce găsi.

```
FĂRĂ total-recall (sesiune Claude nouă):          CU total-recall (sesiune nouă, același prompt):
──────────────────────────────────────            ──────────────────────────────────────────────
> care DB am ales pentru proiect?                 > care DB am ales pentru proiect?

„Nu am context despre o decizie                   → recall_memory(query="DB proiect")
anterioară legată de baza de date.                „Ați ales PostgreSQL față de MySQL,
Îmi poți da mai multe detalii?"                   pentru suportul JSONB — decizie stocată
                                                  pe 1 iunie (architecture/db-choice.md)."
```

Publicul nu trebuie să creadă pe cuvânt — vede diferența pe ecran în 20 de secunde.

---

## Slide 15 — Soluția: total-recall

> Un plugin Claude Code care dă AI-ului memorie persistentă, căutabilă, între sesiuni.

> 🎬 **Beat live:** rulează pe ecran `claude -p "Reaminteste-ti decizia noastra despre baza de date"` și arată apelul `recall_memory` în output. (Pentru public, comanda e și „tema de acasă" din handout.)

**Ce este:**

- **Plugin Claude Code** instalat din marketplace
- **MCP server** cu 17 unelte (stdio, înregistrat via `claude mcp add`)
- **Vault de fișiere Markdown** stocat local la `~/.total-recall/`
- **Hook-uri automate** care injectează contextul la fiecare sesiune nouă
- **Skill `/total-recall:memory-workflow`** pentru sesiuni structurate de recall/store

**Ce nu este:**

- Nu trimite date în cloud (vaultul personal este complet local)
- Nu folosește o bază de date opacă — fiecare memorie este un fișier `.md` citibil
- Nu suprascrie context — injectează, nu înlocuiește

---

## Slide 16 — Structura pe disk

> 💡 **WOW:** zero bază de date opacă — memoria AI-ului tău e un folder de fișiere `.md` pe care le poți citi, edita, versiona cu git și deschide în Obsidian.

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

## Slide 17 — Arhitectura: modulele principale

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

## Slide 18 — De ce algoritmi proprii (fără dependențe grele)

> **O singură dependență obligatorie** (`@modelcontextprotocol/sdk`). Toți algoritmii cheie — TF-IDF, Ebbinghaus, RRF, frontmatter parser — sunt scriși de la zero.

**Ce câștigi:**

1. **Securitate:** fără `gray-matter` → fără CVE-ul `js-yaml` (GHSA-h67p-54hq-rp68)
2. **Scoring coerent:** title-boost, tag-boost, Ebbinghaus = o singură formulă, nu trei librării
3. **Determinism:** zero apeluri LLM, zero cost, merge offline / air-gapped
4. **Auditabilitate:** fiecare decizie de scoring e observabilă prin `get_stats`

> **Filozofia:** dependențele grele = risc de CVE + breaking-change + black-box. Doar ONNX și sqlite-vec rămân externe — și ele opționale.

---

## Slide 19 — Dual Vault: personal vs org

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

**Filtru de confidențialitate (org sync):**

- Blochează secrete și chei API după tipare cunoscute (chei PEM, `sk-`, `ghp_`, `AKIA`, JWT, Slack/GitLab/Google tokens etc.)
- Detectează și **secrete etichetate** — ex. `aws_secret_access_key = …`: un `~/.aws/credentials` lipit din greșeală e blocat înainte de push
- Blochează toate adresele email (cu excepția domeniilor din allowlist)
- Fail-closed: dacă filtrul nu poate analiza conținutul, NU face push

---

## Slide 20 — Cele 17 unelte MCP

> 🎬 **Beat live — ideea sticky demonstrată, nu enunțată:** spui „reține că prefer PostgreSQL" → modelul alege singur `store_memory`; întrebi „ce am decis despre DB?" → alege `recall_memory`. CRUD complet + căutare + întreținere, **în limbaj natural** — nu înveți 17 nume de unelte.

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

## Slide 21 — Algoritmul de căutare: TF-IDF + Ebbinghaus

> 💡 **WOW:** memoria AI-ului **uită ca un om** — curba uitării lui Ebbinghaus (1885) aplicată în cod: memoriile neimportante și neaccesate se estompează din rezultate, fiecare accesare le „reîmprospătează" cu +20%.

> **Ce e TF-IDF?** Term Frequency × Inverse Document Frequency — algoritmul clasic de căutare text: un cuvânt punctează mult dacă apare **des în documentul respectiv** (TF) dar **rar în restul colecției** (IDF). „postgresql" care apare de 5 ori într-o memorie și aproape nicăieri altundeva = scor mare; „proiect", care apare peste tot = scor aproape zero. _Inverted index_ = harta inversă `cuvânt → lista documentelor care îl conțin`, ca indexul de la finalul unei cărți — de asta căutarea nu citește fișierele, doar indexul.

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
decay = importanceScore × exp(−λ × daysSince)
        × (1 + accessCount × 0.2 + confirmations × 0.1 − flags × 0.1)
        — rezultat limitat (clamp) la [0, 1]
```

| importanceScore | λ (viteza de uitare) | Comportament                                    |
| --------------- | -------------------- | ----------------------------------------------- |
| 1.0 (critic)    | 0.032                | Decay lent — memoria rămâne relevantă săptămâni |
| 0.5 (normal)    | 0.096                | Decay mediu                                     |
| 0.3 (scăzut)    | 0.122                | Decay rapid — dispare din rezultate în zile     |

Fiecare acces adaugă +20% forță de retenție (`accessCount × 0.2`); fiecare confirmare +10%, fiecare flag −10% (`confirm_memory`) — memoria nu doar „îmbătrânește", ci primește feedback.

---

## Slide 22 — Embeddings și căutare multilinguală (opționale)

> Embeddings = opționale, lazy-load, complet locale (sau via Ollama / Vertex AI). Fără ele, pluginul degradează curat la TF-IDF.

**Provideri configurabili** (în `~/.total-recall/config.json`): `huggingface` (implicit, local MiniLM), `ollama` (API local, `bge-m3`), `vertexai` (Google Cloud, `text-embedding-004`).

**Căutare multilinguală:** flag-ul `enableMultilingualSearch: true` activează expansiune de tokeni EN↔RO (ex. „decizie" găsește și „decision").

🎬 **Climaxul live al TEMEI 2** — stochează memoria în **engleză**, apoi într-o sesiune nouă întreabă în **română** și urmărește pe ecran cum expansiunea „decizie"→"decision" o găsește. Ăsta e momentul pe care dev-ii îl povestesc mai departe:

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

## Slide 23 — Hook-urile: integrarea automată (Claude Code / Copilot / Gemini)

> 💡 **WOW:** înainte de compactarea contextului (`PreCompact`), pluginul **salvează automat learnings-urile sesiunii** — cunoașterea supraviețuiește chiar și când contextul e șters.

> Deși inițial create exclusiv pentru Claude Code, hook-urile de lifecycle rulează acum și pe **GitHub Copilot CLI** și **Gemini CLI** (prin `hooks.copilot.json` și `hooks.gemini.json`).

### Execuția pe clienți non-Claude (Copilot și Gemini CLI)

- **Cum funcționează:** La pornirea sau pe parcursul sesiunii, clientul Copilot sau Gemini apelează hook-ul corespunzător.
- **Side-effects executate:** Hook-urile de fundal rulează normal (trag ultimele memorii din git, reconstruiesc cache-ul indexului local, execută push/sync automat în org-vault).
- **Limitare (graceful degradation):** Deoarece acești clienți drops/ignoră output-ul stdout al hook-urilor, **injectarea automată a indexului de context (`additionalContext`) în memoria de conversație este dezactivată**. Modelul nu vede rezumatul memoriilor la pornire, însă le poate interoga oricând manual prin uneltele MCP.

### `SessionStart` (4 pași, secvențiali)

```
1. pull-org-vault.sh       — git pull pe branch-ul org-vault (dacă e configurat)
2. build-memory-index.sh   — scanare awk a frontmatter-ului → .index-cache.txt
3. load-memory-index.sh    — cat .index-cache.txt → injectat în context (doar Claude Code)
4. load-open-questions.sh  — cat open-questions.md → injectat în context (doar Claude Code)
```

**Efect:** La fiecare nouă sesiune Claude, modelul primește automat rezumatul tuturor memoriilor tale — fără să ceri explicit.

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

### `SessionEnd` — cleanup: loghează sesiunea și asigură flush-ul embeddings-urilor înainte de exit.

---

## Slide 24 — Instalare și utilizare practică

> 💡 **Util:** același plugin, 4 clienți — Claude Code, Copilot CLI, Gemini CLI, standalone — cu un singur `install.sh`.

### Instalare bazată pe client

Scriptul `install.sh` este acum conștient de starea clientului și acceptă argumente specifice:

```bash
# 1. Clonează marketplace-ul și construiește pluginul
git clone https://github.com/adrian-balaban/my-claude-plugins-marketplace.git
cd my-claude-plugins-marketplace/plugins/total-recall
npm install && npm run build

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

## Slide 25 — Compatibilitate: Claude Code vs Copilot vs Gemini vs Codex

**Trei niveluri de integrare** (povestea din spatele matricei):

1. **Full** — Claude Code: unelte MCP + context injection automat + skills
2. **Parțial** — Copilot / Gemini CLI: uneltele și hooks merg, dar contextul nu se auto-injectează — modelul trebuie să întrebe
3. **Manual** — Codex CLI: doar unelte MCP, fără hooks

| Capabilitate                  | Claude Code                 | GitHub Copilot CLI        | Gemini CLI                | OpenAI Codex CLI          |
| ----------------------------- | --------------------------- | ------------------------- | ------------------------- | ------------------------- |
| **MCP Server (17 unelte)**    | ✅ Nativ                    | ✅ stdio MCP suportat     | ✅ stdio MCP suportat     | ✅ `~/.codex/config.toml` |
| **Side Effects (Sync/Index)** | ✅ Da                       | ✅ Da (hooks automate)    | ✅ Da (hooks automate)    | ❌ Nu (manual)            |
| **Context Injection**         | ✅ Da (`additionalContext`) | ❌ Nu (ignorat de client) | ❌ Nu (ignorat de client) | ❌ Nu                     |
| **Playbook Skills**           | ✅ Da (nativ)               | ❌ Nu                     | ❌ Nu                     | ❌ Nu                     |

> **Bonus:** vault-urile total-recall se deschid nativ în **Obsidian** (fișiere `.md` cu frontmatter YAML). Nu folosi Obsidian Sync pe `org-vault` — sync-ul trebuie să treacă prin git-ul total-recall.

> **„De ce nu folosiți cq?"** — comparație onestă: `cq` (Mozilla.ai) acoperă **7 host-uri** (Claude, Codex, Copilot, Cursor, OpenCode, Pi, Windsurf), dar **fără context injection** — agentul trebuie să interogheze explicit store-ul. total-recall acoperă 3 clienți cu hooks automate (+ context injection nativ în Claude Code) și obiect diferit: memorie de context, nu knowledge units partajate.

---

## Slide 25b — Noutăți: ce s-a închis de curând în total-recall (Bonus)

> 💡 **WOW — cq se întâlnește cu Ebbinghaus:** noul `confirm_memory` aduce mecanismul de _endorsement_ validat de cq (Mozilla.ai) direct în curba de uitare: memoria nu doar „îmbătrânește", ci **primește feedback** — o memorie accesată des dar flag-uită „greșită" nu mai rămâne sus.

Trei găuri închise, spuse ca poveste:

1. **Team memory stale** → reconcile automat după `git pull`: memoriile push-uite de colegi apar imediat, nu la restart.
2. **Vector stale** → re-embed la orice update (inclusiv tags/importanceScore), nu doar la schimbarea de conținut.
3. **Feedback fără efect** → semnalele confirm/flag intră în scorul Ebbinghaus (WOW-ul de mai sus).

Plus: semantic rerank local (`rerank_memories`, embeddings + cosine, fără apel LLM), `export_memories`/`import_memories` pentru „schimb laptopul", coalescing pe sync hook și test property-based pe frontmatter.

📄 **Detalii** (toate cele 7 îmbunătățiri, cu motivarea fiecăreia): [details/changelog.md](details/changelog.md)

---

## Slide 26 — Sinteza finală și întrebări deschise

> 💡 **UTIL Takeaway — 3 lucruri de făcut mâine dimineață:** (1) Instalează Ollama, (2) rulează `ollama launch claude --model gemma3:4b` pentru teste locale rapide, (3) adaugă `total-recall` pentru memorie persistentă între sesiuni. Primele 10 minute cu total-recall, pas cu pas: [details/primele-10-minute.md](details/primele-10-minute.md) · Ghidul de decizie printabil: [details/decizie-o-pagina.md](details/decizie-o-pagina.md)

### Ce am acoperit

**Claude vs Ollama:**

- Claude API: calitate maximă, cost per token, date în cloud · Ollama: gratuit, 100% local, offline
- `ollama launch claude`: harness-ul Claude Code pe model local — fără proxy
- Agent Claude vs LangChain: diferența e **cine deține loop-ul**, nu dacă pot rula local
- Decizia cheie: **confidențialitate > calitate > cost**

**Total Recall:**

- Plugin MCP (17 unelte) pentru memorie persistentă — Claude Code, Copilot, Gemini CLI
- Vault dual (personal local + org pe git cu privacy filter), căutare hibridă cu Ebbinghaus decay
- Memoria = fișiere Markdown: git-abile, Obsidian-abile, ale tale

**Firul Mozilla.ai, recapitulat ca un kit de suveranitate:** llamafile = portabilitate totală · any-llm = multi-provider fără framework · Otari = gateway cu bugete · cq = shared agent learning. Le-am întâlnit pe parcurs; împreună sunt răspunsul open-source la „AI-ul cloud s-a scumpit".

### Întrebări deschise pentru discuție

1. Cum integrezi total-recall într-o echipă? (org vault, drepturi de scriere) — și unde trage linia față de un standard extern: cq.exchange (store partajat cu review uman) vs git-ul echipei (total-recall org-vault)?
2. Ce modele Ollama ați testat pe hardware de lucru real?
3. Există scenarii unde ați combina ambele: Ollama pentru cod, Claude pentru analiză?
4. Cum gestionezi actualizările de model în Ollama față de API (fără breaking changes)?
5. Strategii de backup pentru vaultul total-recall?

---

## Slide 27 — Resurse

### Total Recall

- **Repo:** `github/total-recall/`
- **Arhitectura detaliată:** `plugins/total-recall/ARCHITECTURE.md`
- **Instalare:** `plugins/total-recall/install.sh --help`
- **README:** `plugins/total-recall/README.md`

### Ollama

- **Site oficial:** ollama.com
- **Hub modele:** ollama.com/library
- **API reference:** ollama.com/docs (compatibilă OpenAI)

### Claude API

- **Documentație:** docs.anthropic.com
- **Modele curente:** claude-sonnet-5 (preț introductiv $2/$10 per MTok până la 31 aug 2026, apoi $3/$15 — verificat 11 iul 2026), claude-sonnet-4-6, claude-opus-4-8, claude-haiku-4-5 (ID canonic: `claude-haiku-4-5-20251001`)
- **Prețuri:** anthropic.com/pricing
- **DPA / GDPR:** anthropic.com/legal

### Integrare Claude Code ↔ Ollama

- **Comandă oficială:** `ollama launch claude` (docs.ollama.com/integrations/claude-code)
- **Compatibilitate API Anthropic:** docs.ollama.com/api/anthropic-compatibility
- **Variabile de mediu:** `ANTHROPIC_BASE_URL`, `ANTHROPIC_AUTH_TOKEN` (nu seta `ANTHROPIC_API_KEY` pe calea manuală — v. Slide 11)

### Ecosistemul Mozilla.ai (Slide 7, 9, 11b, 13, 14)

- **Otari gateway:** github.com/mozilla-ai/otari (+ `docs/use-with-claude-code.md`)
- **llamafile:** github.com/mozilla-ai/llamafile · docs.mozilla.ai/llamafile
- **any-llm:** github.com/mozilla-ai/any-llm
- **cq (shared agent learning):** github.com/mozilla-ai/cq
- **Articolul „AI Got Expensive. Now What?":** blog.mozilla.ai/ai-got-expensive-now-what

### Handout-uri (folderul `details/` din acest repo)

- **Ghidul de decizie pe o pagină (printabil):** [details/decizie-o-pagina.md](details/decizie-o-pagina.md)
- **Primele 10 minute cu total-recall:** [details/primele-10-minute.md](details/primele-10-minute.md)
- Restul materialelor de sprijin sunt linkate din fiecare slide (📄 **Detalii**)

---

**Q&A — 15 minute**

> Mulțumesc pentru participare. Cod, arhitecturi și întrebări — le abordăm pe toate.
