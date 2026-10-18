# Backlog

## 1. Review container and Railway conventions

Container and Railway deployment conventions belong to shared production
operations, independent of Junaga's personal setup.

Document essential Railway deployment and resource details in `RESOURCES.md`.
Source: `/usr/local/PLAN.md`, Railway section.

The draft below proposes isolated agent environments, but the architecture has
not been selected or implemented. Review its Podman isolation, resource limits,
filesystem layers, Git topology, and cleanup rules. Choose the simplest workable
approach and validate a small end-to-end task before adopting it.

### Projectless task folder

Codex Settings → General includes a **Projectless task folder** setting with a
**Change** button. It selects where tasks started outside projects store their
data by default. Record this existing feature as an input to the container and
workspace design; this chat currently uses `/home/junaga/Documents/Codex`.

Motivation for eventual agent containers: an archived agent's stale checkout
kept `master` reserved; include reliable checkout cleanup and recovery.

### Agent development doctrine

Agents are peers: give each a named task, an isolated branch, and a bounded
machine. The host integrates reviewed commits; agents never edit its primary
checkout.

#### Primitives

| Need              | Primitive                   | Rule                                                                                       |
| ----------------- | --------------------------- | ------------------------------------------------------------------------------------------ |
| Isolation         | Rootless Podman             | No home, SSH agent, Podman socket, or primary checkout mount.                              |
| CPU, RAM, forks   | cgroup v2                   | Set `--cpus`, `--memory`, `--memory-swap`, and `--pids-limit`. CPU shares are not a cap.   |
| Private files     | OverlayFS or Btrfs snapshot | Use a private writable layer over an immutable base. Never expect zero storage.            |
| Parallel history  | Git branch + worktree       | One unique `agent/<task>` branch and worktree per agent.                                   |
| Integration       | Host Git                    | Review, test, and merge only after the agent stops.                                        |

#### Lifecycle

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

#### Git topology choices

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

#### Host budgeting

Treat capacity as a schedule, not a hope. Reserve memory and CPU for the OS,
browser, editor, and one compilation burst before assigning agent limits. For
example, a 16 GiB / 8-core desktop might reserve 4 GiB / 2 cores and run at
most three agents limited to 3 GiB / 2 cores. Cgroups bound CPU, memory, and
PIDs—not disk. On Btrfs, use a subvolume quota when an agent needs a disk cap.

## 2. Validate rebuilding the system

The repository is intended to recreate the operating system around the
persistent home, work, and repository data, but a full reinstallation run-
through remains untested. Later, use a disposable environment to follow the
documented setup and identify missing configuration or manual steps. Update the
source and instructions until rebuilding is reproducible. This is a future task,
not authorization to reinstall the live host or reinstate the declined backup-
restoration test.

## 3. Resolve Codex glyphs on the native Linux console

Source: live USB office PC, 2026-10-10.

- [ ] Resolve missing Codex TUI glyphs while preserving the native Linux virtual console. User prefers keeping the existing console and avoiding a kernel rebuild; investigate a suitable custom console font containing Codex symbols within the existing glyph limit. No font or kernel changes have been applied.

Findings (2026-10-10):

- Codex runs on `tty1` with `TERM=linux` and UTF-8 locale settings. The active font has 791 Unicode mappings (several codepoints can share one glyph); box borders are supported, but tested checkmarks, warning symbol, Braille spinner characters and `↳` are missing. No missing glyph was present in the sampled screen, so the exact user-observed characters remain unconfirmed. None of the installed console fonts covered the full tested symbol set.
- Running kernel is `6.12.107+deb13-amd64`, with `CONFIG_VT=y` and `CONFIG_FRAMEBUFFER_CONSOLE=y`. Linux 6.12 console mapping caps glyph indices at 512, and framebuffer font loading accepts only 256 or 512 glyphs. UTF-8 decoding does not supply missing glyph pictures.
- Linux 6.12 framebuffer console support is a boolean built-in option, not a loadable-module option. Some kernel framebuffer-console documentation still describes older module support.
- Searches of configured Debian package repositories and GitHub projects found no verified ready-made Unicode/wide-character console module for this kernel. This is a search finding, not proof that no implementation exists. A custom hooking/livepatch module is theoretically possible but unverified and would require kernel development.
- CJKTTY and Linux-TTY-UTF-8-Patch extend native console rendering through kernel-source patches, rather than documented drop-in modules. Kmscon is a userspace alternative; the user prefers retaining the native Linux console.

Primary references:

