# Agent Claude vs agent LangChain — comparația detaliată

> Material de sprijin pentru **Slide 12** din `prezentare.ro.md`.

## Diferența fundamentală, axă cu axă

| Axa                      | Agent Claude (Claude Code / Agent SDK)                                                                                                                                            | Agent LangChain (LangChain / LangGraph)                                                                                                                     |
| ------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Modelul**              | Clientul e prins de **Claude/Anthropic** (format API Anthropic), DAR din `ollama launch claude` backend-ul poate fi **Ollama** — client Claude Code + model local. | **Model-agnostic** la nivel de framework — Claude, GPT, Gemini, **Ollama local**, orice                                                                     |
| **Cine deține loop-ul**  | Anthropic: harness închis, opinat (plan mode, hooks, permisiuni, subagents, MCP, compaction). Configurezi, nu scrii loop-ul.                                                      | Tu scrii loop-ul / graful. LangGraph = mașină de stări explicită (noduri, muchii, routing condiționat, checkpointuri).                                      |
| **Starea**               | Conversație + memorie fișier + MCP (ex. total-recall). Compactare de context built-in.                                                                                            | Abstracții pluggable: `BufferMemory`, summary, retriever vectorial; LangGraph are checkpointer (in-mem/SQLite/Postgres) pentru stare durabilă între rulări. |
| **Tool-uri**             | **MCP** e standardul. Subagents (Task), hooks (Pre/PostToolUse), skills.                                                                                                          | Funcții `@tool` + integrări (loaders, retrievers, vector stores). Are și adaptoare MCP acum.                                                                |
| **Computer use / mediu** | First-class: bash, edit fișiere, computer use (ecran/tastatură) în Agent SDK. Claude Code = harness specializat cod.                                                              | Doar ce-i dai tu ca tool. Fără computer use built-in decât dacă-l wirezi.                                                                                   |
| **Control flow**         | Modelul decide mult; îl direcționezi cu CLAUDE.md, skills, permission mode.                                                                                                       | **Tu controlezi** graful — routing forțat, ramuri paralele, human-in-the-loop gates. Mai mult workflow-engine decât agent liber.                            |
| **Taxa de abstracție**   | Subțire, aproape de API.                                                                                                                                                          | Straturi groase, schimbări breaking între versiuni, abstracții leaky (mulți au migrat la LangGraph sau API raw).                                            |

## Cele trei forme de „agent Claude"

```
Claude Code       → „vreau un agent care să-mi lucreze în repo, ruleze teste,
                     editeze fișiere, cu permisiuni și plan mode — gata din cutie"
                     (nu scrii cod de agent)

Agent SDK         → „vreau un agent Claude programabil propriu" — Claude e creierul,
                     tool-urile și suprafața sunt ale tale. Loop subțire:
                     model + tools + max turns.

LangChain/LangGraph → „vreau un pipeline model-agnostic cu control flow explicit,
                        stare durabilă, human-in-the-loop, sau pot schimba
                        între Claude și un model local"
```

## Pe hardware-ul din prezentare (RTX 3060 / laptop)

|                                            | Agent Claude                                                                                                                                                                                                             | Agent LangChain                                                                                     |
| ------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------- |
| Poate rula pe **Ollama** (RTX 3060 local)? | **DA, din `ollama launch claude`** — client Claude Code + backend Ollama (fără proxy, Ollama vorbește nativ format Anthropic).                                                                                           | **DA** — `ChatOllama`, rulează pe GPU local, zero cost per token, offline, datele nu ies din mașină |
| Inteligență                                | Cu Claude real: maximă (Opus 4.8). Cu Ollama: **depinde de modelul local** (mai slab decât Claude; endpoint-ul Anthropic-compatibil suportă extended thinking și tool calling, dar **nu** prompt caching — v. Slide 10). | Depinde de modelul local (mai slab decât Claude)                                                    |
| Privatitate                                | Cu Claude real: date → Anthropic. Cu Ollama: **100% on-premise**.                                                                                                                                                        | 100% on-premise                                                                                     |
| Cost                                       | Cu Claude: plat per token. Cu Ollama: **zero**.                                                                                                                                                                          | Zero                                                                                                |

> **Alternativa „subțire" la LangChain pentru multi-provider:** **any-llm** (Mozilla.ai, 2.1k ⭐) — un singur `completion()` peste 40+ provideri (OpenAI, Anthropic, Mistral, Ollama…), fără taxa de abstracție LangChain. Dacă tot ce vrei e „schimb providerul dintr-un string", nu-ți trebuie un framework de agenți.

## Regulă de decizie

| Vrei…                                                                     | Alegi                                                       |
| ------------------------------------------------------------------------- | ----------------------------------------------------------- |
| Cod / inginerie în repo, calitate maximă, accept cloud                    | **Claude Code** (cu Claude real)                            |
| Agent custom cu Claude ca creier, tool-uri proprii                        | **Claude Agent SDK**                                        |
| **Harness-ul Claude Code, dar pe model local** (offline, zero cost)       | **`ollama launch claude`** (client Claude + backend Ollama) |
| Control flow explicit, stare durabilă, sau agent model-agnostic pe Ollama | **LangGraph** (nu LangChain clasic)                         |
