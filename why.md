- @Fireship has a great [10 minute video](https://www.youtube.com/watch?v=ShcR4Zfc6Dw) about Linux
- [List of Linux distributions](https://en.wikipedia.org/wiki/List_of_Linux_distributions)
- [linuxatemyram.com](https://www.linuxatemyram.com/)

# Why Debian [//debian.org](https://debian.org/)

Debian the **Universal Operating System** is the worlds vanilla (meaning default) Linux software distribution.

## 5 Reasons to use Debian

### 1 Not Windows

It's almost impossible to develop apps in Windows userspace,

1. kinda like the web; Windows is a "giant mess"
2. Windows for gaming! Linux for programming or hacking
3. macOS, BSD, and most Linux, are Unix systems, Windows is not

![running `ls` on Windows error](.why.png)

### 2 Lightweight and Huge

Every traditional computer program is a single `apt install` command. There are 65000 [packages](https://packages.debian.org/stable/) in the Debian distribution. Any server, database, runtime or tool `docker.io` `nodejs` `python3` ...

Debian "[recommended minimum system requirements](https://www.debian.org/releases/stable/amd64/ch03s04.en.html)" includes,

- `10GB` disk
- `2GB` memory
- any CPU
- no GPU
- no TPM, NIC, USB, NPU ...

_Every CPU [architectures](https://www.debian.org/ports/) **except** `x86` (32-bit PC) is supported. `arm` (Mobile) `x86-64` (64-bit PC) ..._

_The disk can also be an in-memory filesystem, so a disk is optional._

_A fresh install has 200 packages totalling `0.5GB` disk usage, including docs and translations._

### 3 Server System

Debian the "Universal Operating System" is good for embedded, client, and server computers.

You can run a VPS in the public cloud, gameservers like Minecraft, or backend containers. Most servers on the web are Debian based Linux computers.

There is no Arch Linux runner for any [CI server](https://github.com/ligurio/awesome-ci), to build-test-deploy an app. Arch Linux is for workstations not for servers.

Similarly, while NixOS can do everything in theory, most production web servers are either Debian/Ubuntu Linux or BSD systems. The Nix language is mostly used by PC modders, [containers](https://opencontainers.org/) + scripts are the industry default.

### 4 Freedom

Like all open source software, it costs $0.

Debian is **free as in freedom** open source software (FOSS), that is [copyleft](https://en.wikipedia.org/wiki/Copyleft) (GPL) licensed. Developed by thousands of volunteers from all over the world, with the exception of `non-free-firmware`, Debian is free for anyone, to use, modify, and redistribute. A lot of Linux distros redistribute Debian, like Ubuntu, Tails, Raspberry Pi OS.

### 5 Stable

With a test-release cycle of 24 months, Debian never has fresh software, but the packages you do get, are secure and stable on their own, and with each other. If you do need the latest/beta/testing/unstable version of something, install it manually and document or script the process. -- Instead of trying to discover the perfect house, grow your own garden.

The arguably best thing about Debian, is that it is boring, without any quirks. It's the tool for the job.
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
