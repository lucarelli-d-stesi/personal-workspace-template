# Machine Profiles (`machines/`)

This directory stores hardware and environment profiles for each physical or virtual machine where you run this Personal Operating System.

## Architecture

- **One file per machine**: Named after the machine's hostname slug (e.g. `laptop-dell.md`, `home-desktop.md`, `work-vm.md`).
- **Strictly additive**: Because your private repository is synchronized via Git across devices, each machine writes **only its own file**. This ensures you never experience Git merge conflicts.
- **Auto-generated**: Generated or updated automatically by running `bash setup/bootstrap.sh` on that machine.
- **Template**: See `setup/templates/machine-TEMPLATE.md` in the framework.

## Active Session Tracking (`machines/last-session.md`)

In addition to static machine profiles, the system maintains a dynamic marker: `machines/last-session.md`.
- **Purpose**: Records the machine ID and timestamp of the last active POS session across your synchronized devices.
- **Machine Switch Auto-Audit**: When starting a session on a machine different from `last-session.md`, the AI assistant or `setup/status.sh` automatically performs a node diagnostic health check (git alignment, dependencies, semantic search vector index) and updates `last-session.md`.
- **Automatic Management**: Managed by framework automation (`setup/status.sh`) and the AI assistant. Do not delete it.

