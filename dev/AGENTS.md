## Development workspace

On container deployments, work in `$WORK/dev` (currently `/usr/local/dev`). The mounted volume persists across rebuilds and redeploys.

```sh
$WORK/dev/PROJECT/
$WORK/dev/tmp/YYYY-MM-DD/
$WORK/dev/bin/
$WORK/dev/lib/
$WORK/dev/doc/
```

Use `$REPO` (default `/usr/local/src`) as the image source reference. Commit package and system configuration changes to the upstream repository, then build and deploy a new image.
