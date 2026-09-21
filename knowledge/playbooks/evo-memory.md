# Playbook — Evo-Memory & Episodic Bedrock (Track 4)

> **Scopo**: Trasformare la memoria del Personal Operating System da un archivio passivo ad accumulo infinito in una **memoria vivente, auto-manutentiva e consapevole della dimensione episodica biografica**.

---

## 1. Principi Fondamentali

La memoria a lungo termine di un agente e di una persona non è una coda FIFO né un magazzino statico *write-and-forget*. Si fonda su tre pilastri:

1. **Distillazione e Compattazione Continua (*Signal over Noise*)**:
   - I dettagli operativi minuto-per-minuto (comandi shell, errori transitori, tentativi) sono utili durante la sessione, ma diventano rumore con il passare dei mesi.
   - A task concluso, il worklog viene compattato in un **sommario esecutivo permanente**: risultati fattuali, deliverable verificabili e pattern riutilizzabili.
2. **Memoria Episodica e Calore Latente (*Episodic Bedrock*)**:
   - **Latenza non è Obsolescenza**: Nella psicologia della memoria umana (Tulving, Conway), un evento formativo, una svolta esistenziale, una cicatrice o una decisione fondativa rimangono significativi anche se non vengono nominati per mesi o anni.
   - Un ricordo episodico ad alto carico identitario agisce come un **attrattore gravitazionale latente**: orienta tacitamente scelte, confini e priorità.
   - **Regola di non-decadimento**: Un nodo o osservazione classificato come *Episodic Anchor* (collegato ai valori del profilo, contrassegnato da `[anchor]`, o avente `type: episodic_anchor`) è **immune da qualsiasi potatura basata sul tempo trascorso**.
3. **Reversibilità e Sovranità Umana (*Human-in-the-Loop*)**:
   - L'agente e gli script di Evo-Memory propongono compattazioni e archiviazioni; l'essere umano decide e approva.
   - Nessun dato viene cancellato: ciò che viene "potato" dal contesto attivo viene archiviato ordinatamente (es. `profile/archive/observations-archive.md`) per garantire la piena reversibilità storica in Git.

---

## 2. La Tassonomia dei Ricordi

| Livello di Memoria | Tipo | Natura | Politica di Decadimento / Ciclo Vitale |
| :--- | :--- | :--- | :--- |
| **Episodic Bedrock** | `episodic_anchor` | Eventi di svolta, patti fondativi, lezioni da crisi, pietre miliari esistenziali. | **Decadimento zero**. Rimane attivo o latente indefinitamente. Immune da whittling. |
| **Canonical Patterns** | `knowledge/` | Architetture consolidate, convenzioni, playbook, pattern verificati. | Manutenzione per budget (> 400 righe o split). Aggiornato quando superato (`supersedes`). |
| **Active Observations** | `profile/` | Segnali comportamentali, preferenze provvisorie, abitudini in osservazione. | Valutato per *Recency × Frequency × Relevance*. Whittling dopo 60–90 giorni di inattività. |
| **Operational Ephemera** | `worklog/` | Log minuzioso di sessione, comandi eseguiti, output di debug. | Compattato all'approvazione del task (`done`); log esteso archiviato in append-only. |

---

## 3. Le Quattro Routine Operative

### Routine 1: Compattazione a Chiusura Task (`compact`)
Quando un item di backlog (`<area>-<NNN>.md`) passa a `status: done`:
1. L'agente o l'utente lancia:
   ```bash
   python3 setup/evo_memory.py compact <item-id> --apply
   ```
2. Lo script analizza le sessioni e inserisce in cima al worklog un blocco `## Compacted Summary (Evo-Memory)` contenente:
   - Sintesi esecutiva in 3-5 punti.
   - Elenco dei deliverable tangibili verificati.
   - Pattern e lezioni da esportare in `knowledge/`.
   - Eventuale marcatura di risonanza o evento fondativo.

### Routine 2: Active Whittling delle Osservazioni (`whittle`)
Durante la Weekly Review:
1. L'agente o l'utente verifica lo stato delle osservazioni del profilo:
   ```bash
   python3 setup/evo_memory.py whittle --days 60
   ```
2. **Sonda Ermeneutica dell'LLM**:
   - Per ciascuna osservazione inattiva da oltre 60 giorni, l'agente valuta: *"È un dettaglio contingente dismesso o un'ancora episodica latente che orienta ancora il comportamento?"*
   - Se è un'ancora latente, viene marcata come `type: episodic_anchor` e preservata.
   - Se è un'osservazione dismessa, viene spostata in archivio con `--apply`.

### Routine 3: Verifica Freschezza e Link (`staleness`)
Verifica periodica dell'integrità strutturale:
```bash
python3 setup/evo_memory.py staleness
```
- Rileva link interni markdown interrotti.
- Segnala riferimenti a directory `projects/<nome>` non presenti localmente.

### Routine 4: Deduplica e Consolidamento Semantico (`dedup`)
Prevenzione delle frammentazioni tra `inbox/` e `knowledge/`:
```bash
python3 setup/evo_memory.py dedup
```
- Rileva coppie di documenti con sovrapposizione concettuale e propone una nota canonica unificata.

---

## 4. Integrazione nella Weekly Review

Durante la revisione settimanale, l'agente esegue il briefing digest completo:
```bash
python3 setup/evo_memory.py digest
```
Il digest riporta l'indice di salute della memoria, i worklog in attesa di distillazione, gli ancoraggi episodici attivi e le proposte di consolidamento.
