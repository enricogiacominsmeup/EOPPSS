Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010 -ErrorAction SilentlyContinue
$DomainToRemove = "aimvi.it"

$mailbox = Get-Mailbox enrico.colussi

foreach ($m in $mailbox){
    $smtpaddr = $mailbox.EmailAddresses | Where-Object {$_.prefixstring -eq "SMTP" -and $_.addressString -like "*@$DomainToRemove"}
    foreach ($s in $smtpaddr){
        Set-Mailbox $m -EmailAddresses @{remove=$s.AddressString}
    }
}