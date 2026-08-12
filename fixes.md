# Fixes

Deliberate deviations from Debian defaults are documented here to preserve
their intent.

> Start from Debian's defaults. Deviate only when a concrete limitation can be
> removed while preserving or strengthening the guarantees behind those
> defaults.

## Follow the booted ESP

[`desktop/etc/fstab`](./desktop/etc/fstab)

```fstab
/dev/disk/by-designator/esp  /boot/efi  vfat  umask=0077  0  1
```

A FAT UUID identifies one formatting of one ESP. The systemd designator
identifies the ESP that supplied the running bootloader:

```text
/boot/grub/grub.cfg                  insmod bli
LoaderDevicePartUUID                 c859eaf4-6adf-49ed-8dce-e20ca5fb6349
ID_PART_ENTRY_UUID                   c859eaf4-6adf-49ed-8dce-e20ca5fb6349
ID_DISSECT_PART_DESIGNATOR           esp
/dev/disk/by-designator/esp       -> /dev/sdb1
/boot/efi                         -> /dev/sdb1  (ID_FS_UUID=A31E-0712)
```

GRUB's Boot Loader Interface module writes `LoaderDevicePartUUID`; udev matches
that GPT partition and creates the semantic link. The mount therefore follows
the boot path across FAT reformats, device enumeration changes, and multiple
ESPs instead of assuming a filesystem UUID, partition number, disk, or relation
to `/`. The complete chain was observed on this installation and recorded in
`8da3344`.

## Separate the terminal and desktop identities

[`base/setup.sh`](./base/setup.sh),
[`desktop/install.sh`](./desktop/install.sh), and
[`desktop/bin/desktop`](./desktop/bin/desktop)

Every shell, command, and script runs as `root`. A normal user owns only the
graphical session, desktop applications, and their data. Commands that enter
that identity take its account name explicitly:

```sh
bash ./desktop/install.sh hypr
desktop
install-steam hypr
```

Root scripts resolve that account's HOME from the password database. Graphical
helpers run as the normal user and use `$HOME` directly.

## Make deletion a recoverable state of HOME

[`desktop/format.sh`](./desktop/format.sh),
[`desktop/etc/fstab`](./desktop/etc/fstab), and
[`desktop/etc/btrbk/btrbk.conf`](./desktop/etc/btrbk/btrbk.conf)

Debian does not require a separate filesystem for `/home`. This workstation
uses one Btrfs filesystem after the ESP so root and HOME share the SSD's free
capacity. Root is the filesystem's top level and `/home` is its compressed
child subvolume. Btrbk snapshots `/home` every day. `/root` and
`/usr/local` remain outside that snapshot boundary.

The boundary follows ownership of the data rather than the directory tree:

```text
/                    Debian packages and reproducible installation state
/root                terminal identity: shell, SSH, Git, Codex, CLI state
/usr/local           root-owned local programs, projects, and system recipe
/home/hypr           desktop identity: documents and graphical app state
```

Operating-system and application files can be reinstalled from Debian, source
repositories, and other upstream publishers. The desktop HOME contains the
work whose interactive history matters: documents, saves, browser profiles,
messages, editor state, application databases, dotfiles, and caches.
Snapshotting only `/home` spends copy-on-write metadata and retained blocks
on bootable desktop history rather than on system software.

`format.sh` creates the HOME subvolume and assigns its Zstd compression
property. Swap is intentionally left unconfigured until its policy is chosen;
it does not require either a partition or a subvolume.

Terminal administration is deliberately a separate risk domain. Root owns
shell history, SSH and Git identities, Codex conversations, CLI credentials,
projects, and local programs. Those paths are excluded from Btrbk: a desktop
rewind must never silently roll an SSH key, administrator project, or active
terminal-agent database backward. They require an independent archive or
off-machine backup.

The `hypr` account owns UID/GID 1000 and cannot administer the system generally.
The root VT command `exec desktop` performs GPU module setup, then gives
systemd ownership of tty2 and performs a real PAM login whose shell is the
Hyprland launcher.
That gives `hypr` an active logind seat and its own XDG runtime directory;
nesting `runuser` inside root's existing tty would provide neither. When the
desktop exits, the launcher switches back to the original root VT. Graphical
programs, including Kitty, remain unprivileged. Administration, terminal
commands, and setup scripts run directly from the root VT; the graphical
session has no privilege-escalation bridge back to root.

The default systemd target is `multi-user.target`: every boot deliberately
lands at the root VT, and the desktop starts only with `exec desktop`.
No display manager owns or bypasses that transition.

