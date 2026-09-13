# Onboarding — Set Up Your Personal Operating System (POS)

The **personal-workspace** is a universal, agnostic operational framework. It contains general operating rules, universal methodology skills, and indexing infrastructure.

**All personal data, individual values, boundaries, private sources, and specialized domain skills reside in your private instance repository.**

---

## Quick Start (Automated Bootstrap)

### 1. Clone the framework

```bash
git clone https://github.com/danielelucarelli1980/personal-workspace.git ~/personal-workspace
cd ~/personal-workspace
```

### 2. Run the bootstrap script

```bash
bash setup/bootstrap.sh
```

The script is idempotent and handles:
- **Environment & safety checks**: non-root user, OS detection, disk encryption diagnostic (LUKS/FileVault/BitLocker).
- **Deploying/connecting your personal repo**: asks for your private instance repo (or creates it), clones it into `personal/<name>`, and records `.pos-config`.
- **Seeding the canonical layout**: `profile/`, `areas/`, `backlog/items/`, `knowledge/`, `reference/`, `inbox/`, `journal/`, `skills/`.
- **Generating instance configuration**: creates `<instance_dir>/CLAUDE.md` and symlinks `AGENTS.md` / `GEMINI.md`.
- **Skill partitioning**: links your personal domain skills (`<instance_dir>/skills/*`) into the framework's `.agents/skills/`.
- **Local semantic index (`zg`)**: configures exclusions and builds the local vector index for associative memory.

---

## Organic Discovery (No Upfront Interview)

**There is no initial interview questionnaire.**

Discovery occurs organically over time based on actual tasks and mapped data:
- Start directly by asking your AI assistant to assist with any real task (e.g. *"let's plan a home repair"*, *"help me draft an essay"*, *"compare car insurance quotes"*).
- The assistant will progressively map areas, backlog items, profile observations, and experiential knowledge inside your private instance repo.

---

## Working Loop

1. **Kickoff & Dynamic Pivots**:
   - The agent uses `zg query "<topic>"` to retrieve past experiences across all notes and areas via semantic proximity.
2. **Execution**:
   - Work breakdown, specs, and append-only worklogs in `<instance_dir>/areas/<area>/`.
   - Local-first backlog items in `<instance_dir>/backlog/items/<id>.md` with stable IDs and multi-dimensional tags.
3. **End of Session (Harvesting)**:
   - Follow `knowledge/playbooks/harvesting.md` to update worklogs, STATUS, and distill general lessons into `knowledge/`.
4. **Weekly Review**:
   - Follow `knowledge/playbooks/weekly-review.md` to consolidate the inbox and compact oversized knowledge files.