- [Linux 6.12 console mapping source](https://github.com/torvalds/linux/blob/v6.12/drivers/tty/vt/consolemap.c)
- [Linux 6.12 framebuffer renderer source](https://github.com/torvalds/linux/blob/v6.12/drivers/video/fbdev/core/fbcon.c)
- [Linux 6.12 console driver configuration](https://github.com/torvalds/linux/blob/v6.12/drivers/video/console/Kconfig)
- [CJKTTY patches](https://github.com/gentoo-zh/cjktty-patches)
- [Linux-TTY-UTF-8-Patch](https://github.com/detiam/Linux-TTY-UTF-8-Patch)

The deferred investigation entry was removed from PLAN.md at the user's request; this backlog entry records the completed research and remaining fix.

## 4. Voice harness permissions for edits and Git commits

In the 2026-10-11 voice chat, the backend has full filesystem permissions and
can read files and run commands, but app-provided coordinator instructions
require routing repository file edits through another project chat. The user
reports that ordinary non-voice tasks can edit directly and finds this difference
unexpected and confusing; the earlier chat's configuration was not verified.

Allow the voice agent to make authorized direct file edits without requiring a
separate chat.

On 2026-10-12, the full-access "Bash Login Shell Commit" task, started with a
full-duplex realtime voice call rather than transcription, could run other SSH
commands but received "blocked by policy" for an explicitly authorized remote
Git commit; it also declined shell-escape and new-task delegation requests after
the rejection. The user manually opened this text chat and repeated the same
SSH, commit, and push-to-master instruction, which succeeded against the same
container and checkout. Investigate the suspected voice harness permission or
privilege mismatch: the user reports full access for every task, with the
realtime voice start as the only known difference.

## 5. Understand the shell environment required by Railway SSH

The Dockerfile exports `SHELL=/bin/bash`, introduced by "Export login shell for
Codex SSH", but the original failure and why this setting was required are not
recorded. Railway handles SSH outside the container; root's account shell,
shell startup files, and the environment supplied to a remotely launched process
are separate mechanisms. Reproduce the behavior with and without this variable,
trace how Railway and Codex select the shell, and determine whether to retain or
replace the declaration; the missing-environment explanation remains a hypothesis.

## 6. Load workspace instructions when Codex enters a directory over SSH

Observed on 2026-10-12 in the projectless Windows Codex chat "Upload and unpack
latest archive". Codex used Windows OpenSSH and the saved host
`js-bau-debian`. SSH landed in `/usr/local`, the configured remote workspace,
but Codex did not read its `AGENTS.md` before creating `/data`, transferring
and unpacking an archive, and writing a README.

The user expected workspace-local `data/`. The missed instructions explicitly
say to contain work in the working directory and require human-written READMEs.
Codex read them only after the user challenged the location and instruction
loading. The archive was subsequently moved to `/usr/local/data` and the
README revised at the user's explicit request.

Investigate a suspected harness gap: instructions discovered for the local
execution directory may not be discovered or surfaced when the agent accesses
another workspace through SSH. The observed failure is established; whether
the cause is harness discovery or agent behavior remains unverified.

Expected behavior: discover and read applicable remote workspace and ancestor
`AGENTS.md` files before remote mutations, then load any more specific
instructions for the target directory. Add regression coverage comparing direct
workspace execution with entry through SSH, including a projectless local chat.

## 7. Remote memory

Source: user report and memory-chart screenshot, 2026-10-14.

Registering an SSH remote in the desktop app's connection settings reportedly
raises the remote container's memory usage immediately from roughly 300 KB to
500 MB, even without active work. The attached chart shows usage around
350–440 MB, falling near zero before returning to roughly 440 MB; it does not
identify the responsible processes or establish the cause.

This is a serious resource-cost issue for the user's preferred workflow:
containers stay online with minimal idle resource use, accept SSH connections
for work, and are restarted afterward to clear processes and memory. A desktop
remote connection that keeps hundreds of megabytes resident prevents returning
to that inexpensive idle state.

Current workaround, reported by the user: turn off the remote connection in the
desktop app before restarting the container so it can return to minimal idle
memory usage.

Working theory, unverified: the desktop app starts a persistent Codex CLI or
related remote process as soon as the SSH remote is registered. The user
suspects a heavy JavaScript application remains in memory; neither the process
identity, implementation language, nor source of the memory usage is confirmed.

Investigate which processes start on remote registration and reconnection,
measure their idle memory, and determine whether they persist or restart after
disconnecting or restarting the container. Find a way to release remote Codex
resources when no work is active while preserving SSH availability and the
ability to reconnect and create new work items on demand.

## 8. Cloud skill selection

Bug observed on 2026-10-14: Codex selected the managed cloud runtime skill while initializing an ordinary SSH development container, using cloud-provider environment variables as the trigger. A remote connection or cloud-hosted container does not establish that a Codex-managed cloud environment is attached. The user confirmed submitting this through Codex feedback as a bug on 2026-10-14.

A Codex agent instruction now requires explicit session evidence of an attached Codex-managed environment before using managed cloud skills. Fix skill selection to enforce this distinction across providers and verify ordinary SSH remotes and Codex-managed cloud sessions separately; the instruction is a mitigation, not a verified harness fix.

## 9. Clarify human review of source-code diffs

`agent/DEVELOP.md` says humans must not write or read source code, while
`AGENTS.md` requires showing the diff and commit message for human approval.
The review instruction does not distinguish documentation diffs from source
code diffs. Decide whether human review must be limited to documentation or
whether source-code review is an explicit exception, then align the rules.
