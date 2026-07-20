# Debian [//debian.org](https://debian.org/)

I use the Debian operating system almost everywhere; [Desktop GUI](https://www.reddit.com/r/unixporn/top/?t=year) and [Terminal CLI](https://en.wikipedia.org/wiki/Terminal_emulator).

```sh
uname #> Linux
hostnamectl #> Debian
```

## Installation

It is highly recommended to install Debian on Windows WSL. Do not waste your time installing it on PC hardware.

### Windows

On Windows 11 use the [windows/linux/](./windows/linux) subsystem.

```sh
wsl.exe --install debian
```

### Cloud

Get a server in [the cloud](https://getdeploying.com/reference/compute-prices) to install and run 24/7 online apps or games. Sign up with a credit; debit card. Then provision; subscribe; rent any container; server; hardware.

### Hardware (64-Bit-IBM-PC)

For Desktop; Laptop; `x86-64` devices **create a bootable USB drive** (similar to the [windows/](./windows) installation procedure). Boot UEFI, boot the USB, install into a HDD; SSD; M.2, then boot that filesystem. You can also boot from microSD; network; memory. Ask ChatGPT; call me on discord `@junaga` for help.

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

## Configuration

Install packages; and login to OpenAI [Codex](https://openai.com/codex).

```sh
sudo bash ./base/upgrade.sh

codex login
codex "code a \"Hello, World\" API in JavaScript"
```

Copy configs; and setup Microsoft [VS Code](https://code.visualstudio.com/).

```sh
bash ./base/setup.sh
cp -ra ./base/home/. ~/.
source ~/.bashrc

# 1: Download and Install VS Code for Windows or Linux
code --install-extension ms-vscode-remote.remote-ssh
# 3: register your SSH public key on the remote server
rcode sosdan ./dev
```

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

For a graphical workstation, continue with the [desktop/](./desktop/README.md) readme.
