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
workspace design.

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

The container build exports `SHELL="/bin/bash"`, introduced by commit `39a1bbe`
("Export login shell for Codex SSH"); the original failure was not recorded.

Investigated 2026-10-23: Codex CLI `0.164.0` selects the shell through the account
database, where root uses `/bin/bash`, rather than through `$SHELL`. Disassembly
of the running Railway SSH helper (`49c490e613`) shows `main.findShell` searches
`PATH` for `bash`, then `sh`, before checking `/bin/bash`, `/usr/bin/bash`,
`/bin/sh`, and `/usr/bin/sh`. This helper contains no literal `SHELL`.
Local tests with `env -u SHELL` confirm Bash still starts; it initializes a shell
variable named `SHELL` but does not export it to child processes.

The declaration appears redundant for these shell selectors, but the original
desktop SSH connection has not been reproduced without it. Fresh Railway SSH
testing was blocked by rejected configured credentials and an expired saved
login. Retain the declaration until the desktop connection can be tested;
`tini` does not replace shell environment configuration.

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

### Railway cleanup

After work, stop unneeded task processes to free memory and CPU.
Restart the current Railway container with the existing image only when needed
to reclaim resources. Save work and let necessary tasks finish gracefully before
restarting. Do not rebuild or redeploy for resource cleanup.

## 8. Cloud skill selection

Bug observed on 2026-10-14: Codex selected the managed cloud runtime skill while initializing an ordinary SSH development container, using cloud-provider environment variables as the trigger. A remote connection or cloud-hosted container does not establish that a Codex-managed cloud environment is attached. The user confirmed submitting this through Codex feedback as a bug on 2026-10-14.

A Codex agent instruction now requires explicit session evidence of an attached Codex-managed environment before using managed cloud skills. Fix skill selection to enforce this distinction across providers and verify ordinary SSH remotes and Codex-managed cloud sessions separately; the instruction is a mitigation, not a verified harness fix.

## 9. Clarify human review of source-code diffs

`agent/DEV.md` says humans must not write or read source code, while
`AGENTS.md` requires showing the diff and commit message for human approval.
The review instruction does not distinguish documentation diffs from source
code diffs. Decide whether human review must be limited to documentation or
whether source-code review is an explicit exception, then align the rules.

## 12. Responses evaluation

