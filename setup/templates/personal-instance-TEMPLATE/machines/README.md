# Machine Profiles (`machines/`)

This directory stores hardware and environment profiles for each physical or virtual machine where you run this Personal Operating System.

## Architecture

- **One file per machine**: Named after the machine's hostname slug (e.g. `laptop-dell.md`, `home-desktop.md`, `work-vm.md`).
- **Strictly additive**: Because your private repository is synchronized via Git across devices, each machine writes **only its own file**. This ensures you never experience Git merge conflicts.
- **Auto-generated**: Generated or updated automatically by running `bash setup/bootstrap.sh` on that machine.
- **Template**: See `setup/templates/machine-TEMPLATE.md` in the framework.
