# Kernel — conventions

> Always loaded. Formats and rules shared by every instance.

## Language

- Framework (this repo): **English**.
- Instance content (areas, specs, worklogs, profile): **the user's language**,
  declared in the instance `CLAUDE.md`.

## Files and naming

- Everything is Markdown with optional YAML frontmatter. Kebab-case
  filenames, ISO dates (`YYYY-MM-DD`) everywhere.
- The instance repo is the user's own: any name, possibly pre-existing.
  Its local mount point is registered in `.pos-config` at the framework
  root (`instance_dir=...`), never derived from a naming convention.
- Instance layout (one folder per life area) — the canonical structure the
  playbooks rely on; grafted alongside existing content, never overwriting it:

```
<instance_dir>/             # private instance repo, user-chosen name
├── CLAUDE.md               # generated from setup/templates/CLAUDE.template.md
├── profile/                # emotional backbone: values, style, boundaries, observations
├── machines/<id>.md        # per-machine profile: hardware specs, installed tools, scenario
├── skills/                 # individual domain skills (e.g. specialized dev, study, analysis)
├── reference/sources/      # catalog of external repos and sources (content & method)
├── knowledge/              # personal distilled reference, grows from use
├── areas/<area>/
│   ├── STATUS.md           # dashboard: one row per activity + machine-owned sync block
│   ├── context.md          # identity of the area (frontmatter + free sections)
│   ├── specs/<item>.md     # requirements, Summary-first
│   └── worklog/<item>.md   # append-only diary
├── backlog/items/<id>.md   # local-first activities (see backlog-item template)
├── inbox/                  # staged lessons learned, consolidated at weekly review
└── journal/                # optional cross-area diary
```


## Stable ids

Backlog items use `<area>-<NNN>` (e.g. `home-012`): assigned once, **never
reused**, never renamed. `external_ref` stays empty until a bridge adapter
claims the item (`<adapter>:<model>:<id>`, e.g. `odoo:task:1234`).

## Summary-first documents

Every spec starts with a `## Summary` section (2–5 lines) that must stand on
its own. Readers (human or LLM) read the summary first and open detail
sections only when the task touches them.

## Append-only worklogs

One `## YYYY-MM-DD` section per session, with bold sub-entries:
**Done:**, **Next:**, **Blocked by:**. Never rewrite past sections.

## Machine-owned regions (sentinel markers)

Machine-written content inside human-edited files is delimited by HTML
comment pairs, namespaced `pos`:

```
<!-- pos:<tag> (auto-generated — do not edit inside) -->
...
<!-- /pos:<tag> -->
```

Reserved tags: `pos:sync` (external mirror in STATUS.md), `pos:queue`
(communicable digest queue in worklogs), `pos:mapping` (external-system
mapping in context.md). Writers must read before writing, be idempotent, and
never touch anything outside their markers.

## Size budget

Knowledge files aim to stay under **400 lines**. Larger files must open with
a `## Index` block enabling targeted reads; past the budget they are
candidates for GC (`knowledge/playbooks/knowledge-gc.md`).

## Multi-user readiness (dormant)

Instances are per-person by construction (a profile belongs to one person).
An area's `context.md` may declare `shared: true` for a future family-shared
setup; until then it has no effect.
