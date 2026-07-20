# total-recall compatibility — the full matrix and ecosystem

Complement to the "Compatibility" slide (the integration levels + matrix 1/2 are on the slide).

## Matrix (2/2)

| Capability           | Claude Code                 | GitHub Copilot CLI        | Gemini CLI                | OpenAI Codex CLI |
| -------------------- | --------------------------- | ------------------------- | ------------------------- | ---------------- |
| **Context Injection** | ✅ Yes (`additionalContext`) | ❌ No (ignored by client) | ❌ No (ignored by client) | ❌ No            |
| **Playbook Skills**  | ✅ Yes (native)             | ❌ No                     | ❌ No                     | ❌ No            |

## Obsidian and cq

> **Bonus:** total-recall vaults open natively in **Obsidian** (`.md` files with YAML frontmatter). Do not use Obsidian Sync on `org-vault` — sync must go through total-recall's git.

> **"Why don't you use cq?"** — `cq` covers **7 hosts** (Claude, Codex, Copilot, Cursor, OpenCode, Pi, Windsurf), but **without context injection**; total-recall covers 3 clients with automatic hooks + native context injection in Claude Code. Different objects: context memory vs shared knowledge units.