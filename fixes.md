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

## Autologin Linux virtual terminals

[`base/setup.sh`](./base/setup.sh)

```sh
sudo systemctl edit getty@.service --stdin <<-EOF
	[Service]
	ExecStart=
	ExecStart=-login -f $USER
EOF
```

Authority is kept on the web, not in a password stored on every machine. A
Linux VT therefore starts the local user session without authentication.

Autologin makes the VT a recovery interface independent of root-password
knowledge and network login:

```text
hardware VT          /dev/ttyN  -> login -f $USER -> recover through sudo
cloud VGA/VNC VT     /dev/ttyN  -> login -f $USER -> repair network or SSH
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
getty@ttyN.service -> login -f <user> -> PAM session -> shell
```

systemd opens, resets, hangs up, and deallocates the VT. `login -f` skips
authentication while preserving normal account and session setup. For this
fixed VT scope, `agetty` mainly adds an `/etc/issue` banner and username prompt
that autologin does not use.

The heredoc expands `$USER` when setup writes the drop-in, and the `-` prefix
preserves the vendor unit's ignored-exit behavior. The override cannot affect
`serial-getty@.service`, SSH, display managers, rescue mode, containers, or WSL.
The reduction to direct `login` is recorded in `833393a`.

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
