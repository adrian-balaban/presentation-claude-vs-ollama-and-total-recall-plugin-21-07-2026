# GLM-5.2 și Kimi-K2.7-Code — modelele `:cloud` chinezești în detaliu

> Material de sprijin pentru **Slide 5** din `prezentare.ro.md`.

## GLM-5.2 — Zhipu AI (Beijing)

- Flagship-ul Z.ai (spin-off Tsinghua); context **~1M tokens** (976K — verificat pe [ollama.com/library/glm-5.2](https://ollama.com/library/glm-5.2)), 756B parametri, bun la raționament, agentic și cod
- Pentru un dev român: română slabă (rămâi pe Claude pentru RO), date sensibile → servere în China

> **Context rapid:** GLM-5.2 (lansat iun 2026) — performanță comparabilă cu Claude Opus 4.8 la ~6× mai ieftin, open-source MIT, 66% pe benchmarks de programare (vs 67% Claude). Modele chineze = 45% din traficul OpenRouter (2026).

## Kimi-K2.7-Code — Moonshot AI (Beijing)

- Specializat pe **generare și analiză de cod** (Python, TS, Java, Go, C++); concurent DeepSeek-Coder
- Puncte forte: boilerplate/scaffolding, code review, explicare cod legacy

## Comparație rapidă

| Model | Companie | Cel mai bun la | Cost vs Claude | Risc GDPR |
|---|---|---|---|---|
| **GLM-5.2** | Zhipu AI 🇨🇳 | Text chinezo-englez, documente lungi | ~50–70% din Haiku | ⚠️ Ridicat |
| **Kimi-K2.7-Code** | Moonshot AI 🇨🇳 | Code review, generare cod | ~50–60% din Haiku | ⚠️ Ridicat |
| **Claude Haiku** | Anthropic 🇺🇸 | Sarcini generale rapide, română | Referință | ✅ Scăzut (DPA EU) |
| **Claude Sonnet** | Anthropic 🇺🇸 | Raționament, arhitectură, cod complex | ~4–5× Haiku | ✅ Scăzut |

## ⚠️ Atenție: confidențialitate și GDPR

- Ambele modele procesează datele pe **servere în China** (Zhipu AI Beijing, Moonshot AI Beijing)
- China = jurisdicție fără echivalent adecvat GDPR recunoscut de EU (spre deosebire de US post-Privacy Shield reînnoit)
- **Nu trimite prin aceste API-uri:** cod cu date personale ale clienților, IP proprietar, credențiale, contracte
- Pentru echipe enterprise EU: verificați DPA (Data Processing Agreement) înainte de utilizare

## Pot rula GLM-5.2 / Kimi-K2 local? (Bonus)

> **Răspuns scurt: nu pe hardware obișnuit.** Kimi-K2 = ~600 GB VRAM, GLM-5.x = 100–200 GB — doar clustere datacenter. Pe Ollama, întreaga familie GLM-5 e `:cloud`-only; singurul GLM rulabil local e `glm-4.7-flash` (30B, 12–24 GB VRAM). **„Open-weight" ≠ „încape pe hardware-ul tău".**

**Ce poți rula realist pe CPU:**

```bash
ollama pull qwen3:4b        # ~3 GB, ~3–8 tok/s
ollama pull llama3.2:3b     # ~2 GB
ollama pull gemma3:4b       # ~3 GB
```

**Cum folosești modelele `:cloud`:**

```bash
ollama login                           # cont pe ollama.com
ollama run glm-5.2:cloud               # direct
ollama launch claude --model glm-5.2:cloud  # în Claude Code
```
