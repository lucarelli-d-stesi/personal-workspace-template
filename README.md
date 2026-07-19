# Personal Workspace — a Personal Operating System (POS)

A file-based **Personal Operating System**: a stable cognitive architecture that
lets an LLM assistant (Claude Code or similar) work alongside you on your
personal and family life — projects, daily activities, hobbies, learning,
household planning, personal finance — with continuity, method and memory,
instead of one-off chat sessions.

The idea follows the shift from chatbots to *personal operating systems*:
what matters is not the generative model but the architecture around it —
a **kernel** of non-negotiable principles, an **orchestrator** of procedures,
a **selective memory** that stays lean and precise, and an **emotional
backbone** that regulates tone and priorities without ever overriding facts.
The lineage is the classic one of augmented intelligence (Bush's memex,
Licklider's man-computer symbiosis, Engelbart's intellect augmentation):
the human decides, the system prepares, remembers and proposes.

## Architecture: two repositories

| Repo | Visibility | Contains |
|---|---|---|
| **Framework** (this repo) | public | kernel, conventions, templates, playbooks, update channel. Zero personal data — ever. |
| **Instance** (any repo you choose) | private, one per person | your areas, backlog, worklog, knowledge, profile. Name and structure are yours — setup asks you to indicate it and mounts it inside the framework under `personal/` (gitignored). |

Personal data cannot physically end up in the public repo: the two working
trees are different repositories. Framework improvements reach instances
through reviewed migration scripts (`setup/updates/`), never through merges.

## Core mechanisms

- **Areas** (`areas/<area>/` in your instance) — the unit of work: one folder
  per life area (family, home, finance, health, hobbies, learning, projects)
  with `STATUS.md` (dashboard), `context.md` (identity), `specs/`
  (requirements) and `worklog/` (append-only diary).
- **Local-first backlog** — activities are plain files with stable ids and a
  free thread → sprint → task hierarchy, born ready for a future external
  project-management tool (see `bridges/CONTRACT.md`): when you adopt one,
  you plug in an adapter — no data migration.
- **Lazy knowledge** — only `kernel/` and the knowledge INDEX are always
  loaded; everything else is read on demand and kept within size budgets
  (see `knowledge/playbooks/knowledge-gc.md`).
- **Harvesting** — the context builds itself from use: a bootstrap interview
  seeds it, an end-of-session routine feeds it, a weekly review consolidates
  and compacts it.
- **Emotional backbone** (`profile/` in your instance) — your values, style
  and boundaries, with explicit provenance (declared vs observed) and
  confidence. It modulates *how* the assistant works — tone, priorities,
  when to push back — never *what is true*: a verifiable fact always
  outranks any opinion, including yours. Entries are periodically
  challenged so the profile stays a hypothesis, not a cage.

## Quick start

Follow [ONBOARDING.md](ONBOARDING.md). In short: clone this repo, create your
private instance repo, seed it from the templates, then run the bootstrap
interview (`knowledge/playbooks/bootstrap-interview.md`) with your assistant.

## Status

Early stage. Roadmap: bootstrap scripts and skills, then the first bridge
adapter (Odoo). The framework language is English; your instance uses
whatever language you prefer.

## License

[MIT](LICENSE)
