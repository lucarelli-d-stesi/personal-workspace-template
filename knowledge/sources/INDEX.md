# POS Marketplace & Ecosystem Hub

Benvenuto nel **Marketplace del Personal Operating System (POS)**.

Questo catalogo raccoglie e indicizza le **fonti esterne**, i **connettori CLI**, i **server MCP (Model Context Protocol)**, i **blueprint architetturali** e le **skill specialistiche** disponibili nel framework condiviso.

---

## 1. Vetrina degli Strumenti a Catalogo

| Icona & Nome | Categoria | Ambito | Accesso & Auth | Stato | Scheda di Dettaglio |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 🏛️ **[Italia Corpus](italia-corpus.md)** | `data-source` | Diritto, PA, Terzo Settore | Open Data (Raw HTTP on-demand) | `ready` | [italia-corpus.md](italia-corpus.md) |
| 🎓 **[Spaggiari ClasseViva](classeviva.md)** | `cli-tool` | Scuola, Famiglia, Studio | CLI + API (Credenziali locali protette) | `ready` | [classeviva.md](classeviva.md) |
| 📅 **[Google Workspace MCP](google-workspace-mcp.md)** | `mcp-server` | Produttività, Agenda, Email | Server MCP locale (OAuth 2.0 personale) | `ready` | [google-workspace-mcp.md](google-workspace-mcp.md) |
| 🗺️ **[Google Maps MCP](google-maps-mcp.md)** | `mcp-server` | Mobilità, Territorio, Meteo | Server MCP locale (Google Maps API Key) | `ready` | [google-maps-mcp.md](google-maps-mcp.md) |
| 📢 **[Publora Social Suite](publora.md)** | `skill-mcp` | Comunicazione & Social Media | Server MCP / REST (API Key Publora) | `ready` | [publora.md](publora.md) |
| 🏗️ **[Cetmix Tower](cetmix-tower.md)** | `blueprint` | DevOps, Ingegneria, Odoo | Open Source (Consultazione / Clone) | `ready` | [cetmix-tower.md](cetmix-tower.md) |
| 📄 **[Docling](docling.md)** | `cli-tool` | Documenti, PDF, OCR, Tabelle | Open Source / Locale (Python / uvx) | `ready` | [docling.md](docling.md) |
| 🕷️ **[Scrapling](scrapling.md)** | `cli-tool` | Web Scraping, Anti-Bot, Open Data | Open Source / Locale (Python / Stealth) | `ready` | [scrapling.md](scrapling.md) |
| 🧠 **[Memory Layer](memory-layer.md)** | `cli-tool` | Coding Agents, Continuità, Ingegneria | PostgreSQL + pgvector (Locale / Rust) | `ready` | [memory-layer.md](memory-layer.md) |

---

## 2. Dettaglio delle Fonti Disponibili

### 🏛️ Italia Corpus (`source-italia-corpus`)
- **Tipo**: `data-source` (Archivio documentale e normativo)
- **Cosa fa**: Mette a disposizione l'intero corpus delle leggi e dei decreti della Repubblica Italiana (oltre 280.000 atti normativi pubblicati su Normattiva, convertiti e indicizzati in Markdown).
- **Accesso**: *Remote-on-demand* via HTTP raw. **Zero bloat**: non viene clonato l'intero repository, ma l'assistente AI effettua download puntuali dei singoli testi di legge quando necessario.
- **Trigger semantici**: leggi, decreti, normative, Testo Unico Enti Locali (TUEL), Codice del Terzo Settore (ETS/APS/ODV), contratti pubblici, concorsi, Codice Amministrazione Digitale (CAD).
- **Attivazione**: [Vedi scheda dettagliata](italia-corpus.md).

### 🎓 Spaggiari ClasseViva API & CLI (`source-classeviva`)
- **Tipo**: `cli-tool` & `api-connector`
- **Cosa fa**: Interfaccia il registro elettronico scolastico Spaggiari ClasseViva, usato in migliaia di scuole primarie e secondarie italiane.
- **Profili supportati**:
  - **Genitore (`G...`)**: visualizzazione multi-figlio di compiti, scadenze, circolari d'istituto con allegati PDF, voti e note.
  - **Studente (`S...`)**: estrazione automatica dei compiti dell'agenda, scomposizione delle attività pomeridiane e schemi di ripasso per le interrogazioni.
- **Accesso & Sicurezza**: Utilizza lo script CLI integrato `setup/classeviva-cli.py`. Le credenziali risiedono esclusivamente nel file locale protetto `~/.config/pos/classeviva.env` (permessi `600`, mai tracciato in Git).
- **Trigger semantici**: scuola, compiti, voti, circolari, bacheca, lezioni, interrogazioni, registro elettronico, studio pomeridiano.
- **Attivazione**: [Vedi scheda dettagliata](classeviva.md).

