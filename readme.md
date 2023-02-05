I use [Debian](https://debian.org/) _interactively_ (not as a server) almost everywhere.

- on bare metal, and VMs
- as VM on _Windows subsystem for Linux_
  - `cmd.exe` -> `wsl --install -d debian`
- as [devcontainer on github.com](https://github.com/features/codespaces)

The goal on every platform is the same, I need a working development environment. A _dev box_ or _dev container_, to write, test, debug and deploy software and apps.

## Setup

After installing Debian on any platform I configure the system, most importantly `apt` and `bash`.

- add custom `./sources.list`
- install my `./packages`
- set my bash shell profile (copy `./home/`)

The `./setup.bash` script does this, and some other things.

- uninstall unwanted packages
- cleanup `/etc/`

## Why I use Debian

### 1. It's a [free](https://www.debian.org/intro/free) and open source, [copyleft](https://en.wikipedia.org/wiki/Copyleft) licensed (GPL), Linux software distribution

Fireship has a [great 10 minute video](https://www.youtube.com/watch?v=ShcR4Zfc6Dw) that explains what a Linux distro is.

Linux > Windows. period. If you think differently, stop reading my files, turn off your computer, and go sell it. Also fuck you. No for real, Windows is for gaming but Linux is for working.

### 2. It's tiny and [lightweight](https://www.debian.org/releases/stable/amd64/ch03s04.en.html)

- ~200 packages in new install
- ~500MB in new install (with docs, i18n and `systemd`)
- 2GB storage and 500MB memory, system requirements

### 3. It's huge and powerfull

- [~60.000 packages](https://packages.debian.org/stable/) make up the distribution
- runs on x86, x86-64, ARM, [everywhere](https://www.debian.org/ports/)
- [is the upstream of every good linux distro](https://upload.wikimedia.org/wikipedia/commons/b/b5/Linux_Distribution_Timeline_21_10_2021.svg), like Steam OS or Raspberry Pi OS.

### 4. It's stable.

Most servers on the internet are Debian based Linux servers. Software is tested for years before it is included in the Debian stable branch. With a new release of Debian coming around roughly every 24 months. Unlike for example rolling releases "Arch Linux", which is pretty unstable. If you need `nodejs` version 18 and not version 12. Just install it manually, and carry the script to install it with you. _forever_.

More reasons on [debian.org/intro/why_debian](https://www.debian.org/intro/why_debian)

Basically it works, is stable and is found everywhere in the cloud. The possibly best thing about Debian, is that it is _boring_, without any weird features. It's the tool for the job.
