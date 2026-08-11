# Issues

## 1. Linux application identity database

Create and publish a community database mapping Linux applications and window
roles to Wayland app IDs, X11 classes, titles, tags, and other useful metadata.

## 2. Tape edge navigation

Implement [tape edge navigation](desktop/tape-navigation.md): reveal a subtle
arrow over each visible clipped-window fragment and focus that exact window
when the fragment is clicked.

## 3. Native Keycast overlay

Implement the native [Keycast overlay](desktop/keycast.md).

## 4. Persistent shutdown-failure logging

Enable persistent final-shutdown logging with a kernel built with
`CONFIG_PSTORE_CONSOLE`, plus the pstore kernel parameters needed to capture
hangs after journald has stopped.

## 5. Privilege-safe boot upgrades and Codex daemon startup

The `@reboot` entry installed by `base/setup.sh` runs `base/upgrade.sh` as the
desktop user, although the upgrade script performs privileged package and
`/etc/apt` operations. Running the script manually with `sudo` caused Codex
remote control to start as root under `/tmp/.codex`, leaving an errored,
root-owned daemon disconnected from the desktop user session.

Implement a privilege-safe boot service with an explicit user phase before
restoring automatic remote-control startup.

## 6. Restore scrollback to the Linux kernel virtual console

Provide useful, bounded scrollback on the actual Linux kernel virtual terminals
without requiring a userspace terminal emulator or multiplexer. The intended
interface is the traditional Shift+PageUp and Shift+PageDown behavior on
`/dev/ttyN`. Keep at least one stock kernel console available as a rescue path,
and do not make Codex, the graphical desktop, or system recovery depend on the
new implementation.

### Motivation and constraint

Codex currently runs directly on `tty1` with `TERM=linux`. Once output leaves
the screen, the active console cannot recover it. Codex's `--no-alt-screen`
option avoids its alternate-screen TUI and would let a terminal retain future
output, but it cannot add history to a terminal which has no scrollback buffer.

The desired environment is specifically the in-kernel VT console. GNU Screen,
tmux, fbterm, and similar process wrappers are not the architecture wanted here.
KMSCON is a capable DRM/KMS system console with structured scrollback, Unicode,
international input, fonts, and other improvements, but it is a userspace
terminal emulator which replaces the kernel renderer. If DRM/KMS userspace is
required merely to obtain a console, booting the desktop is already an option;
therefore KMSCON is not the solution to this issue.

### Current machine and kernel

The investigation was performed on Debian kernel `6.19.14+deb14-amd64` with
`CONFIG_VT=y`, `CONFIG_VT_CONSOLE=y`, `CONFIG_VGA_CONSOLE=y`, and
`CONFIG_FRAMEBUFFER_CONSOLE=y`. Debian compiles fbcon into `vmlinux`; it is not
a separate `fbcon.ko` in this build. The registered console backends are the
dummy system driver and the modular framebuffer console.

The active framebuffer is firmware-provided `efifb` (`EFI VGA`). Its visible
and virtual dimensions are both 1024x768, leaving no hidden rows. A framebuffer
is pixel memory, not the monitor itself or a terminal history. Its mode often
matches the displayed resolution, but the firmware fixes its base address,
stride, format, and reserved size at boot.

The kernel retains limited hardware-backed scrolling machinery. It can pan
through spare legacy VGA memory or framebuffer rows outside the visible area,
when such memory exists. This is not normal terminal scrollback: it retains
rendered pixels in a finite device surface instead of storing characters and
attributes in a RAM ring. On this machine the virtual framebuffer is no taller
than the visible framebuffer, so that mechanism retains zero lines.

UEFI normally exposes complete visible display modes rather than an arbitrary
visible window into an extremely tall surface. Linux cannot safely extend the
fixed `efifb` reservation into unrelated RAM. At 32 bits per pixel, retaining
10,000 text rows rendered with a 16-pixel-high font at 1024 pixels wide would
consume about 625 MiB and may exceed a GPU's maximum surface height. A terminal
cell buffer is much smaller and preserves searchable characters, colors, and
attributes instead of only their rendered result.

### Why the expected option is missing

Linux removed the general RAM-backed software scrollback implementations in
2020. The relevant upstream commits are:

- vgacon: `973c096f6a85e5b5f2a295126ba6928d9a6afd45`
- fbcon: `50145474f6ef4a9c19205b173da6264a644c7489`

The fbcon removal addressed the implementation implicated in
`CVE-2020-14390`, a slab out-of-bounds write involving scrollback and VT resize.
Consequently current kernels do not provide the old
`fbcon=scrollback:<size>` option or its former Kconfig setting. No Debian
configuration, boot parameter, packaged kernel module, or userspace library can
enable a discarded fbcon history buffer. Userspace also cannot reconstruct
rows after the kernel has overwritten them.

