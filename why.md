> 'ls' is not recognized as an internal or external command, operable program or batch file.
>
> _a common error on Windows_

# Why Debian [//debian.org](https://debian.org/)

The "Universal Operating System" Debian is the worlds vanilla (meaning default) Linux distribution.

@Fireship has a great [10 minute video](https://www.youtube.com/watch?v=ShcR4Zfc6Dw) that explains what a "Linux distro" is.

## 5 Reasons to use Debian

### 1. Not Windows

It's almost impossible to develop an app in Windows userspace, enable the [Windows Subsystem for Linux](https://github.com/junaga/windows/tree/main/wsl). A two year old MacBook is a good purchase but also not Linux.

- Windows is not "Unix-like" (Linux, macOS, BSD are)
- Windows is required for gaming but Linux for programming
- like the web Windows is a "giant mess"

### 2. A Server System

Debian the "Universal Operating System" is good for embedded, client, and server computers.

You can run a VPS in the public cloud, gameservers like Minecraft, or backend containers. Most servers on the web are Debian based Linux computers.

There is no Arch Linux runner for [any CI server](https://github.com/ligurio/awesome-ci), to build-test-deploy an app. Arch Linux is for workstations not for servers. Similarly, while NixOS can do everything in theory, most production web servers are either Debian/Ubuntu Linux or BSD systems.

### 3. Huge but lightweight

Every traditional computer program is a single `apt install` command away from operation. `docker.io` `nodejs` `sshfs` etc

- distribution of [65000 packages](https://packages.debian.org/stable/)
- install has 200 packages totalling 0.5GB (with docs and i18n)
- runs [everywhere](https://www.debian.org/ports/) `ARM` `x86` `x86-64`..
- 4GB storage and 500MB memory [recommended minimum system requirements](https://www.debian.org/releases/stable/amd64/ch03s04.en.html)

### 4. Freedom

Free _as in freedom_ open source software (FOSS), that is [copyleft](https://en.wikipedia.org/wiki/Copyleft) (GPL) licensed. Developed by thousands of volunteers from all over the world, with the exception of `non-free-firmware`, Debian is free for anyone to use, modify, and redistribute. A lot of [Linux distros](https://upload.wikimedia.org/wikipedia/commons/a/ad/2023_Linux_Distributions_Timeline.svg) redistribute Debian, like Ubuntu, Tails, Raspberry Pi OS.

Finally, like all open source software, it costs $0.

### 5. Stable

With a test-release cycle of 24 months, Debian never has fresh software, but the packages you do get, are secure and stable on their own, and with each other. If you do need the latest/beta/testing/unstable version of something, for example `nodejs`, install it manually and document or script the process. Instead of trying to discover your perfect distro, grow your own.

The arguably best thing about Debian, is that it is boring, without any quirks. It's the tool for the job.
