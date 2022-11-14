$mbx=Import-Csv -Path "C:\Users\enrgiaco.SMEUP\Desktop\Desktop Temp\Config_MAIL_SALFVG NE.csv" -Delimiter ";"
foreach ($m in $mbx){
    New-Mailbox -shared -Alias $m.Alias -Name $m.DisplayName -DisplayName $m.DisplayName
    Add-MailboxPermission -Identity $m.Alias -User nsftadmin -AccessRights FullAccess -InheritanceType All
}

New-Mailbox -shared -Alias "Trieste" -Name "SAL FVG - Trieste" -DisplayName "SAL FVG - Trieste"
New-Mailbox -shared -Alias "regionale" -Name "SAL FVG - Regionale" -DisplayName "SAL FVG - Regionale"
get-mailbox "SAL*" | Add-MailboxPermission -Identity $_.Alias -User 0alec1 -AccessRights FullAccess -InheritanceType All