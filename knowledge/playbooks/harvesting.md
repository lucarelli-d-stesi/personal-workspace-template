# Playbook — end-of-session harvesting

The context builds itself from use. At the end of every working session on
an area, the assistant runs this routine. Everything is **proposed**, the
user confirms; nothing external is pushed without explicit approval.

## 1. Worklog (append-only)

Append a `## YYYY-MM-DD` section to `areas/<area>/worklog/<item>.md` with
**Done:** / **Next:** / **Blocked by:**. Never rewrite past sections.

## 2. STATUS dashboard

Update the item's row in `areas/<area>/STATUS.md` (state, date, next step).
Update the backlog item's `status` in its frontmatter if it changed.

## 3. Digest queue (only if a bridge is configured)

If something *communicable* happened (a milestone, a decision, a deliverable
— not the technical diary), append one digest-style bullet inside the
`<!-- pos:queue -->` block of the worklog. The bridge flushes the queue as a
single note at session end (confirmation-gated) and archives it under
`## Sent (<date>)`.

## 4. Lessons learned (atomic decomposition → `inbox/`)

If the session produced non-obvious, reusable insights (a mistake to avoid,
a pattern that worked, a fact worth keeping):
- **Decompose-first**: Decompose the experience into atomic, single-proposition claims
  rather than composite narrative summaries (e.g. "Tool X requires flag Y when run under environment Z"
  instead of a 3-paragraph story).
- **Propose in `inbox/`**: One short entry or bullet per atomic lesson, tagged with domain/area.
- **Judge before creating**: Flag whether this atomic insight is genuinely new, or refines/supersedes
  an existing note in `knowledge/`.
- **Atomic density**: Keeping each lesson atomic and dense maximizes associative recall with `zg`
  and avoids semantic dilution. Consolidation happens at weekly review, not now.

## 5. Profile signals (propose only, describe never prescribe)

Orientation context describes the world the assistant operates in; it never prescribes or injects
a fictional persona. If the session showed a recurring behavioral signal (e.g. decisions on money
keep getting postponed; the user consistently prefers concrete examples over abstract theory):
- Propose an entry for `profile/observations.md` with `source: observed`, the evidence, and low/medium confidence.
- The user may accept, amend, or refuse. Declared entries (`values`, `style`, `boundaries`) are **never**
  edited by the assistant on its own initiative.

## 6. Climate and emotional resonance (optional → `journal/` or `context.md`)

If the session revealed a meaningful emotional climate, heightened life pressure,
or an unrepeatable life season (e.g. financial strain after an unforeseen expense,
an intensive caregiving phase for a relative, recovery fatigue, or a family milestone),
propose capturing this "temperature":
- Either as a reflective entry in `journal/YYYY-MM-DD.md` (or `YYYY-Www.md`),
- Or by updating the `## Current phase and climate` section of the relevant area's `context.md`.
This ensures that narrative identity and life context are not lost behind cold transactional logs.

