<#
 # Windows Update di un nodo exchange:

https://learn.microsoft.com/en-us/exchange/perform-a-server-switchover-exchange-2013-help
https://learn.microsoft.com/en-us/exchange/managing-database-availability-groups-exchange-2013-help#performing-maintenance-on-dag-members

#>

Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn

$server = "Mercurio013"

# Spostamento dei servizi dal nodo da aggiornare e sospensione del nodo

Set-ServerComponentState $Server -Component HubTransport -State Draining -Requester Maintenance
Restart-Service MSExchangeTransport
# Set-ServerComponentState $Server -Component UMCallRouter -State Draining -Requester Maintenance
Redirect-Message -Server $Server -Target mercurio014.aimail.local
Suspend-ClusterNode $Server
Set-MailboxServer $Server -DatabaseCopyActivationDisabledAndMoveNow $True
Set-MailboxServer $Server -DatabaseCopyAutoActivationPolicy Blocked
Set-ServerComponentState $Server -Component ServerWideOffline -State Inactive -Requester Maintenance


# Ripristino dei servizi dopo la manutenzione:

Set-ServerComponentState $Server -Component ServerWideOffline -State Active -Requester Maintenance
#Set-ServerComponentState $Server -Component UMCallRouter -State Active -Requester Maintenance
Resume-ClusterNode $Server
Set-MailboxServer $Server -DatabaseCopyActivationDisabledAndMoveNow $False
Set-MailboxServer $Server -DatabaseCopyAutoActivationPolicy Unrestricted
Set-ServerComponentState $Server -Component HubTransport -State Active -Requester Maintenance
Restart-Service MSExchangeTransport

cd "C:\Program Files\Microsoft\Exchange Server\V15\Scripts"
.\RedistributeActiveDatabases.ps1 -BalanceDbsByActivationPreference -DagName DAG01 -Confirm