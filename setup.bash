#!/bin/bash
# Setup a new Debian system in my preferred way.

if test "$(whoami)" != "root"
then
	echo "Error: run with \`$ sudo bash -e \$FILE\`" >&2
	exit 1
fi

#=== Uninstall unwanted packages ===

uninstall='apt-get --quiet remove --purge -y'
# I don't write C code
$uninstall gcc-9-base
# I use the "VS Code" editor exclusively
$uninstall nano vim-tiny vim-common

#=== We only have one user ===
# Always create new VMs, never new users

rm -r /etc/profile
rm -r /etc/profile.d/
rm -r /etc/bash.bashrc
# Remove new user $HOME template
rm -r /etc/skel

# TODO
# remove redundant users
# sudo timedatectl set-timezone UTC
