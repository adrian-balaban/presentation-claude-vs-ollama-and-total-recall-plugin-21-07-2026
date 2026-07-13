# Claude Code ↔ Ollama — capabilități, limitări și mecanica variabilelor de mediu

> Material de sprijin pentru **Slide 10** din `prezentare.ro.md`.

## De ce contează diferența dintre cele două variabile

- `ANTHROPIC_API_KEY` pleacă pe fir ca header `x-api-key`.
- `ANTHROPIC_AUTH_TOKEN` devine `Authorization: Bearer <token>` — backend-urile non-Anthropic (Ollama, Otari) citesc de regulă doar Bearer.
- Claude Code adaugă singur `/v1/messages` la URL, deci `ANTHROPIC_BASE_URL` trebuie să fie **root-ul** serverului (fără `/v1` la coadă).

## Capabilități suportate

Toate condiționate de modelul ales: tool calling, file edits, subagents, web search/fetch, vision, thinking controls.

## Limitări cunoscute când folosești Ollama cu Claude Code

- Endpoint-ul Anthropic-compatibil din Ollama suportă: messages, streaming, system prompts, vision, **tool calling**, **extended thinking** (suport basic — `budget_tokens` e acceptat dar **neaplicat**, deci controlul de buget de thinking din Claude Code nu are efect; de verificat pe [docs.ollama.com/api/anthropic-compatibility](https://docs.ollama.com/api/anthropic-compatibility)). **Nu** suportă: **prompt caching** (deci fără cache hit-uri / cost savings), `tool_choice`, `metadata`, PDF, citations, `count_tokens`. Computer use nu trece prin acest endpoint.
- Calitatea output-ului depinde complet de modelul ales — harness-ul e același, inteligența o pune modelul.
- Tool use / function calling: funcționează doar cu modele care suportă (Llama 3.x, Mistral, Qwen 2.5, Qwen3, qwen3-coder).
- Context window mai mic poate trunchia fișiere mari (recomandat 64K+ pentru repo-uri mari).
