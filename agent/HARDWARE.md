## `BBP` - Background Batch Process

System and desktop processes must take priority over Background batches.

- Keep headroom for responsive system work and desktop use, including free disk space.
  - Reduce the combined BBP allowance as foreground demand grows.
- On routers you control, prioritize foreground traffic over batches.
- Use `systemd-run` for quick batches.

```ini
[Slice]
CPUWeight=10
IOWeight=10
MemoryHigh=50%
```

## `RPL` - Recommended Partition Layout

- Prefer one filesystem per drive.
  - Filesystems must contain a `UUID`.
- Where supported, prefer subvolumes over partitions.
  - Every volume should have a unique `label`.
    - `BACKUP` volumes must be on separate drives.
- Avoid Windows/Linux/etc `HDD` installs.
  - Default `SWAP` to `RAM / 2` with zswap.

```
GPT
├─ MBR
├─ ESP / MSR / WinRE / …
├─ PART
│  └─ FS
│     ├─ ROOT
│     ├─ HOME
│     └─ WORK
├─ SWAP
└─ LBA_LAST
```

## `HRR` - Hardware Resource Record

Understand the system, verify assumptions and investigate uncertainty. Produce a dated record of its hardware and condition.

- Communicate any concerning `HEALTH` or `USAGE` readings.
- Report observed or measured values, never advertised specifications.
- Record names and stats, not serial numbers.
  - Group duplicate components with `Nx` (e.g. `2x memory`).
  - Request labels for naming conflicts (e.g. `HDD` -> `BACKUP_HDD`).
    - Assume, and confirm, the [`RPL`](#rpl---recommended-partition-layout).
- for `WAN_HEALTH` run the [Cloudflare Speed Test](https://speed.cloudflare.com/) in a headless browser.

### Example `HRR`

- `doc/host/$HOSTNAME.env`

```sh
# Hardware Resource Record
HRR="2026-10-23"

# --------------------
# Storage
# --------------------
SSD="Micron 2450 MTFDKBA512TFK"
SSD_SIZE="476.94 GiB" # Device capacity.
SSD_USAGE="30.4%" # Filesystem usage.
SSD_HEALTH="100%" # Drive endurance remaining.

HDD="Second Disk"
HDD_HEALTH="passed" # SMART result.

BACKUP_HDD="Third Disk"

# --------------------
# Computer
# --------------------
HW="Acer Aspire A515-57"
HW_TYPE="laptop" # e.g. desktop, laptop, tablet, phone, router, virtual machine.
HW_TEMP="cooled" # cooled | throttled
HW_VENDOR_HQ_COUNTRY="TW"

BTT="Panasonic AP19B5L"
BTT_SIZE="53 Wh"
BTT_HEALTH="72.6%" # Full charge ÷ design capacity.

CPU="Intel Core i5-1235U"
CPU_ARCH_YEAR="2021" # Microarchitecture debut.
CPU_VENDOR_HQ_COUNTRY="US"

RAM="2x SK hynix HMAA1GS6CJR6N-XN" # Module part number.
RAM_SIZE="2x 8 GiB"
RAM_TYPE="DDR4"

GPU="Intel Iris Xe Graphics"
GPU_RAM="shared"

WAN="TP Link" # the router
WAN_TYPE="4G LTE"
WAN_OPERATOR="E-Plus"
WAN_HEALTH="3/5" # Lowest Cloudflare Network Quality Score.

# --------------------
# Components
# --------------------

DISPLAY="2x Acer K242HQL"
DISPLAY_RESOLUTION="2x 1920x1080"
DISPLAY_REFRESH="2x 60 Hz"

HEADSET="Nothing Headphone (1)"
HEADSET_BLT="82:4D:A7:19:C3:6E"

MOUSE="Logitech Pebble M350s"
MOUSE_BLT="DA:71:2C:96:48:B5"

KEYBOARD="Logitech K120"
KEYBOARD_USB="6b2e:91a4"

KEY="Google Titan Security Key v2"
KEY_USB="a731:5c82"
```
