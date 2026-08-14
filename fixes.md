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

[`desktop/install.sh`](./desktop/install.sh) and
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

## Use `/usr/local` as the terminal workspace

[`base/home/.bashrc`](./base/home/.bashrc)

Interactive root shells start in `/usr/local`. HOME remains shell and account
state; `/usr/local` is the administrator workspace for local programs,
projects, and the system recipe. Non-interactive shells keep their caller's
working directory.

## Autologin on Linux virtual terminals

Debian’s `getty@.service` displays a login prompt and requires credentials.
This single-administrator system treats the local console as its recovery path
when the network is unavailable. [`base/login.sh`](./base/login.sh) therefore
replaces the virtual-terminal prompt with a session for the current user:

```systemd
[Service]
ExecStart=
ExecStart=-login -f $USER
```

The override affects only `getty@.service` instances, not serial consoles, SSH,
or display managers. Anyone with physical or hypervisor-console access receives
the current user's access.

## Initialize the terminal identity

[`base/login.sh`](./base/login.sh)

Base configures Git with the local administrator and host identity:

```sh
git config --global user.name "$USER"
git config --global user.email "$USER@$HOSTNAME"
```

## Add Upstream Package Repositories

[`base/repo/nvidia.sources`](./base/repo/nvidia.sources),
[`base/repo/nodejs.sources`](./base/repo/nodejs.sources)

Debian stable is the base system. Upstream vendor repositories are added only
when Debian does not provide the required current software.

These sources use HTTPS-only trust through `Trusted: yes`. APT accepts their
repository metadata without a separate signing key, so each source extends the
trust boundary to its publisher, HTTPS delivery path, and the host certificate
store.

## Check for package updates every 60 seconds

[`base/install.sh`](./base/install.sh) and
[`base/upgrade.sh`](./base/upgrade.sh)

Cron starts the upgrade script once per minute, its fastest standard schedule.
The script takes a non-blocking self-lock, so an active upgrade makes the next
tick exit instead of queuing or overlapping. This minimizes the delay between a
trusted repository publishing an update and this host beginning installation.

## Standardize on NetworkManager

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
