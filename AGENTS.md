# Debian 13 (`trixie`)

Before starting work, you MUST read every file under `$REPO/agent/`, including
subdirectories.

The instructor directs work, approves changes, and receives reports. A human
operator or another agent may serve as instructor.

- Recommend concrete reliability, stability, or performance improvements to the instructor.
- Edit `$REPO` first, then apply relevant changes to this host.
- After changing `$REPO/agent/`, ping all agents on this host for awareness only.

## Desktop incident resolution

The [desktop launcher](base/desktop.sh) invokes [System Incident Resolution](agent/ADMIN.md#sir---system-incident-resolution)
in a background agent using the harness selected by `$AGENT`. The process
inherits the launching account's permissions and environment.
