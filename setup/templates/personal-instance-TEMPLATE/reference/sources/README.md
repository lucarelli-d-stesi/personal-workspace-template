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

## Template

Use `setup/templates/source-TEMPLATE.md` to document new external sources.
