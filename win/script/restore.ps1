<#
.SYNOPSIS
  Restores EVERYTHING back into %USERPROFILE%, then re-imports your HKCU registry hive.
.PARAMETER StorePath
  Directory where the backup lives (same path you used above).
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$StorePath
)

# 1) Validate backup exists
$profileBackup = Join-Path $StorePath "UserProfile"
if (-not (Test-Path $profileBackup)) {
    Throw "Backup directory not found: $profileBackup"
}

# 2) Mirror-copy back into your user folder
robocopy `
    $profileBackup `
    $Env:USERPROFILE `
    /MIR /COPYALL /XJ /R:0 /W:0 | Out-Null

# 3) Re-import your HKCU registry hive
$regFile = Join-Path $StorePath "HKCU_Backup.reg"
if (Test-Path $regFile) {
    reg import $regFile | Out-Null
} else {
    Write-Warning "Registry backup not found: $regFile"
}

# 4) Reset ACLs so your user owns everything
icacls $Env:USERPROFILE /reset /T | Out-Null

Write-Host "✅ Restore complete!"
Write-Host "  Please log off and back on (or reboot) to apply all settings."
