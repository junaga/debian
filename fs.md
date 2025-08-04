- https://refspecs.linuxfoundation.org/fhs.shtml
- https://systemd.io/THE_CASE_FOR_THE_USR_MERGE/

# Linux Filesystem

Because the Linux BSD Unix filesystem hirachy is complicated, developers sometimes put everything in `$HOME`, which is fine.

In 1970 only executable `bin` binary files, linkable `lib` library files, and compilable `src` source files existed, everything else was text. Today a lot of other non-text file formats or "binary files" exist, like `.png`, `.jpeg`, `.mp3` or `.mp4`. That's also why executables on Unix don't have a file extension, like `.exe` on Windows, the only format a binary file could possibly have was CPU exectuable.

```sh
/etc/             # configuration
/mnt/             # drives
/boot/            # kernel
```

User installed Software

```sh
/usr/local/bin/   # executables
/usr/local/sbin/  # admin executables
/usr/local/lib/   # library
```

Distribution installed Packages

```sh
/usr/bin/         # executables
/usr/sbin/        # admin executables
/usr/lib/         # library
/usr/share/       # data library
```

Unix Tools and C library

```sh
/bin/
/sbin/
/lib/
```

Data

```sh
$HOME             # user data
/var/             # system data
```

Volatile data

```sh
/tmp/             # runtime data
/run/             # system runtime data
```

Kernel and Hardware

```sh
/sys/
/proc/
/dev/
```
