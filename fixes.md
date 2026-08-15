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

AI has changed the vulnerability landscape. In late 2025, Google observed the
gap between vulnerability disclosure and active exploitation collapse from
weeks to days, alongside AI-assisted attempts to probe targets.
[Google Cloud Threat Horizons H1 2026](https://cloud.google.com/security/report/resources/cloud-threat-horizons-report-h1-2026)

Frontier models can accelerate the other side of that window: OpenAI reports
that its cyber model found previously unknown, high-severity flaws in V8 and
other real-world software. The Linux Foundation launched Akrites to coordinate
open-source remediation before AI-assisted discovery turns into exploitation.
[OpenAI Daybreak](https://openai.com/index/expanding-daybreak-as-the-cyber-defense-window-narrows/)
[Linux Foundation Akrites](https://www.linuxfoundation.org/press/linux-foundation-and-industry-leaders-launch-akrites-to-defend-critical-open-source-software-against-ai-enabled-cyber-threats)

The threat model is the interval after a trusted publisher releases a fix and
before this host adopts it. The security objective is to minimize that
post-fix exposure window without forcibly disrupting active users.

The solution is continuous convergence to the newest trusted, compatible
package set. Manual patching adds human delay; immutable-image replacement and
fleet patching require additional infrastructure. Debian's native package
manager already provides publisher trust, dependency resolution, and safe
package installation, so it is the smallest solution that meets the objective.

The implementation follows from that choice: scheduled APT convergence provides
the cadence, and `needrestart` activates patches in eligible system services.
One update policy covers every configured source, avoiding a second selective
allow-list alongside the source list. User sessions and kernel reboots remain
explicit decisions because they are disruptive.

One check per minute is 43,200 requests per month for one host. For comparison,
npm’s terms describe five million monthly requests as clearly unreasonable.
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
