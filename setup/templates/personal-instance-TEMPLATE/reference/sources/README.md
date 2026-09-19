# External Sources Catalog (`reference/sources/`)

This directory catalogs external repositories, databases, and third-party codebases mapped as references in your personal system.

## Source Archetypes

1. **Content Sources** (e.g. legal corpora, large documentation sets):
   - Huge repositories containing text or reference data.
   - **Never cloned or bulk-indexed**: fetched on demand via raw URLs or API lookups.
   - Only the relevant takeaways or applicable norms are distilled into `knowledge/`.
2. **Method Sources** (e.g. architectural blueprints, DevOps patterns, reference templates):
   - Repositories whose structure, configuration, or engineering patterns you wish to adopt.
   - Inform the creation of new personal `skills/` or are cloned under `projects/` for local experimentation.

## Relationship with Framework Suggested Sources (Thin Overlay Pattern)

- The shared framework maintains a general catalog of recommended references in `knowledge/sources/` (e.g. `italia-corpus` for Italian legislation, `cetmix-tower` for DevOps patterns, `google-maps-mcp` for geo tools).
- When you decide to activate a suggested source for your personal day-to-day workflow, do **NOT** duplicate technical URLs or paths. Instead, create a **Thin Overlay** in this directory (`reference/sources/<id>.md`):

```yaml
---
id: source-<id>
name: <Name>
source_ref: knowledge/sources/<id>.md
profile: personal
status: active
tags: [tag1, tag2]
areas: [area1, area2]
---

# <Name> — Attivazione Personale (Thin Overlay)

Vedi specifica tecnica completa, endpoint e note d'accesso in `knowledge/sources/<id>.md`.

## Mappatura Operativa sulle Aree di Vita
- **`area1/`**: scopo e uso specifico in questa area
- **`area2/`**: scopo e uso specifico in questa area
```

- This ensures the source descriptor and its personal mapping are indexed by your local semantic engine (`zg`) while keeping disk consumption minimal and technical specs centralized in the framework.

## Template for Custom/Private Sources

If you add a private or third-party source that is not in the framework catalog, use `setup/templates/source-TEMPLATE.md` to document its full specification directly here.


