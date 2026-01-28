efibootmgr --timeout 0

sed -i s/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/ /etc/default/grub
rm -r /etc/default/grub.d/
update-grub

apt modernize-sources -y
rm /etc/apt/sources.list.bak
apt update
apt upgrade -y
apt install --no-install-recommends micro git ca-certificates -y
apt install --no-install-recommends bash-completion command-not-found -y
