# total-recall — the first 10 minutes after install

> Support checklist for the "Final synthesis" section in `prezentare.ro.md`.

1. **Run a small local model:** `ollama pull gemma3:4b` (~3 GB, works on CPU too).
2. **Store your first memory:** in a Claude Code session say "remember that we prefer PostgreSQL with monthly partitioning" — watch the `store_memory` call in the output.
3. **Open the .md file it created:** `ls ~/.total-recall/personal-vault/` — the memory is a text file you can read, edit, version with git, or open in Obsidian.
4. **Start a new session** and watch the context injection from `SessionStart` — the memory index shows up automatically, without you asking for anything.
5. **Run the dedicated skill:** `/total-recall:memory-workflow` for a structured recall/store session.