set -eu
iso=$(realpath "${1:?Pass a Debian Live ISO}")
test -r "$iso"
work=/tmp/debian-test
mkdir -p "$work"
cleanup() {
	test ! -f "$work/vars.fd" || rm "$work/vars.fd"
	rmdir "$work"
}
trap cleanup EXIT
trap 'exit 1' INT TERM

# Boot the actual ISO with both firmware types. Close each VM to continue.
boot() {
	qemu-system-x86_64 -enable-kvm -m 2048 -smp 2 \
		-cdrom "$iso" -boot d -nic none -display gtk "$@"
}
cat <<'CHECKS'
Select Live system in each VM and confirm the desktop or console works.
For a remastered ISO, check the live user and kernel:
  uname -r; test -d /lib/modules/$(uname -r)
  git --version; gh --version; codex --version; hf version
  systemd-nspawn --version; podman --version; tailscale version
  ls -la ~; ls -la ~/.ssh
  systemctl --failed
Confirm your dotfiles are present. Networking is disabled for this boot test.
Close each VM window after checking it; QEMU exit alone is not a test pass.
CHECKS
printf '\nBIOS boot:\n'
boot
printf '\nUEFI boot:\n'
cp /usr/share/OVMF/OVMF_VARS_4M.fd "$work/vars.fd"
boot -machine q35,smm=on \
	-drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE_4M.fd \
	-drive "if=pflash,format=raw,file=$work/vars.fd"
printf '\nBoth VMs closed. Boot and guest checks require manual confirmation.\n'
