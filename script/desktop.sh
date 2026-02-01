# faster PC boot
efibootmgr --timeout 0
sed -i "s|GRUB_TIMEOUT=5|GRUB_TIMEOUT=0|" /etc/default/grub
rm -r /etc/default/grub.d/
update-grub
