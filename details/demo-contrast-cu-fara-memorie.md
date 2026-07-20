# Demo: contrast with/without memory (slide 21)

Support for the bullet in `idei.txt` / slide 21:

> Alternatively, the contrast with/without memory: a question that asks for past context → without the plugin Claude doesn't know; with total-recall it retrieves it.

## Why `--bare` (and not `mcpServers`)

`total-recall` is loaded as a **plugin** (`plugin:total-recall:total-recall`), not as an MCP server in `settings.json`. So you stop it with `claude --bare` (skip plugins + hooks + MCP), not by editing `mcpServers`.

`--bare` = "minimal mode: skip hooks, LSP, plugin settings, --agents, --plugin-dir" → the `recall_memory` / `search_index` tools don't exist in the session. Claude either says "I don't know" or hallucinates — both make the point.

## The test recipe, in 2 sessions

### 1. Without plugin (Claude doesn't know)

Start in a clean dir, with no project `CLAUDE.md`, no plugins:

```bash
mkdir -p /tmp/demo-no-memory && cd /tmp/demo-no-memory
asciinema rec casts/slide-21-demo-fara-memorie.cast
claude --bare
# ask the question; Claude has no recall_memory/search_index -> doesn't know
exit  # stop asciinema
```

### 2. With plugin (total-recall retrieves)

Normal session, **interactive** (so you can approve `recall_memory`):

```bash
cd /tmp/demo-no-memory   # anywhere without repo files
asciinema rec casts/slide-21-demo-cu-memorie.cast
claude
# same question; approve recall_memory at the prompt -> retrieves from vault
```

## Choosing the question (the critical part)

It must be a fact that **exists in the total-recall vault but NOT in the repo / git / `CLAUDE.md`** — otherwise "without plugin" still knows from files and the contrast collapses. Verify the candidate with `grep` in the repo before the demo.

### Good candidates (in memory, not in repo)

| Question | Answer (from memory) | Why it can't be known without the plugin |
|---|---|---|
| "What does the team prefer for local tests with Ollama?" | `ollama launch claude` (org memory) | Not in the repo |
| "What did I fix in total-recall in recent sessions?" | vector search, rebuild native deps, wipe org repo history | Not in *this* repo's git |
| "How many memories does total-recall have right now?" | 571 (from the index) | It's live state, not a file |

### Pitfall

Avoid "what local model did I use for TTFT?" — `details/masurare-ttft.md` already says `gemma3:4b`, so without the plugin Claude finds it via `Read`/`Grep`. The "cold-load" part is only in memory; the question must be phrased exactly on that.

## Recommendation for the demo

A single question, run in both sessions (like slide 7):

> "How long does the cold-load of the gemma3:4b model take on the demo laptop?"

- **Without plugin** (`--bare`): "I don't have access to that information" (or offers to run a live benchmark).
- **With plugin**: `recall_memory` → finds the local memory with the cold-load time. **The exact value is intentionally not written here** — it's stored only in the total-recall vault, so the retrieval from memory can be demonstrated, not from files.

## Verified on 20 Jul 2026

- **Without plugin** (`claude --bare -p`, empty dir `/tmp/demo-no-memory`): Claude didn't know — it checked the directory, personal documents, tried sandboxed commands, then offered to run a live benchmark. ✅
- **With plugin** — memory confirmed directly: `recall_memory("gemma3:4b cold load duration demo laptop")` returns as top hit (score 216.5) the memory `project/demo-laptop-gemma3-4b-cold-load-2-min` with the exact fact. ✅
- **Verification limitation**: in a non-interactive session (`-p`), the permission on `recall_memory` is refused (there's no one to approve it), and `--dangerously-skip-permissions` was blocked by the harness classifier. So it couldn't be simulated end-to-end via `-p`.
- **Conclusion for the demo**: run the "with plugin" session **interactively** (`claude`, not `-p`), so you can approve `recall_memory` at the prompt — that's where it works. And make sure the answer doesn't exist in any file in cwd (that's why the "with" session runs from a dir without repo files; the value was intentionally removed from this file).

### Collateral bug observed

When closing the session with the plugin, total-recall's `SessionEnd` hook threw a JSON validation error (an `additionalContext` field placed at the wrong level in the `Stop/SubagentStop` schema). It doesn't affect the demo, but it's worth a ticket in `../total-recall`.