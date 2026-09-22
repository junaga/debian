# Build and flash a Debian live USB with this repository's system setup.
# Set URL to the live ISO and USB to the destination device; USB is overwritten.

set -eu
test $(whoami) != "root" && exec sudo -E sh $0
cd $(dirname $0)

URL=${URL:?Set URL to the source Debian live ISO}
USB=${USB:?Set USB to the destination device}


# Download
curl -fL $URL > debian.iso

# Unpack
osirrox -indev debian.iso -extract /live/filesystem.squashfs fs
unsquashfs -d debian fs

# Remove the live-medium source.
sed -i '\|file:/run/live/medium|d' debian/etc/apt/sources.list

# Install packages
systemd-nspawn -D debian -a \
	--bind-ro=$PWD:/mnt \
	-E SYSTEMD_OFFLINE=1 \
	sh /mnt/instpkg.sh

# Repack
mksquashfs debian fs -noappend
xorriso -dev debian.iso -map fs /live/filesystem.squashfs \
	-rm /md5sum.txt /sha256sum.txt /live/filesystem.packages -- \
	-boot_image any replay -end

# Flash
cp debian.iso $USB
sync

# Clean up
rm debian.iso fs
