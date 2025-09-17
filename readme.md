- [github.com/microsoft/WSL](https://github.com/microsoft/WSL)
- [github.com/apple/container](https://github.com/apple/container)
- [github.com/pbatard/rufus](https://github.com/pbatard/rufus)

# Debian `13` [//debian.org](https://debian.org/)

I use the Debian operating system almost everywhere, [with](https://www.reddit.com/r/unixporn/top/?t=year) and [without](<https://en.wikipedia.org/wiki/Terminal_emulator>) a graphical interface,

- on Windows
- container, VPS, dedicated host
- `x86-64` Laptop and Desktop

## Hello World

With an `$EDITOR` like [VS Code](https://code.visualstudio.com/) you can manually configure `~/`.

```sh
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
uname --machine # x86_64 or aarch64 (CPU architecture)
```

## Installation

1. On **Windows 10 or 11** you can [`wsl.exe --install`](./win/linux/README.MD) `debian`.

2. When buying or managing a **host, server, container** in the **public cloud**, just select "Debian 13" in the dropdown during setup.

3. **Hardware installations** are difficult, for PC hardware i recommend [github.com/pbatard/rufus](https://github.com/pbatard/rufus).

```sh
uname # Linux
hostnamectl | grep trixie # Debian GNU/Linux 13
```

## Download

Download the `.zip` repository manually; or with `wget`, `curl`, `git clone`; or `apt` itself, if nothing else is installed.

```sh
WHO="junaga"
WHAT="debian"
WHEN="main"
LINK="https://codeload.github.com/$WHO/$WHAT/tar.gz/refs/heads/$WHEN"
cd ~/

/usr/lib/apt/apt-helper download-file $LINK tar.gz
tar -xz -f tar.gz
rm tar.gz

mv $WHAT-$WHEN/ src/
```

## Configuration

Install packages

```sh
sudo bash src/script/upgrade.bash
```

Copy dotfiles

```sh
ls
rm .bash_logout
cp -r src/home/. .
edit .env # code, cursor, vim, micro

exit # and enter
```

(Optional) Git sex GitHub

```sh
bash src/script/git6hub.bash
```

(Optional) Move user home

```sh
cp -r $HOME/. /usr/local/.
sudo chown -R $USER:$USER /usr/local/
sudo sed -i "s|$HOME|/usr/local|" /etc/passwd

exit # and enter
```

(Optional) Clean filesystem

```sh
sudo rm -r /home/
sudo rm -r /root/
sudo bash src/script/purge.bash

# only in virtual machines
sudo rm -r /media/
sudo rm -r /mnt/

# only in containers
sudo rm -r /boot/
```
