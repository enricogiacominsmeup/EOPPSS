Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010

 $report = [System.Collections.Generic.List[System.Object]]::new()

 $mailbox = Get-Mailbox -ResultSize unlimited

 foreach ($m in $mailbox){
    $s = Get-MailboxStatistics -Identity $m.identity
    $reportLine = [PSCustomObject]@{
        "Mailbox Name"            = $m.DisplayName
        "Email address"           = $m.PrimarySmtpAddress
        "LastLoggedOnUserAccount" = $s.LastLoggedOnUserAccount
        "LastLogonTime"           = $s.LastLogonTime
        "LastLogoffTime"          = $s.LastLogoffTime
    }
    $report.add($reportLine)

 }
 $report| Out-GridView
 $report | export-csv -Path \agg\MailboxAccessStatistics.csv