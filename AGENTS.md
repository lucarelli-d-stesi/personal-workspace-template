# Personal Workspace — Agent Instructions

Benvenuto nel Personal Operating System (POS).
Questo file definisce le linee guida universali e vincolanti per qualsiasi agente LLM (Antigravity, Claude Code, Gemini CLI, Cursor, Codex).

---

## 1. Architettura a Due Livelli: Framework e Istanza Personale

Il sistema si fonda sulla netta separazione tra **Base Operativa Condivisa (Framework)** e **Contesto Individuale (Istanza Personale)**, consentendo a persone diverse (colleghi, familiari, studenti) di usare la stessa base operativa con configurazioni individuali completamente isolate:

1. **Workspace Generale (`personal-workspace`) — Base Operativa Comune**:
   - È agnostico rispetto all'individuo e funge da motore operativo.
   - Contiene: principi fondanti e convenzioni (`kernel/`), routine operative (`knowledge/playbooks/`), **skill metodologiche generali** (gestione progetti, redazione testi), script di automazione (`setup/bootstrap.sh`).
   - **Nessuna attività né dato personale qui**: non esistono `areas/` né `backlog/` nel framework. Nessun dato privato è tracciato in questo repository.
2. **Workspace Personale (`personal/<instance_dir>/`, es. `personal/daniele-lucarelli-pos/`)**:
   - È il repository privato di ciascun individuo (indicato nel file locale `.pos-config`).
   - Contiene:
     - **Valori e confini individuali**: `profile/values.md`, `boundaries.md`, `style.md`, `observations.md`.
     - **Fonti e reference personali**: documentazione tecnica privata, note di studio o lavoro (`reference/`, `knowledge/`).
     - **Tutti i filoni di attività**: vita familiare, veicoli, casa, finanze, salute, carriera, progetti personali (`areas/`, `backlog/items/`, `journal/`, `inbox/`).
     - **Skill specialistiche individuali**: competenze legate al proprio dominio o percorso (es. skill Odoo per lo sviluppatore, traduzione dal latino per la studentessa del liceo, analisi logica per le medie) in `skills/`.

### Principi Fondamentali (Kernel)
I principi del kernel in `kernel/principles.md` e le convenzioni in `kernel/conventions.md` sono vincolanti:
1. *I fatti battono le opinioni*: non inventare o alterare dati storici o fattuali.
2. *Proponi, non imporre*: l'agente prepara, ricorda e propone; l'essere umano decide.
3. *Reversibilità e append-only*: log e worklog si appendono; modifiche distruttive richiedono conferma esplicita.
4. *Privacy by architecture*: dati personali, valori e attività vivono solo nell'istanza privata. Nessun dato operativo o sensibile risiede nel framework pubblico.

---

## 2. Struttura del Workspace e Routing

```
personal-workspace/                     # FRAMEWORK / BASE OPERATIVA (Condivisa e Agnostica)
├── AGENTS.md / CLAUDE.md / GEMINI.md   # Istruzioni universali per gli agenti
├── kernel/                             # Costituzione: principi non negoziabili e convenzioni
├── knowledge/playbooks/                # Routine: harvesting, review settimanale, knowledge GC
├── .agents/skills/                     # SKILL METODOLOGICHE GENERALI (comuni a tutti)
│   ├── project-management/             # Metodologia WBS, stime, cronoprogramma, milestone
│   ├── text-drafting/                  # Metodo di redazione e revisione testi
│   └── <instance-skills-link>          # [GITIGNORED] Collegamenti locali alle skill dell'istanza
├── setup/                              # Script di bootstrap e template
│   └── bootstrap.sh                    # Setup automatico, deploy repo privato e indicizzazione
└── personal/                           # [GITIGNORED nel framework] Istanze private individuali
    └── <instance_dir>/                 # Repository privato dell'utente (.pos-config: instance_dir)
        ├── profile/                    # Valori personali, confini, stile, osservazioni
        ├── skills/                     # SKILL SPECIALISTICHE PERSONALI (es. odoo-*, latino, ecc.)
        ├── reference/                  # Fonti e reference tecniche private dell'utente
        ├── knowledge/                  # Conoscenza ed esperienza distillata personale
        ├── areas/                      # TUTTI I FILONI DI ATTIVITÀ DELL'UTENTE
        │   └── <area>/                 # STATUS.md, context.md, specs/, worklog/
        ├── backlog/items/              # Item e task di tutti i filoni (<area>-<NNN>.md)
        ├── inbox/                      # Cattura rapida e note grezze
        └── journal/                    # Diario cross-area
```

### Regole di Routing per gli Agenti:
1. **Zero attività alla radice comune**:
   - NON creare MAI cartelle `areas/` o `backlog/` nel framework `personal-workspace/`.
   - Modifiche al framework riguardano unicamente: regole generali, skill metodologiche universali, playbooks e setup.
2. **Tutte le attività vivono nel workspace personale**:
   - Ogni task operativo, spec, worklog o aggiornamento di stato va scritto e mantenuto ESCLUSIVAMENTE dentro `<instance_dir>/areas/<area>/` e `<instance_dir>/backlog/items/`.
3. **Organic Discovery (Nessuna intervista iniziale)**:
   - Non avviare questionari o interviste a freddo. Aree, attività e profilo emergono organicamente dalle richieste e dal lavoro quotidiano.

---

## 3. Memoria Associativa e Ricerca Semantica (`zg` / `zvgrep`)

Le attività personali non sono compartimenti stagni: si collegano per **vicinanza semantica** (es. rinnovo RCA auto che si allarga a polizze capofamiglia e polizza vita).

1. **Avvio Prompt (Kickoff semantico)**:
   - All'inizio di un task complesso o trasversale, usa `zg query "<argomento>"` (o il tool MCP `zvec_grep_search` con `root: <personal-workspace>`) per recuperare note ed esperienze pregresse da tutto il workspace personale.
2. **Virata in corso d'opera (Dynamic Pivot)**:
   - Se l'utente devia o allarga il focus verso un altro tema, non forzare riorganizzazioni di cartelle: lancia una nuova query semantica per richiamare vincoli e note del nuovo ambito.
3. **Fine Sessione (Harvesting)**:
   - Segui `knowledge/playbooks/harvesting.md`:
     - L'azione contingente con scadenza va nel backlog dell'area con tag trasversali (`tags: [veicoli, assicurazioni, famiglia]`).
     - Le lezioni generali apprese vanno salvate in una nota tematica in `<instance_dir>/knowledge/`.
     - L'indice semantico si aggiorna automaticamente, rendendo l'esperienza subito disponibile per il futuro.

---

## 4. Separazione e Sovranità degli Ambiti (STeSI vs Personal)

1. **Isolamento Rigoroso**:
   - Gli indici vettoriali di STeSI e del Personal Workspace risiedono su file distinti (`index.zvec`). Non esiste contaminazione o contraddizione implicita.
2. **Boundary Crossing Asimmetrico (Read-Only su richiesta)**:
   - Se l'utente chiede esplicitamente di consultare pattern tecnici aziendali (es. Odoo), l'agente può consultare in sola lettura il workspace STeSI.
   - È categoricamente vietato qualsiasi travaso di dati dal personal workspace verso l'ambiente aziendale.
