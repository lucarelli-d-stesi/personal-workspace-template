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
├── projects/               # [GITIGNORED] functional project folders & independent git repos
├── inbox/                  # staged lessons learned, consolidated at weekly review
└── journal/                # optional cross-area diary
```

## Functional project folders (`projects/`)

When an activity involves creating, modifying, or cloning software tools, scripts, or external code:
- The code lives in `<instance_dir>/projects/<project-name>/` (or as a symlink pointing to a local directory such as `~/repos/<project-name>`).
- Each folder under `projects/` is an **independent Git repository** with its own `.git`, remote origin, and lifecycle.
- `projects/*/` is strictly `.gitignore`d in the personal instance repo: build artifacts, `node_modules/`, virtual environments, and source code must never bloat or conflict with the personal notes repository.
- The POS instance maintains the management and context plane:
  - The backlog item (`backlog/items/<id>.md`) links to the directory via `project_dir: projects/<project-name>`.
  - The architectural spec (`areas/<area>/specs/<id>.md`) documents requirements, designs, and decisions.
  - The worklog (`areas/<area>/worklog/<id>.md`) tracks daily implementation steps.
  - General lessons learned and reusable patterns are harvested into `knowledge/` or personal `skills/`.

## External sources (suggested and personal)

External repositories, legal corpora, and architectural blueprints are managed as references rather than bloated local copies:
- **Framework Suggested Sources (`knowledge/sources/<id>.md`)**:
  Curated reference repositories provided by the framework with `profile: suggested`. The LLM proactively suggests them when conversations or tasks match declared `triggers` or domain tags, without requiring upfront cloning.
- **Instance Personal Sources (`<instance_dir>/reference/sources/<id>.md`)**:
  Adopted or custom sources configured for the individual with `profile: personal` and `status: active`.
  - **Thin Overlay Pattern**: When activating a source already present in the framework catalog (`knowledge/sources/<id>.md`), the instance file acts as a thin overlay specifying `source_ref: knowledge/sources/<id>.md` and local area mappings (`areas: [...]`). Technical metadata, collection paths, and fetch rules remain centralized in the framework (DRY).
  - The thin overlay is indexed by `zg`, enabling associative recall while avoiding content redundancy.
- **Access Archetypes**:
  - `content`: Massive document or normative collections (e.g. `italia-corpus`). Accessed via `remote-on-demand` raw URLs for specific articles/files; never cloned in bulk or fully indexed. Extracted conclusions are harvested into `knowledge/`.
  - `method`: Architectural blueprints and DevOps templates (e.g. `cetmix-tower`). Consulted as engineering patterns or cloned on-demand into `projects/<project-name>/` as an independent repository.

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

## Resume briefings

When resuming work on an area or backlog item (after an interruption or at session start,
or when the user asks *"dove eravamo rimasti?"*), the assistant prepares a concise **Resume Briefing**
before proposing actions:
1. **Objective & Phase**: The purpose and current operational phase (`context.md` or spec `## Summary`).
2. **Grounding**: The latest `**Done:**` and `**Next:**` from `areas/<area>/worklog/<item>.md`.
3. **Open Blockers**: Any active `**Blocked by:**` or pending decisions.
4. **Immediate Next Action**: A single, crisp proposed action to unpause work.
See `knowledge/playbooks/resume-briefing.md`.

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

## Epistemic graph relationships

Knowledge and context notes declare relationships via YAML frontmatter to prevent cultural echo chambers (Kernel Principle 7) and balance linear execution with ecological resilience:
- **Linear & Causal**: `depends_on`, `supports`, `supersedes`, `conflicts_with`.
- **Correlative & Process**: `resonates_with` (cross-domain resonance / *Gan-Ying*), `polar_balance` (complementary tension / *Yin-Yang*), `nourishes` (generative flow / *Wuxing Sheng*), `moderates` (homeostatic restraint / *Wuxing Ke*).
Detailed semantics in `knowledge/playbooks/epistemic-resonance.md`; audit with `setup/graph.py`.

## Size budget

Knowledge files aim to stay under **400 lines**. Larger files must open with
a `## Index` block enabling targeted reads; past the budget they are
candidates for GC (`knowledge/playbooks/knowledge-gc.md`).

## Multi-user readiness (dormant)

Instances are per-person by construction (a profile belongs to one person).
An area's `context.md` may declare `shared: true` for a future family-shared
setup; until then it has no effect.
