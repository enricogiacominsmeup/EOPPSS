$olddomain = Read-Host "Input the domain name to replace: "
$newdomain = Read-Host "Input the domain name to replace: "
$userou =    Read-Host "Input the search base OU distinguished name: "
$makealias = $true
$users = Get-ADUser -Filter * -SearchBase $userou -Properties SamAccountName, EmailAddress, ProxyAddresses
Foreach ($user in $users) {
    $oldemail = "$($user.samaccountname)$($olddomain)"
    $newemail = "$($user.samaccountname)$($newdomain)"
    Write-Host "User: $($user.samaccountname)`n------------------------"d

    #Update Mail Attribute    
    If ($user.EmailAddress -ieq $oldemail) {
        Write-Host "Mail Attribute: Old Value Detected Updating..."
        Write-Host "Old Value: $($user.EmailAddress)"
        $user.EmailAddress = $newemail
        Write-Host "New Value: $($newemail)"
    }
    Elseif ($user.EmailAddress -ieq "$newemail") {
        Write-Host "Mail Attribute: New Value Detected Skipping..."
        Write-Host "Value: $($user.EmailAddress)"
    }
    Else {
        Write-Host "Mail Attribute: Unknown Value Detected NOT Updating..."
        Write-Host "Value: $($user.EmailAddress)"
    }

    #Update ProxyAddresses Attribute
    $blnPrimaryOld = $false
    $blnPrimaryNew = $false
    $blnPrimaryOther = $false
    $blnAliasOld = $false
    $blnAliasNew = $false
    ForEach ($proxy in $user.ProxyAddresses) {
        If ($proxy.StartsWith("SMTP:")) {
            If ($proxy -eq "SMTP:$($oldemail)") {
                $blnPrimaryOld = $true
            }
            Elseif ($proxy -eq "SMTP:$($newemail)") {
                $blnPrimaryNew = $true
            }
            Else {
                $blnPrimaryOther = $true
            }
        }
        ElseIf ($proxy.StartsWith("smtp:")) {
            If ($proxy -eq "smtp:$($oldemail)") {                
                $blnAliasOld = $true
            }
            Elseif ($proxy -eq "smtp:$($newemail)") { 
                $blnAliasNew = $true
            }
        }
    }
    If (($blnPrimaryOld -eq $true) -AND ($blnPrimaryNew -eq $false) -AND ($blnPrimaryOther -eq $false)) {
        Write-Host "Primary Email: Old Value Detected Updating..."
        Write-Host "Removing SMTP:$($oldemail)"
        $user.ProxyAddresses.remove("SMTP:$($oldemail)")
        Write-Host "Adding SMTP:$($newemail)"
        $user.ProxyAddresses.add("SMTP:$($newemail)")
        Write-Host "Make Old Email Alias: $($makealias)"                
        If ($makealias -eq $true) {
            Write-Host "smtp:$($oldemail)"  
            $user.ProxyAddresses.add("smtp:$($oldemail)")
        }
    }
    Elseif (($blnPrimaryNew -eq $true) -AND ($blnPrimaryOld -eq $false) -AND ($blnPrimaryOther -eq $false)) {
        Write-Host "Primary Email: New Value Detected Skipping..."
    }
    Else {
        Write-Host "Primary Email: Unknown Value Detected NOT Updating..."
    }


    #Write Values to User
    Write-Host "Setting Values..."
    $result = Set-ADUser -Instance $user
    Write-Host "`n"
}