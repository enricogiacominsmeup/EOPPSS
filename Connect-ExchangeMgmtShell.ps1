$UserCredential = Get-Credential
$Server = read-host -Prompt "Insert Exchange Server FQDN"
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$server/PowerShell/ -Authentication Kerberos -Credential $UserCredential
Import-PSSession $Session -DisableNameChecking