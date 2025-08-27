- https://refspecs.linuxfoundation.org/fhs.shtml
- https://systemd.io/THE_CASE_FOR_THE_USR_MERGE/

# Linux Filesystem

Because the Linux-BSD-Unix-filesystem-hirachy is complicated, developers sometimes put everything in `$HOME`, which is fine.

- concern: user > system > kernel
- dependency: binary > config > library
- durability: cache < variable < static

## Data

Default `$HOME` is `/home/$USER` or `/root/`

```sh
$HOME             # config and data
/etc/             # system config
/var/             # system variable data
/usr/local/share/ # system static data
```

### Cache

Temporary runtime data deleted on reboot

```sh
/tmp/             # cache
/run/             # system cache
```

### Hardware

Interfaces for kernel space<>user space messages and commands

```sh
/dev/
/proc/
/sys/
```

Mounted filesystems; local or remote; from disk, image, or virtual.

```sh
/mnt/             # mount point(s)
```

## Executables

Executables on Unix(-like) systems don't have file extensions, like `.exe` on Windows, because back then, all binary files were CPU executable files, all of them! GPUs did not exist either.

In 1971 almost everything was text! Only executable `bin` binary files, linkable `lib` library files, and compilable `src` source code text files existed. Today, a lot of other non-text file formats or "binary files" exist, like `.png`, `.jpeg`, `.mp3`, `.mp4`, but the directory for executables is still named `bin/`.

### User installed Software

```sh
/usr/local/bin/   # executables
/usr/local/sbin/  # admin executables
/usr/local/lib/   # library
```

### Distribution installed Packages

```sh
/usr/bin/
/usr/sbin/
/usr/lib/
```

### Unix Tools and C library

```sh
/bin/
/sbin/
/lib/
```

### Linux Kernel

The hardware driver

```sh
/boot/            # kernel space executables
```
