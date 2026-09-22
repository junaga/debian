# Debian

We use the [Debian](https://debian.org/) [Linux distribution](https://en.wikipedia.org/wiki/List_of_Linux_distributions) operating system almost everywhere; [Desktop GUI](https://www.reddit.com/r/unixporn/top/?t=year) and [Terminal CLI](https://en.wikipedia.org/wiki/Terminal_emulator).

```sh
uname #> Linux
hostnamectl #> Debian
```

_Agents: see [design.md](./design.md)._

## Installation

### Windows

**Recommended:** Windows 11 with the [Windows/Linux](./Windows/linux) subsystem.

```sh
wsl.exe --install debian
```

### Cloud

Use [the cloud](https://getdeploying.com/reference/compute-prices) to provision or rent a container, server, or hardware for 24/7 online apps or games; debit/credit card required.

### Hardware (Live image)

For `x86-64`: flash a Debian live `.iso` to a storage device, such as a USB drive. Needs ≥4 GB. Back up and unmount first, **flashing deletes all data.** On WSL use [USB passthrough](Windows/linux/usb.md).

```sh
export URL="https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/debian-live-13.7.0-amd64-standard.iso"
export USB="/dev/disk/by-id/usb-SanDisk_Ultra_USB_3.0_4C530000310806116320-0:0" # no "-partN"

sh ./loadsys.sh
```

Next: Boot the flashed device; install Debian on a **fast disk** (`M.2`, `SSD`, `HDD`, `USB`, `microSD`, etc.); then boot the installed system.

## Initialization

Copy & Paste, or download files with `git clone`, `curl`, `wget`.

### History of Copy & Paste

| **System**           | **Copy**       | **Paste**      | **Cut**        | **year** |
| -------------------- | -------------- | -------------- | -------------- | -------- |
| **IBM PC**           | `CTRL+Insert`  | `Shift+Insert` | `Shift+Delete` | 1981     |
| **macOS**            | `CMD+C`        | `CMD+V`        | `CMD+X`        | 1983     |
| **Windows**          | `CTRL+C`       | `CTRL+V`       | `CTRL+X`       | 1995     |
| **Linux Terminals**  | `CTRL+Shift+C` | `CTRL+Shift+V` |                | 2010     |
| **Windows Terminal** | `CTRL+Shift+C` | `CTRL+Shift+V` |                | 2020     |

In 1983 Apple pioneered `C` copy `V` paste `X` cut `Z` undo. Similar keys were added by Windows _19_-95 supplementing the IBM PC keys. Normally the key `CTRL+C` sends byte `3` which is `"End of Text"` in [ASCII and Unicode](https://en.wikipedia.org/wiki/C0_and_C1_control_codes), desktop systems like `explorer.exe` override this. Finally in 2020 `wt.exe` the [Windows Terminal](https://www.youtube.com/watch?v=8gw0rXPMMPE) added common Linux Terminal key combinations.

## Administration

Set up the system; and login to OpenAI [Codex](https://openai.com/codex).

```sh
sh ./instpkg.sh

codex login
codex "create a JavaScript CLI that counts the words in a text file"
```

Set up the user; and setup Microsoft [VS Code](https://code.visualstudio.com/).

```sh
cp -a base/skel/. ~/
EMAIL=$(whoami)@$(hostname) sh ./initacc.sh

source ~/.bashrc

# 1: Download and Install VS Code for Linux or Windows
code --install-extension ms-vscode-remote.remote-ssh
# 3: register your SSH public key on the remote server
rcode sosdan ./dev
```

### Environment

Edit `~/.env` for user preferences such as `LANG`, `EDITOR` and `PAGER`.
[`base/skel/.env`](./base/skel/.env) supplies public defaults; keep credentials
out of this tracked file. `WORK`, `REPO` and `AGENT` are our own conventions and
only affect tools that explicitly read them.

Interactive Bash loads `~/.env` and exports its assignments to child processes.
Use `EDITOR=vim command` to override a preference for one command. Starting a
new interactive shell or sourcing `~/.bashrc` reapplies `~/.env`; it can replace
inherited values. Project `.env` files are loaded by direnv after authorization.
This does not configure already-running processes, graphical sessions, cron or
systemd services; those need their own launch-time environment.

Keep stable behavior in native configuration files: Bash history in `.bashrc`,
npm defaults in `/etc/npmrc`, and desktop application associations in
`mimeapps.list`. Environment overrides work only where the application supports
them. `BROWSER` is supported by some launchers; `EXPLORER` is not a standard
XDG preference. Changing `SHELL` does not change the account's login shell.

### History of Editors

```sh
# ed $FILE             # 1969
# vi $FILE             # 1976
# emacs $FILE          # 1976
# notepad.exe $FILE    # 1983
# emacs $FILE          # 1985
# pico $FILE           # 1989
# vim $FILE            # 1991
# nano $FILE           # 1999
# notepad++.exe $FILE  # 2003
# mate $FILE           # 2004
# subl $FILE           # 2008
# atom $FILE           # 2014
code $FILE           # 2015
# nvim $FILE           # 2015
micro $FILE          # 2016
# cursor $FILE         # 2023
```
