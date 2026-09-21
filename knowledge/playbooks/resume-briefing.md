# Playbook — session resume briefing

Counters the startup friction and amnesia when returning to an area, backlog item,
or project after an interruption or at the start of a session.

**Trigger:**
- User switches focus to an existing area or backlog item.
- User explicitly asks: *"dove eravamo rimasti?"*, *"riprendiamo da qui"*, *"aggiornami sullo stato"*, *"what's next on X?"*.
- Beginning of a deep work session on an open activity.

---

## 1. Grounding Protocol (Inspection Before Action)

Before proposing any edits or executing commands, the assistant rapidly reads:
1. **Target Activity Worklog**: `areas/<area>/worklog/<item>.md` (the latest `## YYYY-MM-DD` entry).
2. **Area Dashboard & Status**: `areas/<area>/STATUS.md` (the item's state and machine sync).
3. **Operational Context & Climate**: `areas/<area>/context.md` (`## Current phase and climate` if present).
4. **Architectural Spec**: `areas/<area>/specs/<item>.md` (only the `## Summary` block).

---

## 2. Briefing Format (The 4 Pillars)

The assistant presents a concise, structured briefing (max 10-15 lines) directly in dialogue:

```markdown
### 🧭 Resume Briefing — [<Item-ID>] <Title>

1. **Obiettivo & Fase Attuale**:
   [Sintesi in una riga dello scopo e della fase operativa da context.md o spec]

2. **Dove eravamo rimasti (Ultimo Avanzamento)**:
   - **Fatto:** [Cosa è stato completato e verificato nell'ultima sessione]
   - **Pianificato:** [L'ultimo Next: registrato nel worklog]

3. **Blocchi & Attenzioni Aperte**:
   - [Eventuali Blocked by:, decisioni in sospeso o verifiche non ancora eseguite (oppure "Nessun blocco")]

4. **Proposta Prossimo Passo Immediato**:
   👉 [Azione concreta e specifica da eseguire subito per riavviare il lavoro]
```

---

## 3. Rules of Engagement

1. **Facts Over Assumptions**: Ground the briefing exclusively in documented worklog and status entries; do not invent or extrapolate unlogged progress (*Kernel Principle 1: Facts beat opinions*).
2. **Propose, Don't Leap**: The briefing concludes with a concrete proposal for the next step. Wait for the user's confirmation before modifying files or executing state-altering actions (*Kernel Principle 2: Propose, don't impose*).
3. **Keep it Crisp**: A resume briefing is a launchpad, not an exhaustive historical chronicle. Never dump past worklog entries beyond the last session.

---

## 4. Intra-Session Dynamic Pivoting & Dialectical Re-entry (Il Segnalibro Dialettico)

Mentre le sezioni precedenti disciplinano il rientro **inter-sessione** (giorni dopo o tra macchine diverse), questo protocollo governa le **virate improvvise e le divagazioni all'interno della stessa conversazione**.

### 1. Il Freeze al momento del Pivot (PUSH)
Quando l'utente devia verso un altro argomento (*"aspetta, prima di continuare volevo chiederti..."*):
1. L'agente non abbandona il contesto alla cieca: fissa mentalmente o dichiara un **Segnalibro Cognitivo**:
   - **Punto di Sospensione**: file, spec o task in lavorazione.
   - **Stato Validato**: l'ultima modifica o decisione approvata.
   - **Cursore Aperto**: il dubbio, test o comando in canna.
2. Esegue il pivot sul nuovo tema interrogando eventualmente `zg` per richiamare note storiche pertinenti.

### 2. Valutazione della Divagazione (Ortogonale vs Risonante)
Durante la deviazione, l'agente osserva la natura del nuovo tema:
- **Divagazione Ortogonale (Interruzione Logistica)**:
  - Temi slegati (check di uno stato, logistica, verifica esterna).
  - Al rientro: **Ripristino Pulito**. L'agente de-biasizza la memoria, ignora il rumore intermedio e riapre il segnalibro esattamente al millimetro in cui era rimasto.
- **Divagazione Risonante (Fecondazione Incrociata / *Gan-Ying*)**:
  - Riflessioni metodologiche, vincoli di licenza, chiarimenti di confini, principi architetturali.
  - Spesso l'utente compie il salto laterale perché la sua mente associativa ha fiutato un collegamento che mancava al task principale.
  - Al rientro: **Merge Dialettico**. L'agente non fa tabula rasa della divagazione: estrae l'insight emerso e lo usa per arricchire il task originario (*Tesi → Antitesi/Deviazione → Sintesi*).

### 3. Il Protocollo di Riaggancio Dialettico (POP & Synthesis)
Al rientro (*"ok, torniamo a prima"*, *"dove eravamo?"* o a chiusura della deviazione), l'agente formula il riaggancio in tre passi:
```markdown
1. RIPRESA DEL SEGNALIBRO:
   "Riapro il segnalibro su [<Item/File>]: eravamo fermi al punto X."
2. PONTE DI RISONANZA (se divagazione risonante):
   "Nel frattempo, affrontando [Tema B], è emerso questo principio/vincolo: [Insight Y]."
3. PROPOSTA DI SINTESI ARRICCHITA:
   "Questo trasforma la nostra prospettiva su A: invece di procedere come previsto in origine,
   propongo di integrare [Insight Y] in questo modo: [Azione concreta]. Procedo?"
```
