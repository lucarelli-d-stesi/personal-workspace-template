# Personal Operating System (POS) — Architectural Roadmap

This document outlines the strategic directions and upcoming evolutionary milestones for the POS framework. These initiatives serve as the foundation for future development sessions, ensuring continuous cognitive enhancement while strictly adhering to the core principles: **local-first sovereignty, human-in-the-loop governance, zero-knowledge privacy, and facts over opinions.**

---

## Strategic Track 1: Cognitive Foundations, Dialectics & Ecosystem Marketplace

### The Vision
A cognitive operating system requires both disciplined methodology for the human-AI interaction loop and an extensible ecosystem of external capabilities. Rather than building monolithic integrations, the system decouples universal cognitive routines from modular external tools.

### Key Capabilities & Deliverables
1. **Core Dialectic Playbooks**:
   - **Reality Check Dialectic** (`weekly-review.md`): Combating milestone inflation and sycophancy with constructive adversarial review.
   - **Atomic Harvesting** (`harvesting.md`): Post-session synthesis translating ephemeral worklogs into durable knowledge notes.
   - **Orientation Whittling** (`knowledge-gc.md`): Systematic pruning of outdated assumptions.
   - **Session Resume Briefing** (`session-resume.md`): Rapid cognitive bootstrapping across session switches.
2. **Ecosystem Marketplace**:
   - Decentralized tool showcases (`knowledge/sources/`, `marketplace/`) and thin overlays (`reference/sources/`).
   - Integrated connectors: Docling, Scrapling, Memory Layer, Google Workspace, ClasseViva, etc.

---

## Strategic Track 2: Relational Epistemic Graph (Linear & Causal Epistemology)

### The Vision
Flat vector similarity searches provide associative recall, but cannot distinguish between contradictory decisions, superseded requirements, or causal prerequisites. The system must understand the **formal genealogical and logical relationships** between concepts.

### Key Capabilities & Deliverables
1. **Standardized Causal Frontmatter**:
   - `supersedes: [<id>]`: Flags that a decision, spec, or convention replaces an older one.
   - `conflicts_with: [<id>]`: Flags an explicit conflict or invalidation of an earlier assumption.
   - `depends_on: [<id>]`: Declares prerequisites (technical, organizational, external).
   - `supports: [<id>]`: Links empirical evidence, citations, test logs, or legal articles validating a claim.
2. **Deterministic Graph Traversal Tooling**:
   - Command-line graph validator (`python3 setup/graph.py check`) detecting dangling references and broken links.
   - Mermaid visualization export (`python3 setup/graph.py mermaid`) rendering formal dependency diagrams.

---

## Strategic Track 3: Epistemic Resonance & Correlative Knowledge Networks (Process Epistemology)

### The Vision
Human thought, strategic planning, and complex life domains rarely follow pure linear causality. Grounded in classical Eastern epistemology (Daoism, *Gan-Ying* / 感應 sympathetic resonance, and *Wuxing* / 五行 ecological flow), the framework models **correlative resonances, dynamic polar balances, and organic regulatory cycles**.

### Key Capabilities & Deliverables
1. **Correlative & Polar Frontmatter**:
   - `resonates_with: [<id>]`: *Gan-Ying* (感應) cross-domain sympathetic resonance connecting disparate areas (e.g. governance patterns echoing family routines).
   - `polar_balance: [<id>]`: *Yin-Yang* (陰陽) dynamic complementary polarities holding generative tensions (e.g. rigor vs. organic discovery, deep focus vs. breadth).
   - `nourishes: [<id>]`: *Wuxing Sheng* (生) generative flow where one domain or insight sustains another.
   - `moderates: [<id>]`: *Wuxing Ke* (剋) homeostatic balance and regulatory restraint preventing runaway imbalances.
2. **Ecological Lineage & Topology Analytics**:
   - Multi-relational lineage tracing (`python3 setup/graph.py lineage <slug>`) displaying the complete web of causes, polarities, nourishment, and regulations.
   - Topology balance inspection (`python3 setup/graph.py stats`) auditing the health and equilibrium between linear logic and correlative resonance.
   - Methodological playbook: [`knowledge/playbooks/epistemic-resonance.md`](knowledge/playbooks/epistemic-resonance.md).

---

## Strategic Track 4: Active Self-Maintaining Memory & Episodic Bedrock (Evo-Memory Suite)

### The Vision
Inspired by continuous memory research and Google DeepMind's *Evo-Memory* paper, long-term cognitive effectiveness depends not on passive accumulation, but on the agent's ability to **actively refine, prune, consolidate, and defragment** knowledge over time. Crucially, the system respects human biographical memory: distinguishing ephemeral operational noise from **latent episodic bedrock** that shapes enduring identity.

### Key Capabilities & Deliverables
1. **Episodic Bedrock & Latent Anchor Safeguards**:
   - Explicit protection for watershed moments, formative crises, and identitarian turning points (`episodic_anchor`, `salience: bedrock`).
   - Latent temperature heuristics: formative memories never decay merely due to calendar silence.
2. **Automated Compaction & Consolidation Engine (`setup/evo_memory.py`)**:
   - **Worklog Compaction** (`compact`): Distills closed backlog items into permanent executive summaries, verified deliverables, and reusable patterns.
   - **Active Whittling Assistant** (`whittle`): Algorithmic pruning of `profile/observations.md` along *Recency × Frequency × Relevance*, safely archiving stale observations to `profile/archive/` while preserving anchors.
   - **Reference Staleness Verifier** (`staleness`): Scans local file links, missing `projects/` repositories, and broken references.
   - **Lexical & Semantic Deduplicator** (`dedup`): Cross-inbox/knowledge overlap detection.
   - **Weekly Memory Digest** (`digest`): Holistic memory health reporting for the human-in-the-loop review.
3. **Methodological Playbook**:
   - Standard operating procedure documented in [`knowledge/playbooks/evo-memory.md`](knowledge/playbooks/evo-memory.md).

---

## Implementation Horizons

| Milestone | Scope | Deliverables | Status |
| :--- | :--- | :--- | :--- |
| **v1.1** | Cognitive Foundations & Marketplace (Track 1) | Reality check dialectic, atomic harvesting, whittling, session resume, tools marketplace. | ✅ Complete |
| **v1.2** | Relational Epistemic Graph (Track 2) | Standardized causal frontmatter (`supersedes`, `depends_on`, `conflicts_with`, `supports`), `setup/graph.py check & mermaid`. | ✅ Complete |
| **v1.3** | Epistemic Resonance & Correlative Networks (Track 3) | Correlative/polar paradigm (*Gan-Ying*, *Wuxing*, polarities), ecological lineage tracing (`setup/graph.py lineage`), topology balance stats, epistemic resonance playbook. | ✅ Complete |
| **v1.4** | Evo-Memory Automation Suite (Track 4) | Autonomous worklog compactor, active whittling engine with episodic bedrock preservation, reference staleness verifier, `setup/evo_memory.py`, evo-memory playbook. | ✅ Complete |
