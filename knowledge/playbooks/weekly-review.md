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
decides.

## 4. Backlog hygiene and planning

- Flag stale items (no worklog activity in N weeks): still relevant?
  Reschedule, downgrade or close (`dropped` is a legitimate state).
- Review each area's STATUS against reality; if a bridge is configured,
  pull first so the mirror is fresh, and state the last-sync date when
  reporting.
- Plan the next sprint: pick the few items that matter, per area.
