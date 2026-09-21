---
id: source-memory-layer
name: Memory Layer (Coding Agents & PostgreSQL)
profile: suggested
status: suggested
category: cli-tool
type: method
url: https://github.com/3vilM33pl3/memory
access: local-sparse
tags: [memory, coding-agents, postgresql, pgvector, rust, mcp, tui, continuity, provenance, software-engineering]
triggers:
  - memoria persistente e continuità per agenti di programmazione (Claude Code, Codex, Cursor)
  - tracciare decisioni architetturali, bug ricorrenti e scelte tecniche per progetti software
  - interrogare la memoria tecnica con citazione delle evidenze (commit, file, diff, test)
  - briefing strutturato di ripresa lavoro (resume) su codebase complesse in projects/
  - memorizzare pattern e vincoli tecnici nei repository git di progetti complessi
  - integrazione server MCP per la memoria di codice basata su PostgreSQL e pgvector
---

# Memory Layer — Memoria Locale Persistente per Coding Agents (Suggerita)

Sistema di memoria locale e open-source (scritto in **Rust 2024**) espressamente progettato per eliminare l'amnesia tra sessioni degli **agenti di sviluppo software** (Claude Code, Codex, Cursor, OpenCode).

Mentre il POS gestisce la governance complessiva della vita e dei progetti in file Markdown sovrani, **Memory Layer** agisce come motore ad altissime prestazioni per singoli repository di codice, trasformando sessioni, commit e decisioni in conoscenza strutturata e ricercabile supportata da **PostgreSQL** e dall'estensione vettoriale **`pgvector`**.

---

## 1. I Punti di Forza Architetturali

1. **Il Ciclo Operativo Completo**:
   `Capture` (intercetta attività e comandi) $\rightarrow$ `Curate` (deduplica, sintetizza e propone modifiche) $\rightarrow$ `Store` (PostgreSQL + pgvector) $\rightarrow$ `Retrieve` (ibrido semantico/lessicale/grafo) $\rightarrow$ `Reinforce` (verifica automatica di staleness a fronte del codice reale).
2. **Resume Briefing Istantaneo (`memory resume`)**:
   Genera un riepilogo contestuale per riprendere il lavoro dopo un'interruzione: cosa è stato fatto nell'ultima sessione, quali file erano in corso di modifica, decisioni fresche e blocchi aperti.
3. **Evidence & Provenance Tracciata**:
   Ogni affermazione o pattern memorizzato è collegato alle prove concrete: hash del commit, file modificati, output di test o comandi eseguiti. Niente allucinazioni senza fonte.
4. **Replacement Proposals con Human Gate**:
   Se una sessione contraddice una regola o decisione pregressa, il sistema non sovrascrive ciecamente: crea una *proposta di sostituzione* che richiede approvazione esplicita via TUI o Web UI.
5. **Autovalidazione a Fronte del Codice**:
   Verifica periodicamente le memorie più utilizzate (*hot memories*): se una funzione o un modulo citato viene cancellato o refactorizzato, la memoria viene segnalata come obsoleta.

---

## 2. Casi d'Uso nel Personal Operating System (POS)

Nel POS, il codice dei progetti risiede nelle cartelle funzionali isolate `<instance_dir>/projects/<nome-progetto>/`:
- **Repository Software Complessi (`projects/`)**:
  - Quando si sviluppano tool CLI, estensioni Odoo o architetture multi-modulo dove più sessioni o agenti diversi intervengono nel tempo.
- **Supporto a Coding Agents Esterni**:
  - Fornisce un server **MCP** (`memory mcp`) a Claude Code o Codex per interrogare lo storico delle decisioni di quel codice prima di toccare i file.
- **Zero Inquinamento del Repo Personale**:
  - La configurazione locale risiede nel file `.mem/project.toml` del progetto git, mentre il database vive nel Postgres locale, lasciando il repository personale snello e privo di bloat.

---

## 3. Architettura & Requisiti di Sistema

- **Runtime**: Binario Rust compilato (Linux x86_64/ARM64, macOS, Windows).
- **Database**: PostgreSQL 15+ con estensione `pgvector` abilitata.
  - Può essere eseguito localmente o tramite container Docker leggero:
    ```bash
    docker run -d --name memory-pg -e POSTGRES_PASSWORD=postgres -p 5432:5432 pgvector/pgvector:pg16
    ```
- **Interfacce Incluse**:
  - **CLI**: `memory remember`, `memory query`, `memory resume`, `memory status`.
  - **TUI**: Interfaccia da terminale split-pane (`memory tui`).
  - **Web UI**: Dashboard grafica con visualizzazione a grafo delle relazioni (`memory web`).
  - **Server MCP**: Protocollo standard per esporre i tool di memoria a qualsiasi LLM.

---

## 4. Adozione nell'Istanza Personale (Thin Overlay)

Per registrare Memory Layer come strumento attivo per i propri progetti software:

Crea il file `personal/<tua-istanza>/reference/sources/memory-layer.md`:

```yaml
---
id: source-memory-layer
name: Memory Layer (Coding Agents)
source_ref: knowledge/sources/memory-layer.md
profile: personal
status: active
type: method
access: local-sparse
tags: [memory, coding-agents, postgresql, pgvector, rust, mcp]
areas: [sviluppo, progetti]
---

# Memory Layer — Attivazione Personale (Thin Overlay)

Attivazione del motore di memoria tecnica per agenti di programmazione:
👉 Consulta la scheda canonica e i comandi in `knowledge/sources/memory-layer.md`.

## Mappatura sui Progetti
- Utilizzato nei repository software in `projects/` (es. tool personalizzati, progetti indipendenti).
- Credenziali PostgreSQL archiviate in `~/.config/pos/memory-layer.env` (permessi `600`).
```
