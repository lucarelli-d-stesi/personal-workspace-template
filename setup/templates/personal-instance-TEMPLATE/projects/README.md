# Functional Projects (`projects/`)

This directory is the local container for all software code repositories, CLI tools, extensions, and cloned external projects.

## Conventions

1. **Independent Git Repositories**:
   - Each subfolder is a full, independent Git repository with its own `.git`, commits, branches, and remotes.
   - The entire `projects/*/` pattern is `.gitignore`d by this personal repository.
2. **Separation of Concerns**:
   - The POS holds planning, architecture, requirements (specs), and diaries (worklogs).
   - `projects/<name>/` holds the code, test suites, Dockerfiles, and dependencies.
3. **External Clones / Symlinks**:
   - You can also symlink external directories into this folder:
     ```bash
     ln -s ~/repos/my-tool projects/my-tool
     ```
