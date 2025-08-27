- [chat.com](https://chat.com/)
- [github.com/microsoft/WSL](https://github.com/microsoft/WSL)
- [github.com/apple/container](https://github.com/apple/container)
- [github.com/pbatard/rufus](https://github.com/pbatard/rufus)
- [linuxatemyram.com](https://www.linuxatemyram.com/)

# Debian `13` [//debian.org](https://debian.org/)

I use the Debian operating system almost everywhere, [with](https://www.reddit.com/r/unixporn/top/?t=year) and [without](<https://en.wikipedia.org/wiki/Terminal_emulator>) a graphical interface,

- on Windows
- container, VPS, dedicated server
- `x86-64` Laptop and Desktop

## Hello World

With an `$EDITOR` like [VS Code](https://code.visualstudio.com/) you can manually configure `~/`.

```bash
ls -a ~/
code ~/

cd /tmp
echo "Hello, World!" >> hello.md
cat hello.md
rm hello.md

# In `wsl.exe` you can run Windows programs on Linux files!
explorer.exe .

ping google.com
# CTRL+C

getent hosts deb.debian.org # fastlydns.net (CDN hosting the packages)
uname --machine # x86_64 or aarch64
```

## Installation

On Windows 10 or 11 [`wsl.exe --install`](./windows/linux/README.MD) `debian`.

_WSL installs the latest version: `stable`, as of writing that's Debian GNU/Linux 13 `trixie`._

```bash
uname # Linux
hostnamectl | grep trixie # Debian GNU/Linux 13
cd ~/
git clone https://github.com/junaga/debian src/
```

## Configuration

Install packages

```bash
sudo bash src/script/upgrade.sh
```

Copy dotfiles

```bash
ls
rm .bash_logout
cp -r src/home/. .
edit .env # code, cursor, vim, micro

exit # and enter
```

(Optional) Git sex GitHub

```bash
bash src/script/git6hub.sh
```

(Optional) Move user home

```bash
cp -r $HOME/. /usr/local/.
sudo chown -R $USER:$USER /usr/local/
sudo sed -i "s|$HOME|/usr/local|" /etc/passwd

exit # and enter
```

(Optional) Clean filesystem

```bash
sudo rm -r /home/
sudo rm -r /root/
sudo bash src/script/purge.sh

# only in virtual machines
sudo rm -r /media/
sudo rm -r /mnt/

# only in containers
sudo rm -r /boot/
```
