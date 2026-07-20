# Installing and using total-recall — the complete steps

> 💡 **Useful:** the same plugin, 4 clients — Claude Code, Copilot CLI, Gemini CLI, standalone — with a single `install.sh`.

## 1. Build from the marketplace

The `install.sh` script is client-state-aware and accepts specific arguments:

```bash
# Clone the marketplace and build the plugin
git clone https://github.com/adrian-balaban/my-claude-plugins-marketplace.git
cd my-claude-plugins-marketplace/plugins/total-recall
npm install && npm run build
```

## 2. Per-client registration

```bash
# For Claude Code (native):
claude plugin install "$(pwd)"

# For GitHub Copilot CLI (MCP + hooks.copilot.json):
./install.sh --copilot

# For Gemini CLI (MCP + hooks.gemini.json):
./install.sh --gemini

# For Standalone installation (writes absolute paths into settings.json):
./install.sh --standalone
```

## 3. Org vault = optional

> **Org vault = optional, disabled by default** (step 6 of `install.sh`, default "n"). Anyone installing only for personal use can skip this step entirely — local memory (`personal-vault`) works 100% from the first run, without git. The org vault is strictly for those who want team-shared memory on git (requires authenticated `gh` CLI, requested **only** at this step).

## 4. Usage in a Claude Code session

```
# Search memories
> "remind me of the database decision"
→ recall_memory(query="database decision")

# Store a memory
> "remember that we prefer PostgreSQL with monthly partitioning"
→ store_memory(title="...", content="...", tags=["architecture", "database"])

# List everything
> "show me all architecture memories"
→ list_memories(category="architecture")

# Dedicated skill
> /total-recall:memory-workflow
```