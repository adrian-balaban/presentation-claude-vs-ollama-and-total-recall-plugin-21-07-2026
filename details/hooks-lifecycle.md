# total-recall hooks — automatic lifecycle integration

> 💡 **WOW:** before context compaction (`PreCompact`), the plugin **automatically saves the session's learnings** — knowledge survives even when the context is wiped.

> Although originally created exclusively for Claude Code, lifecycle hooks now also run on **GitHub Copilot CLI** and **Gemini CLI** (via `hooks.copilot.json` and `hooks.gemini.json`).

## Execution on non-Claude clients (Copilot and Gemini CLI)

- **How it works:** At session start or during the session, the Copilot or Gemini client invokes the corresponding hook.
- **Side-effects executed:** Background hooks run normally (pull the latest memories from git, rebuild the local index cache, perform automatic push/sync to the org-vault).
- **Limitation (graceful degradation):** these clients ignore hook stdout → **automatic context injection (`additionalContext`) is disabled**; the model can query memories at any time through the MCP tools.

## `SessionStart` (4 steps, sequential)

```
1. pull-org-vault.sh       — git pull on the org-vault branch (if configured)
2. build-memory-index.sh   — awk scan of frontmatter → .index-cache.txt
3. load-memory-index.sh    — cat .index-cache.txt → injected into context (Claude Code only)
4. load-open-questions.sh  — cat open-questions.md → injected into context (Claude Code only)
```

**Effect:** At every new Claude session, the model automatically receives a summary of all your memories — without you asking explicitly.

## `PostToolUse` (trigger: `store_memory|update_memory|delete_memory`)

```
sync-org-memory.sh
  ├─ checks whether the memory has the "org" tag
  ├─ applies the confidentiality filter
  └─ git add/commit/push → team's org-vault branch
  + rebuild .index-cache.txt
```

## `PreCompact` (when the context is near the limit)

```
extract-and-store-memories.sh
  ├─ reads the session transcript from stdin JSON (transcript_path)
  ├─ asks Claude to extract 0–3 key learnings as JSON lines
  └─ store-learning.mjs → writes directly as .md files in personal-vault
       (no MCP round-trip; does not overwrite existing memories)
```

## `SessionEnd`

Cleanup: logs the session and ensures embeddings are flushed before exit.