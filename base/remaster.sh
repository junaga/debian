set -eu
test $(whoami) = root || exec sudo sh $0 "$@"
SRC=$(dirname "$0")
ISO="$1"
cd /tmp

# Unpack
osirrox -indev "$ISO" -extract / iso
unsquashfs -d fs iso/live/filesystem.squashfs

# Copy dotfiles
cp -r --preserve=timestamps "$SRC/home/." fs/etc/skel/

# Install packages
systemd-nspawn -D /tmp/fs -a \
	--bind-ro="$SRC:/mnt" \
	--resolv-conf=bind-host -E SYSTEMD_OFFLINE=1 sh /mnt/install.sh

# Repack
chroot fs dpkg-query -W > iso/live/filesystem.packages
mksquashfs fs iso/live/filesystem.squashfs -noappend
xorriso -dev "$ISO" -map iso/live /live \
	-rm /md5sum.txt /sha256sum.txt \
	-- -boot_image any replay -end
