# Privacy and data — the complete Ollama flows

Companion to the "Privacy and data" slides (the Claude API flow is on the slide).

## Ollama remote (`:cloud`)

```
User request
       │
       ▼
localhost:11434 (Ollama daemon)
       │  (HTTPS to provider)
       ▼
Provider servers: Ollama Cloud / Zhipu AI / Moonshot AI
```

**In practice:** `:cloud` ≠ local — data **leaves** your machine exactly like with any cloud API; for providers based in China, there is no GDPR adequacy decision (see the GDPR slide).

## Ollama (local)

```
User request
       │
       ▼
localhost:11434
       │
       ▼
GGUF model in RAM/VRAM — NEVER outside the machine
```

**What this means in practice:**

- Your code, secrets, customer data — stay on your machine
- Zero data egress
- Works in isolated (air-gapped) networks
- Useful for: finance, healthcare, projects under strict NDA, proprietary codebases