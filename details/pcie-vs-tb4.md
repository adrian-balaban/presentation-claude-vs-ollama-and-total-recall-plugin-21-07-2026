# PCIe vs Thunderbolt 4 — why bandwidth doesn't matter for LLM inference

> Support material for the "Can I add a GPU to a laptop?" section of `presentation.md`.
> Explains the claim: **TB4 ≈ 40 Gbps (PCIe x4) vs PCIe x16 desktop**.

The short explanation — it's a comparison of the "pipe thickness" through which the GPU talks to the rest of the computer:

**PCIe (PCI Express)** is the standard bus by which a GPU connects to the CPU/RAM. It comes in "lanes": x1, x4, x8, x16 — each lane is a pair of transmit wires. A desktop GPU sits in a **x16** slot = 16 lanes in parallel. At PCIe 4.0, each lane carries ~2 GB/s, so x16 ≈ **32 GB/s** (~256 Gbps).

**Thunderbolt 4** is the external port (USB-C) you use to connect the eGPU enclosure to the laptop. It has a total limit of **40 Gbps ≈ 5 GB/s** (one-way, nominal), and of that the effective PCIe traffic is usually ~32 Gbps (the rest is reserved for DisplayPort etc.). In practice, the GPU in the enclosure "sees" something equivalent to a **PCIe 3.0 x4** slot — not a generic x4: a PCIe 4.0 x4 would offer roughly double (~64 Gbps). Either way, a quarter or less of the bandwidth the GPU would have in a desktop.

So an RTX 3060 on an eGPU receives data **~4–8× slower** than the same RTX 3060 in a desktop. That sounds disqualifying, but for LLM inference it isn't:

- **At load** (one time): the model, e.g. 8 GB, is copied from SSD/RAM into VRAM. Over TB4 at ~4 GB/s that takes ~2 seconds longer than on desktop. A cost paid once per session.
- **At generation** (the rest of the time): the weights already live in VRAM, all computation happens inside the GPU. Only the prompt and the generated tokens flow over the cable — kilobytes per second. A 40 Gbps pipe for kilobytes is infinitely sufficient, so tok/s is practically identical to the desktop — **provided** the weights + KV cache + compute buffers fit entirely in VRAM and the prompt isn't so large that the prefill phase dominates.

Hence the slide's conclusion: **VRAM matters, not bandwidth** — the situation where TB4 bandwidth hurts is partial CPU/GPU offload — when the model does NOT fit in VRAM, Ollama/llama.cpp constantly shuttles layers and intermediate activations between RAM and GPU; then every generated token traverses the narrow pipe and tok/s can drop dramatically versus an internal GPU. The practical rule: on an eGPU pick models that fit **entirely** in VRAM — and "entirely" includes the KV cache (which grows with context length), compute buffers, and runtime overhead, not just the weights. As a rough guide, a 7B Q4 fits comfortably in 12 GB; a 13B Q4 may already require partial offload at large context — check the allocation reported by the runtime (`ollama ps`) and adjust context or offload accordingly.

This is why gaming on an eGPU usually loses visibly in performance (it constantly moves textures/frames over the cable — how much depends on the game, resolution, and whether the video output returns to the laptop screen), but LLM inference that fits in VRAM loses almost nothing.