Import-Module ActiveDirectory -SkipEditionCheck
Import-Module Microsoft.PowerShell.Management -SkipEditionCheck

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Clean-ADUserAttribute
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [String]
        $SAMAccountName
    )

    Begin
    {
    }
    Process
    {
        $user=Get-ADUser $SAMAccountName -Properties *

        #Pulizia degli attributi
        $FullDistinguishName = "LDAP://" + $user.distinguishedName
        $AccountEntry = New-Object DirectoryServices.DirectoryEntry $FullDistinguishName
        $AccountEntry.PutEx(1, "displayName", $null)
        $AccountEntry.PutEx(1, "altSecurityIdentities", $null)
        $AccountEntry.PutEx(1, "telephoneNumber", $null)
        $AccountEntry.PutEx(1, "mail", $null)
        $AccountEntry.PutEx(1, "wWWHomePage", $null)
        $AccountEntry.SetInfo()
        $AccountEntry.Close()

        #Istruzioni da eseguire dopo "$AccountEntry.Close()"
        $newUPN = ($user.UserPrincipalName).split("@")[0]+"@$UPNSuf"
        Set-ADUser $SAMAccountName -Description "-OGGETTO DISMESSO-" -UserPrincipalName $newUPN
        $user | Move-ADObject -TargetPath $OU


    }
    End
    {
       
    }
}

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function manage-ADDismissedUserACL
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [String]
        $SAMAccountName
    )

    Begin
    {
        $users = Get-ADUser eguidolin -Properties *
    }
    Process
    {
        $ACLPath = "AD:" + $users.distinguishedName
        $ADOACl = get-acl -Path $ACLPath
        $ADOACl.SetAccessRuleProtection($true,$true)
        set-acl -Path $ACLPath -AclObject $ADOACl

        $aclToRemove = $ADOACl.Access | Where-Object {$_.identityReference -like '*Authenticated Users*'}
        foreach ($a in $aclToRemove){
            $ADOACl.RemoveAccessRuleSpecific($a)
            set-acl -Path $ACLPath -AclObject $ADOACl
        }

        $aclToRemove = $ADOACl.Access | Where-Object {$_.identityReference -like '*Creator Owner*'}
        foreach ($a in $aclToRemove){
            $ADOACl.RemoveAccessRuleSpecific($a)
            set-acl -Path $ACLPath -AclObject $ADOACl
        }
        $aclToRemove = $ADOACl.Access | Where-Object {$_.identityReference -like '*Everyone*'}
        foreach ($a in $aclToRemove){
            $ADOACl.RemoveAccessRuleSpecific($a)
            set-acl -Path $ACLPath -AclObject $ADOACl
        }
    }
    End
    {
    }
}

function remove-UserFolders {
    param (
        # Param1 help description
        [Parameter(Mandatory=$true,
        ValueFromPipelineByPropertyName=$true,
        Position=0)]
        [String]
        $SAMAccountName
    )
    <#
        REM cancellazione profili utente su entrambi i fileserver
        REM script by ms del 2021 febbraio 04 ore 11:06
        set INPUT=
        set /P INPUT=digita:
        echo hai digitato: %INPUT%
        echo SE HAI SBAGLIATO USA CTRL+C
        pause
        RD /s /q \\srvfile2\F$\system2018\MS-FOLDER\%INPUT%
        RD /s /q \\srvfile2\F$\system2018\UPM-PROFILE\%INPUT%
        RD /s /q \\srvfile2\F$\system2018\USERCONFIG\%INPUT%
        RD /s /q \\srvfile\F$\system2018\MS-FOLDER\%INPUT%
        RD /s /q \\srvfile\F$\system2018\UPM-PROFILE\%INPUT%
        RD /s /q \\srvfile\F$\system2018\USERCONFIG\%INPUT%
        pause}
    #>

    $path = @(
        "\\srvfile2\F$\system2018\MS-FOLDER\$SAMAccountName",
        "\\srvfile2\F$\system2018\UPM-PROFILE\$SAMAccountName",
        "\\srvfile2\F$\system2018\USERCONFIG\$SAMAccountName",
        "\\srvfile\F$\system2018\MS-FOLDER\$SAMAccountName",
        "\\srvfile\F$\system2018\UPM-PROFILE\$SAMAccountName",
        "\\srvfile\F$\system2018\USERCONFIG\$SAMAccountName"
    )

    Remove-Item -Path $path -Recurse
}

#### Variabili da popolare
## OU a cui mandare gli utenti disattivati
$OU= "OU=Disabilitati,OU=Utenti,OU=_xxxxxx,DC=Sorelleramonda,DC=local"
# Suffisso UPN
$UPNSuf = "Sorelleramonda.local"
Start-Transcript C:\AGG\testad.txt

# routine per recuperare gli utenti da processare
$user = Get-ADUser -correggereComando


# Operazioni sugli utenti
foreach ($u in $user){
    #Sistemazione degli attributi
    Clean-ADUserAttribute -SAMAccountName $u -Verbose
    #Sitemazione delle ACL
    manage-ADDismissedUserACL -SAMAccountName $u -Verbose
    #Sistemazione delle folder
    
}
Stop-Transcript
