# Debian [//debian.org](https://debian.org/)

I use the Debian operating system almost everywhere; [Desktop GUI](https://www.reddit.com/r/unixporn/top/?t=year) and [Terminal CLI](https://en.wikipedia.org/wiki/Terminal_emulator).

## Installation

There are three common Linux environments:

```sh
uname # Linux
hostnamectl # Debian
```

### Windows - _Recommended_

On Windows 11 use the [Windows subsystem for Linux](./windows/linux/README.md).

```sh
wsl.exe --install debian
```

### Cloud

Sign up [in the cloud](https://getdeploying.com/reference/compute-prices) with a credit;debit card, then provision;subscribe;rent a container;server;host.

### Hardware (64-Bit-IBM-PC) - _waste of time_

For Desktop;Laptop;`x86-64` devices you can [create a bootable USB drive](./windows/readme.md). Boot UEFI, boot the USB, install into a HDD;SSD;M.2, then boot that drive. You can also boot from: microSD, network, or memory. Ask ChatGPT for help _and_ call me on discord.

## Initialization

Copy & Paste; or download files with `git clone`, `curl`, `wget`.

### History of Copy & Paste

| **System**           | **Copy**       | **Paste**      | **Cut**        | **year** |
| -------------------- | -------------- | -------------- | -------------- | -------- |
| **IBM PC**           | `CTRL+Insert`  | `Shift+Insert` | `Shift+Delete` | 1981     |
| **macOS**            | `CMD+C`        | `CMD+V`        | `CMD+X`        | 1983     |
| **Windows**          | `CTRL+C`       | `CTRL+V`       | `CTRL+X`       | 1995     |
| **Linux Terminals**  | `CTRL+Shift+C` | `CTRL+Shift+V` |                | 2010     |
| **Windows Terminal** | `CTRL+Shift+C` | `CTRL+Shift+V` |                | 2020     |

In 1983 Apple pioneered `C` copy `V` paste `X` cut `Z` undo. Similar keys were added by Windows _19_-95 supplementing the IBM PC keys. Normally the key `CTRL+C` sends byte `3` which is `"End of Text"` in [ASCII and Unicode](https://en.wikipedia.org/wiki/C0_and_C1_control_codes); desktop systems like `explorer.exe` override this. Finally in 2020 the [Windows Terminal](https://www.youtube.com/watch?v=8gw0rXPMMPE) added common Linux Terminal key combinations.

## Configuration

Install packages; and log in to OpenAI [Codex](https://openai.com/codex).

```sh
sudo bash ./server/upgrade.sh

codex login
codex "code a \"Hello, World\" API in JavaScript"
```

Copy configs; and set up Microsoft [VS Code](https://code.visualstudio.com/).

```sh
bash ./server/setup.sh
cp -ra ./server/.[!.]* ~/.
source ~/.bashrc

# 1: Download and Install VS Code for Windows or Linux ...
code --install-extension ms-vscode-remote.remote-ssh
rcode sosdan ./desktop/dev
```

_History of Editors: CLI, TUI, GUI_

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

For a graphical workstation, continue with the [desktop readme](./desktop/README.md).