Evaluate the official [`openai` CLI](https://developers.openai.com/api/reference/cli)
and the [Open Responses specification](https://www.openresponses.org/specification)
for repeatable shell workflows and interoperable access to model providers.

- Assess CLI installation and updates on Debian, authentication, structured
  output, streaming, exit codes, and suitability for unattended batch work.
- Review the specification's request and response schemas, tool calls,
  streaming events, provider extensions, and acceptance tests.
- Test whether the CLI can use an Open Responses provider through a custom
  base URL; record supported operations and compatibility gaps rather than
  assuming that a shared Responses API foundation guarantees interoperability.

Record tested versions, reproducible examples, operational costs, and an
adoption recommendation before adding either to the system configuration.

## 14. Secure Boot and duplicate firmware entries

Decide whether to use Secure Boot and resolve the confusing duplicate shim and direct systemd-boot firmware entries.

## 15. Permanent browser history without losing passkeys

Chrome deletes local browsing history older than roughly 90 days; find a browser setup that retains native history indefinitely and supports passkeys without Flatpak. Google Password Manager is optional, so evaluate independent passkey providers alongside browsers with configurable history retention. Verify a path for existing passkeys and reliable browser updates before migrating.

## 16. Railway volume usage accounting

Investigate why Railway volume usage can remain high after files are deleted, and document how to verify and reclaim space safely.

Reference: [Railway staff discussion](https://station.railway.com/questions/volume-usage-metric-still-inflated-after-0f7b9674).

## 17. Micro clipboard

Reported 2026-11-05: copying from Micro on a remote Debian host through SSH in
Windows Terminal on Windows 11 reports success in Micro, but the Windows clipboard
does not receive the copied text. Terminal Preview was installed during this
session; the affected Terminal version and exact copy shortcut are unconfirmed.

Investigate Micro's clipboard backend and the path through the remote environment,
SSH, Windows Terminal, and the Windows clipboard. Record the relevant versions,
copy binding, and clipboard settings, and compare editor copy with Terminal copy.
The user suspects Micro or SSH; the cause has not been established.

## 18. Terminal releases

Stay on Windows Terminal Preview: SSH discovery and `Shift+Enter` work there,
confirmed 2026-11-05; the installed Preview version has not been recorded.

- **SSH discovery:** [merged 2025-05-31 (#18814)](https://github.com/microsoft/terminal/pull/18814),
  available in [Preview 1.26.2734.0 (2026-10-02)](https://github.com/microsoft/terminal/releases/tag/v1.26.2734.0),
  but [still disabled in stable 1.25.2733.0](https://github.com/microsoft/terminal/blob/v1.25.2733.0/src/features.xml#L105-L111).
- **Kitty keyboard protocol:** [merged 2026-02-17 (#19817)](https://github.com/microsoft/terminal/pull/19817),
  shipped in [stable 1.25.2733.0 (2026-10-02)](https://github.com/microsoft/terminal/releases/tag/v1.25.2733.0);
  preserves key modifiers so applications can distinguish `Shift+Enter`.

Track subsequent stable releases and reconsider switching when both features ship;
verify SSH discovery and `Shift+Enter` over SSH before changing channels.

## 19. SSH directory

Reported 2026-11-05: opening VS Code and selecting the Railway container through
Remote - SSH lands in `/root` instead of `$WORK` (`/usr/local`). This is a minor
annoyance. `/root` remains the account's home path despite being a symlink, and
the shell startup `cd` into `$WORK` does not produce the expected starting
directory in this workflow.

Investigate how VS Code chooses the initial remote folder and Bash working
directory, and why the existing startup `cd` does not take effect here. Make
fresh connections start in `$WORK` while preserving explicitly selected folders.

## 20. Codex remote

Make desktop browser launching and image clipboard access work while Codex
executes in the remote container.

**Browser launching:** clicking a web link in the remote Codex TUI produces an
in-harness browser-opening error. Codex launches the browser on the TUI host,
which is the headless container. Opening a remote development web server page
also needs a desktop browser and a forwarded port; a container's loopback URL
does not reach that server from the desktop. In `foot`, `Ctrl+Shift+O` opens URL
mode and launches the selected link locally; remote web servers still need
their ports forwarded.

**Image clipboard:** investigated 2026-11-06, pasting an image into Codex running
in the Railway container fails with `clipboard unavailable` and an unreachable
X11 server.
The desktop uses `foot` and connects with `ssh jsbee-dev`, whose endpoint is
`ssh.railway.com`. Codex reads the clipboard on the TUI host; this connection
does not expose the desktop clipboard. The endpoint rejected an X11 forwarding
request and a dynamic reverse-port forwarding probe.

Defer adoption of the experimental remote TUI mode. Run the TUI locally on the
desktop so it can launch the desktop browser and read the desktop clipboard,
and connect it to an app-server in the container through an SSH local port
forward. Codex encodes local image attachments for transport; files, tools, and
sessions remain on the remote.

For a future test, start the backend inside the container:

```sh
codex app-server --listen ws://127.0.0.1:4500
```

On the desktop, keep the tunnel running in one terminal tab:

```sh
ssh -N -L 4500:127.0.0.1:4500 jsbee-dev
```

Run the local TUI in another desktop tab:

```sh
codex agents --remote ws://127.0.0.1:4500 -C /usr/local/src
```

With Codex CLI `0.166.0`, the temporary backend passed its readiness probe,
WebSocket initialization, and session listing. Desktop browser launching,
opening a remote web server through a forwarded port, and clipboard image paste
have not been verified. Before adoption, test these alongside session resume
and reconnection, and define startup and shutdown without adding idle resource
use. The temporary test server was stopped; no permanent listener was configured.

References: [OpenAI remote TUI documentation](https://learn.chatgpt.com/docs/app-server#connect-the-cli-terminal-ui),
[Codex image transport implementation](https://github.com/openai/codex/blob/rust-v0.166.0/codex-rs/tui/src/chatwidget/image_submission.rs),
[Codex browser launcher](https://github.com/openai/codex/blob/rust-v0.166.0/codex-rs/tui/src/app/history_ui.rs#L280),
[Foot URL mode](https://manpages.debian.org/trixie/foot/foot.ini.5.en.html),
[Railway local port forwarding](https://docs.railway.com/cli/ssh#forward-a-port-with-ssh--l).

## 21. Lookup permissions

Confirmed 2026-11-07 with Codex TUI `0.166.0` and shared daemon `0.167.0`
in the Debian container: `git-branch` is configured but omitted from the footer.
The background Git lookup uses daemon defaults instead of the active thread's
`--yolo` permissions. Bubblewrap fails before Git starts with
`Creating new namespace failed: Permission denied`; replaying the same lookup
with explicit full access returns the branch.

Upstream: [openai/codex#53579](https://github.com/openai/codex/issues/53579),
with our [Git branch reproduction](https://github.com/openai/codex/issues/53579#issuecomment-6704359665).

Temporary workaround: set `sandbox_mode = "danger-full-access"` in
[`base/etc/codex/config.toml`](base/etc/codex/config.toml), apply it to
`/etc/codex/config.toml`, and restart with `codex app-server daemon restart`.
This makes full access the host's default, including daemon background commands;
it does not make those commands inherit each thread's restrictions. Activated
and verified 2026-11-07: daemon PID changed from `2658` to `15108`, and its
`command/exec` returns branch `linux` without permission overrides. The user
also confirmed that the branch now appears in the footer.

Remove the setting and restart the daemon once an upstream fix is installed.
Verify that branch and PR lookups follow the active thread's permissions with
normal daemon defaults, including after switching to a restricted thread.

## 22. Host admins

Deferred at the user's request on 2026-11-06. Create one persistent admin agent
for each reachable host (`jsbeew2`, `jsbeew3`), with one directory under
`/usr/local/doc/host/$HOSTNAME/`, one host task directory, and one HRR per host
following `/usr/local/src/agent/HARDWARE.md`. The coordinating admin sends
future host issues and work to the corresponding agent; no monitoring. Do not
start this setup until requested again.

## 23. Codex packaging

Deferred at the user's request on 2026-11-06. The global npm CLI under `/usr`
and Codex's managed daemon under `/usr/local/data/.codex/packages/app-server-daemon`
duplicate the full runtime and update independently. Prefer one package-manager-owned
installation for CLI and server, with executables outside the home directory.
Track https://github.com/openai/codex/issues/41188 for external executable support;
OpenAI's proposed `CODEX_DAEMON_EXECUTABLE` is not an available setting. Track
https://github.com/openai/codex/issues/53410 for using the smaller published server
package instead of another full CLI bundle. Do not replace the current remote
workflow or run experiments until requested. Only daemon release `0.167.0`
remains after cleanup; retain the active runtime.

## 24. Home relocation

Deferred at the user's request. Document home relocation in its own DDD and
implement it in `base/usr-merge2.sh`, replacing the inline container setup.
Keep `/root` as a compatibility symlink and preserve existing home data and
account settings. The old DDD proposed `/usr/root`; the current container uses
`/usr/local/data`. Resolve the destination before implementation. Keep this
separate from DDD 12 and the `WORK` environment variable.