### 📅 Google Workspace MCP (`source-google-workspace-mcp`)
- **Tipo**: `mcp-server` (Model Context Protocol)
- **Cosa fa**: Espone all'assistente AI (Claude Code, Antigravity, Cursor, Codex) oltre 120 strumenti per interagire direttamente con l'ecosistema Google: **Google Calendar** (consultazione e creazione eventi), **Gmail** (lettura, ricerca e bozze email), **Google Drive** (ricerca e download file), **Docs**, **Sheets**, **Tasks** e **Contacts**.
- **Accesso & Sicurezza**: Eseguito localmente via `uvx workspace-mcp` senza proxy intermedi. Richiede credenziali OAuth personali in `~/.config/pos/google.env`. Possibilità di limitare gli strumenti e abilitare la modalità `--read-only`.
- **Trigger semantici**: calendario, appuntamenti, impegni, invio/lettura email, cercare file su Drive, leggere o creare fogli Sheets o documenti Docs.
- **Attivazione**: [Vedi scheda dettagliata](google-workspace-mcp.md) e wizard `setup/setup-google-workspace-mcp.sh`.

### 🗺️ Google Maps Grounding Lite MCP (`source-google-maps-mcp`)
- **Tipo**: `mcp-server`
- **Cosa fa**: Fornisce strumenti geospaziali all'assistente: ricerca luoghi e attività commerciali (`search_places`), calcolo itinerari con tempi di percorrenza e traffico in tempo reale (`compute_routes`), e meteo locale (`lookup_weather`).
- **Accesso & Sicurezza**: Eseguito localmente via `npx` con Google Maps API Key archiviata in `~/.config/pos/google.env`.
- **Trigger semantici**: percorsi, itinerari di viaggio, traffico, calcolo tempi di spostamento, ristoranti/servizi in zona, previsioni meteo per eventi o trasferte.
- **Attivazione**: [Vedi scheda dettagliata](google-maps-mcp.md).

### 📢 Publora Social Suite (`source-publora`)
- **Tipo**: `skill-mcp` (Suite di 9 skill e server MCP)
- **Cosa fa**: Consente la redazione, formattazione specialistica, pianificazione e pubblicazione di contenuti su 7 piattaforme social contemporaneamente: **LinkedIn** (post e analisi statistiche), **YouTube** (video e community), **X / Twitter** (thread e media), **Threads**, **TikTok**, **Bluesky** e **Facebook Pages**.
- **Accesso & Sicurezza**: Tramite connettore Publora REST API o MCP con API Key personale.
- **Trigger semantici**: social post, pubblicare su LinkedIn, tweet, thread, statistiche social, video YouTube, postare su Bluesky o Threads.
- **Attivazione**: [Vedi scheda dettagliata](publora.md) e le skill in `.agents/skills/*-post`.

### 🏗️ Cetmix Tower (`source-cetmix-tower`)
- **Tipo**: `blueprint` & `method-source`
- **Cosa fa**: Repository open-source di riferimento per l'architettura e l'automazione DevOps di Odoo con Traefik, Docker Compose, Postgres e backup automatizzati su S3.
- **Accesso**: Consultazione remota o clone locale nella cartella funzionale `projects/<nome>/`.
- **Trigger semantici**: odoo deployment, docker compose odoo, traefik reverse proxy, devops, configurazione server staging/produzione.
- **Attivazione**: [Vedi scheda dettagliata](cetmix-tower.md).

### 📄 Docling Document Parser (`source-docling`)
- **Tipo**: `cli-tool` & `method` (IBM Research Document Parser)
- **Cosa fa**: Converte documenti ricchi e complessi (**PDF**, **DOCX**, **PPTX**, **XLSX**, scansioni cartacee) in Markdown o JSON preservando la struttura logica, l'ordine di lettura multi-colonna e il codice/formule LaTeX. Include motore OCR locale e ricostruzione avanzata di tabelle complesse con celle unite.
- **Accesso & Sicurezza**: Eseguito localmente via CLI Python (`pip install docling` o `uvx docling`). 100% offline, nessun documento inviato a servizi cloud.
- **Trigger semantici**: convertire PDF complessi, estrarre tabelle da PDF/bilanci/bandi, OCR scansioni cartacee, convertire Word/PowerPoint in Markdown, preparazione dati RAG per LLM.
- **Attivazione**: [Vedi scheda dettagliata](docling.md).

