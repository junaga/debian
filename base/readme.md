# Local filesystem

**Local** means administered here rather than distributed by Debian.

```text
/usr/local/
├── app -> /opt                 standalone application trees
├── bin/                        executable entry points
├── lib/                        program files and dependencies
├── var -> /srv                 persistent service data
├── dev/<subject>/<project>/    projects organized by subject
├── src/                        versioned system definition
├── key/                        private credentials
└── *.md                        working notes
```

`/opt` and `/srv` stay canonical so packages and services see familiar paths.
The `app` and `var` aliases may bring them into the local view without making
software depend on those aliases.

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
| `base/setup.sh` | Network, login, SSH, and Git host configuration |
| `base/home/` | User configuration copied during installation |
| `desktop/` | Optional desktop packages and configuration |

The aliases are naming recommendations, not setup requirements. Scripts neither
create nor depend on them.

The `src` checkout, projects, secrets, notes, and persistent data are
administrator content. Installation scripts configure their environment but do
not create or restore that content.
