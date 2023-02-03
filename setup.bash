#!/bin/bash
# WARN: needs to be run from this directory
# setup a new Debian VM in my preferred way.

if test "$(whoami)" != "root"
then
	echo "Error: run with \`$ sudo bash -e \$FILE\`" >&2
	exit 1
fi

echo "What is the user home directory? Should be something like \`/home/junaga/\`"
read -e -p "user home: " -i "$PWD" home

#=== Bash Shell profile ===
rm $home/{.profile,.bashrc,.bash_logout}
cp -ra ./home/. $home
unset home

rm /etc/profile
rm -r /etc/profile.d/
rm /etc/bash.bashrc

#=== cleanup `/etc` ===
rm -r /etc/skel # new user $HOME template
rm -r /etc/sudoers.d/ # walls and ladders
rm -r /etc/terminfo # don't create new terminfos

#=== add `apt` sources ===
cp -ra ./trusted/. /usr/share/keyrings/
echo -e "\n" >> /etc/apt/sources.list
cat sources.list >> /etc/apt/sources.list
apt update

#=== un-/install packages ===
uninstall='apt remove --purge -y'

# I use the "VS Code" editor exclusively
$uninstall vim-tiny vim-common # nano sensible-utils
# I don't write C code
$uninstall gcc-9-base
# read docs on https://manpages.debian.org
$uninstall isc-dhcp-common
# There is no Desktop
$uninstall tasksel

apt upgrade -y
apt install -y $(cat ./packages)

echo That's it, now `bash --login` and ygtg
