# Debian [//debian.org](https://debian.org/)

We use the Debian operating system almost everywhere. [With](https://www.reddit.com/r/unixporn/top/?t=year) and [without](https://en.wikipedia.org/wiki/Terminal_emulator) GUIs.

```sh
uname # Linux
hostnamectl # Debian
```

## Installation

### Windows - _Recommended_

On Windows 11 or Windows 10 use the [Windows subsystem for Linux](./windows/readme.md).

```sh
wsl.exe --install debian
```

### Cloud

Sign up [anywhere in the cloud](https://getdeploying.com/reference/compute-prices) with a debit;credit card, then rent;subscribe;provision a host;server;container with any `Debian` release and whitelist your SSH public key. I rent on [console.hetzner.com](https://console.hetzner.com/): Server with 2 vCPUs with block storage. ID required for sign up.

### Hardware - _don't do this_

For Desktop;Laptop;`x86-64` devices _64-Bit-Wintel-IBM-PC_ you can [create a bootable USB drive](./desktop/install/readme.md). Boot UEFI, then boot the USB, then install a system to your M.2;SSD;HDD drive, then boot that drive. You can also boot from microSD, network, or memory. Ask ChatGPT for help AND call me on discord for advice.

## Initialization

Copy & Paste! or download files with `git clone`, `curl`, `wget`.

### History of Copy & Paste

| **System**         | **Copy**       | **Paste**      | **Cut**        | **year** |
| ------------------ | -------------- | -------------- | -------------- | -------- |
| **macOS**          | `CMD+C`        | `CMD+V`        | `CMD+X`        | 1983     |
| **IBM PC**         | `CTRL+Insert`  | `Shift+Insert` | `Shift+Delete` | 1981     |
| **Windows**        | `CTRL+C`       | `CTRL+V`       | `CTRL+X`       | 1995     |
| **Linux Terminal** | `CTRL+Shift+C` | `CTRL+Shift+V` |                | 2010     |

In 1983 Apple pioneered: `C` copy `V` paste `X` cut `Z` undo. Similar keys were added by Windows _19_-95, supplementing the IBM PC keys. In 2020 the [Windows Terminal](https://www.youtube.com/watch?v=8gw0rXPMMPE) `wt.exe` added Linux Terminals keys. `wt.exe` and `wsl.exe` are Linux desktop culture incorporated into Microsoft.

Outside Windows `explorer.exe` the key `CTRL+C` sends byte `3` which is `"End of Text"` in [ASCII and Unicode](https://en.wikipedia.org/wiki/C0_and_C1_control_codes).

## Configuration

Install packages and login into OpenAI [Codex](https://openai.com/codex).

```sh
sudo bash ./node/upgrade.sh
codex login # --device-auth

codex "code a \"Hello, World\" API in JavaScript"
```

Configure SSH and install Microsoft [VS Code](https://code.visualstudio.com/).

```sh
REMOTE="root@46.224.172.45"

# 1. Generate public/private keypair
ssh-keygen -N "" -C "junaga"

# 2. Copy public key
cat ~/.ssh/id_ed25519.pub

# 3. Register public key on remote

# 4. Connect remote shell
ssh $REMOTE


# 1. Download and Install VS Code

# 2. Install extensions
bash ./desktop/vscode/extensions.sh

# 3. Quick remote code/files/FTP alias
echo "alias rcode=\"code --remote ssh-remote+$REMOTE\"" >> ~/.bashrc
bash

# 4. Edit remote directory or file
rcode ~/dev/
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

### NVIDIA GPU, [hypr.land](https://hypr.land) and Google Chrome

Make sure you manually disable `Secure Boot` in `UEFI`; Because `apt:nvidia-driver` is not installed, it's compiled with `apt:dkms`. Installing `apt:nvidia-driver` installs the source code, then it compiles, then installs the actual driver software. But the newly compiled software has no cryptographic release signature, which is required for `Secure Boot`.

```sh
sudo bash ./node/upgrade.sh
sudo bash ./desktop/upgrade.sh
cp ./desktop/.hypr ~/.hypr
sudo reboot 0
```

```sh
dbus-run-session Hyprland --config ~/.hypr
```

![Hyprland Desktop Screenshot](./hypr.webp)
