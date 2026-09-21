# Personal Workspace — Agent Instructions

Benvenuto nel Personal Operating System (POS).
Questo file definisce le linee guida universali e vincolanti per qualsiasi agente LLM (Antigravity, Claude Code, Gemini CLI, Cursor, Codex).

---

## 1. Architettura del Personal Operating System (Unified Single-Repo)

Il sistema adotta un modello a **Repository Unico per Utente derivato da un Template Canonico Centralizzato**:

1. **Il Repository dell'Utente (Privato)**:
   - Ogni individuo possiede un unico repository Git privato (es. `utente/mio-pos`), generato a partire dal template pubblico comune.
   - **Tutte le attività, aree, note e valori personali risiedono direttamente alla radice** del workspace, eliminando qualsiasi annidamento fragile o configurazione complessa.
2. **Il Template Canonico Upstream (Pubblico)**:
   - Il repository `lucarelli-d-stesi/personal-workspace-template` funge da **template pubblico e fonte di aggiornamento**.
   - Fornisce: principi e convenzioni (`kernel/`), routine operative (`knowledge/playbooks/`), catalogo strumenti (`knowledge/sources/`), skill metodologiche generali (`.agents/skills/`), script di gestione (`setup/`).
   - È collegato nel workspace dell'utente come remote `template` in sola lettura (con push disarmato).

### Principi Fondamentali (Kernel)
I principi del kernel in `kernel/principles.md` e le convenzioni in `kernel/conventions.md` sono vincolanti:
1. *I fatti battono le opinioni*: non inventare o alterare dati storici o fattuali.
2. *Proponi, non imporre*: l'agente prepara, ricorda e propone; l'essere umano decide.
3. *Reversibilità e append-only*: log e worklog si appendono; modifiche distruttive richiedono conferma esplicita.
4. *Privacy by architecture*: dati personali, valori e attività vivono solo nel repository privato dell'utente. Nessun dato operativo o sensibile deve mai finire nel template pubblico.

---

## 2. Struttura del Workspace e Confini di Directory

```
personal-workspace/                     # UNICO REPOSITORY PRIVATO DELL'UTENTE
├── kernel/                             # [FRAMEWORK] Principi non negoziabili e convenzioni
├── setup/                              # [FRAMEWORK] Script di bootstrap, sync, status, graph, marketplace
├── knowledge/
│   ├── playbooks/                      # [FRAMEWORK] Routine (harvesting, review settimanale, knowledge GC)
│   ├── sources/ (alias: marketplace/)  # [FRAMEWORK] Vetrina marketplace (strumenti e connettori)
│   └── <argomenti>/                    # [PERSONALE] Conoscenza personale distillata (es. politica, salute)
├── .agents/skills/                     # [FRAMEWORK] Skill metodologiche universali (WBS, drafting)
├── AGENTS.md / CLAUDE.md / GEMINI.md   # [FRAMEWORK] Istruzioni universali per gli agenti
│
├── profile/                            # [PERSONALE] Valori personali, confini, stile, osservazioni
├── machines/<id>.md                    # [PERSONALE] Profilo hardware e strumenti per-macchina
├── areas/<area>/                       # [PERSONALE] Filoni di attività (STATUS.md, context.md, specs, worklog)
├── backlog/items/                      # [PERSONALE] Task e iniziative (<area>-<NNN>.md)
├── journal/                            # [PERSONALE] Diario cross-area
├── inbox/                              # [PERSONALE] Cattura rapida e note grezze
├── reference/sources/                  # [PERSONALE] Thin Overlays adottati dal marketplace
├── skills/                             # [PERSONALE] Skill specialistiche individuali (es. odoo-*, latino)
└── projects/                           # [PERSONALE - GITIGNORED] Codebase software e cloni indipendenti
```

### Regole di Routing per gli Agenti:
1. **Dati Personali Direttamente alla Radice**:
   - Ogni task operativo, spec, worklog o aggiornamento di stato va scritto e mantenuto ESCLUSIVAMENTE dentro `areas/<area>/` e `backlog/items/`.
   - Nessuna nota o dato personale va inserito nei file del framework (`kernel/`, `setup/`, `knowledge/sources/`, `knowledge/playbooks/`).
2. **Organic Discovery (Nessuna intervista iniziale)**:
   - Non avviare questionari o interviste a freddo all'onboarding. Aree, attività e profilo emergono organicamente dalle richieste e dal lavoro quotidiano.
