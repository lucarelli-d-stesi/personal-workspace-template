# Playbook — weekly review

The consolidation loop that keeps the POS lean, current and honest. Run it
weekly (or when the inbox piles up). Order matters.

## 1. Inbox consolidation

Go through the instance `inbox/`. For each staged lesson decide:

- **Personal specific** → merge into the instance's `knowledge/<topic>.md`.
- **Domain-agnostic, framework-worthy** → candidate for the public
  framework's `knowledge/reference/` (strip *all* personal data first; the
  user reviews before anything leaves the instance).
- **Stale or wrong** → drop it, say why.

Deduplicate against what already exists. Empty the inbox: consolidated
entries are removed, not archived.

## 2. Knowledge size check

Check instance and framework knowledge files against the 400-line budget
(`kernel/conventions.md`). Files over budget or missing their `## Index`
block → run `knowledge-gc.md`.

## 3. Profile challenge (anti-echo-chamber)

Select profile entries with high `confidence` and `last_challenged` older
than ~90 days (or empty). For each, ask openly: is this still true? Does
`observations.md` hold contrary evidence? Outcomes:

- **Confirmed** → bump `last_challenged`.
- **Weakened** → lower `confidence`, note the evidence.
- **Contradicted by facts** → the fact wins (kernel principle 1): amend or
  retire the entry with the user.

Also review `observations.md`: recurring observations with accumulating
evidence may be *proposed* for promotion to a declared entry — the user
decides. Stale observations without recent evidence are whittled to archive
via `knowledge-gc.md`.

## 4. Reality check & dialectic (anti-sycophancy)

Examine recent updates across `STATUS.md`, `context.md`, and recently completed backlog items.
LLMs naturally suffer from *validation gravity* (shared enthusiasm and mutual escalation with the user).
Apply an adversarial reality check to safeguard truth over optimism (*Kernel Principle 1: Facts beat opinions*):

- **Milestone & Done verification**: Is an item marked `done` supported by tangible, verified evidence
  (code executed and tested, document reviewed, output confirmed)? If it was only partially implemented
  or remains an untested prototype, keep it accurately labeled as `in-progress` or `testing`.
- **Mythology & claim deflation**: Check whether recent narrative entries in `context.md` or worklogs
  inflated an experimental script or preliminary idea into a "breakthrough" or "complete architecture".
  Deflate claims to their strict factual baseline.
- **Advocate vs. Challenger lens**: For high-stakes decisions or major architectural choices made during
  the week, articulate the skeptic's counter-argument before ratifying them.

## 5. Backlog hygiene and planning

- Flag stale items (no worklog activity in N weeks): still relevant?
  Reschedule, downgrade or close (`dropped` is a legitimate state).
- Review each area's STATUS against reality; if a bridge is configured,
  pull first so the mirror is fresh, and state the last-sync date when
  reporting.
- Plan the next sprint: pick the few items that matter, per area.
