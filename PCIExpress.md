# PCIe vs Thunderbolt 4 — de ce banda nu contează la inference LLM

> Material de sprijin pentru Slide 4 din `prezentare.ro.md`.
> Explică afirmația: **TB4 ≈ 40 Gbps (PCIe x4) vs PCIe x16 desktop**.

Explicația pe scurt — e o comparație între „grosimea țevii" prin care GPU-ul comunică cu restul calculatorului:

**PCIe (PCI Express)** e magistrala standard prin care un GPU e legat de CPU/RAM. Vine în „lane-uri" (benzi): x1, x4, x8, x16 — fiecare lane e o pereche de fire de transmisie. Un GPU de desktop stă într-un slot **x16** = 16 benzi în paralel. La PCIe 4.0, fiecare lane duce ~2 GB/s, deci x16 ≈ **32 GB/s** (~256 Gbps).

**Thunderbolt 4** e portul extern (USB-C) prin care conectezi enclosure-ul eGPU la laptop. Are o limită totală de **40 Gbps ≈ 5 GB/s**, iar din acestea traficul PCIe efectiv e de obicei ~32 Gbps (restul e rezervat pentru DisplayPort etc.). Practic, GPU-ul din enclosure „vede" ceva echivalent cu un slot **PCIe x4** — un sfert sau mai puțin din benzile pe care le-ar avea în desktop.

Deci un RTX 3060 pe eGPU primește date de **~4–8× mai încet** decât același RTX 3060 într-un desktop. Sună descalificant, dar pentru inference LLM nu e:

- **La încărcare** (o singură dată): modelul de ex. 8 GB se copiază din SSD/RAM în VRAM. Prin TB4 la ~4 GB/s durează ~2 secunde în plus față de desktop. Cost plătit o dată per sesiune.
- **La generare** (tot restul timpului): greutățile stau deja în VRAM, tot calculul se întâmplă în interiorul GPU-ului. Prin cablu circulă doar promptul și tokenii generați — kilobytes pe secundă. O țeavă de 40 Gbps pentru kilobytes e infinit suficientă, deci tok/s e practic identic cu desktopul.

De unde și concluzia din slide: **contează VRAM-ul, nu banda** — singura situație în care banda TB4 te doare e când modelul NU încape în VRAM și Ollama plimbă permanent straturi între RAM și GPU; atunci fiecare token generat traversează țeava îngustă și eGPU-ul devine vizibil mai lent decât un GPU intern. Regula practică: pe eGPU alege modele care încap complet în cei 12 GB VRAM (7B–13B la Q4), nu modele „aproape încap".

De asta gaming-ul pe eGPU pierde 10–25% (mută texturi/frame-uri în continuu prin cablu), dar inference-ul LLM pierde aproape nimic.
