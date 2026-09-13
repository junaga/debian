# Debian Design Deviations `DDD`

Debian 13 `trixie` is the baseline. We deviate from its defaults only when
doing so significantly improves the system. This document records each
decision and its rationale.

## Replace `apt-secure` with HTTPS

All package sources use HTTPS. HTTPS uses system CAs instead of APT's GPG
(`.gpg`) keys. [`base/repo/apt.conf`](./base/repo/apt.conf) disables `apt-secure`
enforcement for "unauthenticated" repositories and packages.

If a repository serves signed `InRelease` without a `.gpg` key, APT warns but
continues.

## Shared local workspace

One person uses separate Unix accounts for desktop configurations, with one
active desktop at a time. A non-root maintainer owns `/usr/local`, consolidating
local software and intentionally shared application profiles. Bind-mount it at
`~/.local` and link `~/bin` to `.local/bin`; homes retain documents and dotfiles.
The bind mount preserves home paths inside Steam containers. Cross-account
permissions and profile compatibility still require validation.

Shared profiles can contain personal saves and credentials: sharing does not
make them disposable. Home Btrfs snapshots exclude the mounted tree, so its
retention policy is separate. Open issue: exclude personal installations from
root's PATH and system-wide library/resource discovery.

## Install updates every two minutes

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

## Autologin on Linux virtual terminals

Debian’s `getty@.service` displays a login prompt and requires credentials.
This single-administrator system treats the local console as its recovery path
when the network is unavailable. [`base/init.sh`](./base/init.sh) therefore
replaces the virtual-terminal prompt with a session for the current user:

```systemd
[Service]
ExecStart=
ExecStart=-login -f $USER
```

The override affects only `getty@.service` instances, not serial consoles, SSH,
or display managers. Anyone with physical or hypervisor-console access receives
the current user's access.

## Agent development

The agent-development doctrine is kept in
[`base/prompt/readme.md`](./base/prompt/readme.md). It describes principles and
standard Linux tools rather than imposing a project-specific orchestrator.
