# Personal Operating System (POS) — Architectural Roadmap

This document outlines the strategic directions and upcoming evolutionary milestones for the POS framework. These initiatives serve as the foundation for future development sessions, ensuring continuous cognitive enhancement while strictly adhering to the core principles: **local-first sovereignty, human-in-the-loop governance, zero-knowledge privacy, and facts over opinions.**

---

## Strategic Track 1: Typed Knowledge Relationships (Epistemic Graph)

### The Vision
Flat vector similarity searches (such as *"find notes semantically close to X"*) provide associative recall, but they cannot distinguish between contradictory decisions, superseded requirements, or causal dependencies. As a personal knowledge base compounds over months and years, the system must understand the **epistemic and genealogical relationships** between concepts.

### Planned Enhancements
1. **Standardized Relational Frontmatter**:
   Formally introduce typed relational fields in Markdown frontmatter across `specs/`, `backlog/items/`, and `knowledge/`:
   - `supersedes: [<id>]`: Identifies that this decision, architectural spec, or guideline replaces an older one.
   - `conflicts_with: [<id>]` / `contradicts: [<id>]`: Flags an explicit conflict or invalidation of an earlier assumption.
   - `depends_on: [<id>]`: Declares prerequisites (e.g., technical requirements, preliminary approvals, external APIs).
   - `supports: [<id>]`: Links empirical evidence, citations, test logs, or legal articles that validate a given claim.
2. **Relational Graph Traversal in Tooling**:
   - Enhance the `zg` (vector grep) and status scripts with relational flags (e.g. `zg graph <item-id>`) to display lineage trees (ancestors, descendants, dependencies).
   - Assistant protocol: when an agent accesses a spec or note marked with `supersedes:`, it must prioritize the superseding document and avoid resurrecting obsolete conventions.
3. **Contradiction & Integrity Linter**:
   - A lightweight diagnostic check (integrated into `setup/status.sh` or `weekly-review`) that detects dangling dependencies (`depends_on` pointing to dropped items) or unresolved contradictions.

---

## Strategic Track 2: Active Self-Maintaining Memory (Evo-Memory Pattern)

### The Vision
Inspired by research in continuous memory systems and Google DeepMind's *Evo-Memory* paper, long-term cognitive effectiveness depends not on passive accumulation, but on the agent's ability to **actively refine, prune, consolidate, and defragment** knowledge over time. The assistant must evolve from a passive log-writer into an active curator of signal over noise.

### Planned Enhancements
1. **Automated Compaction & Consolidation Loops**:
   - **Worklog Compaction**: Once a backlog item is verified and closed, semi-automate the extraction of enduring lessons into `knowledge/` while compacting verbose daily logs into a permanent summary.
   - **Semantic Clustering**: Routine scripts that scan `knowledge/` and `inbox/` for near-duplicate insights, proposing unified canonical entries during the weekly review.
2. **Dynamic Staleness & Reference Verification**:
   - Add a staleness checker that inspects paths, URLs, and code symbols cited in `reference/` and `knowledge/`. If referenced files or commands in `projects/` no longer exist, the note is flagged for re-validation.
3. **Active Whittling for Profile Observations**:
   - Implement the whittling criteria established in `knowledge/playbooks/knowledge-gc.md`:
   - A background or review helper that ranks entries in `profile/observations.md` by *Recency × Frequency × Relevance*, proposing the archival of inactive observations older than 60–90 days into `profile/archive/observations-archive.md`.
4. **Dialectic Review Assistant**:
   - Provide an interactive slash-command or review mode that guides the user through the **Reality Check Dialectic** (`weekly-review.md`), deliberately challenging completed tasks and detecting milestone inflation or shared sycophancy before confirming milestones.

---

## Implementation Horizons

| Milestone | Scope | Deliverables | Status |
| :--- | :--- | :--- | :--- |
| **v1.1 (Current)** | Cognitive Playbooks & Ecosystem Marketplace | Dialectic reality check, atomic harvesting, whittling playbook, session resume briefing, ecosystem marketplace (Docling, Scrapling, Memory Layer). | ✅ Complete |
| **v1.2 (Next Sessions)** | Relational Epistemic Graph | Typed frontmatter conventions (`supersedes`, `depends_on`), graph exploration helper in `zg`/CLI, integrity linting. | 🎯 Planned |
| **v1.3 (Future)** | Evo-Memory Automation Suite | Worklog compactor, reference staleness verifier, semi-automated whittling assistant, interactive weekly review CLI. | 📋 Backlog |
