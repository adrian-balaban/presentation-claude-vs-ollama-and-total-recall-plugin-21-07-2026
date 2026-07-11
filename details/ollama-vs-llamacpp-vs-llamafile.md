# Ollama vs llama.cpp vs llamafile — detalii și critica de suveranitate

> Material de sprijin pentru **Slide 7** din `prezentare.ro.md`.

## llamafile în practică

```bash
curl -LO https://huggingface.co/mozilla-ai/llamafile_0.10/resolve/main/Qwen3.5-0.8B-Q8_0.llamafile
chmod +x Qwen3.5-0.8B-Q8_0.llamafile
./Qwen3.5-0.8B-Q8_0.llamafile        # gata — zero install, zero daemon
```

**Trade-off-uri oneste** (recunoscute chiar de Mozilla.ai): binarele sunt mari (runtime-ul se livrează cu fiecare model), swap-ul de modele e mai greoi decât `ollama pull`, iar pe Apple Silicon stack-urile MLX sunt mai rapide. llamafile e pentru cazul în care AI-ul trebuie să fie **portabil, vendor-free și cu adevărat al tău**.

## Critica de suveranitate: Ollama = „managed service wearing a hoodie" (Mozilla.ai)

> Critica **nu** e că Ollama ar fi closed-source — codul chiar e open source (MIT). Critica vizează **modul de operare**, care reproduce tiparele unui serviciu gestionat: arată a open source rebel, dar se comportă ca un vendor cloud.

Concret, trei mecanisme:

1. **Registry centralizat.** `ollama pull llama3.2` nu descarcă un fișier de oriunde — trage dintr-un registru controlat de compania Ollama (ollama.com/library), cu un sistem de manifest propriu, non-standard. Ce modele apar acolo, cum sunt denumite, ce tag-uri există — decide vendorul. E exact modelul Docker Hub: cod open source, canal de distribuție proprietar.

2. **Formatul „blob".** Modelele circulă în ecosistem ca fișiere **GGUF** standard — le poți lua de pe Hugging Face și rula cu llama.cpp, LM Studio, llamafile etc. Dar când Ollama le trage, le sparge și le stochează în cache-ul daemonului ca blob-uri cu nume hash (`~/.ollama/models/blobs/sha256-...`), plus manifeste proprii. Fișierul tău de 24 GB nu mai e un „fișier model" pe care să-l copiezi pe alt tool sau pe un stick — e un artefact pe care doar Ollama știe să-l folosească direct. (Tehnic blob-ul *conține* GGUF-ul și poate fi recuperat, dar nu e formatul portabil pe care l-ai descărcat.)

3. **Daemon obligatoriu.** Nu rulezi „un model", rulezi un serviciu de fundal (`ollama serve`) care gestionează registry-ul, cache-ul și API-ul. Ești legat de ciclul lui de viață, update-urile lui, deciziile lui.

**Deci „soft lock-in" înseamnă:** nimic nu te *împiedică legal sau tehnic* să pleci (codul e liber, GGUF-ul e recuperabil) — dar cu cât folosești mai mult, cu atât modelele, scripturile și workflow-ul tău depind de registrul, formatul de stocare și daemonul unui singur vendor. Costul de ieșire crește tăcut. Prin contrast, argumentul llamafile: „modelul e un fișier" — un singur executabil pe care îl copiezi, arhivezi, ștergi, fără registru și fără daemon.

Sursa: [blog.mozilla.ai/ai-got-expensive-now-what](https://blog.mozilla.ai/ai-got-expensive-now-what/) · [github.com/mozilla-ai/llamafile](https://github.com/mozilla-ai/llamafile)
