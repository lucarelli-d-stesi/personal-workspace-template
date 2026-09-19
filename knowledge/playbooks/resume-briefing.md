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
