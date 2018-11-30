<#
***NOTE***
***NOTE***
***NOTE***

This script has not been tested. Use at your own risk

***NOTE***
***NOTE***
***NOTE***

Author: Me | Various Internet People
Date: 11/29/2018
To be used in junction with 'GetOnPremDLtoCSV.ps1', which will generate the CSV needed for this script to run.
Takes the entries in the CSV and creates the distribution groups and adds their members, from an on-premise Exchange server,
to Exchange Online (Office 365)
#>

$liveCred = Get-Credential
$session2 = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $liveCred -Authentication Basic -AllowRedirection
Import-PSSession $session2

$csvFile = Read-Host "Enter the Path of CSV file (Eg. C:\DG.csv)"
$entries = Import-Csv $csvFile
$entries | Where-Object {$_.Grouptype -like "*Security*"} | %{
 
New-DistributionGroup -Name $_.Name -PrimarySmtpAddress $_.PrimarySMTPAddress -type Security
 
}
 
$entries | Where-Object {($_.GroupType -eq "Universal" -or $_.GroupType -eq "Global")} | %{
 
New-DistributionGroup -Name $_.Name -PrimarySmtpAddress $_.PrimarySMTPAddress -type Distribution
 
}

Remove-PSSession $session2
