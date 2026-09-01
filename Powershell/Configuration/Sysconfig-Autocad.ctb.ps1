# ================================
# .ctb AutoCAD Plot Style Deploy
# ================================

$DownloadUrl = "stagingurlhere"
$FileName = "MHK.ctb"

$AutodeskRoot = Join-Path $env:APPDATA "Autodesk"
$TempFile = Join-Path $env:TEMP $FileName

Write-Host "Searching for AutoCAD Plot Styles folders..." -ForegroundColor Cyan

if (-not (Test-Path $AutodeskRoot)) {
    Write-Host "Autodesk folder not found: $AutodeskRoot" -ForegroundColor Red
    exit 1
}

# Find every "Plot Styles" folder underneath AppData\Roaming\Autodesk
$PlotStyleFolders = Get-ChildItem `
    -Path $AutodeskRoot `
    -Directory `
    -Recurse `
    -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -eq "Plot Styles" }

if (-not $PlotStyleFolders) {
    Write-Host "No Plot Styles folders found." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Found $($PlotStyleFolders.Count) Plot Styles folder(s):" -ForegroundColor Green

foreach ($Folder in $PlotStyleFolders) {
    Write-Host "  $($Folder.FullName)"
}

# Determine which folders are missing MHK.ctb
$MissingFolders = @(
    $PlotStyleFolders | Where-Object {
        -not (Test-Path (Join-Path $_.FullName $FileName))
    }
)

Write-Host ""

if ($MissingFolders.Count -eq 0) {
    Write-Host "$FileName already exists in every Plot Styles folder." -ForegroundColor Green
    exit 0
}

Write-Host "$FileName is missing from $($MissingFolders.Count) folder(s)." -ForegroundColor Yellow

# Download only once
Write-Host ""
Write-Host "Downloading $FileName..." -ForegroundColor Cyan

try {
    Invoke-WebRequest `
        -Uri $DownloadUrl `
        -OutFile $TempFile `
        -UseBasicParsing `
        -ErrorAction Stop

    if (-not (Test-Path $TempFile)) {
        throw "Download completed but the file was not found at $TempFile"
    }

    Write-Host "Download successful." -ForegroundColor Green
}
catch {
    Write-Host "Failed to download $FileName." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# Copy into missing Plot Styles folders
foreach ($Folder in $MissingFolders) {

    $Destination = Join-Path $Folder.FullName $FileName

    try {
        Copy-Item `
            -Path $TempFile `
            -Destination $Destination `
            -Force `
            -ErrorAction Stop

        Write-Host "Installed: $Destination" -ForegroundColor Green
    }
    catch {
        Write-Host "FAILED: $Destination" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

# Clean up
if (Test-Path $TempFile) {
    Remove-Item $TempFile -Force -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "MHK.ctb deployment complete." -ForegroundColor Cyan
