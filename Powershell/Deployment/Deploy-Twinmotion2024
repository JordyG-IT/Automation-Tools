# ================================================
# TODO: REFACTOR ROADMAP
# -----------------------------------------------
# 1. Convert major logic blocks into functions
#    - Download-Installer
#    - Validate-Hash
#    - Install-Package (MSI/EXE/ZIP)
#    - Write-Log
#
# 2. Stop hardcoding paths
#    - Use $Env:ProgramData\IT\deployments or similar
#
# 3. Add structured logging
#    - Timestamped logs
#    - Write-Log function using Add-Content
#
# 4. Improve error handling
#    - Use Try/Catch around Invoke-WebRequest + installer calls
#    - Capture $_.Exception.Message
#
# 5. Add basic telemetry
#    - Write "(Get-Date) - Action" before each major step
#
# 6. Move config toward JSON
#    - Parameters: Name, URL, ExpectedHash, InstallerType, SilentArgs
#
# 7. Add detection + rollback logic
#    - Detect partial install
#    - Clean up folder or registry if installer fails
#
# Notes:
# This evolves the script from a one-off tool → reusable installer engine.
# ================================================



$InstallCheck = get-itemproperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*' | Where-object {($_.Displayname -eq 'Twinmotion For Revit')}
$Downloadurl = '!!stagingurlhere!!'
$Outfile = 'C:\IT\Twinmotion 2023.2.3 for Revit 2024.2 - Installer.zip'
$ExpectedHash = '!!YourHashHere!!'
$MaxTries = 3
$Extract = 'C:\IT\Twinmotion\Twinmotionion 2023'
$getdate= get-date
$ProgressPreference = 'SilentlyContinue'

Write-host "$getdate :Beggining Installation Script"
#Check to see if install exist
if ($InstallCheck)
{
    Throw "$getdate :Twinmotion For Revit 2024 already exist"
}
#Checks to see if the Download .zip folder exist
elseif (test-path $Outfile) 
{
    Write-host "$getdate :Folder Exist, checking file hash."

    $hash = (Get-FileHash $Outfile).Hash
    #checks to see if the Existing Folders Hash is correct
    if ($hash -eq $ExpectedHash){
        Write-host "$getdate :Folder hash matches expected, installing"
    }
    #If $hash is not -eq to $ExpectedHash Tries to download 3 times, checks hash each time.
    else
    {
        Write-Host "$getdate :Folder Corrupt, redownloading"

        for ($i=1; $i -le $Maxtries; $i++)
        {
            Write-host "$getdate :Download attempt $i"

            Invoke-webrequest -uri $Downloadurl -Outfile $Outfile

            $hash = (Get-fileHash $Outfile).Hash
            #Checking Hash, exits if true
            if ($hash -eq $ExpectedHash){
                Write-host "$getdate :Download hash matches expected hash, proceeding to install."
                break
            }
            #Exits Script if max retries reached.
            elseif ($i -eq $Maxtries) {
                Throw "$getdate :Maximum Attempts Reached exiting process."
            }
            #Continues if Hash fails
            else {
                Write-host "$getdate :Download Failed, trying again"
                continue
            }
        }
    }
}
# If the folder doesnt exist, we start downloading it
else 
{
    Write-Host "$getdate :Download Folder not found, initiating download"
    for ($i=1; $i -le $Maxtries; $i++)
        {
            Write-host "$getdate :Download attempt $i"

            Invoke-webrequest -uri $Downloadurl -Outfile $Outfile

            $hash = (Get-fileHash $Outfile).Hash

            if ($hash -eq $ExpectedHash){
                Write-host "$getdate :Download hash matches expected hash, proceeding to install."
                break
            }
            elseif ($i -eq $Maxtries) {
                Throw "$getdate :Maximum Attempts Reached exiting process."
            }
            else {
                Write-host "$getdate :Download Failed, trying again"
                continue
            }
        }
}

Write-host "$getdate :Extracting Archive"

Expand-Archive -Path $Outfile -DestinationPath $Extract -Force

Write-host "$getdate :Installing Package now..."

msiexec.exe /package 'C:\IT\Twinmotion\Twinmotion 2023.2.3 for Revit 2024.2 - Installer\TwinmotionRevitSetup.msi' /quiet /norestart /log 'c:\IT\Twinmotion\Logfile.txt'

if ($InstallCheck){
    Write-host "$getdate :Sucessfully Installed"
}
else {
    Write-host "$getdate :Something went wrong with the Installation"
}
