# Instalare și utilizare total-recall — pașii compleți

> 💡 **Util:** același plugin, 4 clienți — Claude Code, Copilot CLI, Gemini CLI, standalone — cu un singur `install.sh`.

## 1. Build din marketplace

Scriptul `install.sh` este conștient de starea clientului și acceptă argumente specifice:

```bash
# Clonează marketplace-ul și construiește pluginul
git clone https://github.com/adrian-balaban/my-claude-plugins-marketplace.git
cd my-claude-plugins-marketplace/plugins/total-recall
npm install && npm run build
```

## 2. Înregistrare per client

```bash
# Pentru Claude Code (nativ):
claude plugin install "$(pwd)"

# Pentru GitHub Copilot CLI (MCP + hooks.copilot.json):
./install.sh --copilot

# Pentru Gemini CLI (MCP + hooks.gemini.json):
./install.sh --gemini

# Pentru instalare Standalone (scrie căi absolute în settings.json):
./install.sh --standalone
```

## 3. Org vault = opțional

> **Org vault = opțional, dezactivat implicit** (pasul 6 din `install.sh`, default „n"). Cine instalează doar pentru uz personal poate ignora complet acest pas — memoria locală (`personal-vault`) funcționează 100% de la prima rulare, fără git. Vaultul org e strict pentru cine vrea memorie partajată de echipă pe git (necesită `gh` CLI autentificat, cerut **doar** la acest pas).

## 4. Utilizare în sesiune Claude Code

```
# Caută memorii
> "reamintește-mi decizia despre baza de date"
→ recall_memory(query="decizie baza de date")

# Stochează o memorie
> "reține că preferăm PostgreSQL cu partitionare pe lună"
→ store_memory(title="...", content="...", tags=["architecture", "database"])

# Listează tot
> "arată-mi toate memoriile de arhitectură"
→ list_memories(category="architecture")

# Skill dedicat
> /total-recall:memory-workflow
```
