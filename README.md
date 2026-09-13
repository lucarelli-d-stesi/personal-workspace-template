# Personal Workspace — Personal Operating System (POS)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A file-based, open-source **Personal Operating System (POS)**: a cognitive architecture and operational framework designed for LLM assistants (Claude Code, Antigravity CLI, Codex, etc.) to collaborate alongside you across your entire life — software projects, daily activities, family responsibilities, personal finance, vehicles, and continuous learning — with long-term memory, consistent methodology, and privacy by design.

---

## 1. Architectural Foundation: Two-Tier Separation

The framework strictly decouples the **agnostic operational engine** from the **individual private context**:

```
personal-workspace/                         # 1. SHARED FRAMEWORK (Public / Agnostic Base)
├── kernel/                                 # Non-negotiable principles & conventions
├── knowledge/playbooks/                    # Work routines (harvesting, weekly review, GC)
├── .agents/skills/                         # Generic methodology skills (project-management, text-drafting)
├── setup/                                  # Dynamic bootstrap, diagnostics & LLM installers
└── personal/                               # [GITIGNORED] Local mount point for private instances
    └── <instance_dir>/                     # 2. PRIVATE PERSONAL REPO (Your life context)
        ├── profile/                        # Emotional backbone (values, style, boundaries)
        ├── machines/<id>.md                # Per-machine profile (hardware specs, local tools)
        ├── skills/                         # Specialized personal domain skills
        ├── reference/sources/              # Curated catalog of external references (content & method)
        ├── knowledge/                      # Distilled personal insights and experience
        ├── areas/<area>/                   # Life streams (STATUS.md, context.md, specs/, worklog/)
        ├── backlog/items/                  # Activities & tasks with stable IDs (<area>-<NNN>.md)
        └── projects/                       # [GITIGNORED] Independent software repositories
```

* **Framework Repo (`personal-workspace`)**:
  - Completely agnostic of any single individual.
  - Contains **zero personal data, zero life areas, and zero private tasks**.
  - Provides the kernel conventions, generic skills, semantic indexing configuration, and automation scripts.
* **Instance Repo (`personal/<instance_dir>/`)**:
  - A completely independent, private Git repository owned by each user.
  - Contains all personal streams of responsibility, private notes, domain skills, and project plans.
  - Syncs privately via Git across multiple user devices without leaking data to the framework.

---

## 2. Key Capabilities & Mechanics

* **Organic Discovery (Zero Initial Survey)**:
  No rigid questionnaires or upfront interviews. Life areas, profiles, and priorities emerge organically through real day-to-day interactions.
* **Associative Semantic Memory (`zg` / `zvec-grep`)**:
  Built-in local semantic vector search (powered by local embeddings, BM25, and ripgrep). Tasks and ideas are linked by **semantic proximity** across life domains, accommodating dynamic topic pivots during work sessions.
* **Skill Partitioning**:
  - **Universal Methodology Skills** (Work Breakdown Structure, project scheduling, formal text drafting) live in the framework (`.agents/skills/`).
  - **Specialized Domain Skills** (e.g. Odoo framework internals, ancient Greek translation, advanced data science) live in each individual's private instance repo (`skills/`) and are dynamically linked at bootstrap.
* **Dual-Axis Model: The Machine Axis (`machines/<id>.md`)**:
  The system detects the local environment scenario (`vm`, `wsl`, `mac`, `linux`, `termux`), hardware resources (vCPU, RAM, swap, disk), and installed CLI tools. Each physical machine maintains its own additive file in `machines/`, preventing Git merge conflicts across multi-device setups.
* **Functional Project Repositories (`projects/`)**:
  When tasks require developing software tools or cloning external repositories, they reside in `projects/<project-name>/` as first-class, independent Git repositories, isolated from the personal notes repository.
* **End-of-Session Harvesting**:
  At the conclusion of each session, actionable tasks are routed to the backlog, while distilled learnings and reusable architectural insights are harvested into `knowledge/` or refined into skills.

---

## 3. Deployment & Quick Start

### Prerequisites
* **Operating System**: Linux (bare-metal, KVM, Proxmox), Windows WSL2, or macOS (Apple Silicon / Intel).
* **Base Utilities**: `bash` (v4+ recommended), `git`, `curl`, `python3` (v3.10+).

### Step-by-Step Installation

1. **Clone the Framework**:
   ```bash
   git clone https://github.com/danielelucarelli1980/personal-workspace.git ~/personal-workspace
   cd ~/personal-workspace
   ```

2. **Run the Automated Bootstrap**:
   ```bash
   bash setup/bootstrap.sh
   ```
   *The bootstrap is 100% user-path agnostic, handles non-root execution safely, configures your private instance repository, establishes semantic indexing (`zg`), links skills, and sets up your AI assistants.*

3. **Bootstrap Options**:
   * **Unattended / Non-interactive**:
     ```bash
     bash setup/bootstrap.sh --yes
     ```
   * **Environment Health Check & Audit**:
     ```bash
     bash setup/bootstrap.sh --check
     # or directly:
     bash setup/status.sh
     ```

### Local AI Assistant Setup
The bootstrap includes an installer ([setup/install-llm.sh](setup/install-llm.sh)) supporting:
* **Claude Code**: Native CLI installation with automated skill links.
* **Antigravity CLI (`agy`)**: Automated local configuration with the `zvec-grep` MCP semantic tool.
* **Codex CLI**: Environment scaffolding.

---

## 4. Environment & Deployment Auditing

To ensure that tools, symlinks, vector indices, and machine profiles are properly configured before starting work:
```bash
bash setup/status.sh
```
This inspects:
- Git status of framework and personal instance repositories.
- Hardware resources (CPU cores, RAM availability, disk space, encryption status).
- Installed tools and CLI environments (Python, Node.js, Docker, Claude Code, Antigravity, Gitleaks).
- Semantic index coverage (`.zvec-grep/index.zvec`).
- Per-machine profile freshness.

---

## 5. Sharing & Template Usage

If you want to use this repository as the foundation for your own or your team's Personal Operating System:

1. Click the green **"Use this template"** button on GitHub to create your own repository.
2. Follow the deployment steps above to initialize your private personal instance.
3. For personal repository scaffolding, refer to the starter blueprint in [setup/templates/personal-instance-TEMPLATE/](setup/templates/personal-instance-TEMPLATE/).

> **Note on Contributions**:
> This repository is maintained as an individual operational base and cognitive template. We do not accept Pull Requests. Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

---

## 6. License

This project is licensed under the [MIT License](LICENSE) — feel free to adapt, study, and modify it for your own personal and professional needs.
