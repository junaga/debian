# Debian Design Deviations `DDD`

Unix, Linux, and Debian 13 (`trixie`) conventions are the baseline. We deviate from them
only when doing so significantly improves the system. This document records each
decision and its rationale.

## 9. Replace `apt-secure` with HTTPS

All package sources use HTTPS. HTTPS uses system CAs instead of APT's GPG
(`.gpg`) keys. [`base/etc/apt/apt.conf`](./base/etc/apt/apt.conf) disables `apt-secure`
enforcement for "unauthenticated" repositories and packages.

If a repository serves signed `InRelease` without a `.gpg` key, APT warns but
continues.

## 11. Install updates every two minutes

AI shortens the interval between disclosure and exploitation: Google observed
it collapse from weeks to days in late 2025, and OpenAI has demonstrated that
frontier models can find previously unknown, high-severity flaws in real-world
software. [Google Cloud Threat Horizons H1 2026](https://cloud.google.com/security/report/resources/cloud-threat-horizons-report-h1-2026)
[OpenAI Daybreak](https://openai.com/index/expanding-daybreak-as-the-cyber-defense-window-narrows/)
Akrites coordinates open-source remediation before those discoveries become
exploitation. [Linux Foundation Akrites](https://www.linuxfoundation.org/press/linux-foundation-and-industry-leaders-launch-akrites-to-defend-critical-open-source-software-against-ai-enabled-cyber-threats)

The threat is post-fix exposure: the time from a trusted publisher releasing a
fix to this host installing it. This host minimizes that interval by converging
every two minutes across every configured source and using `needrestart` to activate
eligible system services; user sessions and kernel reboots remain explicit
because they are disruptive. That is 21,600 requests per month for one host;
npm calls five million monthly requests clearly unreasonable.
[npm Open Source Terms](https://docs.npmjs.com/policies/open-source-terms/)

Containers install packages when the image is built and receive updates through
image rebuilds. Omit the host automatic-update cron job from container builds.

## 12. Keep administration state below the local workspace

Preserve directory roles: `/` anchors the system and its mount points, `/usr`
holds system resources, and `/usr/local` contains our local administration and
development files.

Keep projects in `dev` and root's home directory in `data`, below the workspace
and easy to inspect alongside local work. Treat
`/usr/local` as the persistence boundary between our own files and the replaceable
operating system: retaining or mounting it lets us reinstall the OS or replace a
container while preserving projects and the administration environment.
The default `PATH` already includes `/usr/local/bin`, so local commands fit this
workspace without adding a home-specific `bin` directory to the search path.

Keep `/root` as a compatibility symlink to `/usr/local/data`, preserving existing
home paths and account settings without changing `/etc` solely to relocate
storage. This follows the [usr merge](https://systemd.io/THE_CASE_FOR_THE_USR_MERGE/)
pattern of retaining old paths as symlinks; this home relocation is our own
convention.
