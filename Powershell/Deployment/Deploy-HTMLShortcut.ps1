$webpageUrl = "urlhere"
$browserPath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

$defaultDesktop = "$env:USERPROFILE\Desktop"
$onedriveDesktop = "$env:OneDrive\Desktop"

function Create-Shortcut ($targetPath) {
    $shortcutPath = Join-Path $targetPath "Ajera.lnk"
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $browserPath
    $shortcut.Arguments = $webpageUrl
    $shortcut.Save()
}

$created = $false

# Try default Desktop first
try {
    Create-Shortcut -targetPath $defaultDesktop
    Write-Host "Successfully created shortcut at: $defaultDesktop" -ForegroundColor Green
    $created = $true
}
catch {
    Write-Warning "Failed to create shortcut at: $defaultDesktop"
}

# If default failed, try OneDrive Desktop
if (-not $created) {
    try {
        Create-Shortcut -targetPath $onedriveDesktop
        Write-Host "Successfully created shortcut at: $onedriveDesktop" -ForegroundColor Green
        $created = $true
    }
    catch {
        Write-Error "Failed to create shortcut at: $onedriveDesktop"
    }
}
