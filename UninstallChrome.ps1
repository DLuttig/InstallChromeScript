<#

.SYNOPSIS
    This script uninstalls Google Chrome from the system.

.DESCRIPTION
    The script removes the Google Chrome installation from the system.

#>

$ErrorActionPreference = "Stop"

$uninstallkeys = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\Google Chrome",
    "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Google Chrome"
)

$key = $uninstallkeys | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1

if (-not $key) {
    Write-Host "Google Chrome is not installed on this system."
    exit 0
}

$uninstallString = (Get-ItemProperty -Path $key).UninstallString

if (-not $uninstallString) {
    Write-Error "Uninstall string not found for Google Chrome."
    exit 1
}

if ($uninstallString -match 'msiexec\.exe') {
    $arguments = "/x `"$($uninstallString -replace 'msiexec\.exe', '')`" /qn /norestart"
} else {
    $arguments = "/c `"$uninstallString`" /quiet /norestart"
}

Write-Host "Starting Google Chrome uninstallation..."
$process = Start-Process -FilePath $uninstallString -ArgumentList $arguments -Wait
$process.WaitForExit()

if ($process.ExitCode -eq 0) {
    Write-Host "Google Chrome uninstallation completed successfully."
} else {
    Write-Error "Google Chrome uninstallation failed with exit code: $($process.ExitCode)"
}