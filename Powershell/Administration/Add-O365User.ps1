<#
====================================================================================================
SECURITY NOTICE / REFACTORING ROADMAP:
The post-provisioning notification email serves as vital confirmation that account creation and 
licensing completed. However, sending cleartext temporary passwords via email introduces security risk.

TECHNICAL DEBT / TODO:
Refactor account setup to generate a Microsoft Entra Temporary Access Pass (TAP) via Graph API 
(`New-MgUserAuthenticationTemporaryAccessPassMethod`). 

The confirmation email workflow will be retained, but $results will contain a time-bound TAP 
passcode (or TAP creation link) instead of a static temporary password.
====================================================================================================
#>

<#====================================================================================================
13. DESIGN PRINCIPLES
====================================================================================================

- Modular functions
- Reusable components
- Policy-driven behavior
- Language-agnostic architecture
- Minimal hardcoding
- Clear separation of concerns
- Expandable maturity model
- Incremental improvement over rewrites

==================================================================================================== #>

#=================================================================================================
# INPUT DATA
#=================================================================================================
$firstname = read-host 'Users First Name '
$FirstInit = $firstname[0]
$Lastname = read-host 'Users Last Name '
$Department = read-host 'Users Department '
$Office = read-host 'Users Office '
$logpath = "$env:USERPROFILE\Desktop\Onboard_($Firstname)-($Lastname).txt"
    $results = @()

#=================================================================================================
#FUNCTIONS
#=================================================================================================
function Write-log {
     param(
        [ValidateSet("INFO","ERROR","DEBUG")]
        [string]$level,

        [Parameter(Mandatory=$true)]
        [string]$message
    )
        Add-content $logpath "$(Get-Date): [$level]: $message"
        Write-host "$(Get-date): [$level]: $message"
}

#!!Refactor this to use TAP!!#

function get-randompassword{
    param (
        [int]$length = 12
    )
    
    $chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()'
    return  (-join (1..$length | ForEach-Object { $chars[(Get-SecureRandom -Maximum $chars.Length)] }))
}

#generate and pass password info to a variable
$PasswordProfile = @{
    ForceChangePasswordNextSignIn = $true
    Password = "$(get-randompassword)"
}
$User = @{
    accountEnabled = $true
    displayName = "$Firstname $Lastname"
    givenName = $Firstname
    surname = $Lastname
    department = $Department
    officeLocation = $Office
    userPrincipalName = "$FirstInit$Lastname@domain.com".ToLower()
    mailNickname = "$Firstinit$Lastname".ToLower()
    PasswordProfile = $PasswordProfile
}

#=================================================================================================
# Import Modules
#=================================================================================================
Import-Module Microsoft.Graph.Groups
Import-Module Microsoft.Graph.Users

#=================================================================================================
#Connect to Microsoft graph api https://learn.microsoft.com/en-us/powershell/microsoftgraph/overview?view=graph-powershell-1.0
#=================================================================================================
try {
    try {
        Connect-MgGraph -Scopes "User.ReadWrite.All","Mail.Send" -ErrorAction Stop
        Write-log INFO 'Successfully authenticated to Graph API'
    }
    catch {
        Write-log ERROR "Error failed to authenticate to O365 $($_.Exception.Message)"
        throw
    }

    #=================================================================================================
    #Create the user https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.users/new-mguser?view=graph-powershell-1.0
    #=================================================================================================

    try{
        $Newuser = New-MgUser -BodyParameter $User -ErrorAction Stop
        write-log INFO "successfully created user $($user.userPrincipalName)"
        $results += [PSCustomObject]@{
                Name    = $newuser.DisplayName
                Email   = $newuser.UserPrincipalName
                Action  = "Account Creation"
                Status  = "Success"
                Details = ""
                Password = "$($PasswordProfile.password)"
            }
    }
    catch {
        write-log ERROR "something went wrong with user account creation. $($_.Exception.Message)"

        $results += [PSCustomObject]@{
                Name    = $newuser.DisplayName
                Email   = $newuser.UserPrincipalName
                Action  = "Account Creation"
                Status  = "Failed"
                Details = $_.Exception.Message
            }

        throw "something went wrong with user account creation.$($_.Exception.Message)"
    }

    #=================================================================================================
    #Put the user in a the security group which auto assigns licensing. 
    #https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.groups/new-mggroupmemberbyref?view=graph-powershell-1.0
    #=================================================================================================
    $GroupId1 = 'GroupID user should be added to'
    $GroupId2 = 'GroupID user should be added to'
    $odata = "https://graph.microsoft.com/v1.0/directoryObjects/$($newuser.Id)"

    try {
    New-MgGroupMemberByRef -GroupId $GroupId1 -OdataId $odata -ErrorAction Stop
        write-log INFO 'Successfully added user to Business Standard Licensing Group'

        $results += [PSCustomObject]@{
                Name    = $newuser.DisplayName
                Email   = $newuser.UserPrincipalName
                Action  = "Group assignment"
                Status  = "Success"
                Details = ""
            }
    }
    catch {
        write-log ERROR "Could not put user in Licensing Group $($_.Exception.Message)"

        $results += [PSCustomObject]@{
                Name    = $newuser.DisplayName
                Email   = $newuser.UserPrincipalName
                Action  = "Group assignment Licensing"
                Status  = "Failure"
                Details = "$($_.Exception.Message)"
            }
    }
    try {
    New-MgGroupMemberByRef -GroupId $GroupId2 -OdataId $odata -ErrorAction Stop
        write-log INFO 'Successfully added user to Licensing Group'

        $results += [PSCustomObject]@{
                Name    = $newuser.DisplayName
                Email   = $newuser.UserPrincipalName
                Action  = "Group assignment"
                Status  = "Success"
                Details = "$($_.Exception.Message)"
            }
    }
    catch {
        write-log ERROR "Could not put user in Licensing Group $($_.Exception.Message)"

        $results += [PSCustomObject]@{
                Name    = $newuser.DisplayName
                Email   = $newuser.UserPrincipalName
                Action  = "Group assignment"
                Status  = "Failure"
                Details = "$($_.Exception.Message)"
            }
    }
}

finally {
$htmlTable = $results | ConvertTo-Html -Fragment -PreContent "<h2>Provisioning Summary</h2>" | Out-String

$mailBody = @{
        message = @{
            subject = "$($newuser.DisplayName) Microsoft Information"
            body = @{
                contentType = "HTML"
                content = [string]$htmlTable
            }
            toRecipients = @(
                @{
                    emailAddress = @{
                        address = "your@domain.com"
                    }
                }
                @{
                    emailAddress = @{
                        address = "your@domain.com"
                    }
                }
            )
        }
    }
    try{
    Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/me/sendMail" -Body $mailBody
    }
    catch {
        write-log ERROR "Something went wrong with the email send $($_.Exception.Message)"
    }

    Disconnect-MgGraph
}
