# Unix [Filesystem Hierarchy Standard](https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard)

```sh
/dev/ # Devices (pseudo filesystem)
/mnt/ # Default mountpoints
/etc/ # Configuration
```

> "There is no place like `$HOME`"

```sh
/home/$USER/ # You, also me. and him/her/them.
```

## Binaries and libraries

_(System)_ binaries are on `$PATH`. Libraries are usually _relativly imported_ by binaries, like `import ../lib/utils`.

Common programs accross all Linux and Unix distributions

```sh
/bin/
/sbin/
/lib/
```

Installed packages that are part of the distribution

```sh
/usr/bin/
/usr/sbin/
/usr/lib/
```

User installed programs, that are not in the distribution

```sh
/usr/local/bin/
/usr/local/sbin/
/usr/local/lib/
```

Additional libraries that are restricted in a certain way.

```sh
/usr/include/ # C Header files library
/usr/share/ # "architecure independent" data, library
```

`usr/share/zoneinfo` is the timezones file.

## Cache and data (todo)

```
/tmp/
/var/
/run/
```

## Additional directories

Alternatives created throughout the ages.

```sh
# Just use `$HOME/`
/srv/ # Used by web servers and containers
/usr/src/ # source code
/root/ # root user `$HOME` directory

# Just use `/usr/local/*`
/opt/ # "Optional addon software"
/var/opt/
```

## Technical

### `/boot/` directory

Everything to boot the in-memory Linux kernel space and mount the `/` root. `/boot/` does not exist in VMs, and is only used during "shutdown" -> "booting" time. The directory is not required during system runtime, and could even be deleted.

```sh
/boot/
/boot/grub/ # GRUB Bootloader
/boot/vmlinux # Kernel
```

### `/dev/` pseudo filesystem

"[Device files](https://en.wikipedia.org/wiki/Device_file#Naming_conventions)" and other interfaces

```sh
/dev/pts/$N # emulated terminals
/dev/sd$X # SATA and USB drive (like: sda, sdb, sdc)
/dev/sd$X$N # SATA and USB drive partition (like: sda1, sda2, sda3)
/dev/mmcblk0p1 # First found (Micro) SD Card drive and partition
/dev/nvme0n1p1 # First found NVMe bus, drive and partition
```

```sh
/dev/null # should be named `/dev/void`
/dev/random # every file that ever existed is written in here
```

### `/proc/` pseudo filesystem

The second generation Unix pseudo filesystem. It enabled programs (`/bin/`, `/sbin/` etc) to interface with the kernel-space. Before this existed, utilities like [`ps`](<https://en.wikipedia.org/wiki/Ps_(Unix)>) had to manually read the physical memory `/dev/mem/`.

```sh
/proc/$PID/ # process interface
/proc/$PID/cmdline # command used to start the process
/proc/$PID/exe # symlink to the binary used to start the process (it can already be gone)
/proc/$PID/environ # environment variables (by `\0`)
/proc/$PID/cwd # symlink to the working directory
/proc/$PID/fd/ # symlinks to files open
```

Everything in Unix is a file, this includes kernel space internals.

```sh
/proc/ # kernel space interface
/proc/cmdline # kernel paramters (from bootloader or supervisor)
/proc/version # kernel version string
/proc/filesystems # supported filesystems
```

### `/sys/` pseudo filesystem

Because `/proc/` became a huge mess, Linux created `/sys/`. The third generation pseudo fs (after `/dev/` and `/proc/`). It's a structured interface that mirrors the linux kernel-space.

```sh
/sys/ # new kernel space interface
/sys/modules/ # kernel modules loaded
```

### `/lost+found/` filesystem

Damaged files that got picked up by `fsck`. In Unix every filesystem has it's own `lost+found/` "directory". On `systemd` managed systems or VMs this directory is usually not required.