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

## 2. Choose your private instance repo

The instance repo is yours: any name, any hosting, new or pre-existing (an
existing notes repo works too). The framework never assumes its name or
structure — setup **asks** you to indicate it. Only two requirements: it is
a git repo and it is **private**.

```bash
# a new repo, named however you like:
gh repo create <any-name> --private
# clone it inside the framework (personal/ is gitignored — the two repos never mix):
git clone git@github.com:<login>/<any-name>.git personal/<any-name>
```

Record your choice in `.pos-config` at the framework root (local file, not
tracked — the future `bootstrap.sh` will ask and write it for you):

```
instance_dir=personal/<any-name>
```

## 3. Seed the instance structure

The layout in `kernel/conventions.md` is the canonical structure the
playbooks rely on — but it is a proposal to graft, not a mold: if your repo
already has content, keep it and add the POS folders alongside (the
bootstrap interview will help map what exists onto areas).

```bash
cd personal/<any-name>
mkdir -p profile areas backlog/items knowledge inbox journal
cp ../../setup/templates/profile/*.md profile/
# rename: values-TEMPLATE.md -> values.md, etc.
```

## 4. Generate your assistant configuration

Copy `setup/templates/CLAUDE.template.md` to `<instance_dir>/CLAUDE.md`
and replace the `{{NAME}}` and `{{LANGUAGE}}` placeholders. Then create a
workspace-level `CLAUDE.md` in the framework root **of your local clone only**
(it is not tracked) or configure your assistant to load, in order:

1. `kernel/principles.md` and `kernel/conventions.md` (always)
2. `knowledge/INDEX.md` (always — routing map, content on demand)
3. `<instance_dir>/CLAUDE.md` (your identity and language)

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
