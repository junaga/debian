# Linux Filesystem

Because the Linux BSD Unix filesystem is complicated, developers sometimes put everything in `$HOME`, which is fine.

```sh
/etc/             # configuration
/mnt/             # drives
/boot/
```

User installed Software

```sh
/usr/local/bin/   # executables
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