Legacy vgacon may expose a small hardware-memory history on suitable BIOS/VGA
systems, but it is not a general solution for this UEFI, NVIDIA, and Hyprland
machine. Switching console backends or firmware modes solely to obtain a few
hardware rows would be fragile and still would not provide a real history.

### Existing 2026 patch

Alan Mackenzie of Nuremberg posted a new framebuffer-console soft-scrollback
patch to the `gentoo-user` mailing list on 24 February 2026:

https://www.mail-archive.com/gentoo-user@lists.gentoo.org/msg196315.html

It adds Shift+PageUp/PageDown, per-VT RAM buffers,
`CONFIG_FRAMEBUFFER_CONSOLE_SOFT_SCROLLBACK`, a configurable buffer size, and
GPM selection in scrolled regions. The post says Linux 6.18.12, while its
example directory and filename say 6.12.18; resolve that discrepancy against
the author's tree. This was shared on a Gentoo user discussion list, not
accepted by Gentoo, Debian, or upstream Linux. The posted diff modifies core VT
and fbcon code, contains unfinished-looking comments, and appears to require
careful separation from unrelated tree changes. Treat it as prior art, not as a
patch ready to install.

If this route is pursued, audit and forward-port it to Debian's kernel, test it
specifically against the original resize vulnerability, package it separately,
and keep the stock Debian kernel bootable. A completed implementation should go
first to the upstream Linux VT/fbcon maintainers; Gentoo and Debian integration
can follow through their normal bug and kernel-package processes.

### Console-driver module route

The kernel VT subsystem owns `/dev/ttyN`, terminal state, escape-sequence
interpretation, and keyboard integration. A low-level `struct consw` console
driver renders that state. fbcon is the current renderer.

Linux supports modular console drivers. This Debian kernel exports the GPL
`do_take_over_console()` interface and `give_up_console()`. An out-of-tree GPL
module can register a `struct consw`, take over a selected VT range, and later
return it to the fallback driver. Takeover is immediate: for every already
allocated VT in the selected range, the kernel saves the screen, deinitializes
the old renderer, initializes the new renderer, and redraws. VTs outside that
range remain on fbcon. The module can also become the default renderer for newly
opened consoles.

A safe prototype should therefore use only `tty2`, leaving `tty1` and all other
VTs on stock fbcon. Unbinding or unloading the prototype must return `tty2` to
fbcon without rebooting.

Upstream Linux 6.19 fbcon is about 3,450 lines in `fbcon.c`, 232 lines in its
header, and roughly 700 lines of direct bitblit, tileblit, and rotation helpers:
about 4,400 lines around the renderer. The generic VT core is another roughly
5,000 lines which a new driver would reuse. This is not necessarily a huge
project, but it is not a small history hook either. fbcon does not expose its
internal renderer as a supported delegation API, so a truly separate module
would need to implement framebuffer drawing and lifecycle callbacks as well as
the history buffer, or require a small upstream kernel interface which permits
safe delegation.

For VPS installations, the driver applies only when the virtual machine exposes
a usable VGA/framebuffer console. Serial consoles such as `ttyS0` and
hypervisor consoles such as `hvc0` use different rendering/transport paths and
would not gain this framebuffer history. Their scrollback normally belongs to
the terminal client or hypervisor. A VPS may have `/dev/ttyN` state but no local
framebuffer on which to display it.

### Required design and safety properties

Before choosing the fbcon patch or separate-driver route, build a minimal
feasibility prototype and review the boundary between the VT core and fbcon.
The eventual implementation must:

- retain characters and attributes in a bounded, configurable RAM ring per VT,
  not retain enormous rendered-pixel surfaces;
- support Shift+PageUp and Shift+PageDown through the existing VT scrollback
  callback;
- define correct behavior when new output arrives while viewing history;
- survive console resize, font changes, VT allocation/deallocation, VT
  switching, blanking, graphics-mode transitions, and module unload;
- preserve color, character attributes, and the kernel's current Unicode screen
  representation accurately enough for redraw and selection;
- use correct locking and lifetime rules under concurrent writes and switches;
- validate every ring-buffer offset and size, including overflow and allocation
  failure paths;
- regression-test the `CVE-2020-14390` resize sequence and fuzz relevant resize,
  selection, and `TIOCLINUX` operations;
- take over only an explicitly selected test VT until stability is proven;
- fall back cleanly to fbcon on unload or failure;
- remain compatible with the NVIDIA/Hyprland desktop and preserve a stock
  console and stock Debian kernel for recovery;
- package reproducibly for Debian, using DKMS only if the design is genuinely
  viable as an out-of-tree module; and
- document that framebuffer-backed VPS consoles are supported separately from
  serial and hypervisor consoles.

Completion means Codex and ordinary shell output can be reviewed with
Shift+PageUp/PageDown directly on a real kernel VT, across resize and VT-switch
tests, without GNU Screen, tmux, KMSCON, a graphical terminal, or a userspace
terminal-emulation daemon, and without weakening the machine's recovery path.
