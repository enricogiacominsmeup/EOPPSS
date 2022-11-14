Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn

#$SourceServer = Read-Host "Scrivere il nome netbios del server Exchange 2010 sorgente:"
#$DestServer = Read-Host "Scrivere il nome netbios del server Exchange 2016 destinazione:"

$SourceServer = "Mailserv"
$DestServer = "srvsvc03"


$RC = Get-ReceiveConnector -Server $SourceServer | Select-Object -Property Identity,Name,Enabled,ProtocolLoggingLevel,MaxMessageSize,MaxLocalHopCount,MaxHopCount,AuthMechanism,PermissionGroups,RemoteIPRanges,Bindings,FQDN

foreach ($r in $RC){
    $dom = Read-Host "Vuoi creare sul nuovo server il connettore di ricezione"$r.name"?(S/N)"
    if ($dom -eq "S"){
    Write-Host -ForegroundColor Green "Creazione del connettore $r.name"
    New-ReceiveConnector -Server $DestServer -Name $r.Name -TransportRole FrontendTransport -AuthMechanism $r.AuthMechanism -PermissionGroups $r.PermissionGroups -RemoteIPRanges $r.RemoteIPRanges -Fqdn $r.Fqdn -ProtocolLoggingLevel $r.ProtocolLoggingLevel -Bindings 0.0.0.0:25 #-WhatIf
    }
    else{
    Write-Host -ForegroundColor red "Skip"
  