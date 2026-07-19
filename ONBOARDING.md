# Onboarding — set up your POS

Idempotent checklist: every step can be re-run safely. Automation scripts
(`bootstrap.sh`, `install-llm.sh`) are on the roadmap; until then the steps
are manual and explicit.

## Prerequisites

- A GitHub account (or any git hosting) where you can create a **private** repo.
- An LLM coding assistant with filesystem access (e.g. Claude Code).
- Disk encryption at rest is strongly recommended before storing personal data.

## 1. Clone the framework

```bash
git clone https://github.com/danielelucarelli1980/personal-workspace.git ~/personal-workspace
cd ~/personal-workspace
```

## 2. Create your private instance repo

Create a **private** repo named `<your-name>-pos` and clone it inside the
framework (the `personal/` folder is gitignored — the two repos never mix):

```bash
gh repo create <your-name>-pos --private
git clone git@github.com:<login>/<your-name>-pos.git personal/<your-name>
```

## 3. Seed the instance structure

```bash
cd personal/<your-name>
mkdir -p profile areas backlog/items knowledge inbox journal
cp ../../setup/templates/profile/*.md profile/
# rename: values-TEMPLATE.md -> values.md, etc.
```

## 4. Generate your assistant configuration

Copy `setup/templates/CLAUDE.template.md` to `personal/<your-name>/CLAUDE.md`
and replace the `{{NAME}}` and `{{LANGUAGE}}` placeholders. Then create a
workspace-level `CLAUDE.md` in the framework root **of your local clone only**
(it is not tracked) or configure your assistant to load, in order:

1. `kernel/principles.md` and `kernel/conventions.md` (always)
2. `knowledge/INDEX.md` (always — routing map, content on demand)
3. `personal/<your-name>/CLAUDE.md` (your identity and language)

## 5. Run the bootstrap interview

Open your assistant in the workspace and ask it to run
`knowledge/playbooks/bootstrap-interview.md`. Outcome: your first 3–5 areas
with their `context.md`, an initial declared-only profile, and the choice of
task backend (none → local backlog, which is the default).

## 6. Adopt the working loop

- During work: specs and worklogs per area, backlog items with stable ids.
- End of session: `knowledge/playbooks/harvesting.md`.
- Weekly: `knowledge/playbooks/weekly-review.md`.

## 7. Stay up to date

Pull the framework regularly. Structure migrations arrive as reviewed
scripts in `setup/updates/` (see its README): read, approve, apply — never
run updates blindly.
