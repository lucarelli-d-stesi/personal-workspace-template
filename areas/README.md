# Life Areas (`areas/`)

An **Area** represents a permanent domain of responsibility in your life (e.g. `family`, `finance`, `home`, `career`, `vehicles`, `health`, `community`).

## Key Principles

- **Permanent, Not Ephemeral**: Areas do not expire or get completed (unlike tasks or projects). Aim for 4–7 macro areas.
- **Canonical Structure**:
  ```
  areas/<area>/
  ├── STATUS.md              # Dashboard of active, waiting, blocked, and concluded items
  ├── context.md             # Identity of the area (purpose, participants, constraints)
  ├── specs/<item-id>.md     # Architectural requirements (Summary-first format)
  └── worklog/<item-id>.md   # Append-only diary of sessions (Done / Next / Blocked)
  ```
- **Templates**: See `setup/templates/` in the framework for `context-TEMPLATE.md`, `STATUS-TEMPLATE.md`, `spec-TEMPLATE.md`, and `worklog-TEMPLATE.md`.

## Area Artifacts Overview

1. **`STATUS.md`**: The real-time operational dashboard. Lists active, waiting, blocked, and concluded backlog items with their current blocker or next step.
2. **`context.md`**: The permanent anchor of the area:
   - **People involved**: Who this area touches (family, partners, advisors).
   - **Current goals & constraints**: Boundaries, budget, rhythms.
   - **Current phase and climate**: Captures the perceived pressure, economic or emotional climate, and life season (updated periodically during reviews).
   - **External mapping**: Links to dedicated Drive folders, recurring calendar cadences, or mail threads.
3. **`specs/<item-id>.md`**: Architectural or initiative requirements, adhering strictly to the **Summary-first** convention (a concise, executive summary at the top followed by detailed requirements).
4. **`worklog/<item-id>.md`**: Append-only execution diary. Every session logs `Done`, `Next`, and `Blocked`.

