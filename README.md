# Personal Workspace — Personal Operating System (POS)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A file-based, open-source **Personal Operating System (POS)**: a cognitive architecture and operational framework designed for LLM assistants (Claude Code, Antigravity CLI, Codex, etc.) to collaborate alongside you across your entire life — software projects, daily activities, family responsibilities, personal finance, vehicles, and continuous learning — with long-term memory, consistent methodology, and privacy by design.

---

## 1. Architectural Foundation: Two-Tier Separation

The system strictly decouples the **agnostic operational engine (Framework)** from each **individual private context (Personal Instance)**, enabling different people (family members, colleagues, students) to share the same operational base while keeping their private data completely isolated:

```
personal-workspace/                         # 1. SHARED FRAMEWORK (Public / Agnostic Engine)
├── kernel/                                 # Non-negotiable principles & conventions
├── knowledge/
│   ├── playbooks/                          # Operational routines (harvesting, weekly review, GC)
│   └── sources/                            # Curated external source catalog (laws, docs, blueprints)
├── .agents/skills/                         # Generic methodology skills (project-management, text-drafting)
├── setup/                                  # Installer, bootstrap, diagnostics, updates & LLM setups
│   ├── install.sh                          # Public one-line installer
│   ├── bootstrap.sh                        # Interactive onboarding wizard & setup
│   ├── check-updates.sh                    # Zero-knowledge framework & template sync
│   ├── status.sh                           # Diagnostic audit of environment & services
│   └── install-llm.sh                      # Local AI assistants setup (Claude, Antigravity, Codex)
└── personal/                               # [GITIGNORED] Local mount point for private instances
    └── <instance_dir>/                     # 2. PRIVATE PERSONAL REPO (Your life context)
        ├── profile/                        # Emotional backbone (values, style, boundaries, observations)
        ├── machines/                       # Per-machine profiles (<id>.md) & session tracking
        ├── skills/                         # Specialized personal domain skills (e.g. odoo-*, latin, etc.)
        ├── reference/sources/              # Thin Overlays mapping framework sources to life areas
        ├── knowledge/                      # Distilled personal insights and experience
        ├── areas/<area>/                   # Life streams (STATUS.md, context.md, specs/, worklog/)
        ├── backlog/items/                  # Activities & tasks with stable IDs (<area>-<NNN>.md)
        ├── journal/                        # Cross-area daily journal & life climate observations
        ├── inbox/                          # Rapid capture notes & raw incoming material
        └── projects/                       # [GITIGNORED] Independent software code repositories
```

* **Framework Repo (`personal-workspace`)**:
  - Completely agnostic of any individual user.
  - Contains **zero personal data, zero life areas, and zero private tasks**.
  - Provides kernel conventions, generic methodology skills, semantic indexing configuration, update tools, and automation scripts.
