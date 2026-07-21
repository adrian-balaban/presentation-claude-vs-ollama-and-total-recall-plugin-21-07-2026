# Modele locale · Limitări și concluzia practică

Material de sprijin pentru slide-ul „Modele instalate în Ollama (`ollama list`)" — mașina de demo: **Dell Latitude 5521** (i7-11850H, MX450 2GB GDDR6).

**Limitări pe acest hardware:**

- MX450 (2GB VRAM) nu poate ține niciun model în VRAM — toate rulează pe CPU via RAM
- `qwen3.5` (6.6 GB) și `ornith:9b` (5.6 GB) sunt singurele care intră confortabil în 16 GB RAM → ~3–8 tok/s
- Modelele cu tag `:cloud` (kimi-k2.7-code, glm-5.2) sunt **API-uri externe proxiate prin Ollama** — nu rulează local

**Extinderi posibile pentru a rula local:**

- GLM-5.2 necesita investitie de minim ~10000 euro conform [insiderllm.com/guides/run-glm-5-2-locally](https://insiderllm.com/guides/run-glm-5-2-locally/)
- realist: un LLM local mic (`qwen3.5`, `gemma4`) plus eGPU extern necesita investitie de minim ~700 euro — 📄 [egpu-pe-laptop.md](egpu-pe-laptop.md)

**Concluzia practică:** pe acest laptop, Claude API rămâne alegerea corectă; modelele locale = experimente offline.
