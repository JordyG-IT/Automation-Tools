# 1. Stop Edge so it doesn't overwrite the file
Get-Process msedge -ErrorAction SilentlyContinue | Stop-Process -Force

# 2. Path to the Default Edge profile
$prefFile = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Preferences"

# 3. Make sure the file exists
if (!(Test-Path $prefFile)) {
    Write-Output "Preferences file not found"
    return
}

# 4. Backup (important)
Copy-Item $prefFile "$prefFile.bak" -Force

# 5. Load JSON into a PowerShell object
$json = Get-Content $prefFile -Raw | ConvertFrom-Json

# 6. Set notifications to an empty object
$json.profile.content_settings.exceptions.notifications = @{}

# 7. Save it back
$json | ConvertTo-Json -Depth 20 | Set-Content $prefFile -Encoding UTF8
