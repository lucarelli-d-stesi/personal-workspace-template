# Personal Instance Repository — Starter Template

This repository is a **starter template** for your private Personal Instance within the **Personal Operating System (POS)** ecosystem.

While the shared framework ([personal-workspace](https://github.com/danielelucarelli1980/personal-workspace)) provides the operational engine, generic methodology skills, and automation routines, **this repository is your private cognitive space**: it holds your personal life areas, private backlog items, values, machine profiles, and domain skills.

---

## 1. Directory Layout

```
<your-personal-pos>/
├── profile/                 # Emotional backbone: values, style, boundaries, observations
├── machines/                # Per-machine profiles: hardware specs, local tools (additive)
├── skills/                  # Your specialized domain skills (e.g. dev, study, analysis)
├── reference/sources/       # Catalog of external repositories & sources (content & method)
├── knowledge/               # Personal distilled knowledge, patterns, and lessons learned
├── areas/                   # Your life streams (family, home, finance, health, career...)
│   └── <area>/              # STATUS.md, context.md, specs/, worklog/
├── backlog/items/           # Tasks and activities with stable IDs (<area>-<NNN>.md)
├── projects/                # [GITIGNORED] Independent software repos and dev clones
├── inbox/                   # Quick capture and staging ground for lessons learned
└── journal/                 # Cross-area journal and diary
```

---

## 2. Quick Setup with the POS Framework

1. **Create your private repo**:
   - Create a new **private** Git repository on GitHub (e.g. `yourname-pos`) using this directory as the initial template.
2. **Clone the POS Framework**:
   ```bash
   git clone https://github.com/danielelucarelli1980/personal-workspace.git ~/personal-workspace
   cd ~/personal-workspace
   ```
3. **Run the Bootstrap Script**:
   ```bash
   bash setup/bootstrap.sh
   ```
   - When prompted, provide the Git URL or local folder name of your private instance (e.g. `yourname-pos`).
   - The bootstrap will mount your private repository inside `personal/<your-instance-dir>/`, configure `.pos-config`, initialize your machine profile, link your personal skills, and generate the local semantic vector index.

4. **Start Working**:
   - Launch your AI assistant (Claude Code: `claude`, Antigravity CLI: `agy`).
   - No initial questionnaires or interviews needed — work directly on real tasks!

---

## 3. Privacy & Security

- **Keep this repository PRIVATE**: It contains your personal projects, family notes, finances, and reflections.
- **Never commit secrets**: Passwords, API tokens, and private SSH keys must never be committed. A pre-push hook using `gitleaks` is automatically configured by the bootstrap script.
- **Independent Git Repositories in `projects/`**: Any software repositories, scripts, or external clones you create under `projects/` are ignored by this repository's `.gitignore`. They maintain their own independent Git history and remotes.
