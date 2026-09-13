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
