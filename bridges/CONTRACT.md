# Bridge contract — external task-system adapters

An adapter connects the instance's local-first backlog to an external
project/activity-management system (a personal Odoo, Todoist, Notion, a
CalDAV calendar…). The backlog is designed so that adopting an adapter later
requires **no data migration**: items already carry stable ids, hierarchy
and an empty `external_ref`.

## Ownership: single writer per field

Bidirectional sync without conflicts requires that every field has exactly
one writing side:

| Surface | Writer | Notes |
|---|---|---|
| Item existence, title, hierarchy (`parent`) | **workspace** | pushed to the external system, gated |
| Item `status` | **workspace** | pushed as the external state, gated |
| Worklog digest (queue flush) | **workspace** | posted as one note/comment, gated |
| External stage/phase, deadlines, assignees | **external system** | pulled into the read-only mirror |
| `external_ref`, mapping block | **adapter** | written once at claim/mapping time |

## Operations

Read (free, no confirmation):
- `map` — resolve the external project/container for an area; write the
  `pos:mapping` block in the area's `context.md`.
- `pull` — fetch the user's items; refresh the `pos:sync` mirror block in
  `STATUS.md`, stamped with the sync date. When reporting status, the
  assistant must state that date and flag divergences between the
  hand-written table and the mirror.
- `show` / `overview` — inspect items, aggregate workload.

Write (each invocation gated by an explicit `--yes` and user confirmation):
- `push-items` — create/update external items from backlog items; fill
  `external_ref`.
- `set-status` — propagate a local status change.
- `push-worklog --from-queue` — flush the worklog's `pos:queue` block as a
  single note, then empty it and archive the lines under `## Sent (<date>)`
  in the same file.

## Adapter rules

- Idempotent, read-before-write; touch only the content inside `pos:*`
  sentinel markers, never the surrounding human-edited text.
- Credentials live outside git, per user (e.g. `~/.config/pos/<adapter>.env`,
  mode 600). Never in the instance repo.
- `external_ref` format: `<adapter>:<model>:<id>` (e.g. `odoo:task:1234`).
- An adapter must degrade gracefully: with no credentials configured, reads
  report "no bridge configured" and the local backlog remains authoritative.

## Planned adapters

- `local/` — the default no-op backend: the backlog itself, no sync.
- `odoo/` — personal Odoo (project.task via XML-RPC): the first concrete
  adapter on the roadmap.
