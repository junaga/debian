- https://en.wikipedia.org/wiki/NTFS
- https://en.wikipedia.org/wiki/File_attribute
- https://en.wikipedia.org/wiki/Shadow_Copy

# Windows Filesystem

```sh
C:\Windows                        # Operating System
C:\Program Files                  # Applications
C:\Users\<user>                   # Data
C:\$Recycle.Bin                   # Trash

C:\ProgramData                    # system data
```

Windows is retarded, we can immediatly see this from the spaces and capitalization in file names `C:\Program Files (x86)`. By default `NTFS` is case-insensitive for all languages. Unicode Case Mapping is invoked on every filesystem and shell op. Not to mention that names in `%PATH%` are truncated with `PATHEXT=.COM;.EXE;.BAT;.CMD;.VBS;.VBE;.JS;.JSE;.WSF;.WSH;.MSC` suffixes. truly developer friendly design. Windows is just as bad as JavaScript. so stop making fun of JavaScript.

## NTFS Attributes

Unix files have exactly one file type (`d`, `l`, ...). Windows files can have multiple attributes (`S` + `H`) at the same time.

| attribute ||
|-|-|
| `D` | Directory |
| `L` |	symbolic Link |
| `R` |	is Read only |
| `H` |	Hidden (like `.` prefix in Unix) |
| `S` |	owned by operating System |
| `A` | a flag "changed since archived" |
| `E` |	filesystem Encrypted file |
| `I` | windows search will not Index | 

Verify there are no filesystem encrypted files and directories recursively, check hidden files too.

```cmd
cipher.exe /U /H /S:C:\
```

Remove Read only, Hidden, and System attributes on files and directories recursively, do not follow symlinks.

```cmd
attrib.exe /D /S /L -R -H -S <file>
```

## NTFS Links

Unix and Windows have symbolic links and hard links, Windows has additional links.

### Junction Points

Junction Points are absolute soft links to modern Windows directories. They replace directories from previous Windows versions for backwards compatibility. Microsoft restructures the Windows filesystem hierarchy between Windows releases. Older Apps, Games, Programms, and Windows itself, read and write the old directory, unaware of the link to the new directory. The first Junction Points in **Windows Vista** replaced some **Windows XP** directories.

```txt
C:\Documents and Settings [C:\Users]
C:\Users\<User>\Application Data [C:\Users\<User>\AppData\Roaming]
C:\Users\All Users [C:\ProgramData]
```

Since **Windows 10** some Junction Points got changed into symbolic links. But a lot of Junction Point files still remain in **Windows 11**.

Some Junction Points are recursive.

### Mount Points

Mount Points are special symbolic links that resolve a directory into the root of a localhost drive.

### Shortcuts

Shortcuts are not filesystem links, they are `.lnk` and `.url` files used by `explorer.exe`.
