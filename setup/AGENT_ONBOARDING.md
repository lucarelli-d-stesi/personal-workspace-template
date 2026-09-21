# Agent Onboarding Protocol (AOP) — Instructions for AI Assistants

> **Target**: AI Assistants (Antigravity CLI, Claude Code, Gemini CLI, Cursor, Codex) tasked by a user with adopting or setting up this Personal Operating System (POS).

---

## 1. Core Principles to Uphold
1. **Privacy by Architecture**: Every user must have their own **Private GitHub Repository**. The upstream template (`lucarelli-d-stesi/personal-workspace-template`) is public and MUST NEVER receive user data, areas, notes, or credentials.
2. **Organic Discovery**: DO NOT conduct initial interviews, questionnaires, or surveys. Let the user's areas and notes emerge organically from their actual tasks.
3. **Deterministic Setup**: Follow this exact sequence below to complete setup safely.

---

## 2. Deterministic Setup Protocol

### Scenario A: GitHub CLI (`gh`) is available and authenticated
If `command -v gh` succeeds and `gh auth status` is OK:
```bash
# 1. Ask the user for their preferred repository name (default: <username>-pos or personal-workspace)
# 2. Create the private repository directly from the template via GitHub API:
gh repo create <repo-name> --template lucarelli-d-stesi/personal-workspace-template --private --clone <target-dir>

# 3. Enter target directory:
cd <target-dir>

# 4. Add the canonical template as a read-only upstream remote with push disarmed:
git remote add template https://github.com/lucarelli-d-stesi/personal-workspace-template.git
git remote set-url --push template "NO_PUSH_UPSTREAM_TEMPLATE"

# 5. Run automated bootstrap:
bash setup/bootstrap.sh --yes
```

---

### Scenario B: Manual clone or `gh` not authenticated
If you are already inside a clone of `lucarelli-d-stesi/personal-workspace-template`:
```bash
# 1. DISARM UPSTREAM PUSH IMMEDIATELY:
git remote rename origin template 2>/dev/null || true
git remote set-url --push template "NO_PUSH_UPSTREAM_TEMPLATE"

# 2. Enable local protection hooks:
git config core.hooksPath .githooks

# 3. Help user set up their own private remote:
# Ask user: "What is your private GitHub repository URL?"
# Once provided:
git remote add origin <user-private-repo-url>
git branch -M main

# 4. Run automated bootstrap:
bash setup/bootstrap.sh --yes
```

---

## 3. Post-Setup Verification
Always verify system health by running:
```bash
bash setup/status.sh
```
Check that:
- [x] `origin` points to the user's private repository (NOT the upstream template).
- [x] Local pre-push hook is active (`.githooks/pre-push`).
- [x] Machine profile is generated (`machines/<hostname-slug>.md`).
- [x] Semantic search index (`zg`) is initialized.

---

## 4. First Interaction with User
Once `status.sh` reports clean health, conclude the setup concisely without interrogation:
> *"Il tuo Personal Operating System è configurato e protetto nel tuo repository privato. I meccanismi di sicurezza anti-leak e l'indice semantico sono attivi. Di cosa vogliamo occuparci oggi (un appunto da salvare, un progetto da avviare, o un'attività da pianificare)?"*
