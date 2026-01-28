- [github.com/microsoft/WSL](https://github.com/microsoft/WSL)
- [github.com/apple/container](https://github.com/apple/container)
- [github.com/pbatard/rufus](https://github.com/pbatard/rufus)

# Debian `13` [//debian.org](https://debian.org/)

I use the Debian operating system almost everywhere, [with](https://www.reddit.com/r/unixporn/top/?t=year) and [without](<https://en.wikipedia.org/wiki/Terminal_emulator>) a graphical interface,

- with Windows
- in the public cloud
- on `x86-64` devices (IBM PC)

## Installation

1. On **Windows 10 or 11** [`wsl.exe --install`](./win/linux/README.MD) `debian`.

2. When buying or renting a **host, server, container** select "Debian 13" during setup, usually from a dropdown.

3. Laptop and Desktop installations are difficult. I used [github.com/pbatard/rufus](https://github.com/pbatard/rufus).

```sh
uname
hostnamectl
```

## Configuration

With an `$EDITOR` like [VS Code](https://code.visualstudio.com/) you can configure manually (`code ~/`).

Copy the files manually, or download with `git clone`, `curl`, `wget`.

`C` for copy, `V` for paste, `X` for cut, `Z` for undo, was invented by Apple in 1983.

| System                                 | **Copy**       | **Paste**      |
| -------------------------------------- | -------------- | -------------- |
| **macOS**                              | `CMD+C`        | `CMD+V`        |
| **Windows & Linux**                    | `CTRL+Insert`  | `Shift+Insert` |
| **Windows & Linux: Desktop**           | `CTRL+C`       | `CTRL+V`       |
| **Windows & Linux: Terminal Emulator** | `CTRL+Shift+C` | `CTRL+Shift+V` |

### dotfiles

```sh
cp -r debian/home/. .
micro .env # code, micro, nano, vim
exit # and enter
```

### packages

```sh
sudo bash debian/script/upgrade.sh
```

### git sex GitHub

```sh
bash debian/script/git6hub.sh
```

### move home (optional)

```sh
cp -r $HOME/. /usr/local/.
sudo chown -R $USER:$USER /usr/local/
sudo sed -i s|$HOME|/usr/local| /etc/passwd
exit # and enter
```

### clean filesystem (optional)

```sh
rm .bash_logout
sudo rm -r /home/
sudo rm -r /root/
sudo bash src/script/purge.sh

# only in virtual machine
sudo rm -r /media/
sudo rm -r /mnt/

# only in container
sudo rm -r /boot/
```
