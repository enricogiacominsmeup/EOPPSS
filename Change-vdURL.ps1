Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn

$server = Read-Host "Server da correggere"



# ECP Virtual Directory
$ecpVD = Get-EcpVirtualDirectory -Server $server
$ecpVD | Set-ecpVirtualDirectory -InternalUrl $ecpVD.ExternalUrl
$ecpVD = Get-EcpVirtualDirectory -Server $server
write-host $ecpVD.Identity "." $ecpVD.InternalUrl "." $ecpVD.ExternalUrl -ForegroundColor Green

# Mapi Virtual Directory
$mapiVD = Get-MapiVirtualDirectory -Server $server
$mapiVD | Set-MapiVirtualDirectory -InternalUrl $mapiVD.ExternalUrl
$mapiVD = Get-MapiVirtualDirectory -Server $server
write-host $mapiVD.Identity "." $mapiVD.InternalUrl "." $mapiVD.ExternalUrl -ForegroundColor Green


# Microsoft Active Sync Virtual Directory
$asVD = Get-ActiveSyncVirtualDirectory -Server $server
$asVD | Set-ActiveSyncVirtualDirectory -InternalUrl $asVD.ExternalUrl
$asVD = Get-ActiveSyncVirtualDirectory -Server $server
write-host $asVD.Identity "." $asVD.InternalUrl "." $asVD.ExternalUrl -ForegroundColor Green


# Off line Address Book Virtual Directory
$oabVD = Get-OabVirtualDirectory -Server $server
$oabVD | Set-OabVirtualDirectory -InternalUrl $oabVD.ExternalUrl
$oabVD = Get-OabVirtualDirectory -Server $server
write-host $oabVD.Identity "." $oabVD.InternalUrl "." $oabVD.ExternalUrl -ForegroundColor Green


# OWA Virtual Directory
$owaVD = Get-OwaVirtualDirectory -Server $server
$owaVD | Set-OwaVirtualDirectory -InternalUrl $owaVD.ExternalUrl
$owaVD = Get-OwaVirtualDirectory -Server $server
write-host $owaVD.Identity "." $owaVD.InternalUrl "." $owaVD.ExternalUrl -ForegroundColor Green


#Exchange Web Services Virtual Directory
$wsVD = Get-WebServicesVirtualDirectory -Server $server
$wsVD | Set-WebServicesVirtualDirectory -InternalUrl $wsVD.ExternalUrl
$wsVD = Get-WebServicesVirtualDirectory -Server $server
write-host $wsVD.Identity "." $wsVD.InternalUrl "." $wsVD.ExternalUrl -ForegroundColor Green

# Configure Autodiscover internal and External URI

$casServer = Get-ClientAccessService -Identity $server
$str=$casServer.AutoDiscoverServiceInternalUri.OriginalString.Split("/")
$orginalHost = $str[2]
$newHost = $owaVD.ExternalUrl.OriginalString.Split("/")[2]
$newURL = $str[0]+"//"+$newHost+"/"+$str[3]+"/"+$str[4]
Set-ClientAccessService -Identity $casServer.Identity -AutoDiscoverServiceInternalUri $newURL
$casServer = Get-ClientAccessService -Identity $server
Write-Host $casServer.Identity "." $casServer.AutoDiscoverServiceInternalUri -ForegroundColor Green