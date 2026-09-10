set -eu
URL_ISO="${ISO:?Set ISO to a download URL}"
USB_2_0="${USB:?Set USB to a whole drive}"

# Download ISO
cd /tmp
file="${URL_ISO##*/}"
curl -vfL "$URL_ISO" > "$file"

# Unmount macOS USB
if test "$(uname)" = Darwin; then
	sudo diskutil unmountDisk "$USB_2_0"
fi

# Unmount Linux USB
if test "$(uname)" = Linux; then
	partitions=$(lsblk -nro PATH "$USB_2_0")
	for partition in $partitions; do
		findmnt -S "$partition" || continue
		sudo umount --all-targets "$partition"
	done
fi

# Copy ISO to USB
sudo cp -v "$file" "$USB_2_0"
sudo sync
echo "Done"
