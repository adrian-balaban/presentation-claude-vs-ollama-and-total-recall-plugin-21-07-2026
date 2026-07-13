# total-recall — primele 10 minute după instalare

> Checklist de sprijin pentru **Slide 25** din `prezentare.ro.md`.

1. **Rulează un model local mic:** `ollama pull gemma3:4b` (~3 GB, merge și pe CPU).
2. **Stochează prima memorie:** într-o sesiune Claude Code spune „reține că preferăm PostgreSQL cu partiționare pe lună" — urmărește apelul `store_memory` în output.
3. **Deschide fișierul .md creat:** `ls ~/.total-recall/personal-vault/` — memoria e un fișier text pe care-l poți citi, edita, versiona cu git sau deschide în Obsidian.
4. **Pornește o sesiune nouă** și urmărește injecția de context de la `SessionStart` — indexul memoriilor apare automat, fără să ceri nimic.
5. **Rulează skill-ul dedicat:** `/total-recall:memory-workflow` pentru o sesiune structurată de recall/store.
