ECHO OFF

REM check that CPU virtualzation is enabled
systeminfo.exe | find "Virtualization"

@REM Enable Windows Features 
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

ECHO uninstalling previous Debian
wsl.exe --unregister Debian

ECHO installing Debian
wsl.exe --install Debian

ECHO:
ECHO Windows needs to mount the "network location"
ECHO sleeping 10 seconds...
PING 127.0.0.1 -n 11 > nul
REM this is how we `sleep` in windows
REM https://stackoverflow.com/questions/1672338/how-to-sleep-for-five-seconds-in-a-batch-file-cmd

PAUSE
