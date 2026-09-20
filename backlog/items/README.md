# Backlog Items (`backlog/items/`)

This directory contains all individual tasks and initiatives across all life areas.

## Conventions

- **Stable IDs**: Files are named `<area>-<NNN>.md` (e.g. `career-001.md`, `home-002.md`). Once assigned, IDs are never reused or renamed.
- **Frontmatter**:
  ```markdown
  ---
  id: career-001
  title: Title of the initiative
  area: career
  kind: thread              # thread | sprint | task
  status: doing             # todo | doing | waiting | done | dropped
  created: YYYY-MM-DD
  due: YYYY-MM-DD
  tags: [topic1, topic2]
  project_dir: projects/... # optional: if linked to a functional code folder
  ---
  Description of the activity.
  ```
- **Template**: See `setup/templates/backlog-item-TEMPLATE.md` in the framework.
