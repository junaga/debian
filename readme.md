- [github.com/microsoft/WSL](https://github.com/microsoft/WSL)
- [github.com/apple/container](https://github.com/apple/container)
- [github.com/pbatard/rufus](https://github.com/pbatard/rufus)

# Debian `14` [//debian.org](https://debian.org/)

I use the Debian operating system almost everywhere, [with](https://www.reddit.com/r/unixporn/top/?t=year) and [without](<https://en.wikipedia.org/wiki/Terminal_emulator>) a graphical interface,

- with Windows
- in the public cloud
- on `x86-64` devices _64-Bit-Wintel-IBM-PC_

## Installation

1. On **Windows 10 or 11** [`wsl.exe --install`](./win/linux/README.MD) `debian`.

2. Rent, Subscribe, Deploy; **host, server, container**; pick "Debian".

3. Laptop and Desktop install -> just ask ChatGPT.

```sh
uname # >Linux
hostnamectl # >Debian
```

## Initialization

Copy & Paste code manually, or download files with `git clone`, `curl`, `wget`.

In 1983 Apple invented `C` for copy, `V` for paste, `X` for cut, `Z` for undo. Windows _19-_95 added similar keys. The original IBM PC clipboard keys remain supported on Windows.

| System                                 | **Copy**       | **Paste**      | **Cut**        |
| -------------------------------------- | -------------- | -------------- | -------------- |
| **macOS**                              | `CMD+C`        | `CMD+V`        | `CMD+X`        |
| **Windows & Linux**                    | `CTRL+Insert`  | `Shift+Insert` | `Shift+Delete` |
| **Windows & Linux: Desktop**           | `CTRL+C`       | `CTRL+V`       | `CTRL+X`       |
| **Windows & Linux: Terminal Emulator** | `CTRL+Shift+C` | `CTRL+Shift+V` |                |

## Configuration

Do anything you like, no really. ask ChatGPT or other Debian users for help. here is what I usually do.

### packages

```sh
sudo bash debian/script/upgrade.sh
```

### dotfiles

With an `$EDITOR` like [VS Code](https://code.visualstudio.com/) you can manually configure dotfiles (`code ~/`).

```sh
cp -r debian/home/. ~/.
code ~/.env # or micro, nano, vim,
exit # and enter
```

### (optional) move home

```sh
sudo bash debian/script/autoremove.sh

sudo chown -R $USER:$USER /usr/local/
cp -r /home/$USER/. /usr/local/.
sudo sed -i "s|/home/$USER|/usr/local|" /etc/passwd
exit # and enter
sudo rm -fr /home/

sudo sed -i "s|/root|/tmp|" /etc/passwd
sudo rm -fr /root/
```
