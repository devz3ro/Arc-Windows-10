function Log {
    param ([string]$message)
    Write-Host $message
    Add-Content -Path $logFile -Value $message
}

function Check-and-Update-AppxPackage {
    param (
        [string]$PackageName,
        [string]$PackageVersion,
        [string]$PackageUri
    )
    $existingPackage = Get-AppxPackage -Name $PackageName
    if ($existingPackage) {
        $installedVersion = [version]$existingPackage.Version
        $newVersion = [version]$PackageVersion
        if ($installedVersion -lt $newVersion) {
            Log "Updating $PackageName from version $installedVersion to $newVersion."
            return Add-AppxPackageSafe -PackagePath $PackageUri -PackageName $PackageName
        } else {
            Log "$PackageName is already up to date with version $installedVersion."
            return $false
        }
    } else {
        Log "$PackageName is not installed. Installing version $PackageVersion."
        return Add-AppxPackageSafe -PackagePath $PackageUri -PackageName $PackageName
    }
}

function Add-AppxPackageSafe {
    param (
        [string]$PackagePath,
        [string]$PackageName
    )
    try {
        Add-AppxPackage -Path $PackagePath -ForceApplicationShutdown
        Log "Package installed: $PackageName"
    } catch {
        Log "Failed to install package: $($_.Exception.Message)"
        return $false
    }
    return $true
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
    Invoke-WebRequest -Uri $fontUrl -OutFile $fontZipPath
    Log "Segoe Fluent Icons zip downloaded."
    
    $fontExtractPath = Join-Path -Path $arctempDirectory -ChildPath "SegoeFluentIcons"
    Expand-Archive -Path $fontZipPath -DestinationPath $fontExtractPath -Force
    Log "Segoe Fluent Icons zip extracted."
    
    $fontFilePath = Join-Path -Path $fontExtractPath -ChildPath "Segoe Fluent Icons.ttf"
    Add-Font -fontPath $fontFilePath
}

function Add-Font {
    param ([string]$fontPath)
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

$installerUrl = "https://releases.arc.net/windows/prod/Arc.appinstaller"
$localAppInstaller = "$arctempDirectory\Arc.appinstaller"
Invoke-WebRequest -Uri $installerUrl -OutFile $localAppInstaller
Log "Arc.appinstaller downloaded."

[xml]$xml = Get-Content -Path $localAppInstaller
$mainPackage = $xml.AppInstaller.MainPackage
$mainPackageUri = $mainPackage.Uri
$mainPackageFileName = [System.IO.Path]::GetFileName($mainPackageUri)
$localMainPackagePath = "$arctempDirectory\$mainPackageFileName"
Invoke-WebRequest -Uri $mainPackageUri -OutFile $localMainPackagePath

$mainPackageUpdated = Check-and-Update-AppxPackage -PackageName $mainPackage.Name -PackageVersion $mainPackage.Version -PackageUri $localMainPackagePath

if (-not $mainPackageUpdated) {
    Log "Main package is already up to date."
    Remove-Item -Path $arctempDirectory -Recurse -Force
    Log "Cleanup completed. All temporary files removed."
    exit
}

$originalUBRHex, $originalType = Set-UBR -newUBR "ffffffff" -type 'DWord'

$dependenciesInstalled = $true
$dependencies = $xml.AppInstaller.Dependencies.Package
foreach ($dependency in $dependencies) {
    $depUri = $dependency.Uri
    $depFileName = [System.IO.Path]::GetFileName($depUri)
    $localDepPath = "$arctempDirectory\$depFileName"
    Invoke-WebRequest -Uri $depUri -OutFile $localDepPath
    if (-not (Check-and-Update-AppxPackage -PackageName $dependency.Name -PackageVersion $dependency.Version -PackageUri $localDepPath)) {
        $dependenciesInstalled = $false
    }
}

if ($dependenciesInstalled) {
    Install-Fonts
}

Set-UBR -newUBR $originalUBRHex -type 'DWord'
Log "UBR restored to original value: $originalUBRHex, Type: $originalType"

Remove-Item -Path $arctempDirectory -Recurse -Force
Log "Cleanup completed. All temporary files removed."
