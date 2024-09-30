<#
  .SYNOPSIS
    Installs an Edge Extension by ID
  .DESCRIPTION
    Silently installs a Microsoft Edge extension from Microsoft.
  .PARAMETER ID
    Microsoft Edge Extension ID 
  .EXAMPLE
    ./InstallEdgeExt.ps1 -ID 'hokifickgkhplphjiodbggjmoafhignh'
  .NOTES
    Author: Aaron Stevenson
#>

param(
  [ValidatePattern('^[a-z]{32}$')]
  [Parameter(Mandatory = $true)]
  [String]$ID
)

$UpdateURL = 'https://edge.microsoft.com/extensionwebstorebase/v1/crx'
$ArchType = if ([System.Environment]::Is64BitOperatingSystem) { 'x64' } else { 'x86' }

function Find-Policies {
  $PolicyRegPath = @('HKLM:\Software\Policies\Microsoft\Edge\ExtensionInstallBlocklist')
  
  try {
    if ((Test-Path $PolicyRegPath) -and ($null -ne (Get-ItemProperty -Path $PolicyRegPath))) {
      Write-Warning ('Detected Group Policy settings for Microsoft Edge extensions - manually check for conflicts.') 
    }
  }
  catch {
    Write-Warning 'Unable to detect Microsoft Edge extension policies.'
    Write-Warning $_
  }
}

function Install-Extension {
  Write-Output "`nInstalling Microsoft Edge Extension"
  Write-Output "ID: $ID"
  Write-Output "Link: https://microsoftedge.microsoft.com/addons/detail/$ID"

  try {
    # Set registry path
    if ($ArchType -eq 'x64') { $RegPath = 'HKLM:\Software\Wow6432Node\Microsoft\Edge\Extensions' }
    else { $RegPath = 'HKLM:\Software\Microsoft\Edge\Extensions' }

    # Create extension registry key and necessary properties
    Write-Output "`nAdding extension registry key..."
    $ExtRegKey = Join-Path -Path $RegPath -ChildPath $ID
    New-Item -Path $ExtRegKey -Force | Out-Null
    New-ItemProperty -Path $ExtRegKey -Name 'update_url' -PropertyType 'String' -Value $UpdateURL -Force | Out-Null

    Write-Output 'Complete - relaunch browser to finish installation.'
  }
  catch {
    Write-Warning "Unable to install Edge Extension [$ID]"
    throw $_
  }
}

Find-Policies
Install-Extension