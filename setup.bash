#!/bin/bash -e

if test $(whoami) != root
then
	echo "Error: run with \`$ sudo bash -e \$FILE\`" >&2
	exit 1
fi

dir="$(dirname "$(readlink -f "$0")")"

#=== cleanup fs ===

# I manually install packages in /usr/local/
rm -r /usr/local/
rm -r /srv/
rm -r /opt/
mkdir /usr/local/
rm -r /var/opt/
rm -r /var/local/

# I write my code in $HOME/src/
rm -r /usr/src/

# Linux is for work
rm -r /usr/games/

# I use https://mail.google.com
rm -r /var/mail/
rm -r /var/spool/mail

# # not required in VMs
# rm -r /lost+found/
# rm -r /boot/
# rm -r /media/
# rm -r /root/
# rm -r /var/spool/

#=== cleanup /etc ===

# There is /lib/terminfo/
rm -r /etc/terminfo/
# walls and ladders
rm -r /etc/sudoers.d/

# Add $HOME/.profile manually
rm /etc/profile
rm -r /etc/profile.d/
rm /etc/bash.bashrc
rm -r /etc/skel/ # $HOME template

#=== uninstall packages ===

# I use the "VS Code" editor exclusively
apt remove --purge -y vim-tiny vim-common xxd
# Translations and documentation
apt remove --purge -y debconf-i18n isc-dhcp-common
# There is no Desktop
apt remove --purge -y tasksel

# reduce the output of `apt-mark showmanual`
apt-mark minimize-manual -y

#=== install packages ===

bash -e "$dir"/install/upgrade.bash
rm /etc/bash_completion
rm /etc/zsh_command_not_found

#=== Bash Shell profile ===
echo "Replace directory with "$dir"/home/? (press CTRL+C to abort)"
read -e -p "replace: " -i $PWD home

tmp=/tmp/$RANDOM/
mkdir $tmp

cp -ra "$dir"/home/ $tmp/new-home/ # in case the script would move itself
mv $home/ $tmp/old-home/
mv $tmp/new-home/ $home/
mv $tmp/old-home/ $home/old-home/

echo "That's it, you're gtg."
echo "now: \`$ bash --login\`"
echo "next: \`$ rm -r old-home\`"
