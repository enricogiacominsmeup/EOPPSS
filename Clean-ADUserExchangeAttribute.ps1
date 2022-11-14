function clean-ADUserExchangeAttribute {

    #Requires -version 2
    <#
    .SYNOPSIS
    
    RemoveExchangeAttributes.ps1 - It Will Remove Exchange Attributes from Active Directory Accounts
    
    Caution : Mailbox Will Go Disconnected and Exchange Attributes will be Removed"
    
    
    .DESCRIPTION 
    
    Remove Exchange Attributes for a Corrupted Active Directory Account
    This script has been modified by Enrico Giacomin to solve the issue
    "Windows cannot create the object username because: The name reference is invalid"
    when copying a user from Active Directory USers and COmputers
    
    CAUTION:
    If users are syncronyzed with AAD Connect and an Exchange Hybrid Deployment is on, 
    do not user this script unless you really know well its implication.
    
    After an Exchange Server Crash. At times Some Active Directory accounts will get corrupted 
    and It will not allow to disable the mailbox 
    Its hard to Have all the Exchange attributes to get to Null .
    So simplied the task into a simple script. Where we can set the Exchange attributes to Null in one shot
    
    
    .EXAMPLE 
    
    [PS] C:\>.\RemoveExchangeattributes.ps1
    
    
    Remove Exchange Attributes
    ----------------------------
    
    Remove Exchange 2010 Attributes for a Corrupted Active Directory Account
    
    Caution : Mailbox Will Go Disconnected and Exchange Attributes will be Removed
    Enter Alias: Manager
    
    .NOTES
    Written By: Satheshwaran Manoharan
    Website : www.careexchange.in
    
    Change Log
    V1.0, 08/11/2012 - Initial version
    
    v1.1, 02/11/2018 - Changed to use whitout loading E2010 module
                       Modified which attributes have to be cleared
    #>
    
    #Add Exchange 2010 snapin if not already loaded
    <#if (!(Get-PSSnapin | where {$_.Name -eq "Microsoft.Exchange.Management.PowerShell.E2010"}))
    {
            Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010 -ErrorAction SilentlyContinue
    }
    #>
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   Position=0)]
        [String] $Alias
    
    
    )
    Write-host "
    Remove Exchange Attributes
    ----------------------------
    Remove Exchange 2010 Attributes for a Corrupted Active Directory Account
    Caution : Mailbox Will Go Disconnected and Exchange Attributes will be Removed
    ----------------------------" -ForeGround Red
    Write-Host "Processing Mailbox $alias" -BackgroundColor Green -ForegroundColor Black
    
    $user=Get-ADUser $Alias
    $FullDistinguishName = "LDAP://" + $user.distinguishedName
    $AccountEntry = New-Object DirectoryServices.DirectoryEntry $FullDistinguishName
    $AccountEntry.PutEx(1, "HomeMDB", $null)
    $AccountEntry.PutEx(1, "HomeMTA", $null)
    $AccountEntry.PutEx(1, "legacyExchangeDN", $null)
    $AccountEntry.PutEx(1, "mailNickname", $null)
    $AccountEntry.PutEx(1, "msExchMailboxAuditEnable", $null)
    $AccountEntry.PutEx(1, "msExchAddressBookFlags", $null)
    $AccountEntry.PutEx(1, "msExchALObjectVersion", $null)
    $AccountEntry.PutEx(1, "msExchArchiveQuota", $null)
    $AccountEntry.PutEx(1, "msExchArchiveWarnQuota", $null)
    $AccountEntry.PutEx(1, "msExchBypassAudit", $null)
    $AccountEntry.PutEx(1, "msExchDumpsterQuota", $null)
    $AccountEntry.PutEx(1, "msExchDumpsterWarningQuota", $null)
    $AccountEntry.PutEx(1, "msExchHideFromAddressLists", $null) 
    $AccountEntry.PutEx(1, "msExchHomeServerName", $null)
    $AccountEntry.PutEx(1, "msExchMailboxAuditEnable", $null)
    $AccountEntry.PutEx(1, "msExchMailboxAuditLogAgeLimit", $null)
    $AccountEntry.PutEx(1, "msExchMailboxGuid", $null)
    $AccountEntry.PutEx(1, "msExchOmaAdminWirelessEnable", $null)
    $AccountEntry.PutEx(1, "msExchPoliciesExcluded", $null)
    $AccountEntry.PutEx(1, "msExchSafeSendersHash", $null)
    $AccountEntry.PutEx(1, "msExchShadowProxyAddresses", $null)
    $AccountEntry.PutEx(1, "msExchMobileMailboxFlags", $null)
    $AccountEntry.PutEx(1, "msExchMDBRulesQuota", $null)
    $AccountEntry.PutEx(1, "msExchModerationFlags", $null)
    $AccountEntry.PutEx(1, "msExchPoliciesIncluded", $null)
    $AccountEntry.PutEx(1, "msExchProvisioningFlags", $null)
    $AccountEntry.PutEx(1, "msExchRBACPolicyLink", $null)
    $AccountEntry.PutEx(1, "msExchRecipientDisplayType", $null)
    $AccountEntry.PutEx(1, "msExchRecipientTypeDetails", $null)
    $AccountEntry.PutEx(1, "msExchRemoteRecipientType", $null)
    $AccountEntry.PutEx(1, "msExchTextMessagingState", $null)
    $AccountEntry.PutEx(1, "msExchTransportRecipientSettingsFlags", $null)
    $AccountEntry.PutEx(1, "msExchUMDtmfMap", $null)
    $AccountEntry.PutEx(1, "msExchUMEnabledFlags2", $null)
    $AccountEntry.PutEx(1, "msExchUserAccountControl", $null)
    $AccountEntry.PutEx(1, "msExchUserCulture", $null)
    $AccountEntry.PutEx(1, "msExchVersion", $null) 
    $AccountEntry.PutEx(1, "TargetAddress", $null) 
    $AccountEntry.PutEx(1, "showInAddressBook", $null) 
    
    
    $AccountEntry.SetInfo()
    $AccountEntry.Close()
    }
    
    #clean-ADUserExchangeAttribute -Alias 