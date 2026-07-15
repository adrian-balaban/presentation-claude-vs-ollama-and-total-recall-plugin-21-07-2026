# Cum pot adăuga GPU pe laptop? (eGPU)

> **TL;DR:** Teoretic: GPU-ul intern e soldat — singura opțiune e **eGPU extern via Thunderbolt 4**. Cu un enclosure + RTX 3060 12GB nou (minim ~3.500 lei), rulezi modele de 7–13B complet pe GPU la 20–50 tok/s. Bottleneck-ul TB4 e irelevant pentru inference LLM (contează VRAM-ul, nu banda).

**Ce modele?** Cu 12 GB VRAM: Llama 3.1 8B, Mistral 7B, Qwen 7–14B, DeepSeek-Coder 6.7B — complet pe GPU.

![Razer Core X V2 — enclosure eGPU second-hand pe OLX](../images/razer-core-x-v2-egpu-olx.png)

Vezi și: [pcie-vs-tb4.md](pcie-vs-tb4.md) — de ce banda TB4 nu e bottleneck pentru inference.
