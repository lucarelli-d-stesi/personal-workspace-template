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

## 4. Lessons learned (→ `inbox/`)

If the session produced a non-obvious, reusable insight (a mistake to avoid,
a pattern that worked, a fact worth keeping), propose a short entry in the
instance `inbox/` — one file or one appended bullet per lesson. Consolidation
happens at weekly review, not now.

## 5. Profile signals (propose only, never auto-write)

If the session showed a recurring behavioral signal (e.g. decisions on money
keep getting postponed; the user consistently prefers examples over theory),
propose an entry for `profile/observations.md` with `source: observed`, the
evidence, and low/medium confidence. The user may accept, amend or refuse.
Declared entries (`values`, `style`, `boundaries`) are **never** edited by
the assistant on its own initiative.
