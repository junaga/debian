# Debian 13 Boot Order

1. **UEFI** starts Debian's EFI boot entry: GRUB, or, with Secure Boot, shim
   which verifies and starts GRUB.
2. **GRUB** reads its configuration, loads `/boot/vmlinuz-*` and
   `/boot/initrd.img-*`, and passes the kernel command line.
3. **The kernel** initializes hardware, unpacks the initramfs, and runs its
   `/init`.
4. **The initramfs `/init`** finds and mounts the real root filesystem, then
   switches root and execs `/sbin/init`. With a systemd initramfs,
   `initrd.target` is its boot target.
5. **systemd** (`/sbin/init`, PID 1) starts the default target—the target
   named by `/etc/systemd/system/default.target`—and its dependencies in
   parallel when possible:
   1. `sysinit.target` prepares devices, local filesystems, and system state;
      it includes `local-fs.target` and `swap.target`.
   2. `basic.target` provides the core OS environment.
   3. `multi-user.target` starts normal services and terminal logins.
   4. `graphical.target` builds on `multi-user.target` with a display manager.
6. For repair, use `rescue.target` or `emergency.target`. On shutdown, systemd
   stops units in reverse dependency order, unmounts filesystems, then reboots,
   powers off, or halts.
