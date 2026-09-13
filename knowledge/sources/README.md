# Catalogo Fonti Esterne Suggerite (`knowledge/sources/`)

Questo catalogo raccoglie i repository esterni, banche dati e blueprint architetturali **suggeriti a livello generale dal framework**.

---

## 1. Filosofia: "Zero Bloat, Reference-Only & Proactive Suggestion"

A differenza di progetti tradizionali che richiedono la clonazione di enormi basi di codice o documentazione:
1. **Nessun clone obbligatorio**: Le fonti suggerite non vengono clonate in blocco né innestate nel workspace locale (evitando di saturare lo spazio su disco e l'indice vettoriale).
2. **Referenziazione semantica**: Ciascuna fonte è descritta tramite una scheda Markdown con metadati (`id`, `url`, `triggers`, `access`, `tags`).
3. **Suggerimento Proattivo dell'LLM**: L'assistente AI ha il compito di monitorare il contesto della conversazione. Quando l'utente affronta un argomento di dominio coperto da una di queste fonti (es. un dubbio su una legge italiana, un concorso, una configurazione DevOps), l'LLM:
   - **Propone proattivamente la fonte all'utente** (*«Per questo argomento ti ricordo che abbiamo tra le fonti suggerite Italia Corpus...»*).
   - **Offre opzioni operative**: consultazione mirata on-demand (scaricando solo l'atto/file necessario via URL raw) oppure adozione formale nel catalogo personale dell'istanza.

---

## 2. Archetipi di Fonte

- **Content Sources** (es. [Italia Corpus](italia-corpus.md)):
  - Repository contenenti masse estese di testi, documentazione o norme.
  - Accesso standard: `remote-on-demand` tramite chiamate HTTP puntuali all'endpoint raw di GitHub (`raw.githubusercontent.com/...`).
  - Distillazione: solo le risposte o le interpretazioni applicative vengono registrate nelle note personali in `knowledge/`.
- **Method Sources** (es. [Cetmix Tower](cetmix-tower.md)):
  - Modelli architetturali, pattern di configurazione (es. Docker Compose, Traefik) o blueprint ingegneristici.
  - Accesso standard: consultazione online o clonazione mirata su richiesta dentro la cartella funzionale `projects/<nome>/`.

---

## 3. Flusso di Promozione a Fonte Personale

Quando l'utente desidera rendere una fonte suggerita parte integrante della propria quotidianità:
1. Viene creata una scheda in `<instance_dir>/reference/sources/<nome-fonte>.md` impostando:
   - `profile: personal`
   - `status: active`
   - `indexed: true` (la scheda descrittiva entra a far parte dell'indice semantico locale `zg`).
2. L'LLM utilizzerà la fonte come riferimento permanente per quell'istanza.
