$HostName = (Get-Wmiobject win32_computersystem).__server
$File1 = "C:\$HostName-System-Error.htm"
$File2 = "C:\$HostName-System-Warning.htm"
$File3 = "C:\$HostName-Application-Error.htm"
$File4 = "C:\$HostName-Application-Warning.htm"
Get-EventLog -LogName "system" -EntryType "error" -After (Get-Date).AddHours(-24) | ConvertTo-HTML | Out-File $File1
Get-EventLog -LogName "system" -EntryType "warning" -After (Get-Date).AddHours(-24) | ConvertTo-HTML | Out-File $File2
Get-EventLog -LogName "application" -EntryType "error" -After (Get-Date).AddHours(-24) | ConvertTo-HTML | Out-File $File3
Get-EventLog -LogName "application" -EntryType "warning" -After (Get-Date).AddHours(-24) | ConvertTo-HTML | Out-File $File4
Send-MailMessage -Attachments $File1,$File2,$File3,$File4 -SmtpServer "yourmail-server" -From "$HostName@yourdomain" -To "reciver@yourdomain" -Subject "$Hostname Daily Eventlog-Report"

#Found on Spiceworks: https://community.spiceworks.com/topic/443133-need-a-script-to-capture-windows-event-log-in-last-24-hours?utm_source=copy_paste&utm_campaign=growth
