
# This version checks to see if the program is already installed, if it is it exits
#If there is a copy of the payload
# If the Payload md5 is good it is re-extracted and runs the command.
#if the md5 is bad the payload is redownloaded.

$LockFile = 'C:\IT\AdobeInstall.lock'
$programname = 'Adobe Creative Cloud'
$url = 'stagingurlhere'
$Location = 'C:\IT'
$Outfile = 'C:\IT\AdobeCC.zip'
$Extract = 'C:\IT\AdobeCC'
$ExpectedHash = 'fill with hash from downloaded payload'
$Maxtries = 3 
$ProgressPreference = 'SilentlyContinue'

# Check the to see if the C:/IT directory is made yet
Write-Host "Checking Directory"
New-Item -Path 'C:\IT' -ItemType Directory -ErrorAction SilentlyContinue | Out-Null


#Create a lock file which acts a marker that a version of this script is currently running.
if (Test-Path $LockFile) {
    Throw "Another instance of this script is currently running. Exiting to prevent race condition."
}

try {
    New-Item -Path $LockFile -ItemType File -Force -ErrorAction Stop | Out-Null

    # Check if program is installed
    $InstallCheck = Get-itemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*' | Where-Object { $_.DisplayName -eq "$programname" }
    $InstallCheck2 = Get-itemProperty 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' | Where-Object { $_.DisplayName -eq "$programname" }

    #Check if the deployment has been downloaded

    #If program is installed, exit the script.
    Write-host "Checking if $programname is Installed."

    if ($installcheck -or $installcheck2) {
        Throw "$programname already installed, shutting down script"

    }
    elseif (test-path $Outfile) {
        Write-host 'Checking folder hash.'
        $hash = (Get-FileHash -Algorithm md5 -Path $Outfile).Hash

        if ($hash -eq $ExpectedHash) {
            Write-host "Folder exist and matches hash"
            #if this is true the else statement is never run
        }
        else {
            Write-host 'Folder is corrupt, redownloading.'

            for ($i = 1; $i -le $Maxtries; $i++) {
                Write-Host "Downloading file (attempt $i)"
                Invoke-Webrequest -uri $url -OutFile $OutFile

                Write-host "Checking hash"
                $hash = (get-filehash -Algorithm md5 -path $Outfile).Hash

                if ($hash -eq $ExpectedHash) {
                    Write-host 'Download sucessful'
                    break
                }
                elseif ($i -eq $Maxtries) {
                    Throw 'Maximum number of attempts reached shutting down script'
                }
                else {
                    Write-host 'Download failed, trying again.'
                    continue
                }
            }

        }
    } 
    else {
        for ($i = 1; $i -le $Maxtries; $i++) {
            Write-Host "Folder not found, downloading. (attempt $i)"
            Invoke-WebRequest -uri $url -OutFile $Outfile

            Write-Host "Checking Hash."
            $hash = (get-filehash -Algorithm md5 -Path $Outfile).Hash

            if ($hash -eq $ExpectedHash) {
                break
            }
            elseif ($i -eq $Maxtries) {
                Throw 'Maximum attempts reached, shutting down script.'
            }

            else {
                Write-Host "File Corrupt retrying."
                continue
            }
        }
    }

    Write-Host "Extracting archive..."
    Expand-Archive -Path $Outfile -DestinationPath $Extract -Force

    Write-Host "Starting installer..."
    Start-Process cmd.exe -ArgumentList 'c:\IT\AdobeCC\RMMPackage\Build\setup.exe --silent --ADOBEINSTALLDIR="C:\Program Files\Adobe" --INSTALLLANGUAGE=en_US' -Wait -NoNewWindow
}
finally {
    if (Test-Path $LockFile) {
        Remove-Item -Path $LockFile -Force -ErrorAction SilentlyContinue
    }
}
