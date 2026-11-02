## `RPL` - Recommended Partition Layout

- Prefer one filesystem per drive.
  - Filesystems must contain a `UUID`.
- Where supported, prefer subvolumes over partitions.
  - Every volume should have a unique `label`.
    - `BACKUP` volumes must be on separate drives.
- Avoid `HDD` Windows/Linux/etc installs.
  - Default `SWAP` to `RAM / 2`. _and use `zswap`_

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

### `OSV` - Optional Subvolumes

These additional subvolumes usually make sense and simplify administration.

| Subvolume | Mountpoint                        |
| --------- | --------------------------------- |
| `CACHE`   | `/var/cache`                      |
| `STEAM`   | `$HOME/.steam/debian-installation` |

## `HRR` - Hardware Resource Record

Produce a dated record of system hardware and conditions, including HIDs, and drives plus filesystems.

- Keep values short: names, measurements with units, percentages, or status keywords.
  - Omit serial numbers, mountpoints, and other details.
  - Omit example-value comments from the report.
  - Group duplicate components with `Nx`.
    - Use labels on naming conflicts (e.g. `HDD` -> `BACKUP_HDD`).
- Investigate as `root` or use `sudo`.
  - Report measured values, never advertised specifications.
- Check all drives against [`RPL`](#rpl---recommended-partition-layout)
- Require fresh extended SMART self-tests and full scrubs or supported filesystem integrity checks for every drive; mark untested results `unknown`.
- For `WAN_HEALTH`, run `node base/speedtest.mjs "$CLOUDFLARE_TURN_KEY_ID" "$CLOUDFLARE_TURN_KEY"`
- Keep log files in `job/$HRR/hardware-checks/`; use results from that date.
- Communicate any concerning `HEALTH` or `USAGE` readings.

### Example `HRR`

- `doc/host/$HOSTNAME.env`

```sh
# Hardware Resource Record
HRR="2026-10-23"

# --------------------
# HID - Human Interface Devices
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

# --------------------
# IO - Input and Output
# --------------------
WAN_ROUTER="TP Link"
WAN="4G LTE"
WAN_OPERATOR="E-Plus"
WAN_HEALTH="3/5" # Lowest Cloudflare Network Quality Score.

SSD="Samsung SSD 850 EVO mSATA 250GB"
SSD_SIZE="232.89 GiB"
SSD_ESP="976 MiB"
SSD_SWAP="8 GiB"
SSD_HEALTH="92%" # Estimated SSD endurance remaining.
SSD_FS="btrfs"
SSD_FS_HEALTH="passed" # Filesystem integrity check, such as a Btrfs scrub.
SSD_FS_USAGE="63%"
SSD_FS_UUID="9e156fe2-a8a0-47d8-bce4-03ce6cebc920"

# HDD="Second Disk"
# HDD_HEALTH="passed" # SMART/self-test status.
# BACKUP_HDD="Third Disk"
# ...

# --------------------
# Computer
# --------------------
HW="Acer Aspire A515-57"
HW_TYPE="laptop" # desktop | laptop | tablet | phone | vm
HW_TEMP="operational" # operational | throttled
HW_VENDOR_HQ_COUNTRY="TW"

BTT="Panasonic AP19B5L"
BTT_SIZE="53 Wh"
BTT_HEALTH="72.6%" # Full charge ÷ design capacity.

RAM="2x SK hynix HMAA1GS6CJR6N-XN" # Module part number.
RAM_SIZE="2x 8 GiB"
RAM_TYPE="DDR4"

CPU="Intel Core i5-1235U"
CPU_ARCH_YEAR="2021" # Microarchitecture debut.
CPU_VENDOR_HQ_COUNTRY="US"

GPU="Intel Iris Xe Graphics"
GPU_RAM="shared" # shared | N GiB
```
