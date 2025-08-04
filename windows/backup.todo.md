## Windows backup (prompt)

i need to backup and restore my entire windows profile, with all it's user data and settings, on the same and different machine. when i boot my restored profile it should autostart steam and i am logged in. when i open the start menu it should have my apps pinned. list everything that is user data, as opposed to installation files. when i say all user data, i mean all user data, all of it.

<!-- i use Windows 11 with a local account without a password or any other auth method, i don't have a Microsoft account. -->

## user data (ChatGPT)

1. `%USERPROFILE%` personal files
2. `AppData` application data & per-user settings
3. credential stores
4. `HKCU` registry hive
5. `explorer.exe` desktop customizations

| `%USERPROFILE%\` |                                           |
| ---------------- | ----------------------------------------- |
| `Desktop`        | Files and shortcuts on the desktop        |
| `Documents`      | "My Documents" (Office files, PDFs, etc.) |
| `Downloads`      | Browser downloads                         |
| `Pictures`       | Images you’ve saved or imported           |
| `Videos`         | Recorded videos, movie clips              |
| `Music`          | Music library                             |
| `Favorites`      | Internet Explorer/Edge favorites          |
| `Contacts`       | Windows Contacts (.contact files)         |
| `Links`          | Quick-access "Links" you’ve saved         |
| `Saved Games`    | Per-game save files                       |
| `Searches`       | Custom saved search-queries               |
| `OneDrive`       | Your synced OneDrive folder (if enabled)  |

```
%APPDATA%\
  ├── Microsoft\Windows\Start Menu\Programs\      ← custom shortcuts & Start-menu entries
  ├── Microsoft\Windows\Start Menu\Programs\Startup\ ← per-user autostarts
  ├── Microsoft\Windows\Themes\                   ← your theme configurations
  ├── Microsoft\Windows\Recent\                   ← recent items list
  ├── Microsoft\Windows\Templates\                ← custom templates
  ├── Microsoft\Windows\SendTo\                   ← “Send to…” shortcuts
  ├── Microsoft\Windows\Network Shortcuts\        ← mapped-drive links
  ├── Microsoft\Windows\Performance Monitor\      ← user-specific perf logs
  ├── Microsoft\Credentials\                      ← saved Remote Desktop credentials
  ├── Mozilla\Firefox\Profiles\                   ← Firefox profiles
  ├── Google\Chrome\User Data\                    ← Chrome user-data (bookmarks, cookies)
  ├── Code\User\                                  ← VS Code settings & extensions
  ├── Steam\                                    ← Steam configs, login credentials
  └── … (hundreds more per-app folders)

%LOCALAPPDATA%\
  ├── Microsoft\Windows\Caches\                   ← icon thumbnails, jump-list caches
  ├── Microsoft\Windows\Explorer\                 ← thumbnail/db caches
  ├── Microsoft\Windows\Notifications\            ← toast notifications database
  ├── Packages\                                   ← UWP app data
  └── … (per-app caches & data)
```

| Store                       | Path                                       |
| --------------------------- | ------------------------------------------ |
| Windows Credentials         | `%AppData%\Microsoft\Credentials\*`        |
| Web Credentials (Vault)     | `%LocalAppData%\Microsoft\Vault\*`         |
| DPAPI Master Keys           | `%AppData%\Microsoft\Protect\<SID>\*`      |
| Certificates (Current User) | `%AppData%\Microsoft\SystemCertificates\*` |
| BitLocker recovery keys     | (if escrowed to AD or MS account)          |

| Item                   | Path / File                                                         | Why it matters                                           |
| ---------------------- | ------------------------------------------------------------------- | -------------------------------------------------------- |
| HKCU hive              | `%SystemDrive%\Users\<User>\NTUSER.DAT`                             | All your registry-based user settings                    |
| HKCU classes hive      | `%SystemDrive%\Users\<User>\UsrClass.dat`                           | COM registrations & shell extensions                     |
| Environment variables  | `HKCU\Environment`                                                  | PATH, custom variables                                   |
| Run-once / Run keys    | `HKCU\...\CurrentVersion\Run*`                                      | Autostart entries (Steam-silent login, etc.)             |
| File-type associations | `HKCU\...\CurrentVersion\Explorer\FileExts`                         | Your “default apps” for .docx, .jpg, etc.                |
| Printers               | `HKCU\Printers\Connections`                                         | Per-user network printers                                |
| Power plans            | `HKCU\Control Panel\PowerCfg`                                       | Custom power settings                                    |
| Wireless profiles      | `HKCU\Software\Microsoft\Wcmsvc`                                    | Saved Wi-Fi networks (though some stored in SYSTEM hive) |
| Taskbar pins           | `HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband` |                                                          |
## What does Windows Backup sync that’s outside %USERPROFILE%?

Outside %USERPROFILE%, Windows Backup mostly syncs network credentials, licenses, and security data tied to your MSA.

- Wi-Fi passwords:
    - Stored in C:\ProgramData\Microsoft\Wlansvc\Profiles\
    - Synced via Microsoft Account (MSA)
- BitLocker recovery keys:
    - Stored in your MSA cloud, not locally
- Credential Manager (Web + Windows credentials):
    - Some items sync to your MSA if enabled
    - Includes saved RDP passwords, mapped drive credentials
- Microsoft Edge favorites, settings, and passwords (if Edge sync is on)
- OneDrive configuration (account link and selective sync settings)
- Some Windows Hello configurations (but biometric data itself is not synced)
- Credential Manager
- BitLocker keys
- Windows Vault


can i backup `%USERPROFILE%` into exFAT, or does it also have to be NTFS? does Windows require and or use NTFS specific features on files and dirs in `%USERPROFILE%` or would that be recommended for compatibility?
