<#
Title: userCertExpiryCheck.ps1
Author: Me
Job: Senior Network Engineer
Date: 11/15/2018
Should be able to repurpose for computer objects as well against a security group or OU
#>

Import-Module -Name pspki
Import-Module ActiveDirectory

#Get current date in a format that matches the certificate dates
$date = Get-Date -Format "M/d/yyyy H:mm:ss tt"

#Save the AD Security Group you want to check against to a variable and select the 'Name' property
$groupMembers = Get-ADGroupMember -Identity "Group Name" | Select Name

#Save the CA server name to a variable
$server = 'CA Server (FQDN)'

#Save the template string to a variable
$templateString = "template string for the template you want to check against"

#Use the following line to get all the template strings
#Get-CertificationAuthority -ComputerName $server | Get-IssuedRequest -Property CertificateTemplate | Select-Object -Property CertificateTemplate -Unique

# Use the following line for an individual user/computer
#Get-CertificationAuthority -ComputerName $server | Get-IssuedRequest -Filter "CommonName -eq John Smith" -Property CertificateTemplate

#Save all the certificates that were issued with the template noted above to a variable (array)
$Certs = Get-CertificationAuthority -ComputerName $server | Get-IssuedRequest -property CertificateTemplate | ? { $_.CertificateTemplate -eq $templateString }

#Loop through each certificate in $Certs
#   Loop through each name in $groupMembers
#       Check if the name in the certificate matches the name in the list of users/computers
#           Check if the expiration date of the certificate is after today
#               Append C:\temp\certs.csv with each certificate and its properties
$userCerts = ForEach ($c in $Certs) {
    ForEach ($n in $groupMembers) {
        If ($c.CommonName -eq $n.Name) {
            If ($c.NotAfter -gt $date) {
                Export-Csv -Path C:\temp\certs.csv -InputObject $c -Append -NoTypeInformation
            }
        }
    }
}

#Rename csv to csv.old
Rename-Item C:\temp\certs.csv C:\temp\certs.csv.old -Force

#Get the contents of csv.old, sort them by user/computer name, then export the contents to csv
Import-Csv C:\temp\certs.csv.old | sort CommonName | Export-Csv -Path C:\temp\certs.csv -NoTypeInformation

#Delete csv.old
Remove-Item C:\temp\certs.csv.old -Force
