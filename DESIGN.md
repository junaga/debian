# Debian Design Deviations `DDD`

Debian 13 `trixie` is the baseline. We deviate from its defaults only when
doing so significantly improves the system. This document records each
decision and its rationale. Numbers follow first documentation; removed decisions
leave gaps.

## 2. Autologin on Linux virtual terminals

[`initacc.sh`](./initacc.sh) enables autologin for the account running setup on
Linux virtual terminals, providing recovery access without a network connection.
Physical or hypervisor-console access grants access to that account. Serial
consoles, SSH, and display managers retain their own login settings.

## 9. Replace `apt-secure` with HTTPS

All package sources use HTTPS. HTTPS uses system CAs instead of APT's GPG
(`.gpg`) keys. [`base/apt/apt.conf`](./base/apt/apt.conf) disables `apt-secure`
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
