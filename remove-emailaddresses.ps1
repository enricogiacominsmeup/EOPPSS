Import-Module activeDirectory

function clean-proxyaddresses($Alias, $domain) {
    <#     
    Write-Host $domain
    Write-Host $Alias
    #>    
    $ADaccount = Get-ADobject $Alias
    $FullDistinguishName = "LDAP://" + $ADaccount.distinguishedName
    $AccountEntry = New-Object DirectoryServices.DirectoryEntry $FullDistinguishName
    $addr = $AccountEntry.proxyAddresses
    $itemsToDelete = @()
    $domainToDelete = "*@$domain"
    foreach ($a in $addr) {
        if ($a -like "$domainToDelete") {
            $itemsToDelete += $a
        }
        else {
            Write-Host "Skip " $a
        }
    }
    foreach ($i in $itemsToDelete) {
        $AccountEntry.proxyAddresses.Remove($i)
        write-host -ForegroundColor Red "Match " $i ": I will remove it"
    }
    #$AccountEntry.setInfo()
}

Start-Transcript -Path c:\agg\00_domain-com.txt
$users = Get-ADobject -Properties SAMAccountName -Filter { objectclass -eq "user" -and proxyAddresses -like "*domain.com" }
foreach ($u in $users) {
    clean-proxyaddresses -Alias $u.SAMAccountName -domain domain.com
}
Stop-Transcript

Start-Transcript -Path c:\agg\01_domain-com.txt
$groups = Get-ADobject -Properties DistinguishedName,Name,mail,proxyAddresses -Filter { objectclass -eq "group" -and proxyAddresses -like "*@qtecharea365.mail.onmicrosoft.com"}
foreach ($g in $groups) {
    #clean-proxyaddresses -Alias $u.SAMAccountName -domain qtecharea365.mail.onmicrosoft.com
    write-host "Gruppo con indirizzo email in qtecharea:  $g.distiguishedName"
}
Stop-Transcript

