# Playbook — knowledge GC (compaction)

Counters the monotonic growth of an append-mostly knowledge base.
**Trigger: size, not calendar** — a file over the 400-line budget or missing
its `## Index` block (checked during weekly review).

For each flagged file:

1. **Merge duplicates** — recurring-error entries and near-identical lessons
   become one canonical entry.
2. **Promote stable lessons** — what has proven itself repeatedly moves from
   "lessons/errors" sections into the file's canonical patterns.
3. **Retire the obsolete** — content tied to tools or situations no longer in
   use moves to a `legacy/` subfolder (it stays findable, not loaded).
4. **Index** — add or refresh the `## Index` block at the top so targeted
   reads (grep the header, then read the section) stay possible.
5. **Split if still too big** — one sub-topic per file, updating the routing
   rows in `knowledge/INDEX.md` (or the instance's own index).

What GC is **not**: deletion of useful content to make room. Git keeps
history, but the knowledge itself must remain complete — GC compacts and
reorders, it never impoverishes.

---

## Orientation & Profile Whittling

The always-loaded orientation layer (`profile/`, `areas/<area>/context.md`) must stay lean,
load-bearing, and razor-sharp (*"the few things that make the room the room"*). It describes
the real world as it is, never an inflated persona.

During GC or weekly review:

1. **Active observations budget**: Keep active items in `profile/observations.md` bounded (target: under ~30 entries).
2. **Whittling stale observations**:
   - Rank observations along *Recency × Frequency × Relevance*.
   - Observations older than 60–90 days without recent reinforcing evidence and not yet promoted to declared profile files (`values.md`, `style.md`, `boundaries.md`) are deactivated.
   - Move deactivated observations to `profile/archive/observations-archive.md`.
   - Never delete: archival preserves the audit lineage in Git while keeping the active context uncluttered and preventing token bloat.
3. **Context phase tightening**: Ensure `context.md` in each area reflects the *current phase* and operational climate, not past worklog entries. Completed phases belong in worklog history, not in the active orientation block.