## Load NVIDIA DRM modesetting once at boot

[`desktop/etc/modprobe.d/nvidia-kms.conf`](./desktop/etc/modprobe.d/nvidia-kms.conf)
and [`desktop/bin/desktop`](./desktop/bin/desktop)

Hyprland needs NVIDIA's atomic DRM KMS interface. On this installation,
Debian's selected NVIDIA alternative exposes
`/etc/modules-load.d/nvidia.conf`, which asks `systemd-modules-load.service` to
load `nvidia-drm` during early userspace. The proprietary NVIDIA
`550.163.01` driver defaults its `modeset` parameter to disabled.

Module parameters are fixed when a module is inserted. A later command such
as `modprobe nvidia_drm modeset=1` succeeds when the module is already present,
but it does not change `/sys/module/nvidia_drm/parameters/modeset`. Hyprland
then starts without the required KMS interface and immediately exits. Unloading
and reinserting the active display module would normally apply the parameter,
but that is not safe with this driver build on this machine.

The attempted hot reload produced repeated kernel warnings at
`nv_drm_revoke_modeset_permission` in `nvidia-drm-drv.c:1226`, followed by an
unusable graphical session. Debian tracks the same warning against
`nvidia-driver` version `550.163.01` as
[bug #1128843](https://bugs.debian.org/1128843). The module did unload and
reinsert, so the precise restriction is that it cannot be *safely* reloaded
here, not that the kernel always rejects the operation.

The parameter is therefore supplied before the first insertion:

```modprobe
options nvidia-current-drm modeset=1
```

The names differ because Debian's modprobe rules map the public
`nvidia-drm` request to the version-selected `nvidia-current-drm` module file.
After insertion, the kernel exposes the upstream runtime name `nvidia_drm`.
The complete path is:

```text
/etc/modules-load.d/nvidia.conf
        -> systemd-modules-load.service requests nvidia-drm
        -> modprobe applies /etc/modprobe.d/nvidia-kms.conf
        -> Debian loads nvidia-current-drm with modeset=1
        -> /sys/module/nvidia_drm/parameters/modeset contains Y
```

`systemd-modules-load` initiates loading; `modprobe`, not systemd itself, reads
the option. `desktop/install.sh` copies the tracked file into
`/etc/modprobe.d`, then rebuilds the initramfs after installing the NVIDIA DKMS
module. Keeping the option in the initramfs also makes it effective if a future
boot path loads NVIDIA DRM before the real root filesystem is available.

The launcher's `modprobe nvidia_drm modeset=1` remains idempotent: it loads the
module with the right argument if boot-time loading is absent, and otherwise
leaves the already-correct module alone. It must never unload the active DRM
module. Verify the boot-time state before starting the desktop:

```sh
cat /sys/module/nvidia_drm/parameters/modeset # Y
exec desktop
```

### One mechanism for trash, history, and backup

A desktop trash can implements deletion by renaming a file into a userspace
directory and recording enough metadata to move it back. That is useful but
incomplete: command-line deletion can bypass it, applications can overwrite or
truncate files in place, and moving a large tree to trash is still a visible
file operation. Cloud services commonly add server-side version history, but
only for data already synchronized to that service.

Btrfs snapshots preserve an earlier filesystem tree without renaming its
files. Btrbk creates read-only points in time below normal applications, so
the same recovery mechanism covers deletion, overwrite, truncation, and
renames performed by graphical applications, shells, package managers, or
programs. A snapshot initially shares extents with the live subvolume; extra
space is consumed only as later writes make old extents unique. Deletion thus
becomes a recoverable state transition until retention expires instead of a
special userspace move.

Windows commonly presents trash, file history, and backup as separate systems.
Linux uses the same immutable HOME snapshot as the source for all three:

```text
trash    -> recover a path from a snapshot taken before its deletion
history  -> inspect or recover any path from an earlier snapshot
backup   -> replicate that snapshot to an independent Btrfs filesystem
```

There is no special rename into a trash directory and no application-specific
version store. Normal deletion remains normal deletion; the filesystem history
retains the earlier path and contents until that checkpoint expires. Recovery
can copy one file, restore an application's complete state, or create a new
writable branch from an older HOME.

This is stronger than a trash directory, but it is not literally impossible
to lose data:

- a file created and deleted between snapshots was never captured;
- the schedule gives routine changes a recovery-point objective of at most one
  day, not zero;
- cleanup intentionally expires snapshots and eventually releases their
  extents;
- snapshots share the same disk and do not survive device loss, corruption,
  theft, or destruction;
- snapshots of a running database or virtual machine are filesystem-consistent,
  not necessarily application-consistent.

A local snapshot is not yet a backup because it dies with the SSD. Btrbk turns
the same snapshot into a backup by transferring it incrementally with Btrfs
send/receive to another Btrfs disk or host. The current archive filesystem is
ext4, so it is not configured as a native Btrbk target. Its experimental raw
target mode is deliberately avoided. After an independent target is available
as Btrfs, adding one `target` line to `btrbk.conf` provides the backup copy
without introducing a second history format or recovery model.

### Bootable past desktops

A `/home` snapshot captures the persistent desktop rather than the installed
system: dotfiles, documents, credentials, browser profiles, application
databases, game saves, editor state, and other user data. It intentionally does
not capture the kernel, Debian packages, application binaries under `/usr`, or
system state under `/var`.

An old read-only snapshot can be cloned into a new writable Btrfs subvolume and
used as `/home` for a controlled desktop launch. The current Debian
installation and current programs then open a historical desktop state:

```text
read-only desktop snapshot
          |
          +-> writable historical branch -> /home -> launch desktop

current HOME branch remains preserved and can be selected again
```

This is a bootable past desktop, not a bootable past operating system. Current
application versions may migrate old profile formats when opened, cloud sync
may reapply remote state, and a snapshot made while an application was running
is filesystem-consistent rather than necessarily application-consistent. Test
historical branches offline when remote synchronization could be destructive.
Never mount the read-only snapshot itself as an active HOME: applications need
to write, so boot a disposable writable clone and retain both the source
snapshot and the current HOME branch.

For a smaller rewind, close the application and its background processes,
create a safety snapshot of the present, and restore the complete logical
application state from the chosen checkpoint. A machine reboot is unnecessary
for an isolated application restore; replacing all of `/home` requires
the graphical session to be stopped and should be performed from a root VT or
rescue environment.

### Cache is disposable but not worthless

HOME snapshots initially include `~/.cache`. An application can normally
delete and reconstruct cache data, but reconstructible does not mean devoid of
historical value. A browser cache may retain the only local fragments of a web
page which later disappears: HTML, images, scripts, media segments, or API
responses. Historical caches can therefore contribute to application rewind
and occasionally act as an accidental digital archive.

They are not dependable web archives. Browsers use indexed and versioned cache
formats, evict entries independently, and may need network APIs which no longer
exist. A newer browser may reject an old cache, and a cached dynamic page may be
incomplete. Deliberate preservation should use an archival format, but those
limitations do not make incidental history useless.

The cost is write churn. This installation currently has about 7.8 GiB in
`~/.cache`, including roughly 4.2 GiB of Chrome HTTP cache and 1.7 GiB of Codex
runtimes. A cache capped at 4 GiB can replace its contents many times; snapshots
retain those evicted generations until the checkpoints containing them expire.
The historical space can therefore greatly exceed the live cache size.

Btrfs snapshots cover a complete subvolume and cannot exclude a directory by
pattern. Excluding `~/.cache` would require making it a nested subvolume, or
giving it its own independent snapshot policy. Do not discard it preemptively.
Keep cache history in the initial HOME policy, measure its exclusive retained
space, and separate it only if observed churn competes materially with durable
user history.

### Retention and space

The packaged persistent daily Btrbk timer keeps 31 daily, 12 monthly, and all
yearly HOME snapshots. Hourly and weekly tiers are disabled. Btrbk manages
retention without Btrfs quotas; qgroup rescans previously made ordinary
listing and cleanup expensive on this HOME.

Unchanged snapshots are cheap, while frequently rewritten files retain more
old extents. Unlimited yearly retention therefore requires ordinary capacity
monitoring because a sufficiently long or high-churn history can eventually
exhaust the shared filesystem.

## Autologin Linux virtual terminals

[`base/setup.sh`](./base/setup.sh)

```sh
systemctl edit getty@.service --stdin <<-EOF
	[Service]
	ExecStart=
	ExecStart=-/usr/sbin/agetty --autologin root --noreset --noclear - \${TERM}
EOF
```

Authority is kept on the web, not in a password stored on every machine. A
Linux VT therefore starts the root terminal session without authentication.

Autologin makes the VT a recovery interface independent of root-password
knowledge and network login:

```text
hardware VT          /dev/ttyN  -> agetty --autologin root -> administer
cloud VGA/VNC VT     /dev/ttyN  -> agetty --autologin root -> repair network or SSH
cloud serial console ttyS*/hvc* -> serial-getty@.service (not covered)
```

The drop-in inherits the VT scope and TTY lifecycle from `getty@.service`:

```systemd
ConditionPathExists=/dev/tty0
StandardInput=tty
StandardOutput=tty
TTYPath=/dev/%I
TTYReset=yes
TTYVHangup=yes
TTYVTDisallocate=yes
```

```text
getty@ttyN.service -> agetty --autologin root -> PAM session -> shell
```

systemd opens, resets, hangs up, and deallocates the VT. `agetty` supplies the
terminal parameters and invokes PAM login with the fixed root identity.

The `-` prefix preserves the vendor unit's ignored-exit behavior. The override cannot affect
`serial-getty@.service`, SSH, display managers, rescue mode, containers, or WSL.

Root autologin grants anyone with physical or hypervisor-console access complete
authority. That is deliberate for this single-user workstation recovery model;
multi-user or physically untrusted machines must remove the drop-in.

## Guarantee an SSH identity

[`base/setup.sh`](./base/setup.sh)

```sh
set -e

ssh-keygen -q -N "" \
	-f ~/.ssh/id_ed25519 \
	-C "$EMAIL" || true

cat ~/.ssh/id_ed25519.pub
```

```text
local private key       -> proves identity
remotely registered key -> grants access

no key                  -> create -> print public key
existing key + "n"      -> keep   -> print public key
missing public key      -> cat status 1 -> set -e stops
```

Setup only needs to guarantee an SSH identity and print its public key for
remote authorization. `-q` removes generation chatter, `-N ""` removes the
offline passphrase, and `-f` pins the identity path. The email passed through
`-C` is a management label, not authentication data.

On a repeat run, declining the destructive overwrite returns status `1`.
`|| true` accepts that one path while `set -e` remains active everywhere else.
This interaction was introduced in `0965401`.

## Set the release policy to Debian Testing

[`base/upgrade.sh`](./base/upgrade.sh)

```sh
DEBIAN="testing"

test -f /etc/apt/sources.list && mv /etc/apt/{sources.list,sources.list.disabled}
cat > /etc/apt/sources.list.d/debian.sources <<-EOF
	Types: deb
	URIs: http://deb.debian.org/debian
	Suites: $DEBIAN
	Components: main contrib non-free non-free-firmware
	Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF

apt update --allow-releaseinfo-change
apt full-upgrade --yes
```

An installer, WSL distribution, or cloud image only supplies the initial
filesystem. The repository supplies the release policy. Replacing
`debian.sources` makes every installation track the `testing` suite instead of
the release or codename chosen by its bootstrap.

`testing` is the integrated next Debian release: packages enter it through
migration from `unstable`. Following the suite alias moves the complete Debian
package graph across release codenames instead of updating selected applications
outside APT. That difference includes current development runtimes, not merely
new desktop applications:

| Runtime | Stable `trixie` | Testing `forky` |
| --- | ---: | ---: |
| Node.js | 20.19.2 | 24.18.0 |
| Go | 1.24.4 | 1.26.3 |
| Python | 3.13.5 | 3.14.6 |

Package versions were recorded on 2026-07-22.

`--allow-releaseinfo-change` accepts the initial suite change; `full-upgrade`
resolves its dependency transitions. The source replacement dates to `28274ab`.

## Standardize on NetworkManager

[`base/upgrade.sh`](./base/upgrade.sh)

Debian [recommends NetworkManager for desktops but not
servers](https://www.debian.org/doc/manuals/debian-reference/ch05.en.html#_the_modern_network_configuration_for_desktop).
This repository uses it on every host to keep one configuration format and CLI.
It is preferred over `systemd-networkd` because it also covers interactive
Wi-Fi, mobile broadband, VPN profiles, secrets, runtime switching, checkpoints,
and desktop integration.

NetworkManager is production-ready: RHEL uses it for bare-metal and virtual
servers, hypervisors, container hosts, bonds, bridges, VLANs, routes, VPNs, and
[fleet automation](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html-single/configuring_and_managing_networking/index).
OpenShift also uses it beneath
[nmstate](https://docs.redhat.com/en/documentation/openshift_container_platform/4.20/observability/networking_operators/index)
to configure cluster nodes in production.

The upgrade imports `/etc/network/interfaces`, migrates its profiles to native
NetworkManager keyfiles, stops the old service, and restarts NetworkManager to
complete the handover. WSL and containers are skipped because their host owns
their networking.
