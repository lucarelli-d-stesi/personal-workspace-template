# Catalogo & Marketplace del POS (`knowledge/sources/`)

Questa directory (referenziata anche dal symlink alla radice [`marketplace/`](../../marketplace/)) costituisce il **Marketplace & Ecosystem Hub** del Personal Operating System (POS): una vetrina comune e dinamica di banche dati, connettori CLI, server MCP (Model Context Protocol) e blueprint architetturali messi a disposizione dal framework.

👉 **Vetrina Completa**: vedi [`INDEX.md`](INDEX.md) per l'elenco dettagliato e la matrice delle fonti disponibili.

---

## 1. Filosofia: "Zero Bloat, Opt-In & Proactive Suggestion"

1. **Nessun clone obbligatorio**: Le fonti suggerite non vengono clonate in blocco né innestate nel workspace locale (evitando di saturare lo spazio su disco e l'indice vettoriale).
2. **Referenziazione semantica**: Ciascuna fonte è descritta tramite una scheda Markdown con metadati (`id`, `url`, `triggers`, `access`, `tags`).
3. **Suggerimento Proattivo dell'LLM**: L'assistente AI monitora il contesto della conversazione. Quando l'utente affronta un argomento di dominio coperto da una di queste fonti (es. scuola, leggi, Google Workspace, social media, DevOps), l'LLM:
   - **Propone proattivamente la fonte all'utente** (*«Per questo argomento ti ricordo che nel marketplace del workspace abbiamo...»*).
   - **Offre opzioni operative**: consultazione mirata on-demand (scaricando solo l'atto/file necessario via URL raw) oppure adozione formale nel catalogo personale dell'istanza.

---

## 2. Archetipi di Strumenti nel Marketplace

- **Data Sources & Banche Dati** (es. [Italia Corpus](italia-corpus.md)):
  - Grandi moli di testi, documentazione o norme.
  - Accesso standard: `remote-on-demand` tramite chiamate HTTP puntuali all'endpoint raw di GitHub (`raw.githubusercontent.com/...`).
- **CLI Tools & Connettori API** (es. [Spaggiari ClasseViva](classeviva.md)):
  - Script eseguibili integrati (`setup/classeviva-cli.py`) per interrogazione di servizi esterni.
  - Credenziali private archiviate sul computer locale in `~/.config/pos/` (permessi `600`, rigorosamente fuori Git).
- **MCP Servers (Model Context Protocol)** (es. [Google Workspace MCP](google-workspace-mcp.md), [Google Maps MCP](google-maps-mcp.md)):
  - Connettori standard per esporre tool e risorse agli assistenti AI (Claude Code, Antigravity, Cursor, Codex).
- **Skills & Automazioni Specialistiche** (es. [Publora Social Suite](publora.md)):
  - Pacchetti di istruzioni metodologiche e connettori API per compiti complessi (es. posting multi-piattaforma).
- **Method Sources & Blueprints** (es. [Cetmix Tower](cetmix-tower.md)):
  - Modelli architetturali, pattern Docker Compose o blueprint ingegneristici per lo sviluppo in `projects/`.

---

## 3. Flusso di Adozione (Thin Overlay)

Quando l'utente desidera rendere una fonte del marketplace parte integrante della propria vita:
1. Viene creata una scheda leggera in `personal/<instance_dir>/reference/sources/<nome-fonte>.md`:
   ```yaml
   ---
   name: Spaggiari ClasseViva
   source_ref: knowledge/sources/classeviva.md
   status: active
   areas: [famiglia, studio]
   ---
   ```
2. La scheda personale contiene **solo la mappatura sulle proprie aree di vita** (`areas: [...]`), evitando duplicazioni di testo o URL tecnici.
3. Se lo strumento richiede credenziali o token privati, questi risiedono in `~/.config/pos/<id>.env`.

---

## 4. Gestione da Riga di Comando (`setup/marketplace.sh`)

Per verificare rapidamente gli strumenti a catalogo e lo stato di adozione nella propria istanza:
```bash
# Mostra la vetrina completa con lo stato di adozione
bash setup/marketplace.sh

# Dettagli, trigger e istruzioni per uno strumento specifico
bash setup/marketplace.sh --info classeviva

# Output JSON per assistenti o automazioni
bash setup/marketplace.sh --json
```

---

## 5. Ciclo di Vita delle Fonti (Deprecazione & Rimozione)

Se una fonte del framework viene dismessa:
1. **Deprecazione dolce**: la scheda riceve `status: deprecated` con motivazione; l'LLM smette di proporla ai nuovi utenti e informa con garbo chi la usa già.
2. **Rimozione sicura**: se la scheda viene eliminata dal framework, [`setup/check-updates.sh`](../../setup/check-updates.sh) rileva il Thin Overlay orfano e propone all'utente di archiviarlo (`reference/sources/archive/`) o congelarlo come fonte privata locale. **I dati, note e log storici dell'utente non vengono mai toccati o persi.**
