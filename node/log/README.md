# Node Log

`node/log` is a nightly review loop for one Linux node.

```sh
bash node/log/goodnight.sh
```

It writes one dated checkpoint:

```sh
~/log/YYYY-MM-DD/system.log
~/log/YYYY-MM-DD/codex.log
~/log/YYYY-MM-DD/goodnight.log
~/log/goodnight.lock
```

`goodnight.lock` is both the run lock and checkpoint history. Each successful review appends one timestamp. The next run captures:

```text
latest goodnight.lock timestamp -> current run timestamp
```

If today's `goodnight.log` already exists, `goodnight.sh` treats the earlier report as premature: it removes today's `system.log`, `codex.log`, and `goodnight.log`, rolls back one checkpoint line, and rebuilds the day with the newer activity included.

For capture without review:

```sh
bash node/log/goodnight.sh --no-run
```

For a standalone system snapshot:

```sh
bash node/log/system.sh
```

Standalone `system.sh` writes `./system.log` unless an output path is provided.

## Scope

`system.log` is node health evidence: kernel, boot artifacts, drivers, storage, memory, system processes, systemd units/timers/sockets, apt, dpkg, DKMS, listening sockets, journals, and Codex runtime warnings.

`codex.log` is a Codex TUI digest: session metadata, open/complete session status, human messages, assistant messages, explicit reasoning summaries when Codex records them, task completions, small tool and command counts, and patch summaries as paths plus counts. It is not a raw tool-output stream.

`goodnight.log` is the review of only `system.log` and `codex.log`.
