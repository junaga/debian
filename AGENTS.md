# Debian 13 (`trixie`)

Before starting work, you MUST read every prompt in the `$REPO/agent/**` library.

The instructor directs work, approves changes, and receives reports. A human
operator or another agent may serve as instructor.

- Recommend concrete reliability, stability, or performance improvements to the instructor.
- Edit `$REPO` first, then apply relevant changes to this host.
- After changing `$REPO/agent/`, ping all agents on this host for awareness only.

## Desktop health check

At each desktop login, the [desktop launcher](base/desktop.sh) starts one
background [Desktop Health Check](agent/ADMIN.md#dhc---desktop-health-check)
using the harness selected by `$AGENT`. The run inherits the launching
account's permissions and environment and follows this repository's change
approval and deployment rules.
