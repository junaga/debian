[I use](./why.md) the [Debian](https://debian.org/) operating system, with and [without](https://learn.microsoft.com/en-us/windows/terminal/tutorials/ssh) a desktop, almost everywhere.

- Laptop and Workstation PC
- VM on the [Windows Subsystem for Linux](https://learn.microsoft.com/en-us/windows/wsl/install)
  - Admin `cmd.exe` -> `wsl --install -d debian`
- Containers and VMs on the public cloud

## The `setup.bash` script

After installing Debian on any platform, I configure the system

- remove some artifacts in the filesystem
- install packages with `apt` and `npm` ([install/upgrade.bash](./install/upgrade.bash))
- copy [home/](./home/) (my dotfiles) to `$HOME/`

```sh
# install Debian, enter the shell
cd $HOME
# download https://github.com/junaga/debian
sudo bash -e debian/setup.bash
# confirm `$HOME/` replacement
```
