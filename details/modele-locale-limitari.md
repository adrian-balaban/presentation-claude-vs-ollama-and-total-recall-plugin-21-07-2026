# Local models · Limitations and the practical conclusion

Supporting material for the "Models installed in Ollama (`ollama list`)" slide — demo machine: **Dell Latitude 5521** (i7-11850H, MX450 2GB GDDR6).

**Limitations on this hardware:**

- MX450 (2GB VRAM) cannot hold any model in VRAM — everything runs on CPU via RAM
- `qwen3.5` (6.6 GB) and `ornith:9b` (5.6 GB) are the only ones that fit comfortably in 16 GB RAM → ~3–8 tok/s
- Models tagged `:cloud` (kimi-k2.7-code, glm-5.2) are **external APIs proxied through Ollama** — they do not run locally

**Possible upgrades to run locally:**

- GLM-5.2 requires a minimum investment of ~7000 euro per [insiderllm.com/guides/run-glm-5-2-locally](https://insiderllm.com/guides/run-glm-5-2-locally/)
- realistic: a small local LLM (`qwen3.5`, `gemma4`) plus an external eGPU requires a minimum investment of ~700 euro — 📄 [egpu-pe-laptop.md](egpu-pe-laptop.md)

**Practical conclusion:** on this laptop, the Claude API remains the right choice; local models = offline experiments.