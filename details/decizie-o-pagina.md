# Ghid de decizie pe o pagină — Claude API sau Ollama? (+ primii pași)

> Handout-ul promis în Slide 0: printează sau salvează pagina asta pentru echipă.

## 1. Arborele de decizie

```
Datele tale pot ieși din infrastructura ta?
 ├── NU  → Ollama (local) — obligatoriu
 └── DA  → Ai nevoie de calitate top-tier (raționament complex, cod avansat)?
            ├── DA → Claude API (Sonnet/Opus)
            └── NU → Ollama cu model 7–8B, cost $0
```

## 2. Scenarii → alegere

| Scenariu                                                             | Alegere                         | Model recomandat                              |
| -------------------------------------------------------------------- | ------------------------------- | ---------------------------------------------- |
| Proiect cu date sensibile / NDA                                      | Ollama                          | DeepSeek Coder 33B sau Qwen 2.5 Coder 32B     |
| Echipă enterprise cu restricții cloud                                | Ollama                          | Llama 3.3 70B (server local)                  |
| Prototipare rapidă, calitate maximă                                  | Claude API                      | Sonnet 4.6/5 sau Opus 4.8                     |
| Developer indie, buget limitat                                       | Ollama                          | Llama 3.1 8B sau Qwen 2.5 7B                  |
| Sarcini critice de raționament                                       | Claude API                      | Opus 4.8 cu extended thinking                 |
| Cod cu context mare (>50K tokens)                                    | Claude API                      | Sonnet (200K context)                         |
| Offline / air-gapped                                                 | Ollama                          | Orice model descărcat prealabil               |
| Echipă cu GPU server partajat                                        | Ollama                          | Llama 3.3 70B, server central                 |
| Echipă care vrea Claude + modele locale + control buget centralizat  | **Otari gateway** (self-hosted) | Claude real + orice provider, chei virtuale   |

## 3. Găsește-ți tier-ul de cost (amortizare hardware vs API)

| Profil            | Cheltuială API tipică | Amortizare GPU local                          |
| ----------------- | --------------------- | ---------------------------------------------- |
| Indie / light     | ~$30/lună             | ani — rămâi pe API sau CPU-only               |
| Daily driver      | ~$100/lună            | ~6 luni (RTX 3080 SH ~$600)                   |
| Agentic developer | ~$400/lună            | ~5 luni (RTX 4090 ~$2.000)                    |

## 4. Regula GDPR scurtă

- Cod ne-sensibil + buget mic → modele `:cloud` (atenție: inferența GLM/Kimi rulează în China).
- Română, date sensibile, raționament critic → Claude (US, acoperit de EU-US Data Privacy Framework; rezidență EU doar via Bedrock/Vertex regiuni EU).
- Date care nu au voie să iasă deloc → Ollama local / air-gapped.

## 5. Mâine dimineață (checklist)

1. Instalează Ollama → `ollama pull gemma3:4b`
2. `ollama launch claude --model gemma3:4b` — harness-ul Claude Code pe model local
3. Adaugă `total-recall` pentru memorie persistentă între sesiuni
4. Primele 10 minute cu total-recall: v. [primele-10-minute.md](primele-10-minute.md)
