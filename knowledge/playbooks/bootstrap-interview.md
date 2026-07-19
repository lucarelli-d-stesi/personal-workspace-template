# Playbook — bootstrap interview

Goal: seed a brand-new instance with the minimum vital context in one
session. Style: **open dialogue**, one theme at a time — not a form to fill.
Everything produced here is `source: declared`; observed entries come later
from use.

## 0. Locate and inventory the instance repo

Resolve the instance from `.pos-config` (`instance_dir=...`) at the
framework root; if missing, ask the user to indicate their repo and write
the file. If the repo already contains material (notes, lists, documents),
inventory it briefly and use it as *input* for the interview: existing
content often reveals the real areas better than questions do. Graft the
POS folders alongside what exists — never move or overwrite the user's
material without asking.

## 1. Life areas (→ `areas/<area>/context.md`)

Explore which 3–5 areas matter *now* (family, home, finance, health, hobby,
learning, personal projects…). Fewer is better: areas can be added anytime
with this same structure. For each chosen area create `context.md` from
`setup/templates/context-TEMPLATE.md`, an empty `STATUS.md` from its
template, and `specs/` + `worklog/` folders. Ask enough to fill the context
honestly: what this area is, who is involved, current goals, constraints,
recurring rhythms (weekly? seasonal?).

Family note: family members appearing here are *content* (people an area is
about), not users of the system. Only the interviewee gets a profile.

## 2. Task backend (→ bridge choice)

Ask explicitly: **"Do you already use a tool for tasks/activities (Todoist,
Notion, Trello, a calendar, a personal Odoo…)?"**

- **No** → the local backlog is the backend. Explain the stable-id rule and
  the thread → sprint → task hierarchy; create the first items from what
  emerged in step 1.
- **Yes** → note which tool in the instance `CLAUDE.md`; if an adapter for
  it exists under `bridges/`, follow its setup; if not, still use the local
  backlog and record the tool as the future bridge target. The data
  structure is identical either way (`external_ref` empty until a bridge
  claims the item).

## 3. Initial profile (→ `profile/`)

Short and honest — this is a starting hypothesis, not a portrait:

- **values.md** — what matters in how decisions get made (2–5 entries).
- **style.md** — how they like to work and be spoken to: direct or padded,
  when to be challenged, appetite for detail.
- **boundaries.md** — hard lines: topics to handle with care, times or
  surfaces that are off-limits, privacy red lines (health, minors, money).

Every entry uses the template's provenance block (`source: declared`,
`confidence`, `since`, `last_challenged` empty). Remind the user of kernel
principle 1: the profile shapes *how*, facts win over it always.

## 4. Wrap up

- Fill `{{NAME}}`/`{{LANGUAGE}}` in the instance `CLAUDE.md` if not done.
- Propose the first commit of the instance repo (user confirms).
- Point at the working loop: `harvesting.md` at end of session,
  `weekly-review.md` weekly.
