# Structure updates — framework → instance channel

The framework evolves; instances migrate through reviewed scripts, never
through merges. This mirrors a proven shared/personal workspace model.

## How it works

1. A maintainer adds `NNNN-slug.sh` here (`NNNN` zero-padded, ascending =
   application order; ids are never reused) and pushes the framework.
2. On the user's request ("update my workspace"), the assistant computes the
   scripts not yet recorded in the instance's `.pos-updates-applied` marker,
   **reads** each one, summarizes it in plain language, runs a danger scan,
   and proposes it. Only approved scripts run, one at a time, in order.
3. Each applied id is appended to `.pos-updates-applied` (tracked in the
   instance repo). Nothing runs automatically or on a schedule: human
   approval plus review is the checkpoint.

## Script contract

- Receives **one argument**: the instance repo directory (`$1`). Must not
  write outside it — no `$HOME`, no absolute paths, no `..`.
- **Idempotent** and **additive by default** (create/append, don't delete).
  A useful idiom: `grep -qxF "line" file || printf 'line\n' >> file`.
- Destructive operations, `sudo`, network access, `git push` → the script
  must carry a `# DANGEROUS` header line and is never applied without an
  explicit per-script override.
- `exit 0` on success (including a deliberate skip when preconditions don't
  apply); non-zero leaves it unapplied and stops the sequence.
- May read framework templates via the `WORKSPACE_DIR` environment variable.

Periodically, stable updates get folded into the onboarding baseline and
remain as historical no-ops, so new instances don't replay the whole history.