3. **Sviluppo Software e Cloni di Repository (`projects/`)**:
   - Quando un task richiede di sviluppare un software/tool o clonare repository esterni, opera sempre dentro `projects/<nome-progetto>/`.
   - Ciascuna cartella in `projects/` è un **repository Git indipendente** (con il proprio `.git` e remote); non committare codice sorgente o dipendenze nel repo del POS.
   - Nel POS mantieni esclusivamente la governance: item di backlog (`project_dir: projects/<nome-progetto>`), spec architetturale e worklog.
4. **Riservatezza del README del Repository Privato**:
   - Il file `README.md` alla radice dell'istanza privata non deve **MAI** elencare, riassumere o esporre attività in corso, iniziative specifiche o dati personali dell'utente.
   - Deve rimanere una panoramica rigorosamente architetturale, tecnica e metodologica (ruolo del POS, comandi di routine, separazione codice/governance). Non mettere mai in bella vista le attività dell'utente sulla vetrina del repository.

---

## 3. Git Topology Awareness & Cognitive Push Safeguard

L'agente LLM agisce come **guardiano preventivo della riservatezza (Cognitive Guard)**:

1. **Verifica Topologia Remote Pre-Push**:
   Prima di eseguire o proporre qualsiasi comando `git push`, l'agente DEVE controllare i remote configurati (`git remote -v`):
   - **Rilevamento Clone Template**: Se `origin` punta al repository pubblico del template (`lucarelli-d-stesi/personal-workspace-template`), l'agente **NON DEVE MAI** eseguire push di commit contenenti modifiche a `areas/`, `profile/`, `backlog/`, `journal/`, `inbox/`.
   - **Intervento Proattivo**: L'agente blocca l'azione e spiega:
     > *"⚠️ Attenzione: il tuo workspace sta usando come 'origin' il template pubblico. I tuoi dati personali non devono essere inviati lì! Ti aiuto a creare un tuo repository GitHub privato (es. tuo-utente/mio-pos) e a reindirizzare 'origin'."*
2. **Remote Template di Sola Lettura**:
   - Il remote `template` serve unicamente per ricevere aggiornamenti del framework (`git fetch template main`).
   - Il push verso `template` deve sempre rimanere disarmato (`git remote set-url --push template NO_PUSH_UPSTREAM_TEMPLATE`).

---

## 4. Memoria Associativa, Ricerca Semantica (`zg`) e Grafo Epistemico

1. **Avvio Prompt (Kickoff semantico)**:
   - All'inizio di un task complesso o trasversale, usa `zg query "<argomento>"` (o il tool MCP `zvec_grep_search`) per recuperare note ed esperienze pregresse da tutto il workspace.
2. **Virata in corso d'opera (Dynamic Pivot)**:
   - Se l'utente devia o allarga il focus verso un altro tema, non forzare riorganizzazioni di cartelle: lancia una nuova query semantica per richiamare vincoli e note del nuovo ambito.
3. **Grafo Epistemico & Relazioni Tipizzate (Track 1)**:
   - Quando crei note o documenti di conoscenza, adotta relazioni tipizzate nel frontmatter YAML:
     ```yaml
     status: active | superseded | deprecated | proposed
     # Relazioni Lineari / Causali (Logica Formale & Esecuzione)
     supersedes: [slug-nota-precedente]
     depends_on: [slug-dipendenza]
     conflicts_with: [slug-contraddizione]
     supports: [slug-argomento]
     # Relazioni Correlative & di Processo (Epistemic Resonance & Pluralism)
     resonates_with: [slug-risonanza]     # Gan-Ying: risonanza simpatica cross-dominio
     polar_balance: [slug-polarita]       # Yin-Yang: polarità complementare dinamica
     nourishes: [slug-nutrimento]         # Wuxing Sheng: generazione e linfa vitale
     moderates: [slug-regolazione]        # Wuxing Ke: freno omeostatico e potatura
     ```
   - Se una nota ne sostituisce un'altra, aggiungi un disclaimer evidente in cima al vecchio documento:
     `> ⚠️ SUPERSEDED BY [Titolo Nuovo](file:///...) in data YYYY-MM-DD`
   - Usa `python3 setup/graph.py check`, `python3 setup/graph.py lineage <slug>`, `python3 setup/graph.py mermaid` o `python3 setup/graph.py stats`.
   - Per approfondire la modellazione di tensioni feconde e risonanze consulta `knowledge/playbooks/epistemic-resonance.md`.
