# Compatibilitate total-recall — matricea completă și ecosistemul

Complement la slide-ul „Compatibilitate" (nivelurile de integrare + matricea 1/2 sunt pe slide).

## Matricea (2/2)

| Capabilitate          | Claude Code                 | GitHub Copilot CLI        | Gemini CLI                | OpenAI Codex CLI |
| --------------------- | --------------------------- | ------------------------- | ------------------------- | ---------------- |
| **Context Injection** | ✅ Da (`additionalContext`) | ❌ Nu (ignorat de client) | ❌ Nu (ignorat de client) | ❌ Nu            |
| **Playbook Skills**   | ✅ Da (nativ)               | ❌ Nu                     | ❌ Nu                     | ❌ Nu            |

## Obsidian și cq

> **Bonus:** vault-urile total-recall se deschid nativ în **Obsidian** (fișiere `.md` cu frontmatter YAML). Nu folosi Obsidian Sync pe `org-vault` — sync-ul trebuie să treacă prin git-ul total-recall.

> **„De ce nu folosiți cq?"** — `cq` acoperă **7 host-uri** (Claude, Codex, Copilot, Cursor, OpenCode, Pi, Windsurf), dar **fără context injection**; total-recall acoperă 3 clienți cu hooks automate + context injection nativ în Claude Code. Obiecte diferite: memorie de context vs knowledge units partajate.
