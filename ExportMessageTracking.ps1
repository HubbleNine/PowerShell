<#
Title: ExportMessageTracking.ps1
Author: Me | Senior Network Engineer
Date: 11/29/2018

Used to get messages for an individual send and/or all senders for
a specific time frame from a remote on-premise exchange server
#>

$csvFilePath = Read-Host "Please enter the path to save your csv, i.e. C:\Users\username\Desktop\MessageResults.csv"
$server = Read-Host "Please enter your Exchange Server FQDN: "
$startDateTime = Read-Host "Please enter the start date/time in format MM/DD/YYYY H:MM:SS AM/PM"
$endDateTime = Read-Host "Please enter the end date/time in format MM/DD/YYYY H:MM:SS AM/PM"
$sender = Read-Host "Please enter the sender address to search for. You can use wildcards to search for all by entering *@*"
$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$server/powershell

Import-PSSession $session -AllowClobber -DisableNameChecking

Get-MessageTrackingLog -ResultSize Unlimited -Server $server -Start $startDateTime -End $endDateTime |
where{$_.sender -like $sender} | Export-CSV $csvFilePath