4. **Fine Sessione (Harvesting)**:
   - Segui `knowledge/playbooks/harvesting.md`:
     - L'azione contingente con scadenza va nel backlog dell'area con tag trasversali.
     - Le lezioni generali apprese vanno salvate in una nota tematica in `knowledge/`.

---

## 5. Separazione e Sovranità degli Ambiti (STeSI vs Personal)

1. **Isolamento Rigoroso**:
   - Gli indici vettoriali di STeSI e del Personal Workspace risiedono su file distinti (`index.zvec`). Non esiste contaminazione o contraddizione implicita.
2. **Boundary Crossing Asimmetrico (Read-Only su richiesta)**:
   - Se l'utente chiede esplicitamente di consultare pattern tecnici aziendali (es. Odoo), l'agente può consultare in sola lettura il workspace STeSI.
   - È categoricamente vietato qualsiasi travaso di dati dal personal workspace verso l'ambiente aziendale.

---

## 6. Asse Macchina e Consapevolezza dell'Ambiente Locale

1. **Profilo Macchina (`machines/<id>.md`)**:
   - Ogni macchina possiede un file dedicato in `machines/<id>.md` (nome = hostname slug, es. `stesi-workspace.md`).
   - Prima di proporre comandi di sistema, script o esecuzione di tool pesanti, consulta il profilo per verificare: scenario (`vm`, `wsl`, `mac`, `linux`), vCPU/RAM disponibili, Docker runtime e versioni installate.
2. **Tracciamento Sessione e Rilevamento Switch (`machines/last-session.md`)**:
   - In `machines/last-session.md` viene registrata l'ultima macchina su cui si è svolta una sessione.
   - All'avvio di sessione, se l'hostname differisce da quanto registrato (switch di macchina), l'agente esegue automaticamente `bash setup/status.sh` per verificare la salute del nodo e allineare lo stato.
3. **Audit del Deploy (`setup/status.sh`)**:
   - In caso di dubbi sullo stato del setup, allineamento git o tool mancanti, esegui o consiglia `bash setup/status.sh`.

---

## 7. POS Marketplace & Fonti Esterne

1. **Marketplace del Framework (`knowledge/sources/` e symlink `marketplace/`)**:
   - Raccoglie la vetrina condivisa di strumenti, connettori e basi di conoscenza (`INDEX.md` o `bash setup/marketplace.sh`).
2. **Comportamento dell'Agente**:
   - **Richiesta esplicita**: presenta una panoramica chiara distinguendo ciò che è attivo da ciò che è disponibile.
   - **Suggerimento proattivo contestuale**: quando l'utente affronta un'attività pertinente (es. compiti scolastici, normative, invio email, pianificazione trasferte), propone lo strumento a catalogo senza imporre nulla.
   - **Attivazione a 1-Click (Thin Overlay)**: se l'utente accetta, crea la scheda in `reference/sources/<id>.md` (`source_ref: knowledge/sources/<id>.md`, `areas: [...]`) e guida alla configurazione delle eventuali credenziali in `~/.config/pos/<id>.env`.
3. **Fonti Private dell'Utente**:
   - Se una fonte è strettamente personale e privata, vive **esclusivamente** nell'istanza dell'utente (`reference/sources/`) e **non viene mai aggiunta al catalogo pubblico del framework**.

---

## 8. Aggiornamenti del Framework dal Template (Zero-Knowledge Sync)

1. **Trigger**:
   - Quando l'utente chiede *"ci sono novità nel workspace?"*, *"verifica aggiornamenti"* o simili, l'agente esegue:
     ```bash
     bash setup/check-updates.sh
     ```
2. **Analisi e Proposta trasparente**:
   - Se il remote `template` ha rilasciato nuove feature o fix al framework, ne spiega l'effetto.
   - Con `bash setup/check-updates.sh --apply`, preleva i file aggiornati del framework e applica eventuali migrazioni in `setup/updates/`.
3. **Inviolabilità dei dati personali**:
   - Non vengono mai sovrascritti né eliminati file in `profile/`, `areas/`, `backlog/`, `journal/`, `inbox/`, `skills/` o `knowledge/`.
