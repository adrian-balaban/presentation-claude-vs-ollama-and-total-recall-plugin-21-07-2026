# How can I add a GPU to a laptop? (eGPU)

> **TL;DR:** In theory: the internal GPU is soldered — the only option is an **external eGPU via Thunderbolt 4**. With an enclosure + a new RTX 3060 12GB (minimum ~3.500 lei), you run 7–13B models fully on the GPU at 20–50 tok/s. The TB4 bottleneck is irrelevant for LLM inference (VRAM matters, not bandwidth).

**Which models?** With 12 GB VRAM: Llama 3.1 8B, Mistral 7B, Qwen 7–14B, DeepSeek-Coder 6.7B — fully on the GPU.

![Razer Core X V2 — second-hand eGPU enclosure on OLX](../images/razer-core-x-v2-egpu-olx.png)

See also: [pcie-vs-tb4.md](pcie-vs-tb4.md) — why TB4 bandwidth is not a bottleneck for inference.