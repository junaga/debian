# Why Debian

> The Universal Operating System

[Debian](https://www.debian.org/) is the worlds vanilla (meaning default) Linux Software Distribution. `@Fireship` has a [great 10 minute video](https://www.youtube.com/watch?v=ShcR4Zfc6Dw) that explains what a "Linux distro" is.

## 5 Reasons to use Debian

### 1. Not Windows

> 'ls' is not recognized as an internal or external command, operable program or batch file.

It's almost impossible to develop an App when sitting in Windows OS userspace. Get a MacBook, or use a Linux - like Ubuntu.

- macOS, most Linux, and all BSD, are Unix-like, Windows is not.
- kinda like the web, Windows is a _giant mess_.
- Windows is required for gaming, but Linux is for working.

#### It's getting better

Microsoft is trying to fix this, with [powershell v6+](https://github.com/PowerShell/PowerShell), and the [Windows Subsystem for Linux](https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux) (WSL), v2 virtual machine, project.

### 2. Server system

Debian, is the "universal operating system". Meaning embedded, client, and server, OS. You can run VMs in the public cloud, game servers like Minecraft, and backend containers. Most servers on the web are Debian based Linux servers.

There is no "Arch Linux" runner for [any CI server](https://github.com/ligurio/awesome-ci), to build-test-deploy a software. It's for workstations, not for servers.

### 3. Huge but lightweight

- [~65.000 packages](https://packages.debian.org/stable/) make up the distribution
- ~200 packages using ~0.5GB in new install (with docs and i18n)
- [system requirements](https://www.debian.org/releases/stable/amd64/ch03s04.en.html) of 4GB storage and 500MB memory
- runs on ARM, x86, x86-64, [everywhere](https://www.debian.org/ports/)
- is the upstream of [a lot of linux](https://upload.wikimedia.org/wikipedia/commons/a/ad/2023_Linux_Distributions_Timeline.svg), like Ubuntu, Tails, and Raspberry Pi OS.

### 4. Freedom

Free, _as in freedom_, open source software (FOSS), that is [copyleft](https://en.wikipedia.org/wiki/Copyleft) (GPL) licensed.

Developed by thousands of volunteers from all over the world, with the exception of `non-free-firmware`, Debian is free for anyone to use, modify, and distribute. Also it costs $0.

### 5. Stable

With a test-release cycle of 24 months, Debian never has fresh software, but the packages you do get, are secure and stable on their own, and with each other. If you need the latest version of something, for example `nodejs`, just install it manually, and carry the script to install it with you. Yes, forever.

The arguably best thing about Debian, is that it is boring, without any weird features. It's the tool for the job.
