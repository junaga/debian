<#
.SYNOPSIS
  Backs up EVERYTHING under %USERPROFILE% (files, AppData, Protect, NTUSER.DAT, UsrClass.dat, Start/Menu layouts, Steam, .ssh, WSL, etc.)
  plus exports the live HKCU registry hive for your user.
.PARAMETER StorePath
  Directory to hold the backup (e.g. D:\ProfileBackup).
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$StorePath
)

# 1) Create the backup root
if (-not (Test-Path $StorePath)) {
    New-Item -ItemType Directory -Path $StorePath | Out-Null
}

# 2) Mirror-copy the entire user folder
#    - /MIR       = mirror (creates an exact mirror)
#    - /COPYALL   = copy data, attributes, timestamps, security, owner, auditing
#    - /XJ        = exclude junctions (avoid recursion into C:\Users)
#    - /R:0 /W:0  = no retries or waits
robocopy `
    $Env:USERPROFILE `
    (Join-Path $StorePath "UserProfile") `
    /MIR /COPYALL /XJ /R:0 /W:0 | Out-Null

# 3) Export the live HKCU hive
$regFile = Join-Path $StorePath "HKCU_Backup.reg"
reg export HKCU $regFile /y | Out-Null

Write-Host "✅ Backup complete!"
Write-Host "  • Files & folders: $StorePath\UserProfile"
Write-Host "  • Registry hive:   $regFile"
