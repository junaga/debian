## Environment

```sh
# DEFAULT
WORK="$HOME"
REPO="$WORK/src"
AGENT="codex"
```

Resolve variables in order; first set value wins:

1. Run `env`.
2. Read `$WORK/.env`.
3. Use `DEFAULT`s.

- Read `$WORK/AGENTS.md` for development.
- Read `$REPO/AGENTS.md` for administration.
