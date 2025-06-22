- [chat.com](https://chat.com/)
- [github.com/microsoft/WSL](https://github.com/microsoft/WSL)
- [github.com/apple/container](https://github.com/apple/container)
- [github.com/pbatard/rufus](https://github.com/pbatard/rufus)
- [linuxatemyram.com](https://www.linuxatemyram.com/)

# Debian 12 [//debian.org](https://debian.org/)

I use the Debian operating system almost everywhere, [with](https://www.reddit.com/r/unixporn/top/?t=year) and [without](<https://en.wikipedia.org/wiki/Terminal_emulator>) a graphical interface,

- on Windows
- container, VPS, dedicated server
- `x86` Laptop and Desktop

## Installation

On Windows 10 or 11 [`wsl.exe` install `debian` or `ubuntu`](./windows/linux/README.MD). WSL installs the latest version: `stable`, as of writing that's Debian GNU/Linux 12: `bookworm`.

```cmd
wsl.exe --install debian
REM enter username
REM enter password
REM enter password
```

## Hello World

With an `$EDITOR` like [VS Code](https://code.visualstudio.com/) you can manually configure `~/`.

```bash
ls -a ~/
code ~/

cd ~/
echo "Hello, World!" >> hello.md
cat hello.md

sudo ping google.com
# CTRL+C

uname # Linux
hostnamectl # Debian GNU/Linux 12 (bookworm)
getent hosts deb.debian.org # fastlydns.net
whoami
```

In `wsl.exe` you can run Windows programs on Linux files!

```bash
explorer.exe .
```

## Configuration

Install packages and copy dotfiles.

```bash
sudo bash ./script/upgrade.sh
```

```bash
rm ~/.bash_logout
cp -r ./home/. ~/.
source ~/junaga.sh
bash ./script/config.sh

exit
# enter bash
```

(Optional) Move `~/` somewhere else

```bash
sudo sed -i "s/\/home\/$USER/\/usr\/local/" /etc/passwd
sudo chown -R $USER:$USER /usr/local/
cp -r /home/$USER/. /usr/local/.
sudo rm -r /home/

exit
# enter bash
```
