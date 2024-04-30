function Add-Font {
    Param([string]$fontPath)
    $fontsFolder = (New-Object -ComObject Shell.Application).Namespace(0x14)
    $fontName = [System.IO.Path]::GetFileName($fontPath)
    $fontsFolder.CopyHere($fontPath)
    $regPath = "HKLM:\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Fonts"
    $fontNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($fontPath)
    New-ItemProperty -Path $regPath -Name "$fontNameWithoutExtension (TrueType)" -Value $fontName -PropertyType String -Force | Out-Null
    Log "$fontName installed."
}

function Set-UBR {
    param (
        [string]$newUBR,
        [Microsoft.Win32.RegistryValueKind]$type
    )
    $path = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
    $name = "UBR"

    $originalUBR = (Get-ItemProperty -Path $path).UBR
    $originalType = (Get-ItemProperty -Path $path).UBR.GetType().Name
    $originalUBRHex = "{0:x}" -f $originalUBR  # Convert decimal to hex
    Log "Setting UBR to new value. Original UBR: $originalUBR (Decimal), $originalUBRHex (Hex), Type: $originalType"

    $decimalValue = [convert]::ToInt32($newUBR, 16)
    Set-ItemProperty -Path $path -Name $name -Value $decimalValue -Type $type
    return $originalUBRHex, $originalType
}

function Log {
    param (
        [string]$message
    )
    Write-Host $message
    Add-Content -Path $logFile -Value $message
}

$logFile = Join-Path -Path $PSScriptRoot -ChildPath ("Arc.appinstaller(" + (Get-Date -Format "MM-dd-yyyy-hhmmtt") + ").log")
$arctempDirectory = Join-Path -Path $PSScriptRoot -ChildPath "arctemp"
if (-not (Test-Path -Path $arctempDirectory)) {
    New-Item -ItemType Directory -Path $arctempDirectory | Out-Null
}

$fontUrl = "https://aka.ms/SegoeFluentIcons"
$fontZipFileName = "Segoe-Fluent-Icons.zip"
$fontZipPath = Join-Path -Path $arctempDirectory -ChildPath $fontZipFileName
Invoke-WebRequest -Uri $fontUrl -OutFile $fontZipPath
Log "Segoe Fluent Icons zip downloaded."

$fontExtractPath = Join-Path -Path $arctempDirectory -ChildPath "SegoeFluentIcons"
Expand-Archive -Path $fontZipPath -DestinationPath $fontExtractPath -Force
Log "Segoe Fluent Icons zip extracted."

$fontFilePath = Join-Path -Path $fontExtractPath -ChildPath "Segoe Fluent Icons.ttf"
Add-Font -fontPath $fontFilePath

try {
    $originalUBRHex, $originalType = Set-UBR -newUBR "ffffffff" -type 'DWord'

    $installerUrl = "https://releases.arc.net/windows/Arc.appinstaller"
    $localAppInstaller = "$arctempDirectory\Arc.appinstaller"
    Invoke-WebRequest -Uri $installerUrl -OutFile $localAppInstaller
    Log "Arc.appinstaller downloaded."

    [xml]$xml = Get-Content -Path $localAppInstaller
    $msixUrl = $xml.AppInstaller.MainPackage.Uri
    Log "Found MSIX URL: $msixUrl"

    $localMsixInstaller = "$arctempDirectory\Arc.msix"
    Invoke-WebRequest -Uri $msixUrl -OutFile $localMsixInstaller
    Log "Arc.msix downloaded."

    Add-AppxPackage -Path $localMsixInstaller
    Log "Arc has been installed successfully."
}
catch {
    Log "An error occurred: $_"
}
finally {
    if ($originalUBRHex -and $originalType) {
        Set-UBR -newUBR $originalUBRHex -type 'DWord'
        Log "UBR restored to original value: $originalUBRHex, Type: $originalType"
    }

    Remove-Item -Path $arctempDirectory -Recurse -Force
    Log "Cleanup completed. All temporary files removed."
}
