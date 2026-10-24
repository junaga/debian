# Development

Contain work in your working directory.

```sh
./dev/$PROJECT/
./job/YYYY-MM-DD/$TASK/
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
