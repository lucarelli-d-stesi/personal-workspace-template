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

## Suggested External Sources (Fonti Suggerite)

Catalogo di fonti e repository esterni di riferimento raccomandati a livello di framework. L'LLM le propone proattivamente all'utente quando emergono necessità o domande pertinenti, senza richiederne la clonazione integrale in locale.

| Topic / Dominio | Fonte | File / Riferimento | Archetipo / Accesso |
|---|---|---|---|
| Panoramica & regole di suggerimento | Catalogo Fonti Suggerite | `sources/README.md` | Policy & lifecycle |
| Legislazione italiana, PA, Terzo Settore (Normattiva) | Italia Corpus (`ahmeabd/italia-corpus`) | `sources/italia-corpus.md` | Content (`remote-on-demand`) |
| Blueprint DevOps Odoo, Docker, Traefik | Cetmix Tower (`cetmix/cetmix-tower`) | `sources/cetmix-tower.md` | Method (`local-clone` / blueprint) |
| Google Workspace (Gmail, Calendar, Drive via MCP) | Google Workspace MCP (`taylorwilsdon/google_workspace_mcp`) | `sources/google-workspace-mcp.md` | Method (`uvx workspace-mcp`) |
| Registro elettronico scolastico, compiti, circolari | Spaggiari ClasseViva (`Lioydiano/Classeviva`) | `sources/classeviva.md` | Method (`python3 setup/classeviva-cli.py`) |


## Instance layout

The per-person structure (areas, backlog, profile, inbox, personal skills and sources) is defined in
`kernel/conventions.md`. Templates live in `setup/templates/`.

