# Btrfs consolidation

The SanDisk Debian Live USB has a writable `BTRFS-CONVERT` tools partition.
The current `/home/hypr` is staged and verified at
`/mnt/archive/home-consolidation-20260812/hypr.tar`. Old HOME snapshots were
intentionally deleted; the new `/home` snapshot history starts empty.

Reboot and repeatedly press **F8** at the ASUS logo. Select the entry beginning
**UEFI:** for **SanDisk Ultra USB 3.0**, then select **Live system (amd64)**.
Open a terminal after XFCE starts and run:

```sh
sudo -i
mkdir -p /consolidate
mount LABEL=BTRFS-CONVERT /consolidate
/consolidate/run-btrfs-consolidation
```

Type `CONSOLIDATE` when prompted. The program checks the exact disks, archive,
source generation, both Btrfs filesystems, and partition table before changing
storage. It then removes partition 3, expands partition 2, grows the existing
Btrfs filesystem, restores HOME, creates native HOME/swap subvolumes, rebuilds
the boot files, creates the first fresh HOME snapshot, performs a final offline
Btrfs check, and reboots. HOME restoration displays an exact file-count progress
bar. If power or another recoverable error interrupts the procedure after the
partition expansion, boot the same USB and run the same command again; it
recognizes the expanded layout and restarts the derived restore from the
verified archive. A completion marker prevents accidental reruns.