### 🕷️ Scrapling Web Scraper & Crawler (`source-scrapling`)
- **Tipo**: `cli-tool` & `method` (Adaptive Stealth Web Scraper)
- **Cosa fa**: Framework di web scraping ad altissime prestazioni specificamente progettato per estrarre dati puliti per LLM superando filtri anti-bot moderni (**Cloudflare Turnstile**, DataDome, Akamai) con overhead minimo. Dispone di tre motori di fetch (`Fetcher`, `StealthyFetcher`, `DynamicFetcher`) e selettori adattivi che resistono alle modifiche del layout HTML.
- **Accesso & Sicurezza**: Eseguito localmente in Python (`pip install scrapling`). Non richiede proxy residenziali a pagamento o servizi terzi di captcha-solving.
- **Trigger semantici**: estrarre dati da siti protetti da Cloudflare, scraping albi pretori/bandi/notizie, Single Page Application con rendering JS, monitoraggio pagine e tariffe, aggirare errori 403/captcha.
- **Attivazione**: [Vedi scheda dettagliata](scrapling.md).

### 🧠 Memory Layer (`source-memory-layer`)
- **Tipo**: `cli-tool` & `method` (Local-first memory engine per coding agents)
- **Cosa fa**: Sistema di memoria persistente e ad alte prestazioni scritto in Rust per singoli progetti di sviluppo software. Memorizza decisioni, commit, vincoli architetturali e bug passati, supportando Claude Code, Codex e Cursor via MCP, TUI e CLI. Include `memory resume` per il briefing istantaneo di ripresa lavoro, deduplicazione con gate umano e auto-validazione a fronte del codice.
- **Accesso & Sicurezza**: Eseguito localmente con database PostgreSQL + `pgvector` (tramite container Docker locale o installazione bare-metal). 100% locale, nessuna telemetria forzata, totale sovranità sui dati di progetto.
- **Trigger semantici**: memoria persistente per coding agents, tracciare decisioni architetturali per Claude Code/Codex, storico decisioni software con evidenza commit, briefing di ripresa (resume) su progetti software in `projects/`.
- **Attivazione**: [Vedi scheda dettagliata](memory-layer.md).

---

## 3. Filosofia del Marketplace: "Opt-In & Zero-Knowledge"

1. **Agnostico e Non Vincolante**:
   Nessuno strumento del marketplace è pre-installato o obbligatorio. Ogni utente del workspace (ad es. Daniele, Claudia, Gemma, Petra) sceglie autonomamente cosa attivare in base alle proprie esigenze.
2. **Attivazione tramite Thin Overlay**:
   Per "adottare" uno strumento nella propria vita, l'utente o l'assistente AI crea un file leggero in `personal/<istanza>/reference/sources/<id>.md`:
   ```yaml
   ---
   name: Spaggiari ClasseViva
   source_ref: knowledge/sources/classeviva.md
   status: active
   areas: [famiglia, studio]
   ---
   ```
   In questo modo, l'istanza personale non duplica documentazione o percorsi tecnici, ma si limita a collegare lo strumento alle proprie aree di responsabilità.
3. **Credenziali Rigorosamente Private**:
   Tutte le credenziali, token e password personali risiedono sul disco locale dell'utente in `~/.config/pos/` (permessi `600`). Non entrano mai nella cronologia Git e non sono mai condivise tra utenti.

---

## 4. Come Usare e Consultare il Marketplace

### Da Riga di Comando
Puoi verificare lo stato del catalogo e scoprire strumenti non ancora attivati con:
```bash
bash setup/marketplace.sh
```
Per dettagli su un singolo strumento:
```bash
bash setup/marketplace.sh --info classeviva
```

### Tramite Assistente AI
Puoi interagire in linguaggio naturale in qualsiasi sessione:
- *"Mostrami cosa c'è nel marketplace del workspace"*
- *"Quali strumenti posso attivare per la scuola o lo studio?"*
- *"Attiva Google Workspace nella mia area lavoro/carriera"*
- *"Ci sono novità o nuovi connettori nel marketplace?"*

---

## 5. Ciclo di Vita delle Fonti (Deprecation & Retirement)

- **`status: ready`**: Fonte pienamente operativa, testata e supportata.
- **`status: experimental`**: Fonte o connettore in fase di sviluppo/collaudo.
- **`status: deprecated`**: La fonte è contrassegnata per il ritiro (es. API terze dismesse). Non viene più proposta a nuovi utenti; chi la utilizza riceve un avviso trasparente dall'assistente per pianificare la transizione.
- **`status: retired`**: Fonte rimossa dal catalogo attivo. [`setup/check-updates.sh`](../check-updates.sh) rileva eventuali thin overlay orfani e guida l'utente ad archiviare o ripulire la configurazione locale.
