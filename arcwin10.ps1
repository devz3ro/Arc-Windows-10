$fontUrl = "https://aka.ms/SegoeFluentIcons"
$fontZipFileName = "Segoe-Fluent-Icons.zip"

$appInstallerUrl = "https://releases.arc.net/windows/prod/Arc.appinstaller"

$workingDirectory = Join-Path -Path $PSScriptRoot -ChildPath "working"

if (-not (Test-Path -Path $workingDirectory)) {
    New-Item -ItemType Directory -Path $workingDirectory | Out-Null
}

$fontZipPath = Join-Path -Path $workingDirectory -ChildPath $fontZipFileName
Invoke-WebRequest -Uri $fontUrl -OutFile $fontZipPath
Write-Host "Segoe Fluent Icons zip downloaded."

$fontExtractPath = Join-Path -Path $workingDirectory -ChildPath "SegoeFluentIcons"
Expand-Archive -Path $fontZipPath -DestinationPath $fontExtractPath
Write-Host "Segoe Fluent Icons zip extracted."

function Add-Font {
    Param([string]$fontPath)
    $fontsFolder = (New-Object -ComObject Shell.Application).Namespace(0x14)
    $fontName = [System.IO.Path]::GetFileName($fontPath)
    $fontsFolder.CopyHere($fontPath)
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
    $fontNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($fontPath)
    New-ItemProperty -Path $regPath -Name "$fontNameWithoutExtension (TrueType)" -Value $fontName -PropertyType String -Force | Out-Null
}

$fontFilePath = Join-Path -Path $fontExtractPath -ChildPath "Segoe Fluent Icons.ttf"
Add-Font -fontPath $fontFilePath
Write-Host "Segoe Fluent Icons font installed."

$appInstallerPath = Join-Path -Path $workingDirectory -ChildPath "Arc.appinstaller"
Invoke-WebRequest -Uri $appInstallerUrl -OutFile $appInstallerPath
Write-Host "Arc.appinstaller download complete. File saved to: $appInstallerPath"

[xml]$xmlContent = Get-Content -Path $appInstallerPath

$msixUrl = $xmlContent.AppInstaller.MainPackage.Uri

if ($msixUrl -ne $null) {
    $msixPath = Join-Path -Path $workingDirectory -ChildPath ([System.IO.Path]::GetFileNameWithoutExtension($msixUrl) + ".zip")
    
    Invoke-WebRequest -Uri $msixUrl -OutFile $msixPath
    Write-Host "Arc.x64.msix download complete. File saved and renamed to: $msixPath"
    
    $extractionDirectory = Join-Path -Path $workingDirectory -ChildPath "Arc"
    
    Expand-Archive -Path $msixPath -DestinationPath $extractionDirectory
    Write-Host "Extraction complete. Files extracted to: $extractionDirectory"

    $filesToDelete = @("[Content_Types].xml", "AppxBlockMap.xml", "AppxSignature.p7x")
    $folderToDelete = "AppxMetadata"

    foreach ($file in $filesToDelete) {
        $filePath = Join-Path -Path $extractionDirectory -ChildPath $file
        if (Test-Path -LiteralPath $filePath) {
            Remove-Item -LiteralPath $filePath
            Write-Host "$file deleted successfully."
        } else {
            Write-Host "$file does not exist."
        }
    }

    $folderPath = Join-Path -Path $extractionDirectory -ChildPath $folderToDelete
    if (Test-Path -Path $folderPath) {
        Remove-Item -Path $folderPath -Recurse
        Write-Host "$folderToDelete folder deleted successfully."
    } else {
        Write-Host "$folderToDelete folder does not exist."
    }

    $appxManifestPath = Join-Path -Path $extractionDirectory -ChildPath "AppxManifest.xml"
    if (Test-Path -Path $appxManifestPath) {
        (Get-Content -Path $appxManifestPath) -replace '10.0.22000.0', '10.0.10000.1000' | Set-Content -Path $appxManifestPath
        Write-Host "AppxManifest.xml updated successfully."
    } else {
        Write-Host "AppxManifest.xml does not exist."
    }

    Add-AppxPackage -Register $appxManifestPath
    Write-Host "App package registered successfully."

} else {
    Write-Host "No Arc.x64.msix URL found in the Arc.appinstaller file."
}