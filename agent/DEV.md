# Development

Contain work in your working directory.
Keep host jobs in `$WORK/job/YYYY-MM-DD/TASK/`; never create undated entries in `job/`.
Keep artifacts for tasks belonging to this workspace in the task's job directory,
including scratch files, inputs, evidence, context, unfinished patches, and results.
Use `$WORK/tmp/` for context and files that don't belong in this workspace.
They need to be migrated elsewhere.
Choose by where the files belong, regardless of age or completion.
Check ownership and active use before moving or cleaning existing files.
Keep ongoing projects in `$WORK/dev/`, lasting subject records in `$WORK/doc/`,
and unresolved issues in the relevant `BACKLOG.md`, linking job evidence as needed.

```sh
./dev/$PROJECT/
./job/YYYY-MM-DD/$TASK/
./tmp/
./lib/
./bin/
./opt/
./data/
```

## Source code

You own all source code. Humans must not write or read source code.

```
       Humans     <-->     AI agents
      /      \            /         \
 Product     Documentation       Source code
```

## Branches

Commit documentation on dev branches and generated source on build branches.
AIOS work uses `linux`; AIOSDE docs use `desktop`, and builds use
`desktop-<model>-<effort>-YYYY-MM-DD-HH-MM`.
Record the exact dev commit in each build.

## Documentation

```
AGENTS.md / README.md — project
├── PROMPT.md — description
│   └── DESIGN.md — definition
│       └── SPEC.md — specification
│           └── IMPL.md — implementation
├── RESOURCES.md — external accounts and services
├── PLAN.md — unimplemented changes
└── BACKLOG.md — unresolved issues
```

- Number `BACKLOG.md` issues in order.
- Remove completed work from `PLAN.md` and `BACKLOG.md`.
- `SPEC.md` must not omit any requirements.
- `README.md` must be human-written.
- Not every project needs an `AGENTS.md`.
- Prefer less documentation and fewer files.

<!--
`SKILL.md` defines an instruction package, not a document like `AGENTS.md` instructions.
-->

## Ignore

Reference `.gitignore`.

```ignore
tmp/
*.log*
dist/
```
