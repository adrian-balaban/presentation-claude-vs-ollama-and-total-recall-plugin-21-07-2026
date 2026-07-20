# A treia cale: Otari de la Mozilla, gateway Anthropic-compatibil

> 💡 **WOW:** același truc `ANTHROPIC_BASE_URL`, dar cu **buget enforcement ÎNAINTE de request, nu după factură.**

**Otari** (Mozilla.ai, open-source, lansat mai 2026, construit peste `any-llm`) e un gateway LLM self-hosted care expune și endpoint-ul Anthropic (`POST /v1/messages`) — deci Claude Code poate rula prin el exact ca prin Ollama, dar cu stratul operațional pe care Ollama nu-l are:

- **Bugete** per user / per cheie, aplicate _înainte_ ca cererea să ruleze
- **Chei virtuale** — clientul nu vede niciodată cheia reală Anthropic/OpenAI; le poți revoca oricând
- **Usage & spend tracking** în timp real, pe toate modelele (40+ provideri prin any-llm)
- Rulezi Claude real, GPT, Mistral sau modele locale prin **același endpoint**
