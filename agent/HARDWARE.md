# Hardware inventory

Write one lowercase `$HOSTNAME.env`, named for the inventoried device. Use non-destructive administrator/root inspection and authoritative sources. Document hardware only.

The administrator is responsible for a concise, accurate, unambiguous account of the device's hardware, dependencies, and condition. Use the example below as a guide; include only hardware present in the device. Keep section comments and put dated metadata on the first line; inline field comments below explain their meaning.

```dotenv
# updated=YYYY-MM-DD | status=... | evidence=...

# Processor
CPU=""
CPU_ARCH_YEAR="" # First commercial year of the core microarchitecture, not ISA or model launch.
CPU_VENDOR_HQ_COUNTRY=""

# Device
HW=""
HW_VENDOR_HQ_COUNTRY=""

# Components: models, physical capacities with units, condition
RAM=""
RAM_SIZE=""

SSD=""
SSD_SIZE=""
SSD_HEALTH="" # Percentage of estimated endurance remaining.

HDD=""
HDD_SIZE=""
HDD_SMART="" # Reported overall SMART result: passed or failed; not a numeric score.

BATTERY=""
BATTERY_SIZE="" # Design capacity, rounded to whole Wh.
BATTERY_HEALTH="" # Percentage: 100 * full-charge/design capacity, using unrounded readings in matching units.
```

Group identical components with a quantity. When components need separate entries, use existing names or labels (prefer volume labels for storage); if none exist, ask the operator to name them—for example, `SYSTEM_SSD` and `BACKUP_SSD` instead of `SSD1` and `SSD2`.

For hybrid CPUs with different microarchitecture debut years, identify each design and year. Keep HEALTH values percentage-only. Preserve individual health readings; record material faults separately and omit redundant healthy/OK text from percentage fields. Use `absent` only for confirmed absence and `not applicable` only where no value applies.

Make the evidence basis and unresolved facts clear in the file. Distinguish product makers from designers, foundries, and assemblers. Consider remotely initiated attacks, including remotely delivered code; exclude software, filesystem, and firmware details.

Resolve missing readings and conflicting evidence rather than guessing or omitting relevant facts. If a relevant required reading cannot be obtained, the file is incomplete and not final.
