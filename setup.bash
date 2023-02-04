#!/bin/bash
# WARN: needs to be run from this directory
# setup a new Debian VM in my preferred way.

if test $(whoami) != root
then
	echo "Error: run with \`$ sudo bash -e \$FILE\`" >&2
	exit 1
fi

#=== Bash Shell profile ===
echo "Where to place shell user profile?"
read -e -p "user home: " -i $PWD home

rm $home/{.profile,.bashrc,.bash_logout}
cp -ra ./home/. $home
unset home

#=== configure `apt` ===
apt-mark auto $(apt-mark showmanual)
apt-mark manual $(cat ./packages)

cp -ra ./trusted/. /usr/share/keyrings/
echo -e "\n" >> /etc/apt/sources.list
cat sources.list >> /etc/apt/sources.list
apt update

#=== un-/install packages ===
uninstall="apt remove --purge -y"

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

#=== cleanup `/etc` ===
# We have a shell profile in $HOME
rm /etc/profile
rm -r /etc/profile.d/
rm /etc/bash.bashrc

rm -r /etc/skel # new user $HOME template
rm -r /etc/sudoers.d/ # walls and ladders
rm -r /etc/terminfo # don't create new terminfos

#=== That's it ===
echo That\'s it, you\'re gtg.
echo now: \`$ bash --login\`
echo next: \`$ cd .. && rm -r my-debian\`
