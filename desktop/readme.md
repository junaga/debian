# Desktop

## User model

Use the existing `junaga` account for graphical sessions, terminals, SSH, and
development. `desktop` starts Hyprland as the current user; applications share
that user's home and credentials.

| Identity or path | Purpose |
| ---------------- | ------- |
| `junaga` | Primary workstation account; home `/home/junaga`. |
| `dev` | Primary group for shared workspace access; not a login account. |
| `sudo` | Administration group; desktop policy grants its members passwordless sudo. |
| `quant` | Separate retained account; not used to launch the desktop. |
| `/usr/local/src` | This system configuration repository. |
| `/usr/local/dev` | Development workspaces. |
| `/home/junaga` | Personal configuration, credentials, and application state. |

The installer uses the current account and sudo for system changes. It does not
create or rename accounts, change group membership, or recursively transfer
workspace ownership. The current workspace directories are owned by
`junaga:dev`. See [design.md](../design.md#rootless-local-workspace) for the
ownership and shared-group policy.

## Archive disks

The current 1.8 TB ext4 archive mounts at `/mnt/archive`, identified by UUID
`44db4ead-1413-4041-b963-33e5c634c381`. It preserves Unix ownership, permissions,
and symlinks. This is the permanent location for archived development projects
and workstation backups. `/usr/local/archive` is a symlink to this mount, giving
it a convenient path beside `/usr/local/src` and `/usr/local/dev`.
[`etc/tmpfiles.d/archive.conf`](./etc/tmpfiles.d/archive.conf) recreates the link
at boot if missing; the desktop installer also applies it immediately.

The older 223.6 GB exFAT disk labeled `archive1` mounts at `/mnt/archive1`.
These are two separate physical disks, not duplicate mounts of one archive.
Its entry in
[`etc/fstab`](./etc/fstab) identifies the filesystem by UUID `06AA-08E8`, so the
path survives changes to Linux device names. Systemd mounts it on first access;
`nofail` lets the workstation boot when the disk is disconnected, with a
five-second device timeout for access while absent.

Files appear as `junaga:dev` (UID 1000, GID 1001), with writable group access,
non-executable regular files, and `nosuid,nodev`. exFAT does not retain Unix
ownership, permissions, or symlinks; keep active Git worktrees in
`/usr/local/dev` and use this disk for archives. Check the numeric IDs before
reusing this configuration on another workstation.

Both archives use UUID-based automounts. To apply these entries after merging
them into `/etc/fstab`:

```sh
sudo mkdir -p /mnt/archive /mnt/archive1
sudo install -D -m 0644 desktop/etc/tmpfiles.d/archive.conf /etc/tmpfiles.d/archive.conf
sudo systemd-tmpfiles --create /etc/tmpfiles.d/archive.conf
sudo systemctl daemon-reload
sudo systemctl start mnt-archive.automount mnt-archive1.automount
ls /mnt/archive /mnt/archive1
findmnt /mnt/archive
findmnt /mnt/archive1
```

## NVIDIA GPU, [hypr.land](https://hypr.land) and Google Chrome

On a fresh Btrfs installation, prepare the empty `/home` as root before creating
`junaga`:

```sh
bash ./desktop/format.sh
```

For an existing workstation, `/` must use Btrfs and `/home` must already be a
Btrfs subvolume. This installer contains this host's filesystem UUID and hardware
configuration; review `desktop/etc/fstab` and the other system files before
installing on another machine. It also expects a prepared `/swapfile`. Review
[known source/live differences](../plan.md#source-and-live-differences) before a
rerun on this workstation. The desktop installer copies system configuration,
installs iwd, disables `networking.service`, and enables systemd-networkd and iwd.
It installs static Cloudflare DNS. A live migration must transfer interface
ownership with recovery prepared. Package installation and automatic updates can
also restart services.

Create the intended account and grant its required `dev` and `sudo` membership
before installing on a fresh system. Run the following as `junaga` from the
repository root. Keep `base/login.sh` and `desktop/install.sh` in the user's
session; they request privileges internally. The base home copy is for a fresh
home only; merge existing files while preserving SSH configuration and Codex
project, plugin, and MCP settings. The desktop home configuration and dconf
database are installed only when initializing a fresh desktop home.

```sh
sudo sh ./base/install.sh
# Fresh home only; merge individual files when updating an existing home.
cp -r ./base/home/. ~/.
sh ./base/login.sh

bash ./desktop/install.sh

sudo reboot
```

```sh
# From your local VT:
desktop
```

## Motherboard monitoring and fans

The desktop installer installs Debian's `lm-sensors` for temperature and fan
readings and `fancontrol` for temperature-based fan curves. It does not change
fan profiles or configure a fan curve.

To install these packages on an existing system, run from the repository root:

```sh
sudo bash desktop/install-hardware-control.sh
sensors
```

## Dark mode

The readable [appearance settings](./dconf.d/appearance) select dark mode and
`Adwaita-dark` for native Wayland GTK apps. During fresh desktop creation, the
installer uses `dconf compile` from `dconf-cli` to build `~/.config/dconf/user`.
Only the source is tracked; the binary database is generated during installation.
The desktop launcher does not reset preferences at startup.

`xdg-desktop-portal-gtk` publishes the preference through the XDG Settings portal;
Hyprland's packaged portal configuration selects GTK for this interface.
Applications with their own appearance settings should use their system/default
option. Legacy X11 apps may need separate theme configuration.

## Recover a stuck desktop

Magic SysRq is handled by the kernel, so it can recover the keyboard even when
Hyprland no longer processes input. On the broken desktop VT, press
`Alt+Print Screen+R` to return the keyboard to console mode, then press
`Ctrl+Alt+F1` to reach the console shell. Use `Alt+Print Screen+K` on tty2 only
when the entire graphical session should be terminated.

`Print Screen` is the `SysRq` key. Release the keys between combinations. The
`K` operation intentionally terminates the entire graphical session.

![Hyprland Desktop Screenshot](./hypr.webp)
