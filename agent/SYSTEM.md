```
LANG="en-US-IETF" # Internet English
DATE="2026-10-23"
```

# DDD - Debian Design Deviations

Debian 13 is the system base. We opt out where better practices exist.
This document records those deviations.

## DDD 0: Default Context

- RFC 2119: [#1](https://www.rfc-editor.org/rfc/rfc2119.html#section-1) - Required, [#3](https://www.rfc-editor.org/rfc/rfc2119.html#section-3) - Recommended, [#5](https://www.rfc-editor.org/rfc/rfc2119.html#section-5) - Optional.
- RFC 761: [#2.10](https://www.rfc-editor.org/rfc/rfc761.html#section-2.10) - Robustness Principle.
- RFC [6592](https://www.rfc-editor.org/rfc/rfc6592.html): The Null Packet.

Historical operating system abstractions that sparked paradigm shifts in the computer industry.

| Paradigm  | Release | Implementation     | Siblings       |
| --------- | ------- | ------------------ | -------------- |
| `file`    | 1971    | First Edition Unix | —              |
| `socket`  | 1983    | 4.2BSD             | macOS, Windows |
| `package` | 1996    | Debian 1.1 Buzz    | Ubuntu         |
| `service` | 2015    | Debian 8.0 Jessie  | Arch, NixOS    |

## DDD 9: Authenticate APT sources

Use HTTPS and keep Debian's default APT signature checks. Scope each
third-party repository to its own signing key with `Signed-By`. Use the
vendor's keyring for package-managed sources. Keep keys for sources managed
by this repository in [base/etc/apt/keyrings](../base/etc/apt/keyrings).

## DDD 11: Install updates every 30 minutes

AI shortens the interval between disclosure and exploitation: Google observed
it collapse from weeks to days in late 2025, and OpenAI has demonstrated that
frontier models can find previously unknown, high-severity flaws in real-world
software. [Google Cloud Threat Horizons H1 2026](https://cloud.google.com/security/report/resources/cloud-threat-horizons-report-h1-2026)
[OpenAI Daybreak](https://openai.com/index/expanding-daybreak-as-the-cyber-defense-window-narrows/)
Akrites coordinates open-source remediation before those discoveries become
exploitation. [Linux Foundation Akrites](https://www.linuxfoundation.org/press/linux-foundation-and-industry-leaders-launch-akrites-to-defend-critical-open-source-software-against-ai-enabled-cyber-threats)

The threat is post-fix exposure: the time from a trusted publisher releasing a
fix to this host installing it. This host minimizes that interval by upgrading
eligible packages every 30 minutes and using `needrestart` to activate eligible
system services. The scheduled APT upgrade leaves package removals and updates
to the kernel, bootloader, and initramfs for a manual upgrade. User-session
restarts and reboots also remain manual.

The installer deploys [base/upgrade.sh](../base/upgrade.sh) to a root-owned
`/usr/libexec/system-upgrade` and schedules that copy through cron.

Containers install packages when the image is built and receive updates through
image rebuilds. Omit the host automatic-update cron job from container builds.

## DDD 12: The `WORK` Environment Variable

The `WORK` directory is our workspace. It separates intentionally created files from `HOME` artifacts, simplifying development and agentic engineering.

### The default `WORK="/usr/local"`

`WORK` can be any directory, such as `$HOME` or `$HOME/work`.
Our [`/etc/environment`](../base/etc/environment) defaults to `/usr/local`.

```
/                 root (kernel space)
└── usr/          user space
    └── local/    work space
```

- `/usr/local/bin` is already on `PATH`.
- The [FHS](https://refspecs.linuxfoundation.org/FHS_3.0/fhs/ch04s09.html) reserves it.
- Our [web server](../base/etc/apache2/apache2.conf) serves it at `http://localhost/`.

## DDD 13: Use systemd-boot on UEFI hosts

Use Debian's `systemd-boot` package instead of GRUB. Each installation publishes
uniquely named boot entries, kernels, and initramfs images to the shared EFI
partition through Debian's kernel hooks. System roots may remain Btrfs subvolumes;
boot selection uses EFI variables instead of scanning root filesystems.

Enable zswap when the [desktop function](../base/etc/bash.bashrc) starts a session.
