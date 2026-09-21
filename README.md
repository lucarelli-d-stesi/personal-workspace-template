# Personal Workspace — Personal Operating System (POS)

[![Use this template](https://img.shields.io/badge/GitHub-Use_this_template-2ea44f?style=for-the-badge&logo=github)](https://github.com/new?template_name=personal-workspace-template&template_owner=lucarelli-d-stesi)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

<!-- 🤖 AI ASSISTANT ONBOARDING DIRECTIVE (Antigravity CLI, Claude Code, Gemini CLI, Cursor, Codex): -->
<!-- If the user asks you to adopt, setup or install this workspace, DO NOT IMPROVISE. -->
<!-- Follow the deterministic protocol in: setup/AGENT_ONBOARDING.md -->

A file-based, open-source **Personal Operating System (POS)**: a cognitive architecture and operational framework designed for LLM assistants (Claude Code, Antigravity CLI, Codex, etc.) to collaborate alongside you across your entire life — software projects, daily activities, family responsibilities, personal finance, and continuous learning — with long-term memory, consistent methodology, and privacy by design.

---

## 1. Unified Architecture: Single-Repo from Canonical Template

The system follows a clean **Single-Repo per User** model derived from this canonical template:

1. **Every User Owns a Standalone Private Repository**:
   - Starting from this template via **"Use this template"**, each individual creates their private repository (e.g. `username/my-pos`).
   - **All personal life streams, notes, values, and tasks live directly at the root of the workspace**, eliminating nested directories and mental friction.
2. **Canonical Upstream Template (`personal-workspace-template`)**:
   - This repository serves as the public template, containing shared principles (`kernel/`), operational routines (`knowledge/playbooks/`), universal methodology skills (`.agents/skills/`), and ecosystem tools (`setup/`, `knowledge/sources/`).
   - Users pull non-destructive framework improvements through `setup/check-updates.sh`.

```
my-personal-pos/                        # YOUR PRIVATE STANDALONE POS REPOSITORY
├── kernel/                             # [FRAMEWORK] Principles & conventions
├── setup/                              # [FRAMEWORK] Bootstrap, updates, status, graph & marketplace
├── knowledge/
│   ├── playbooks/                      # [FRAMEWORK] Operational routines (harvesting, review, GC)
│   ├── sources/ (marketplace/)         # [FRAMEWORK] Curated external tools catalog & MCPs
│   └── <topics>/                       # [PERSONAL] Distilled personal insights & experience
├── .agents/skills/                     # [FRAMEWORK] Generic methodology skills (WBS, drafting)
├── AGENTS.md / CLAUDE.md / GEMINI.md   # [FRAMEWORK] Universal instructions for AI assistants
│
├── profile/                            # [PERSONAL] Emotional backbone (values, boundaries, style)
├── machines/<id>.md                    # [PERSONAL] Per-machine profiles & session tracking
├── areas/<area>/                       # [PERSONAL] Life streams (STATUS.md, context.md, specs, worklogs)
├── backlog/items/                      # [PERSONAL] Activities & tasks with stable IDs (<area>-<NNN>.md)
├── journal/                            # [PERSONAL] Daily cross-area journal & life climate
├── inbox/                              # [PERSONAL] Rapid capture notes & raw material
├── reference/sources/                  # [PERSONAL] Thin Overlays adopting tools from the marketplace
├── skills/                             # [PERSONAL] Specialized personal domain skills (e.g. odoo-*, latin)
└── projects/                           # [PERSONAL - GITIGNORED] Autonomous software repositories
```

---

## 2. Triple-Layer Privacy Safeguards

Because personal notes are Markdown files stored in Git, the POS implements built-in defenses against accidental leakage to the public template:

1. **Cognitive Guard (LLM Instruction Safeguard)**:
   Universal agent instructions in `AGENTS.md` mandate that before proposing or executing `git push`, the AI assistant inspects `git remote -v`. If `origin` points to the public upstream template and personal files are detected, the LLM **aborts the push immediately** and guides the user to set up their private repository.
2. **Local Pre-Push Git Hook (`.githooks/pre-push`)**:
   Git hooks activated via `git config core.hooksPath .githooks` physically block any push to `lucarelli-d-stesi/personal-workspace-template` if changes touch personal directories (`areas/`, `profile/`, `backlog/`, etc.).
3. **Automated CI PR Blocker (`.github/workflows/close-pull-requests.yml`)**:
   Any Pull Request opened against this public repository is inspected, flagged for privacy protection, and automatically closed.

---

## 3. Epistemic Relationship Graph & Epistemic Resonance

Knowledge notes, area specs, and backlog items support **typed epistemic relationships** in their YAML frontmatter, bridging Western linear logic with non-linear, correlative, and polar paradigms inspired by classical Eastern epistemology (Daoism, *Gan-Ying*, *Wuxing*):

```yaml
status: active | superseded | deprecated | proposed

# Mode A — Linear & Causal (Western Logic & Action)
supersedes: [previous-note-slug]
depends_on: [dependency-slug]
conflicts_with: [contradiction-slug]
supports: [foundation-slug]

# Mode B — Correlative & Process (Plural Epistemology & Balance)
resonates_with: [resonance-slug]     # Gan-Ying (感應): cross-domain sympathetic resonance
polar_balance: [polarity-slug]       # Yin-Yang (陰陽): dynamic complementary polarity
nourishes: [vital-flow-slug]         # Wuxing Sheng (生): continuous generative nourishment
moderates: [regulative-slug]         # Wuxing Ke (剋): homeostatic balance and pruning
```

- **Validation & Audit**: Run `python3 setup/graph.py check` to detect dangling references or broken links.
- **Lineage & Ecological Tracing**: Run `python3 setup/graph.py lineage <slug>` to view the full relational constellation of a concept (including nourishment, moderation, and polarities).
- **Mermaid Graph**: Run `python3 setup/graph.py mermaid` to visualize knowledge dependencies with typed arrows (`-->`, `<==>`, `<-.->`, `==>`, `-.->`).
- **Topology Statistics**: Run `python3 setup/graph.py stats` to inspect the balance between linear and correlative relations.
- **Methodological Playbook**: Learn how to model dynamic tensions and resonances in [`knowledge/playbooks/epistemic-resonance.md`](knowledge/playbooks/epistemic-resonance.md).

---

## 4. Quick Start & Onboarding

### Option A: Via GitHub Web (Recommended for Humans)
1. Click the green **["Use this template"](https://github.com/new?template_name=personal-workspace-template&template_owner=lucarelli-d-stesi)** button above.
2. Choose **Private** and create your repository (e.g., `username/my-pos`).
3. Clone your private repository locally and run the bootstrap wizard:
   ```bash
   git clone git@github.com:<username>/<your-repo>.git ~/personal-workspace
   cd ~/personal-workspace
   bash setup/bootstrap.sh
   ```

### Option B: Via GitHub CLI (`gh`)
```bash
gh repo create my-pos --template lucarelli-d-stesi/personal-workspace-template --private --clone ~/personal-workspace
cd ~/personal-workspace
bash setup/bootstrap.sh
```

### Option C: Via AI Assistant Prompt (Agentic Onboarding)
Tell your AI assistant (Claude Code, Antigravity CLI, Cursor):
> *"Adopt the memory solution provided by github.com/lucarelli-d-stesi/personal-workspace-template"*

The AI will follow the deterministic protocol in [`setup/AGENT_ONBOARDING.md`](setup/AGENT_ONBOARDING.md) to initialize your private repository safely.

---

## 5. Diagnostic Audit & Updates

### Environment & Deployment Audit
```bash
bash setup/status.sh
```
Audits Git topology, hardware resources, encryption status, installed toolchains, vector index coverage (`zg`), and machine session continuity.

### Zero-Knowledge Framework Updates
```bash
bash setup/check-updates.sh
```
Checks for upstream framework improvements from the canonical template and applies non-destructive updates without ever touching your private data.

---

## 6. Architectural Roadmap & Contributing

- **Roadmap**: Consult the **[Architectural Roadmap](ROADMAP.md)** for ongoing tracks (Epistemic Graphs, Evo-Memory Consolidation).
- **Contributing**: This repository is a personal cognitive template; external Pull Requests are not accepted. See [CONTRIBUTING.md](CONTRIBUTING.md).

---

## 7. License

Distributed under the [MIT License](LICENSE).
