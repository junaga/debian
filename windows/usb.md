# USB passthrough // [learn.microsoft.com](https://learn.microsoft.com/en-us/windows/wsl/connect-usb)

Run in Administrator PowerShell `powershell.exe`

```powershell
winget install --interactive --exact dorssel.usbipd-win
Set-Alias usbipd "$env:ProgramFiles\usbipd-win\usbipd.exe"

# List USB IDs
usbipd list
```

1. Confirm the WSL VM is running
2. replace `<BUSID>` with your USB ID
3. attach the USB

```powershell
wsl --list --running

usbipd bind --busid "<BUSID>"
usbipd attach --wsl --busid "<BUSID>"
```

The USB is now available to WSL2 instead of Windows. In WSL2, use `lsblk` to find it.
