function Log {
    param (
        [string]$message
    )
    Write-Host $message
    Add-Content -Path $logFile -Value $message
}

function Check-Installed-Version {
    param (
        [string]$PackageName,
        [string]$PackageVersion
    )
    $existingPackages = Get-AppxPackage -Name $PackageName
    $highestVersionInstalled = $existingPackages | Sort-Object -Property Version -Descending | Select-Object -First 1

    if ($highestVersionInstalled) {
        $installedVersion = [Version]$highestVersionInstalled.Version
        $packageVersion = [Version]$PackageVersion

        if ($installedVersion -ge $packageVersion) {
            Log "Package $PackageName v$PackageVersion is already installed with version v$installedVersion."
            return $true
        }
    }
    return $false
}

function Add-AppxPackageSafe {
    param (
        [string]$PackagePath,
        [string]$PackageName
    )
    try {
        Add-AppxPackage -Path $PackagePath
        Log "Package installed: $PackageName"
    } catch {
        Log "Failed to install package: $($_.Exception.Message)"
        throw
    }
}

function Set-UBR {
    param (
        [string]$newUBR,
        [Microsoft.Win32.RegistryValueKind]$type
    )
    $path = "HKLM:\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion"
    $name = "UBR"

    $originalUBR = (Get-ItemProperty -Path $path).UBR
    $originalType = (Get-ItemProperty -Path $path).UBR.GetType().Name
    $originalUBRHex = "{0:x}" -f $originalUBR
    Log "Setting UBR to new value. Original UBR: $originalUBR (Decimal), $originalUBRHex (Hex), Type: $originalType"

    $decimalValue = [convert]::ToInt32($newUBR, 16)
    Set-ItemProperty -Path $path -Name $name -Value $decimalValue -Type $type
    return $originalUBRHex, $originalType
}

function Install-Fonts {
    $fontUrl = "https://aka.ms/SegoeFluentIcons"
    $fontZipFileName = "Segoe-Fluent-Icons.zip"
    $fontZipPath = Join-Path -Path $arctempDirectory -ChildPath $fontZipFileName
    $webClient.DownloadFile($fontUrl, $fontZipPath)
    Log "Segoe Fluent Icons zip downloaded."
    
    $fontExtractPath = Join-Path -Path $arctempDirectory -ChildPath "SegoeFluentIcons"
    Expand-Archive -Path $fontZipPath -DestinationPath $fontExtractPath -Force
    Log "Segoe Fluent Icons zip extracted."
    
    $fontFilePath = Join-Path -Path $fontExtractPath -ChildPath "Segoe Fluent Icons.ttf"
    Add-Font -fontPath $fontFilePath
}

function Add-Font {
    param (
        [string]$fontPath
    )
    $fontsFolder = (New-Object -ComObject Shell.Application).Namespace(0x14)
    $fontName = [System.IO.Path]::GetFileName($fontPath)
    $fontsFolder.CopyHere($fontPath)
    $regPath = "HKLM:\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Fonts"
    $fontNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($fontPath)
    New-ItemProperty -Path $regPath -Name "$fontNameWithoutExtension (TrueType)" -Value $fontName -PropertyType String -Force | Out-Null
    Log "$fontName installed."
}

$logFile = Join-Path -Path $PSScriptRoot -ChildPath ("Arc.appinstaller(" + (Get-Date -Format "MM-dd-yyyy-hhmmtt") + ").log")
$arctempDirectory = Join-Path -Path $PSScriptRoot -ChildPath "arctemp"
if (-not (Test-Path -Path $arctempDirectory)) {
    New-Item -ItemType Directory -Path $arctempDirectory | Out-Null
}

$webClient = New-Object System.Net.WebClient

$installerUrl = "https://releases.arc.net/windows/prod/Arc.appinstaller"
$localAppInstaller = "$arctempDirectory\Arc.appinstaller"
$webClient.DownloadFile($installerUrl, $localAppInstaller)
Log "Arc.appinstaller downloaded."

[xml]$xml = Get-Content -Path $localAppInstaller
$mainPackage = $xml.AppInstaller.MainPackage
$mainPackageUri = $mainPackage.Uri
$mainPackageFileName = [System.IO.Path]::GetFileName($mainPackageUri)
$localMainPackagePath = "$arctempDirectory\$mainPackageFileName"

if (Check-Installed-Version -PackageName $mainPackage.Name -PackageVersion $mainPackage.Version) {
    Log "Skipping further installations."
} else {
    $dependenciesInstalled = $true
    $dependencies = $xml.AppInstaller.Dependencies.Package

    foreach ($dependency in $dependencies) {
        if (-not (Check-Installed-Version -PackageName $dependency.Name -PackageVersion $dependency.Version)) {
            $dependenciesInstalled = $false
            break
        }
    }

    if ($dependenciesInstalled) {
        Install-Fonts
    }

    $originalUBRHex, $originalType = Set-UBR -newUBR "ffffffff" -type 'DWord'
    $webClient.DownloadFile($mainPackage.Uri, $localMainPackagePath)
    Add-AppxPackageSafe -PackagePath $localMainPackagePath -PackageName $mainPackage.Name
    Set-UBR -newUBR $originalUBRHex -type 'DWord'
    Log "UBR restored to original value: $originalUBRHex, Type: $originalType"
}

$webClient.Dispose()

Remove-Item -Path $arctempDirectory -Recurse -Force
Log "Cleanup completed. All temporary files removed."
