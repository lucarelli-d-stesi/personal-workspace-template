---
name: project-management
description: Metodologia di gestione progetti, scomposizione delle attività (Work Breakdown Structure - WBS), stima dell'impegno, costruzione di cronoprogrammi e pianificazione milestone. Usa questa skill quando l'utente deve pianificare un'iniziativa complessa, suddividere un obiettivo in task gestibili o strutturare un piano operativo.
---

# Project Management — Metodologia e Pianificazione Attività

Questa skill fornisce un approccio strutturato per trasformare un obiettivo complesso in un piano di lavoro chiaro, realistico e monitorabile, integrato con il backlog locale del Personal Operating System (POS).

## Fasi Operative

### 1. Definizione dell'Obiettivo e Deliverable (Scope)
- Chiarisci con l'utente il risultato finale atteso (**cosa** deve esistere alla fine del progetto che oggi non esiste).
- Identifica i deliverable tangibili (es. un documento, un software funzionante, una pratica amministrativa chiusa, una stanza ristrutturata).
- Definisci i vincoli noti: scadenze esterne improrogabili, budget economico massimo, risorse umane coinvolte.

### 2. Work Breakdown Structure (WBS)
Scomponi l'iniziativa seguendo la gerarchia del backlog POS:
- **Thread** (`kind: thread`): Il filone macro o macro-obiettivo.
- **Sprint / Milestone** (`kind: sprint`): Fasi temporali o pacchetti di lavoro intermedi verificabili.
- **Task** (`kind: task`): Singole unità di lavoro autonome (idealmente tra 30 minuti e 4 ore ciascuna).

Regole di scomposizione:
- Ogni task deve iniziare con un verbo d'azione (es. "Raccogliere preventivi", "Scrivere bozza", "Configurare DNS").
- Se un task supera la mezza giornata di lavoro stimata o contiene "e" logiche complesse, suddividilo ulteriormente.

### 3. Stima e Individuazione delle Dipendenze
- **Stima dell'impegno**: Utilizza timeboxing realistico tenendo conto dei tempi di attesa terzi (es. risposta fornitore, istruttoria ente).
- **Mappatura delle dipendenze**: Per ciascun task identifica:
  - *Prerequisiti*: cosa deve essere completato prima di poter iniziare questo task?
  - *Bloccanti esterni*: c'è una dipendenza da persone o enti esterni?
  - *Parallelismo*: quali attività possono procedere in parallelo senza interferenze?

### 4. Costruzione del Cronoprogramma
- Costruisci una sequenza temporale ordinata identificando il **cammino critico** (la catena di attività dipendenti che determina la durata minima dell'iniziativa).
- Inserisci cuscinetti di sicurezza (buffer) per imprevisti tipici della vita personale/familiare.
- Fissa le **Milestone di controllo**: date chiave in cui fermarsi a verificare l'avanzamento rispetto al piano.

### 5. Traduzione nei File di Backlog
Crea gli item operativi nella cartella `backlog/items/<id>.md` dell'istanza personale attiva, compilando i metadati YAML:
```yaml
---
id: <area>-<NNN>
title: Titolo chiaro e conciso
area: <nome-area>
parent: <id-thread-o-sprint>
kind: task # thread | sprint | task
status: todo # todo | doing | blocked | done
created: YYYY-MM-DD
due: YYYY-MM-DD # opzionale
tags: [tag1, tag2]
---
```
