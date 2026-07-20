# Confidențialitate și date — fluxurile complete Ollama

Complement la slide-urile „Confidențialitate și date" (fluxul Claude API e pe slide).

## Ollama remote (`:cloud`)

```
Cerere utilizator
       │
       ▼
localhost:11434 (daemon Ollama)
       │  (HTTPS către furnizor)
       ▼
Serverele furnizorului: Ollama Cloud / Zhipu AI / Moonshot AI
```

**Practic:** `:cloud` ≠ local — datele **pleacă** de pe mașină exact ca la orice API cloud; pentru furnizorii din China, fără decizie de adecvare GDPR (v. slide-ul GDPR).

## Ollama (local)

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
