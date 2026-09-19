# Journal (`journal/`)

The **Journal** is an optional cross-area diary for daily logs, personal reflections, and weekly summaries that cut across multiple life streams.

## Naming & Cadence

- Files are named by date: `YYYY-MM-DD.md` (or `YYYY-Www.md` for weekly reviews).
- Unlike area worklogs (which strictly track single initiatives with factual tasks), the journal captures the emotional "temperature", personal reflections, cross-cutting priorities, and narrative identity shaping that specific life season.

## Entry Format (`YYYY-MM-DD.md`)

```markdown
# YYYY-MM-DD — Diario di bordo / Journal

## Baricentro del periodo
<!-- Where is the center of gravity right now? (e.g. Family focus, work transition, legal deadlines, health) -->
- 

## Clima percepito e risonanza
<!-- Perceived pressure, energy levels, emotional or economic climate (e.g. post-holiday budget tightening, filial care) -->
- 

## Riflessioni e connessioni trasversali
<!-- Notes on how events intersect across areas, personal thoughts, or unrepeatable moments -->
- 
```

## Harvesting Integration

During weekly reviews or milestone completions (`knowledge/playbooks/harvesting.md`), the assistant harvests climate observations and emotional resonance from recent journal entries to update the `## Current phase and climate` section of affected areas in `areas/<area>/context.md`.


