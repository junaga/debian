# Backup

Maintain this directory when asked. Stop and report failures; report free space below 20%.
Write brief dated `NOTES.md` entries under matching headings. Use relative paths and log links,
not tables. Mark unknown or inferred facts.

## Local backups

`copy/VOLUME/` holds directories: mounts, volumes, partitions.
Summarize the latest backups in `NOTES.md`.

```bash
# No --delete
echo "$(date -Is) START $SRC -> $DST" >> rsync.log
rsync -aHAX --stats --exclude={tmp,dist,node_modules}/ "$SRC/" "$DST/" >> rsync.log 2>&1
echo "$(date -Is) END $SRC -> $DST exit=$?" >> rsync.log
```

## Online accounts

`data/APP/ACCOUNT/` holds downloads: archives, messages, documents,
photos, and contacts. Record each export's date, path, scope and status
in `NOTES.md`.

`keys/` holds credentials: recovery codes, private keys,
seed phrases, and emergency kits. Never print their contents.

## Drive health

Skip unless this directory is a secondary drive's mount point.
Use any tool. Reuse sufficient existing results. Keep reports readable.

Write diagnostic command output to `smart.log` for drive SMART data and self-test
results, and to `scrub.log` for filesystem scrub results where supported.
Record in `NOTES.md`:

- Filesystem: type, UUID, used/free space and scrub result.
- Hardware: model/capacity, manufacture date, powered-on hours and SMART
  summary.
