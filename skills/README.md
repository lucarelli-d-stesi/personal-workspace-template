# Personal Domain Skills (`skills/`)

This directory contains specialized, individual skills specific to your personal or professional domain.

## Distinction: Framework vs Personal Skills

- **Generic Methodology Skills** (e.g. project management, WBS, text drafting) live in the framework repository (`personal-workspace/.agents/skills/`) and are shared by all users.
- **Personal Domain Skills** (e.g. specialized programming frameworks, Latin translation, local legal procedures) live here in your private repository.

## Structure of a Skill

Each skill lives in its own subfolder:
```
skills/<skill-name>/
├── SKILL.md                 # Main instructions with YAML frontmatter (name, description)
└── (scripts / references)   # Optional helper scripts or reference files
```

During bootstrap (`bash setup/bootstrap.sh`), all skills located here are dynamically symlinked into the framework's `.agents/skills/` directory so that AI assistants (Claude Code, Antigravity) can discover and use them automatically.
