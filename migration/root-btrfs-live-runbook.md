# Root Btrfs live conversion

The prepared SanDisk USB boots Debian 13.6 Live XFCE and has a separate
`BTRFS-CONVERT` tools partition. The tools partition contains the reviewed
converter, a one-command runner, this runbook, and the conversion transcripts.

Reboot and repeatedly press **F8** while the ASUS logo is visible. In the
one-time boot menu select the entry beginning **UEFI:** for **SanDisk Ultra USB
3.0**. At the Debian menu select **Live system (amd64)**, not **Start
installer** or an entry under the installer menus. Open the terminal after XFCE
starts and run:

```sh
sudo -i
mkdir -p /convert
mount LABEL=BTRFS-CONVERT /convert
/convert/run-root-btrfs-conversion
```

The runner performs the complete read-only offline preflight first. It asks for
the exact word `CONVERT` only after that preflight passes. The converter then
shows an eight-phase bar, streams the native `e2fsck` and `btrfs-convert`
progress, saves a timestamped log on `BTRFS-CONVERT`, verifies the converted
filesystem and boot artifacts, and reboots into the installed system.

Do not select an installer option, mount the Samsung root partition manually,
run a balance, or delete `ext2_saved`. If any check fails, leave the machine in
the live environment and inspect the newest `convert-root-to-btrfs-*.log` file
on the tools partition.
