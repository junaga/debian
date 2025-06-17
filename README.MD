- [github.com/microsoft/WSL](https://github.com/microsoft/WSL)
- [github.com/apple/container](https://github.com/apple/container)
- [github.com/pbatard/rufus](https://github.com/pbatard/rufus)
- [chat.com](https://chat.com/)

# Debian 12 [//debian.org](https://debian.org/)

I use the Debian operating system almost everywhere, [with](https://www.reddit.com/r/unixporn/top/?t=year) and [without](<https://en.wikipedia.org/wiki/Terminal_emulator>) a graphical interface

- on Windows
- container, VPS, dedicated server
- `x86` Laptop and Desktop

_As of writing, the latest stable release is Debian GNU/Linux 12 `bookworm`_

## Installation

On Windows 10 or 11 [`wsl.exe` install `debian` or `ubuntu`](https://github.com/junaga/windows/tree/main/wsl)

```cmd
wsl.exe --install debian
@REM enter username
@REM enter password
```

```bash
uname # Linux
hostnamectl # Debian GNU/Linux 12 (bookworm)
getent hosts deb.debian.org # fastlydns.net
```

## Hello World

```bash
cd ~/
echo "Hello, World!" >> hello.md
cat hello.md
ls -a ./
```

In `wsl.exe` you can run Windows programs on Linux files!

```bash
explorer.exe .
```

With an `$EDITOR` like [VS Code](https://code.visualstudio.com/) you can manually configure `~/`

```bash
code ~/
```

## Configuration

```bash
sudo bash ./src/upgrade.bash
```

Copy dotfiles into `~/`

```bash
cp -r ./home/. ~/.

source ~/junaga.bash
bash ./src/config.bash

exit # reload shell
```

(Optional) Move `~/` somewhere else

```bash
sudo sed -i "s/\/home\/$USER/\/usr\/local/" /etc/passwd
sudo chown -R $USER:$USER /usr/local/

cp -r /home/$USER/. /usr/local/.
sudo rm -r /home/

exit # reload shell
```

## (Optional) Clean Filesystem

```bash
rm ~/.bash_logout

sudo rm -r /usr/local/src/
sudo rm -r /usr/local/games/
sudo rm -r /usr/local/man
sudo rm -r /usr/local/include/
sudo rm -r /usr/local/share/
sudo rm -r /usr/local/sbin/
sudo rm -r /usr/local/etc/
```

```bash
sudo bash ./src/purge.bash

sudo rm -r /root/
sudo rm -r /srv/
sudo rm -r /opt/
sudo rm -r /usr/games/
sudo rm -r /usr/src/
```

```bash
sudo rm -r /lost+found/
sudo rm -r /boot/
sudo rm -r /media/
```
