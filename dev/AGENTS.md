## Development workspace

On container deployments, work in `$WORK/dev` (currently `/usr/local/dev`). The mounted volume persists across rebuilds and redeploys.

```sh
$WORK/dev/PROJECT/
$WORK/dev/tmp/YYYY-MM-DD/
$WORK/dev/bin/
$WORK/dev/lib/
$WORK/dev/doc/
```

Put packages and system configuration in `$REPO` (default `/usr/local/src`) so the next image contains them.
