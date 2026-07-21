# Total Recall — in short

Reference summary for the total-recall slide (SLIDE 21). The reference content was moved here from the slide so the demo's WOW stays visible on the page.

## Status

- Version: **v1.0.109** · License: **MIT**
- Plugin repo: <https://github.com/adrian-balaban/total-recall>
- Organization vault (team memories): <https://github.com/adrian-balaban/total-recall-memories>

## Where it stores memories

- **Local (personal):** Markdown files on your machine — git-able, Obsidian-able, yours.
- **Team / organization:** a separate vault, version-controlled on GitHub (the memories repo above), with a privacy filter applied at push.

## Which clients it works with

Covered in the talk: **Claude Code** (MCP + hooks + native context injection) and **Gemini CLI** (MCP + hooks).

> ❓ **To decide:** do we also mention **GitHub Copilot CLI**? (Is there audience interest?) Technically it's supported — MCP + hooks — but whether to include it remains undecided. Likewise, **OpenAI Codex CLI** (MCP, no hooks).

The full per-client capability table (+ "why not cq?"): [compatibilitate-clienti.md](compatibilitate-clienti.md)

## Going deeper

- Step-by-step install: [instalare-total-recall.md](instalare-total-recall.md)
- The 17 MCP tools: [unelte-mcp.md](unelte-mcp.md)
- The search algorithm (hybrid + Ebbinghaus decay): [algoritm-cautare.md](algoritm-cautare.md)
- Embeddings & vectorization (bge-m3 via Ollama): [embeddings-vectorizare.md](embeddings-vectorizare.md)
- Architecture by module: [arhitectura-module.md](arhitectura-module.md)