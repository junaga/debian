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

## Add Upstream Package Repositories

[`base/repo/nvidia.sources`](./base/repo/nvidia.sources),
[`base/repo/nodejs.sources`](./base/repo/nodejs.sources)

Debian stable is the base system. Upstream vendor repositories are added only
when Debian does not provide the required current software.

These sources use HTTPS-only trust through `Trusted: yes`. APT accepts their
repository metadata without a separate signing key, so each source extends the
trust boundary to its publisher, HTTPS delivery path, and the host certificate
store.

## Install updates every 60 seconds

AI shortens the interval between disclosure and exploitation: Google observed
it collapse from weeks to days in late 2025, and OpenAI has demonstrated that
frontier models can find previously unknown, high-severity flaws in real-world
software. [Google Cloud Threat Horizons H1 2026](https://cloud.google.com/security/report/resources/cloud-threat-horizons-report-h1-2026)
[OpenAI Daybreak](https://openai.com/index/expanding-daybreak-as-the-cyber-defense-window-narrows/)
Akrites coordinates open-source remediation before those discoveries become
exploitation. [Linux Foundation Akrites](https://www.linuxfoundation.org/press/linux-foundation-and-industry-leaders-launch-akrites-to-defend-critical-open-source-software-against-ai-enabled-cyber-threats)

The threat is post-fix exposure: the time from a trusted publisher releasing a
fix to this host installing it. This host minimizes that interval by converging
every minute across every configured source and using `needrestart` to activate
eligible system services; user sessions and kernel reboots remain explicit
because they are disruptive. That is 43,200 requests per month for one host;
npm calls five million monthly requests clearly unreasonable.
[npm Open Source Terms](https://docs.npmjs.com/policies/open-source-terms/)


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
