# Operating model

## Orientation

Read `$HOME/.env` if present; use its values where the process environment is unset. Default `WORK` to `$HOME`. Read the target project's instructions; resolve requested paths from that project or `$WORK`. Keep standalone work out of unrelated repositories.

`WORK` is the shared workspace, currently `/usr/local`. Administration also reaches the relevant system and account paths. Agents normally edit; `$EDITOR` is the human fallback.

- `dev/$PROJECT`: permanent projects and their dependencies.
- `src`: system source, available without the development mount.
- `bin`, `lib`: local commands and libraries.
- `tmp/YYYY-MM-DD/SUBJECT`: file work, no project. Create it when needed and use it as the working directory for subsequent commands.
- `doc`: reusable knowledge, one descriptive extensionless file per topic; distinguish discovered information from tested experience.

Set the task title to `SUBJECT` (1–3 words) once it is clear; use the same subject for its directory.

## System work

Debian stable (13, `trixie`) is the system baseline. Read `$WORK/src/design.md` for intentional deviations before changing system policy. Verify `/etc/os-release` and configured APT suites before package work; the installed system may differ from the baseline. Bash is the interactive shell; `/bin/sh` is Dash. Services use systemd and journald.

Carry authorized work through installation and activation when needed. Reviews and cleanup inventories stay read-only until changes are requested. Respect discussion-only and source-only requests. Runtime-only operations stay temporary. Inspect current configuration, logs, and source before diagnosing; distinguish evidence from hypotheses and reassess after failed attempts.

The system configuration lives in `$WORK/src`:

- `base/` → `/etc/`, including `base/skel/` → defaults for new accounts; `instpkg.sh` installs shared configuration and packages.
- `desktop/etc/` → `/etc/`, `desktop/home/` → the current home, `desktop/bin/` → `/usr/local/bin/`; `desktop/install.sh` applies the desktop profile.
- `initacc.sh` initializes account Git and SSH.
- Updates: `base/update.sh` → `/etc/update.sh`; the desktop profile uses `desktop/etc/apt/update.sh` → `/etc/apt/update.sh`. Both cron definitions run every two minutes; inspect the active job.

Shared application profiles under `/usr/local` can contain saves and credentials. Check mounts and backup coverage before storage changes; home snapshots exclude mounted trees. Local package fixes follow `src/pkg/` recipes and the provenance recorded in their package descriptions.

Patch source first, then install the affected pieces and activate them as the task requires. Maintain these instructions in `base/skel/.codex/AGENTS.md`; install that source into `$HOME/.codex/AGENTS.md`. Inspect installers before using them; they perform broad setup. Run account/desktop setup as the target user, elevating system steps. Updating a skeleton alone does not update existing accounts.

Use the component's existing owner: APT, deb-get, global pipx/npm, or its project environment. For services, identify system versus user scope, inspect the journal, and use local drop-ins for unit overrides.

## Changes

- Establish the repository, branch/worktree, and live target before editing. Treat manual edits as intentional; preserve accepted choices and unrelated work. Include relevant hidden and untracked files in workspace inventories.
- Prefer small, direct implementations in the existing style. Add abstractions and dependencies for demonstrated needs.
- Track **source → installed → active**. Verify the requested behavior and report the state reached, including any pending activation.
- Keep a practical undo path for disruptive changes, including recovery access before boot, login, or network changes. Reproduce known crashes in isolation. Check persistence when relevant without rebooting just to test.
- Commit only when asked; amending history and pushing each require their own request. Add `Co-authored-by: Codex <codex@openai.com>`. Prefer `gh` for GitHub. Describe an upstream PR’s target and changes before submitting it.

## Working together

For UI work, verify actual interactions and representative rendered states and screen sizes. Test TUIs in a real terminal; prove the layout before broad implementation and include screenshots in the handoff.

Answer directly and briefly; expand when asked. Let the user finish speaking before acting. Stay silent while they are AFK until they announce their return. Align Markdown table columns in source. Keep these instructions concise and system-specific; put detailed procedures in project documentation or `$WORK/doc`.

Follow OpenAI’s [Terms of Use](https://openai.com/policies/terms-of-use/) and [Usage Policies](https://openai.com/policies/usage-policies/) to protect our account from suspension or bans.
