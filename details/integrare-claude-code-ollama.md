# Claude Code ↔ Ollama — capabilities, limitations, and the mechanics of env vars

> Support material for the "Ollama with Claude Code: practical integration" section of `prezentare.ro.md`.

## Why the difference between the two env vars matters

- `ANTHROPIC_API_KEY` goes on the wire as the `x-api-key` header.
- `ANTHROPIC_AUTH_TOKEN` becomes `Authorization: Bearer <token>` — non-Anthropic backends (Ollama, Otari) typically read only Bearer.
- Claude Code appends `/v1/messages` to the URL itself, so `ANTHROPIC_BASE_URL` must be the **root** of the server (no `/v1` suffix).

## Supported capabilities

All conditioned on the chosen model: tool calling, file edits, subagents, web search/fetch, vision, thinking controls.

## Known limitations when using Ollama with Claude Code

- Ollama's Anthropic-compatible endpoint supports: messages, streaming, system prompts, vision, **tool calling**, **extended thinking** (basic support — `budget_tokens` is accepted but **not applied**, so the thinking budget control in Claude Code has no effect; check [docs.ollama.com/api/anthropic-compatibility](https://docs.ollama.com/api/anthropic-compatibility)). **Does not** support: **prompt caching** (so no cache hits / cost savings), `tool_choice`, `metadata`, PDF, citations, `count_tokens`. Computer use does not go through this endpoint.
- Output quality depends entirely on the chosen model — the harness is the same, the model provides the intelligence.
- Tool use / function calling: works only with models that support it (Llama 3.x, Mistral, Qwen 2.5, Qwen3, qwen3-coder).
- A smaller context window can truncate large files (64K+ recommended for large repos).

## What `ollama launch claude` does automatically

- installs/starts the **Claude Code client**
- sets `ANTHROPIC_BASE_URL=http://localhost:11434`, `ANTHROPIC_AUTH_TOKEN=ollama`, `ANTHROPIC_API_KEY=""`

### Key distinction: the format is Anthropic, the intelligence is Ollama

Ollama speaks the Anthropic API format **natively** at `localhost:11434` — **there is no separate proxy**. The Claude Code client "believes" it's talking to Anthropic; in fact the model chosen with `--model` answers:

```
request in Anthropic format → Ollama translates internally → Ollama model responds
      → response re-packaged in Anthropic format → Claude Code client consumes it
```

## Manual method (alternative, without `launch`)

```bash
ollama pull qwen3.5
export ANTHROPIC_BASE_URL=http://localhost:11434
export ANTHROPIC_AUTH_TOKEN=ollama
claude --model qwen3.5
```

Or permanently in `~/.claude/settings.json`:

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "http://localhost:11434",
    "ANTHROPIC_AUTH_TOKEN": "ollama"
  }
}
```