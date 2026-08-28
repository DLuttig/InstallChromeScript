<#
.SYNOPSIS
    This script installs Google Chrome silently using the MSI installer and applies specific policy registry keys.

.DESCRIPTION
    The script checks for the presence of the Google Chrome MSI installer in the same directory as the script. If found, it installs Chrome silently and then creates registry keys to enforce certain policies.
#>

$ErrorActionPreference = "Stop"

$msiName = "GoogleChromeStandaloneEnterprise64.msi"
$msiPath = Join-Path -Path $PSScriptRoot -ChildPath $msiName

if (-not (Test-Path -LiteralPath $msiPath)) {
    Write-Error "Chrome MSI installer not found at path: $msiPath"
    exit 1
}

$arguments = @{
    FilePath = "msiexec.exe"
    ArgumentList = "/i `"$msiPath`" /qn /norestart"
    Wait = $true
    PassThru = $true
}

# Write-Host "Starting Chrome installation..."
$process = Start-Process @arguments
if ($process.ExitCode -eq 0) {
    Write-Host "Chrome installation completed successfully."
} else {
    Write-Error "Chrome installation failed with exit code: $($process.ExitCode)"
}

# Enable Chrome policies by creating registry keys
$chromePoliciesPath = "HKLM:\Software\Policies\Google\Chrome"
$googleUpdatePath = "HKLM:\Software\Policies\Google\Update"

New-Item -Path $chromePoliciesPath -Force | Out-Null
New-Item -Path $googleUpdatePath -Force | Out-Null

# Set Chrome policies
# New-ItemProperty -Path $chromePoliciesPath -Name "HomepageLocation" -Value "https://www.example.com" -PropertyType String -Force | Out-Null
New-ItemProperty -Path $chromePoliciesPath -Name "DefaultBrowserSettingEnabled" -Value 0 -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path $googleUpdatePath -Name "UpdateDefault" -Value 0 -PropertyType DWord -Force | Out-Null