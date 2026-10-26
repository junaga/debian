# `HRR` - Hardware Resource Record

Understand the system, verify assumptions and investigate uncertainty. Produce a dated record of its hardware and condition.

- Communicate any concerning `HEALTH` or `USAGE` readings.
- Record names and stats, not serial numbers.
    - Group duplicate components with `Nx` (e.g. `2x memory`).
    - Request labels for naming conflicts (e.g. `HDD` -> `BACKUP_HDD`).
        - Assume, and confirm, the [`RPL`](#rpl---recommended-partition-layout).

## Example `HRR`

- `./doc/host/$HOSTNAME.env`

```sh
# Hardware Resource Record
HRR="2026-10-22"

# --------------------
# Storage
# --------------------
SSD="Micron 2450"
SSD_SIZE="475.7 GiB" # Filesystem capacity.
SSD_USAGE="29.4%" # Filesystem usage.
SSD_HEALTH="100%" # Drive endurance remaining.

HDD="Second Disk"
HDD_HEALTH="passed" # SMART result.
BACKUP_HDD="Third Disk"

# --------------------
# Computer
# --------------------
CPU="Intel Core i5-1235U"
CPU_ARCH_YEAR="2021" # Microarchitecture debut.
CPU_VENDOR_HQ_COUNTRY="US"

RAM="2x HMAA1GS6CJR6N-XN" # Module part number.
RAM_SIZE="2x 8 GiB"
RAM_TYPE="DDR4"

HW="Acer Aspire A515-57"
HW_VENDOR_HQ_COUNTRY="TW"

# --------------------
# Components
# --------------------
WAN="4G LTE"
WAN_OPERATOR="E-Plus"

BTT="Panasonic AP19B5L"
BTT_SIZE="53 Wh"
BTT_HEALTH="72.6%" # Full charge ÷ design capacity.
```

# `RPL` - Recommended Partition Layout

- Prefer one filesystem per drive.
    - Filesystems must contain a `UUID`.
- Where supported, use subvolumes instead of partitions.
    - Any volume should have a unique `label`.
        - `BACKUP` volumes must be on separate drives.

```
GPT
├─ MBR
├─ ESP / MSR / WinRE / …
├─ PART
│  └─ FS
│     ├─ ROOT
│     ├─ HOME
│     └─ WORK
└─ LBA_LAST
```

# `LPB` - Low Priority Batch

Batches run unattended across all hardware. System and desktop processes take priority.

- Keep headroom for responsive system and desktop use, including free disk space.
    - Reduce the combined LPB allowance as foreground demand grows.
- On routers you control, prioritize foreground traffic over batches.
- Use `systemd-run` for quick batches.

```ini
[Slice]
CPUWeight=10
IOWeight=10
MemoryHigh=50%
```
