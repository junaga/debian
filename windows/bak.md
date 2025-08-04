## Software is just files

Computer hardware deteriorates and eventually needs upgrading or replacement, but software is eternal. All software that was ever made, including every operating system and application, are `directories` of `files` in a `filesystem` on a `disk`. All files can easily be copied between different computers with USB, PCI, WiFi or the internet.

## Windows Backup

[Windows Backup](https://www.microsoft.com/en-us/windows/tips/windows-backup) `ms-settings:backup`, not to be confused with [Backup and Restore](https://en.wikipedia.org/wiki/Backup_and_Restore), is the managed backup solution for Windows version 10 and 11.

Windows Backup "syncs" local documents and some settings with a Microsoft account. It also reinstalls, and data restores if possible, the Apps installed from the [Microsoft Store](https://apps.microsoft.com/), but not the `winget.exe` repository. Unfortunalty Windows Backup does not back up everything in `%USERPROFILE%`, it cherry-picks through `AppData\Roaming` and `NTUSER.DAT`, and completely ignores `AppData\Local`.

## Manual Backup

There is three ways to backup and restore a Windows system manually.

1. Copy all data in the `%USERPROFILE%` directory
   - `Documents`, `Pictures`, `Downloads` ...
   - `AppData\Roaming`, `AppData\Local`
   - `NTUSER.DAT`
2. Image all files in the `%SYSTEMDRIVE%` filesystem
3. Clone all partitions in the partition table

## Copy data directory

exFAT

## Image filesystem

A filesystem moved between two computers can still have it's operating system booted if the two machines have identical

- CPU architecture `x86_64` `ARM64` ...
- motherboard firmware `UEFI` ...
- partition table `GPT` ...
- bootloader `ESP`
