# Desktop

## Source fidelity

`desktop/` describes the desired live workstation. Package defaults, including
their enabled services, are part of that state. Keep them unless this directory
records a deliberate replacement or disablement; an idle default service is not
by itself a reason to remove it.

## Installation

Hyprland configuration for the existing `junaga` account. It contains this
workstation's disk identifiers and hardware settings, so review
[fstab](./etc/fstab) and [install.sh](./install.sh) before using it elsewhere.

The installer requires Btrfs for `/` and a Btrfs subvolume at `/home`. On a
fresh installation with an empty `/home`, prepare it before creating the user:

```sh
sudo bash desktop/format.sh
```

After creating the user in `dev` and `sudo`, run from the repository root:

```sh
sudo sh base/install.sh
# Fresh home only:
cp -r base/home/. ~/.
sh base/init.sh
bash desktop/install.sh
```

The installer replaces home configuration and rebuilds dconf on every run. On
an existing workstation, apply individual changes instead. It also changes
networking, installs packages, and enables services. The swap file at
`/var/lib/solidus/solidus.swap` must already exist.

## SSH

Install the stock OpenSSH server and enable its default service:

```sh
sudo bash desktop/install-ssh.sh
```

## Performance

Performance history runs automatically in the background. No dashboard or manual
capture is required. **Win+L** marks “slowdown started now” and briefly confirms
it; recording continues whether or not you press the shortcut.

Data stays locally in the root-only `/var/log/atop/` directory:

| File                | Contents                                                        |
| ------------------- | --------------------------------------------------------------- |
| `atop_YYYYMMDD`     | Full process inventories every minute, plus incident snapshots. |
| `gpu.jsonl`         | Five-second CPU, paging, pressure, GPU and disk counters.       |
| `incidents.jsonl`   | Automatic reports every 15 minutes, including manual markers.   |

Reports examine the preceding 16 minutes, flag resource pressure, and include
process context and GPU/disk percentiles. Resource-pressure spikes and Win+L
markers trigger extra process snapshots, limited to 120 extra samples per day.
The five-second resource timeline continues after that burst allowance is used.
Win+L markers also appear in
the system journal under `performance-event`. Nothing is uploaded.

### Retention and interpretation

The storage target is roughly **200 MB/day**. Routine full inventories run once
a minute instead of every five seconds; reports omit repeated full text. Brief
resource spikes remain visible in the five-second timeline, but full thread
detail between incidents is less frequent. Extra snapshots are skipped once the
day's raw file reaches 160 MB to reserve space for the routine history.

Raw history has seven-day cleanup. GPU and report logs rotate daily, retain seven
compressed archives, and request earlier rotation above 16 MiB when logrotate
runs. **These are time/rotation limits, not a hard disk-space cap.** Storage use
varies with process activity; the 16 MiB setting is not an enforced file quota.

The reports identify investigation candidates, not proven causes. Disk P99 is
the percentile of interval-average request durations, not the latency of
individual requests or clicks. Background history can still help if a freeze
prevents the shortcut from executing.

Configuration: [Atop](./etc/default/atop),
[log rotation](./etc/logrotate.d/performance-event), and
[report helper](./bin/performance-event). Implementation and later findings are
tracked in [issue #22](https://github.com/junaga/debian/issues/22); deferred tuning
is in [issue #21](https://github.com/junaga/debian/issues/21).

## Removable storage

[Filesystem configuration](./etc/fstab) identifies disks by UUID and mounts them
on demand. Missing removable disks do not block boot.

| Mount          | Filesystem | Purpose                              |
| -------------- | ---------- | ------------------------------------ |
| `/mnt/archive` | exFAT      | File archives; no Unix metadata.     |
| `/mnt/backup`  | Btrfs      | Backups that preserve Unix metadata. |
| `/mnt/stick`   | VFAT       | Removable USB storage.               |

Keep active development workspaces in `/usr/local/dev`. The FAT/exFAT ownership
options assume UID 1000 and GID 1001; check these before reusing the configuration.

## Temperature and fans

The installer adds `lm-sensors` for temperature monitoring. This workstation
does not expose fan-speed or PWM controls to Linux, so it does not install
`fancontrol`. Use `sensors` to read temperatures. Set a fan curve through the
ASUS firmware's Q-Fan controls.

## Appearance

[Appearance settings](./dconf.d/appearance) select dark mode for GTK applications.
The installer compiles them into the user’s dconf database. Applications with
independent theme settings should use their system/default option.

## Recover a stuck desktop

On the desktop virtual terminal, press **Alt+Print Screen+R** to return the
keyboard to console mode, then **Ctrl+Alt+F1** to reach the console shell.
Magic SysRq is handled by the kernel and can work when Hyprland stops responding.
Release the keys between combinations.

**Alt+Print Screen+K** on tty2 terminates the entire graphical session; use it
only when that is intended. `Print Screen` is the `SysRq` key.

![Hyprland desktop](./hypr.webp)
