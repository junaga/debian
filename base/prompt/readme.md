# Agent development doctrine

Agents are peers: give each a named task, an isolated branch, and a bounded
machine. The host integrates reviewed commits; agents never edit its primary
checkout.

## Primitives

| Need | Primitive | Rule |
| --- | --- | --- |
| Isolation | Rootless Podman | No home, SSH agent, Podman socket, or primary checkout mount. |
| CPU, RAM, forks | cgroup v2 | Set `--cpus`, `--memory`, `--memory-swap`, and `--pids-limit`. CPU shares are not a cap. |
| Private files | OverlayFS or Btrfs snapshot | Use a private writable layer over an immutable base. Never expect zero storage. |
| Parallel history | Git branch + worktree | One unique `agent/<task>` branch and worktree per agent. |
| Integration | Host Git | Review, test, and merge only after the agent stops. |

## Lifecycle

1. Start from a clean, committed base revision. Name the task and reserve
   `agent/<task>` from that exact revision.
2. Give the container a private worktree at the normal project path. A Podman
   overlay mount is ideal for disposable work; a Btrfs snapshot is ideal when
   the worktree must survive or needs a disk quota.
3. Put the agent in a rootless container with a declared resource budget. Keep
   the network off unless the task needs it. Install only the project runtime
   in the image.
4. The agent changes, tests, and commits only its own branch. It reports the
   commit SHA, tests run, and any remaining risk.
5. The host verifies the commit in a fresh constrained environment, reviews
   the diff, then merges or cherry-picks it. Destroy the agent's writable layer
   only after its commit is safe.

## Git topology choices

The direct topology is the closest match to a virtual worktree: the container
has an overlay-backed checkout while a shared Git common directory stores
objects and `agent/<task>` refs. Commits become visible on the host immediately.
It requires Git worktree locking, unique branches, no concurrent Git
maintenance, and explicit cleanup of the worktree metadata; use it only for
trusted agents.

The broker topology gives every agent private Git metadata and has it publish
to a bare repository. It adds an explicit fetch step but avoids shared Git
locks, reflogs, hooks, and garbage collection. Use it for untrusted or highly
parallel agents.

Choose one topology per project. Do not share one mutable ordinary worktree,
one index, or one `HEAD` between agents.

## Host budgeting

Treat capacity as a schedule, not a hope. Reserve memory and CPU for the OS,
browser, editor, and one compilation burst before assigning agent limits. For
example, a 16 GiB / 8-core desktop might reserve 4 GiB / 2 cores and run at
most three agents limited to 3 GiB / 2 cores. Cgroups bound CPU, memory, and
PIDs—not disk. On Btrfs, use a subvolume quota when an agent needs a disk cap.
