# Knowledge INDEX — on-demand loading map

> Always loaded. The files listed here are NOT: read them (Read tool) when
> the task touches them. Do not propose actions without reading the relevant
> playbook/reference first.

## Playbooks (read BEFORE acting)

| Operation | File |
|---|---|
| End-of-session routine (worklog, STATUS, lessons, profile signals) | `playbooks/harvesting.md` |
| Weekly consolidation (inbox → knowledge, GC, profile challenge, planning) | `playbooks/weekly-review.md` |
| Compacting oversized knowledge files | `playbooks/knowledge-gc.md` |

## Generic Reference

`reference/` starts empty by design: it grows from harvested general lessons, per
domain (e.g. `reference/finance.md`, `reference/home.md`). Add a row here
whenever a new reference file is created — this INDEX is the routing map.

| Topic | File |
|---|---|
| Local environment: scenarios (vm/wsl/mac/linux), multi-machine setup, local profiles | `reference/local-environment.md` |
| _(other domain references grow from use)_ | |

## Bridges

| Topic | File |
|---|---|
| Adapter contract for external task systems | `../bridges/CONTRACT.md` |

## Instance layout

The per-person structure (areas, backlog, profile, inbox, personal skills and sources) is defined in
`kernel/conventions.md`. Templates live in `setup/templates/`.
