## `BDL` - Backup Directory Layout

Keep one copy per volume. Record backup/export dates, scope, and failures in
`AGENTS.md`. Keep credentials private.

```text
BACKUP/
├── AGENTS.md
├── keys/                         # Credentials and recovery codes.
├── data/                         # Account exports: APP/ACCOUNT/.
│   ├── Google/user@example.com/
│   └── Discord/user@example.com/
└── copy/                         # Local copies: VOLUME/.
    ├── home/
    └── work/
```

Use `rsync -aHAXx` without `--delete`; exclude `tmp/`, `dist/`, and
`node_modules/`. Stop and report failures or free space below 20%.