* **Instance Repo (`personal/<instance_dir>/`)**:
  - A completely independent Git repository owned privately by each user (starting from [pos-instance-template](https://github.com/danielelucarelli1980/pos-instance-template)).
  - Contains all personal streams of responsibility, private notes, specialized domain skills, and project plans.
  - Syncs privately via Git across the user's devices without leaking data to the shared framework.

---

## 2. Key Capabilities & Mechanics

* **Organic Discovery (Zero Initial Survey)**:
  No rigid questionnaires or upfront interviews. Life areas, profiles, and priorities emerge organically through real day-to-day interactions.
* **Associative Semantic Memory (`zg` / `zvec-grep`)**:
  Built-in local semantic vector search (powered by local embeddings, BM25, and ripgrep). Tasks and notes are connected by **semantic proximity** across life domains, accommodating dynamic topic pivots during work sessions.
* **Skill Partitioning**:
  - **Universal Methodology Skills** (Work Breakdown Structure, project scheduling, formal text drafting) live in the framework (`.agents/skills/`).
  - **Specialized Domain Skills** (e.g. Odoo framework internals, ancient languages translation, data science) live in each individual's private instance repo (`skills/`) and are dynamically linked at bootstrap.
* **Dual-Axis Model: The Machine Axis (`machines/<id>.md`)**:
  The system detects the local execution environment (`vm`, `wsl`, `mac`, `linux`, `termux`), hardware resources (vCPU, RAM, swap, disk), and installed CLI tools. Each physical machine maintains its own additive profile in `machines/`, and session continuity is tracked via `machines/last-session.md` to prevent Git merge conflicts across multi-device setups.
* **Curated Sources & Thin Overlays**:
  Large public reference libraries (e.g. Italian legislation corpus, DevOps blueprints) reside in the framework catalog (`knowledge/sources/`). Users activate only what they need via lightweight **Thin Overlays** (`reference/sources/<id>.md`), mapping external sources directly to their life areas without duplicating URLs or disk storage.
* **Functional Project Repositories (`projects/`)**:
  When tasks require developing software tools or cloning external codebases, they reside in `projects/<project-name>/` as first-class, independent Git repositories, completely isolated from the personal notes repository.
* **End-of-Session Harvesting & Life Climate**:
  At the conclusion of each session, actionable tasks are routed to the backlog, while distilled learnings and reusable architectural insights are harvested into `knowledge/` or refined into skills. Perceived pressure and life season shifts are captured in `journal/` and area contexts.
* **Zero-Knowledge Framework & Template Sync**:
  Framework conventions, diagnostic scripts, and template structures evolve over time. The built-in `check-updates.sh` utility inspects upstream improvements and proposes non-destructive migrations without ever exposing private instance data.

---

## 3. Quick Start & Installation

### One-Line Automated Installation (Recommended)

Run the one-line installer in your terminal (Linux, macOS, or Windows WSL2):

```bash
curl -fsSL https://raw.githubusercontent.com/danielelucarelli1980/personal-workspace/main/setup/install.sh | bash
```

The script will:
1. Check and install minimal base prerequisites (`curl`, `git`, `python3`).
2. Clone the `personal-workspace` framework to `~/personal-workspace` (or update it if already present).
3. Launch the interactive onboarding wizard to configure your private instance.

### Manual Installation (Clone & Bootstrap)

If you prefer to clone and inspect the code manually:

```bash
git clone https://github.com/danielelucarelli1980/personal-workspace.git ~/personal-workspace
cd ~/personal-workspace
bash setup/bootstrap.sh
```

### The Interactive Onboarding Wizard

During `bootstrap.sh`, you will be prompted for:
1. **Your Name**: (e.g. `Claudia`, `Gemma`, `Petra`, `Daniele`), which automatically generates your instance folder name (e.g. `personal/claudia-pos`).
2. **Private Repository Setup Mode**:
   - **Option 1 (GitHub CLI — Recommended)**: Automatically creates a new private repository on your GitHub account using the official [pos-instance-template](https://github.com/danielelucarelli1980/pos-instance-template) and clones it locally.
   - **Option 2 (Git Clone)**: Clones an already-existing repository (e.g. if you clicked *"Use this template"* on the GitHub web interface).
   - **Option 3 (Local Offline)**: Initializes an offline private Git repository directly on your machine from the included template.
3. **Automatic Personalization**:
   - Populates your name and language preferences in `CLAUDE.md`.
   - Generates canonical agent symlinks (`AGENTS.md`, `GEMINI.md`).
   - Configures the `template` remote for future zero-knowledge updates.
   - Initializes your local machine profile in `machines/<machine-id>.md`.
   - Offers to set up local AI assistants (Claude Code, Antigravity CLI, Codex).

### Bootstrap Options & Flags

* **Unattended / Non-interactive**:
  ```bash
  bash setup/bootstrap.sh --yes
  ```
* **Reconfigure Personal Instance**:
  ```bash
  bash setup/bootstrap.sh --reconfigure
  ```
* **Environment Health Check & Audit**:
  ```bash
  bash setup/bootstrap.sh --check
  # or directly:
  bash setup/status.sh
  ```

---

## 4. Environment & Deployment Auditing

To ensure that tools, symlinks, vector indices, and machine profiles are properly configured before starting work:

```bash
bash setup/status.sh
```

This diagnostic audit inspects:
- **Repositories Status**: Branch alignment and uncommitted changes in framework and personal instance.
- **Hardware Resources**: CPU cores, RAM availability, swap, disk space, and rest encryption status (LUKS/FileVault/BitLocker).
- **Installed Toolchain**: Python, Node.js, Docker, Claude Code, Antigravity CLI, Codex CLI, Gitleaks.
- **Local Semantic Engine**: `zg` wrapper status and vector index coverage (`.zvec-grep/index.zvec`).
- **External Integrations**: Google Workspace MCP, school portals (ClasseViva), and system bridges.
- **Machine Profile & Session Tracking**: Verifies profile freshness and detects host switches via `machines/last-session.md`.

---

## 5. Zero-Knowledge Framework & Template Updates

As the framework and instance templates evolve, you can check for upstream updates at any time:

```bash
bash setup/check-updates.sh
```

Or simply ask your AI assistant:
> *"Ci sono novità nel workspace?"* / *"Are there any updates?"*

The tool will:
1. Check if the shared framework has new commits from `origin/main`.
2. Inspect pending structural migrations in `setup/updates/` and propose applying them safely (`--apply-migrations`).
3. Compare your personal instance against the latest [pos-instance-template](https://github.com/danielelucarelli1980/pos-instance-template) and offer non-destructive synchronization (`--sync`).
4. **Guarantee of Inviolability**: Personal notes, areas, backlog items, and profiles are **never** overwritten or transmitted.

---

## 6. Multi-User Sharing (Family, Friends, Colleagues)

The POS is designed from the ground up for multi-user adoption:
- **Shared Base Engine**: Multiple family members or team colleagues can clone the same public framework (`personal-workspace`).
- **Completely Isolated Lives**: Each person runs their own private instance repository (`claudia-pos`, `gemma-pos`, `petra-pos`, etc.).
- **Total Privacy**: Because personal data lives in a separate, private repository, no user ever has access to another's tasks, finances, diary, or personal reflections.

To share with someone, simply send them the one-line installer:
```bash
curl -fsSL https://raw.githubusercontent.com/danielelucarelli1980/personal-workspace/main/setup/install.sh | bash
```

---

## 7. Contributing & Template Usage

* **Framework Repository (This Repo)**: Serves as the public engine and template.
* **Instance Starter Template**: 👉 **[pos-instance-template](https://github.com/danielelucarelli1980/pos-instance-template)**

> **Note on Contributions**:
> This repository is maintained as an individual operational base and cognitive template. We do not accept Pull Requests or external feature contributions. Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

---

## 8. Architectural Roadmap

For upcoming initiatives, design tracks (such as typed epistemic graphs and active *Evo-Memory* consolidation loops), and implementation horizons:
👉 Consult the **[Architectural Roadmap](ROADMAP.md)**.

---

## 9. License

This project is licensed under the [MIT License](LICENSE) — feel free to adapt, study, and tailor it for your own personal, academic, or professional journey.
