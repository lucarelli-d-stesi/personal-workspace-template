# User Profile (`profile/`)

This directory houses your individual cognitive identity, values, operational style, and personal boundaries. It acts as the emotional and philosophical compass for your AI assistant.

---

## 1. The Core Profile Files

The starter profile consists of four fundamental declarations:

1. **`values.md`**: Non-negotiable philosophical principles, personal priorities, and ethical anchors.
2. **`boundaries.md`**: Strict limits, what the assistant must never do, privacy boundaries, and consent rules.
3. **`style.md`**: Tone of voice, communication preferences (e.g. direct vs conversational), formatting rules, and preferred rhythms.
4. **`observations.md`**: Append-only log of patterns and habits observed by the assistant over time (the assistant proposes, the user validates).

---

## 2. Organic Discovery (No Cold Interviews)

> [!IMPORTANT]
> The POS strictly forbids upfront questionnaires, interrogation, or cold interviews.

Your profile is populated **organically**:
- The assistant starts with the minimal baseline templates.
- As you work on real tasks, your communication preferences, non-negotiable boundaries, and personal values will surface naturally.
- When an assistant notices a recurring pattern or constraint, it notes it as an observation or proposes adding it to `style.md` / `boundaries.md`.

---

## 3. Organic Extensions (Family, Contacts, Assets)

As your personal system handles daily life, additional reference sheets can be created organically inside `profile/`:

- **`family.md` (or `people.md`)**:
  - Key people in your life (partner, children, parents, close collaborators).
  - Dates of birth, schools, medical contexts, or legal relationships.
  - Ensures the assistant addresses people by name with accurate context across all areas without re-asking.
- **`hardware.md` (or `assets.md`)**:
  - Inventory of personal hardware devices, displays, personal workstations, and vehicles (distinct from the per-node runtime profiles in `machines/<id>.md`).
