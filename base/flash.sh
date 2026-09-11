set -eu
test $(whoami) != "root" && exec sudo -E sh $0
DIR=$PWD/$(dirname $0)
cd /var/tmp

# Download
URL="https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/debian-live-${VERSION}-amd64-standard.iso"
curl -fL $URL > debian.iso

# Unpack
osirrox -indev debian.iso -extract /live/filesystem.squashfs fs
unsquashfs -d debian fs

# Copy dotfiles
cp -r --preserve=timestamps $DIR/home/. debian/etc/skel/

# Install packages
systemd-nspawn -D debian -a \
	--bind-ro=$DIR:/mnt \
	-E SYSTEMD_OFFLINE=1 sh /mnt/install.sh

# Repack
mksquashfs debian fs -noappend
xorriso -dev debian.iso -map fs /live/filesystem.squashfs \
	-rm /md5sum.txt /sha256sum.txt /live/filesystem.packages -- \
	-boot_image any replay -end

# Flash
cp debian.iso $USB
