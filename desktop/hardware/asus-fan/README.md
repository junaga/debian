# ASUS PRIME Z370-P WMI profile controller

This is a reviewable, board-gated kernel module for the native ASUS WMI fan
policy methods discovered in the live BMOF schema. It is intentionally inert
when loaded. It matches only `ASUSTeK COMPUTER INC.` / `PRIME Z370-P` and
exposes a debugfs directory:

```text
/sys/kernel/debug/asus-z370-wmi-control/status
/sys/kernel/debug/asus-z370-wmi-control/snapshot
/sys/kernel/debug/asus-z370-wmi-control/last_result
/sys/kernel/debug/asus-z370-wmi-control/apply_profile
```

`status` performs getter calls for fan types 0 and 1. Writing `READ` to
`apply_profile` captures a snapshot. Writing `SILENT` or `STANDARD` preserves
each policy group's current `AUTO` mode and low limit, changes only the profile, and
requires successful readback of both groups. Any failed write or mismatched
readback attempts to restore every group touched by the operation.

The DFAN request uses the BMOF layout directly: a one-byte fan type, a counted
UTF-16LE mode string, four-byte aligned low limit, and a counted UTF-16LE
profile string. The standalone protocol test checks these offsets and parses
the observed GFAN response shape.

Only native firmware fan profiles are changed. No raw NCT/PWM register writes,
manual curve writes, GPE changes, or boot option changes are made. Physical
header mapping and profile persistence across reboot are unverified. The module is not loaded by the build or install steps.

Build and protocol tests:

```sh
make
make test
```

Use the installed helper:

```sh
sudo /usr/local/bin/asus-fan status
sudo /usr/local/bin/asus-fan silent
sudo /usr/local/bin/asus-fan standard
```

Loading alone performs no WMI getter or setter call. The helper loads the
module on demand; only `silent` and `standard` change profiles. After a kernel
upgrade, rerun `sudo bash desktop/install-hardware-control.sh` from the
repository root to rebuild for the running kernel.
