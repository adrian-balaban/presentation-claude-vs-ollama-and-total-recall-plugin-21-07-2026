# Claude vs Ollama — comparația completă pe 13 criterii

> Material de sprijin pentru secțiunea „Comparație directă: Claude vs Ollama” din `prezentare.ro.md`.

| Criteriu                  | Claude (API Anthropic)                     | Ollama (local)                                                                                      |
| ------------------------- | ------------------------------------------ | --------------------------------------------------------------------------------------------------- |
| **Modele disponibile**    | Claude Sonnet 4.6/5, Opus 4.8, Haiku 4.5   | Llama, Mistral, Gemma, Phi, Qwen, DeepSeek etc.                                                     |
| **Calitate top-tier**     | ✅ Claude Opus 4.8 = state of the art      | Llama 3.3 70B ≈ GPT-4o, dar sub Opus                                                                |
| **Cost per token**        | $3–$15 / 1M tokens (input $3 / output $15) | $0 — hardware propriu                                                                               |
| **Cost infrastructură**   | $0 (fără server propriu)                   | GPU bun: $500–$3000+                                                                                |
| **Confidențialitate**     | Date trimise la Anthropic                  | 100% local, zero egress                                                                             |
| **Latență**               | ~500ms–2s (~1.6 s măsurat)                 | ~100–500 ms (GPU local); ~0.8–1.8 s (CPU-only, comparabil cu API)                                    |
| **Context window**        | 200K tokens (Sonnet/Opus)                  | 4K–128K (depinde de model+VRAM)                                                                     |
| **Raționament avansat**   | ✅ Excelent (extended thinking)            | Limitat la modele mici-medii                                                                        |
| **Disponibilitate**       | Necesită internet + API key                | Funcționează offline                                                                                |
| **Actualizări model**     | Automate (Anthropic)                       | Manual (`ollama pull`)                                                                              |
| **Integrare Claude Code** | ✅ Nativă (este produsul Anthropic)        | ✅ Nativă prin `ollama launch claude` (Ollama expune endpoint compatibil API Anthropic, fără proxy) |
| **Limită rate**           | Există (nivel API)                         | Nelimitată (hardware propriu)                                                                       |
| **GDPR / compliante**     | Politici Anthropic                         | On-premise complet                                                                                  |
