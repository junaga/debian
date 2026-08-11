# Local filesystem

**Local** means administered here rather than distributed by Debian.

```text
/usr/local/
├── app -> /opt                 self-contained applications
├── bin/                        integrated programs
├── lib/                        integrated program files
├── var -> /srv                 persistent local data
├── dev/<subject>/<project>/    active or archived projects
├── src/                        version-controlled system configuration
├── key/                        secrets
└── *.md                        local notes
```

`/opt` and `/srv` stay canonical so packages and services see familiar paths.
Their aliases make applications and data part of one local hierarchy without
adding a compatibility dependency.

Development paths describe what the work belongs to, not where its Git remote
is hosted. Hosting providers, fork relationships, and project lifecycle stay in
project metadata.

`src` is the system recipe, not a copy of the system. Applications and programs
are installed into `app`, `bin`, and `lib`; services write state into `var`;
projects live independently in `dev`; secrets remain in `key`; and notes remain
loose files.

## Construction

| Layer | Provides |
| --- | --- |
| Debian | Operating system and standard filesystem |
| `base/upgrade.sh` | Release policy, upgrades, and base packages |
| `base/setup.sh` | Host configuration and the `app` and `var` aliases |
| `base/home/` | User configuration copied during installation |
| `desktop/` | Optional desktop packages and configuration |

The `src` checkout, projects, secrets, notes, and persistent data are
administrator content. Installation scripts configure their environment but do
not create or restore that content.
