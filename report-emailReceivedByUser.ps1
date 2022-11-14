#Import modules giulia.dalcorso@aimvicenza.it
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010
Import-Module activedirectory

class userAddresses
{
   # Proprietà
    [String]   $usr_diplayName
    [String]   $usr_primaryEmailAddress
    [String[]] $usr_emailaddresses


    # Costruttori
    userAddresses($DisplayName, $primaryEmailAddress, $emailaddresses){
        $this.usr_diplayName          = $DisplayName
        $this.usr_primaryEmailAddress = $primaryEmailAddress
        $this.usr_emailaddresses      = $emailaddresses
    }
    userAddresses(){
        $this.usr_diplayName          = $null
        $this.usr_primaryEmailAddress = $null
        $this.usr_emailaddresses      = $null
    }
}

class emailReport
{
   # Proprietà
    [String]   $eml_diplayName
    [String]   $eml_address
    [int]      $eml_messageCount


    # Costruttori
    emailReport ($eml_diplayName, $eml_address, $eml_messageCount){
        $this.eml_diplayName   = $eml_diplayName
        $this.eml_address      = $eml_address
        $this.eml_messageCount = $eml_messageCount
    }
}

function check-mailReceived ([userAddresses]$l){
    $report1 = New-Object 'System.Collections.Generic.List[emailReport]'

    # Conteggio delle mail ricevute sul primary smtp address
    $a = count-emailreceived ($l.usr_primaryEmailAddress)

    $obj     = New-Object emailReport($l.usr_diplayName,$l.usr_primaryEmailAddress,$a)
    $report1.Add($obj)
    foreach ($e in $l.usr_emailaddresses){
        $obj     = New-Object emailReport($l.usr_diplayName,$e,0)
        [emailReport] $report1.Add($obj)
    }
    $report1
}

function count-emailreceived ($strMailAddr){
    $date = Get-Date
    $a = Get-MessageTrackingLog -Recipients $strMailAddr -Start ((Get-Date).AddDays(-$days)) -ResultSize 5000 -EventId receive
    $a.count
}


#Avvio file di log
#Start-Transcript -Path $logFilePath



# Variable
$logFilePath = "C:\AGG\AGSM\028_AIM2AGSM_MBX-Log.txt"
$days      = 6

# Instance and Inizialising objects
$list   = New-Object 'System.Collections.Generic.List[userAddresses]'
$report = New-Object 'System.Collections.Generic.List[emailReport]'

# User input
$email = Read-Host -Prompt "Inserisci un indirizzo email dell'utente del quale vuoi verificare il numero di mail ricevute"

# fetch users data
$user = Get-Mailbox $email  | Select-Object -Property DisplayName,PrimarySMTPAddress,emailaddresses

# Create collections of objects
<#
$user | ForEach-Object {
    $emailAddr = (($_.EmailAddresses -join ",").Replace("smtp:","")).split(',')
    [userAddresses] $obj = New-Object userAddresses($_.DisplayName, $_.PrimarySmtpAddress,$emailAddr)
    $list.Add($obj)
}
#>

$user | ForEach-Object {
    [userAddresses] $obj = New-Object userAddresses($_.DisplayName, $_.PrimarySmtpAddress,$_.EmailAddresses.smtpaddress)
    $list.Add($obj)
}

foreach ($l in $list){
$objReport = check-mailReceived ($l)
foreach ($o in $objReport){

        $report.Add($o)
    }
}
$report
