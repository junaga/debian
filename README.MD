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

## Installation

On Windows 10 or 11 [`wsl.exe --install`](./windows/linux/README.MD) `debian`.

_WSL installs the latest version: `stable`, as of writing that's Debian GNU/Linux 13 `trixie`._

## Hello World

With an `$EDITOR` like [VS Code](https://code.visualstudio.com/) you can manually configure `~/`.

```bash
ls -a ~/
code ~/

cd ~/
echo "Hello, World!" >> hello.md
cat hello.md
rm hello.md

ping google.com
# CTRL+C

getent hosts deb.debian.org # fastly (CDN hosting the packages)
hostnamectl # Debian GNU/Linux 13
uname --machine # x86_64 or aarch64
whoami

# In `wsl.exe` you can run Windows programs on Linux files!
explorer.exe .
```

## Configuration

Install packages

```bash
sudo bash ./script/upgrade.sh
```

Copy dotfiles

```bash
rm ~/.bash_logout
cp -r ./home/. ~/.

source ~/junaga.sh
bash ./script/git4hub.sh

exit
# enter bash
```

(Optional) Move user home

```bash
sudo sed -i "s|/home/$USER|/usr/local|" /etc/passwd
sudo chown -R $USER:$USER /usr/local/
cp -r /home/$USER/. /usr/local/.
sudo rm -r /home/

exit
# enter bash
```
