#!/bin/bash
# WARN: needs to be run from this directory
# setup a new Debian VM in my preferred way.

if test "$(whoami)" != "root"
then
	echo "Error: run with \`$ sudo bash -e \$FILE\`" >&2
	exit 1
fi

read -e -p "user home: " -i "$PWD" home

#=== Bash Shell profile ===
rm $home/{.profile,.bashrc,.bash_logout}
cp -r ./home/* $home
unset home

rm /etc/profile
rm -r /etc/profile.d/
rm /etc/bash.bashrc

#=== cleanup `/etc` ===
rm -r /etc/skel # new user $HOME template
rm -r /etc/sudoers.d/ # walls and ladders
rm -r /etc/terminfo # don't create new terminfos

#=== add `apt` sources ===
cp -r ./trusted/* /usr/share/keyrings
echo -e "\n\n" >> /etc/sources.list
cat sources.list >> /etc/sources.list

#=== un-/install packages ===
uninstall='apt-get remove --purge -y'
apt update

# I use the "VS Code" editor exclusively
$uninstall vim-tiny vim-common # nano sensible-utils
# I don't write C code
$uninstall gcc-9-base
# read docs on https://manpages.debian.org
$uninstall isc-dhcp-common
# There is no Desktop
$uninstall tasksel

apt upgrade -y
for pkg in $(cat ./packages)
do
	apt install -y $pkg
done
