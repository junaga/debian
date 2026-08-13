# Debian 13 Boot Order

1. **UEFI** starts Debian's EFI boot entry: normally GRUB, or, with Secure
   Boot, shim (`/boot/efi/EFI/debian/shimx64.efi` when the EFI System Partition
   is mounted at `/boot/efi`), which verifies and starts GRUB.
2. **GRUB** reads its configuration, loads `/boot/vmlinuz-*` and
   `/boot/initrd.img-*`, and passes the kernel command line.
3. **The kernel** initializes hardware, unpacks the initramfs, and runs its
   `/init`.
4. **The initramfs `/init`** loads what is needed to find and mount the real
   root filesystem, then switches root and execs `/sbin/init`.
5. **systemd** (`/sbin/init`, PID 1) starts the default target—the target
   named by `/etc/systemd/system/default.target`—and its dependencies in
   parallel when possible:
   1. `sysinit.target` — local filesystems, devices, logging, temporary files,
      and kernel settings.
   2. `basic.target` — core OS environment.
   3. `multi-user.target` — services and terminal logins.
   4. `graphical.target` — optionally adds a display manager and graphical
      login.
6. For repair, boot `rescue.target` or `emergency.target` instead. On
   shutdown, systemd stops units in reverse dependency order, unmounts
   filesystems, then powers off, halts, or reboots.

A target is a synchronization point; a service is a process. `Wants=` and
`Requires=` pull units in; `After=` and `Before=` only order them.
