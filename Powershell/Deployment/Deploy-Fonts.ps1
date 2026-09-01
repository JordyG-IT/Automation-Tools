$url = 'yourstagedfileuri'
$Location = 'C:\IT'
$Outfile = 'C:\IT\Fonts_Standard.zip'
$Extract ='C:\IT\Fonts'
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"

#function to check if fonts are already installed.

function check-fonts{
$InstalledFonts = (Get-ItemProperty -Path $RegPath).PSObject.Properties.Name
$MissingFonts = $FontsToCheck | Where-Object { 
    $Target = $_ 
    (-not ($InstalledFonts | Where-Object { $_ -like "*$Target*" }))
}

if ($MissingFonts.Count -eq 0) {
    Write-Host "Sample Fonts Already Exist, exiting."
    Exit 0
}
}

Check-fonts

Write-Host "Checking Directory"
New-Item -Path 'C:\IT' -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

Write-Host "Downloading file"
try {
    Invoke-Webrequest -uri $url -OutFile $OutFile
    Write-Host "Successful download"
}
catch {
    Write-Host "something went wrong"
}

try {
    Expand-Archive -Path $Outfile -DestinationPath $Extract -Force
    write-host 'successful extract'
}
catch {
    throw 'could not extract'
}

$Fonts = Get-ChildItem -Path $Extract -Recurse -Include *.ttf, *.otf

# install each font
foreach ($Font in $Fonts) {

    $FontFile = $Font.Name
    $Source = $Font.FullName
    $Destination = "$env:WINDIR\Fonts\$FontFile"

    Copy-Item -Path $Source -Destination $Destination -Force -ErrorAction SilentlyContinue

    $Type = if ($Font.Extension -eq ".otf") { "OpenType" } else { "TrueType" }

    $FontName = $Font.BaseName

    New-ItemProperty `
        -Path $RegPath `
        -Name "$FontName ($Type)" `
        -Value $FontFile `
        -PropertyType String `
        -Force
    write-host "successful install $fontname"
}
