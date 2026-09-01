#Need to refactor to use variables for the paths rather then hard-coding paths.

#customize the variables to the environment.
$url = 'urlhere'
$Location = 'C:\IT'
$Extract ='C:\IT\ODT'
$Outfile = 'C:\IT\ODT.zip'

Write-Host "Checking Directory"
New-Item -Path 'C:\IT' -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

Write-Host "Downloading"
Invoke-WebRequest -uri $url -OutFile $Outfile -UseBasicParsing

Write-host "extracting"
Expand-Archive -Path $Outfile -DestinationPath $Extract -Force

Write-Host "Starting installer..."
try {
   
    c:\IT\ODT\setup.exe /configure c:\IT\ODT\Configuration.xml
}
catch {
    Write-Host "Something went wrong with the installation"
}
