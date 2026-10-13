# Develop

Keep work in this directory, ready to reuse when the system is replaced.

```sh
./dev/PROJECT/  # or use YYYY-MM-DD/
./lib/
./bin/
./opt/
./data/
```

## Documentation

Start with `README.md`. Split large sections into child files.

```text
README.md
├── PROMPT.md — thoughts
├── PLAN.md — implementation delta
├── DESIGN.md — shape
│   └── SPEC.md — specification
├── RESOURCES.md — external accounts and services
└── BACKLOG.md — issues, improvements, questions
```

## Ignore

Reference `.gitignore`.

```ignore
tmp/
*.log*
dist/
```
