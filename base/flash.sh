set -eu
test $(whoami) != "root" && exec sudo -E sh $0
DIR=$PWD/$(dirname $0)
cd /var/tmp

# Download
curl -fL $URL > debian.iso

# Unpack
osirrox -indev debian.iso -extract /live/filesystem.squashfs fs
unsquashfs -d debian fs

# Copy dotfiles
cp -r --preserve=timestamps $DIR/home/. debian/etc/skel/

# The Live ISO's source list refers to its boot medium, which is not mounted
# inside the build container. Keep Debian available for the bootstrap step.
sed -i '\|file:/run/live/medium|d' debian/etc/apt/sources.list
echo 'deb http://deb.debian.org/debian/ trixie main non-free-firmware' \
	>> debian/etc/apt/sources.list

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
