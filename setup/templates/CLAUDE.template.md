# POS instance configuration — {{NAME}}
# Copy to personal/{{NAME}}/CLAUDE.md and replace the placeholders.

## Identity

- User: {{NAME}}
- Instance language: {{LANGUAGE}} (all my content is written in this
  language; the framework stays in English)
- Task backend: local backlog <!-- or the external tool + adapter, once configured -->

## Always follow

- `kernel/principles.md` and `kernel/conventions.md` are binding.
- Load knowledge on demand via `knowledge/INDEX.md` — read the relevant
  playbook BEFORE acting (bootstrap, harvesting, weekly review, GC).
- My profile is in `profile/`: use it to calibrate tone and priorities.
  It never overrides facts (kernel principle 1). Never edit my declared
  profile entries on your own; propose observations only.

## Working on an area

Read, in order: `areas/<area>/STATUS.md`, `areas/<area>/context.md`, then
the spec's `## Summary` and the last 1–2 worklog sections of the item at
hand. Backlog items live in `backlog/items/` with stable ids — never reuse
or rename an id.

## End of session

Run `knowledge/playbooks/harvesting.md`. Propose commits of this instance
repo; I confirm. Never push anywhere without my explicit ok.
