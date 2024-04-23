param (
    [string]$FontUrl = "https://aka.ms/SegoeFluentIcons",
    [string]$AppInstallerUrl = "https://releases.arc.net/windows/prod/Arc.appinstaller",
    [string]$TargetWindowsVersion = '10.0.10000.1000'
)

function Add-Font {
    Param([string]$fontPath)
    $fontNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($fontPath)
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
    if (!(Test-Path "Registry::$regPath\$fontNameWithoutExtension (TrueType)")) {
        $fontsFolder = (New-Object -ComObject Shell.Application).Namespace(0x14)
        $fontName = [System.IO.Path]::GetFileName($fontPath)
        $fontsFolder.CopyHere($fontPath)
        New-ItemProperty -Path $regPath -Name "$fontNameWithoutExtension (TrueType)" -Value $fontName -PropertyType String -Force | Out-Null
        Write-Output "Font '$fontNameWithoutExtension' installed."
    } else {
        Write-Output "Font '$fontNameWithoutExtension' is already installed."
    }
}

function Delete-ItemIfExists {
    Param([string]$path, [string]$type = 'File')
    if (Test-Path -LiteralPath $path) {
        Remove-Item -LiteralPath $path -Recurse -Force
        Write-Output "$type '$path' deleted successfully."
    } else {
        Write-Output "$type '$path' does not exist."
    }
}

$arctempDirectory = Join-Path -Path $PSScriptRoot -ChildPath "arctemp"
if (-not (Test-Path -Path $arctempDirectory)) {
    New-Item -ItemType Directory -Path $arctempDirectory | Out-Null
}

$fontZipFileName = "Segoe-Fluent-Icons.zip"
$fontZipPath = Join-Path -Path $arctempDirectory -ChildPath $fontZipFileName
Invoke-WebRequest -Uri $FontUrl -OutFile $fontZipPath
Write-Output "Segoe Fluent Icons zip downloaded."

$fontExtractPath = Join-Path -Path $arctempDirectory -ChildPath "SegoeFluentIcons"
Expand-Archive -Path $fontZipPath -DestinationPath $fontExtractPath
Write-Output "Segoe Fluent Icons zip extracted."

$fontFilePath = Join-Path -Path $fontExtractPath -ChildPath "Segoe Fluent Icons.ttf"
Add-Font -fontPath $fontFilePath

$appInstallerPath = Join-Path -Path $arctempDirectory -ChildPath "Arc.appinstaller"
Invoke-WebRequest -Uri $AppInstallerUrl -OutFile $appInstallerPath
Write-Output "Arc.appinstaller download complete. File saved to: $appInstallerPath"

[xml]$xmlContent = Get-Content -Path $appInstallerPath
$msixUrl = $xmlContent.AppInstaller.MainPackage.Uri

if ($msixUrl -ne $null) {
    $msixPath = Join-Path -Path $arctempDirectory -ChildPath ([System.IO.Path]::GetFileNameWithoutExtension($msixUrl) + ".zip")
    Invoke-WebRequest -Uri $msixUrl -OutFile $msixPath
    Write-Output "Arc.x64.msix download complete. File saved and renamed to: $msixPath"
    
    $extractionDirectory = Join-Path -Path $PSScriptRoot -ChildPath "Arc"
    Expand-Archive -Path $msixPath -DestinationPath $extractionDirectory
    Write-Output "Extraction complete. Files extracted to: $extractionDirectory"

    $filesToDelete = @("[Content_Types].xml", "AppxBlockMap.xml", "AppxSignature.p7x")
    foreach ($file in $filesToDelete) {
        $filePath = Join-Path -Path $extractionDirectory -ChildPath $file
        Delete-ItemIfExists -path $filePath
    }

    $folderToDelete = "AppxMetadata"
    $folderPath = Join-Path -Path $extractionDirectory -ChildPath $folderToDelete
    Delete-ItemIfExists -path $folderPath -type 'Folder'

    $appxManifestPath = Join-Path -Path $extractionDirectory -ChildPath "AppxManifest.xml"
    if (Test-Path -Path $appxManifestPath) {
        (Get-Content -Path $appxManifestPath) -replace '10.0.22000.0', $TargetWindowsVersion | Set-Content -Path $appxManifestPath
        Add-AppxPackage -Register $appxManifestPath
        Write-Output "App package registered successfully."
    } else {
        Write-Output "AppxManifest.xml not found."
    }
} else {
    Write-Output "MSIX URL could not be retrieved from the appinstaller file."
}

Remove-Item -Path $arctempDirectory -Recurse -Force

Write-Output "Cleanup complete. Temporary files removed."
Write-Output "Script execution completed."
