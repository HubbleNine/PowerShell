<#
Title: GetOnPremDLtoCSV.ps1
Author: Me | Various Internet People
Date: 11/29/2018
Reaches out to a remote on-premise Exchange server and exports a list of Distribution groups and their members to a CSV file
#>

$exchange = Read-Host "Enter the FQDN for your On-Prem Exchange server: "
$session1 = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$exchange/powershell
Import-PSSession $session1 -AllowClobber -DisableNameChecking

#Use to create CSV file of all groups and members
$i = 0
$CSVfile = Read-Host "Enter the Path of CSV file (Eg. C:\DG.csv)"
$AllDG = Get-DistributionGroup -resultsize unlimited
$userList = @()
 
Foreach($dg in $allDg) {
    $Members = Get-DistributionGroupMember $Dg.name -resultsize unlimited
    if($members.count -eq 0) {
        $managers = $Dg | Select @{Name='DistributionGroupManagers';Expression={[string]::join(";", ($_.Managedby))}}
        $userObj = New-Object PSObject
        $userObj | Add-Member NoteProperty -Name "DisplayName" -Value EmptyGroup
        $userObj | Add-Member NoteProperty -Name "Alias" -Value EmptyGroup
        $userObj | Add-Member NoteProperty -Name "RecipientType" -Value EmptyGroup
        $userObj | Add-Member NoteProperty -Name "RecipientOU" -Value EmptyGroup
        $userObj | Add-Member NoteProperty -Name "PrimarySMTPaddress" -Value EmptyGroup
        $userObj | Add-Member NoteProperty -Name "DistributionGroup" -Value $DG.Name
        $userObj | Add-Member NoteProperty -Name "DistributionGroupPrimarySMTPaddress" -Value $DG.PrimarySmtpAddress
        $userObj | Add-Member NoteProperty -Name "DistributionGroupManagers" -Value $managers.DistributionGroupManagers
        $userObj | Add-Member NoteProperty -Name "DistributionGroupOU" -Value $DG.OrganizationalUnit
        $userObj | Add-Member NoteProperty -Name "DistributionGroupType" -Value $DG.GroupType
        $userObj | Add-Member NoteProperty -Name "DistributionGroupRecipientType" -Value $DG.RecipientType
 
        $userList += $UserObj 
 
    }
    else {
        Foreach($Member in $members) {
            $managers = $Dg | Select @{Name='DistributionGroupManagers';Expression={[string]::join(";", ($_.Managedby))}}
            $userObj = New-Object PSObject
            $userObj | Add-Member NoteProperty -Name "DisplayName" -Value $Member.Name
            $userObj | Add-Member NoteProperty -Name "Alias" -Value $Member.Alias
            $userObj | Add-Member NoteProperty -Name "RecipientType" -Value $Member.RecipientType
            $userObj | Add-Member NoteProperty -Name "RecipientOU" -Value $Member.OrganizationalUnit
            $userObj | Add-Member NoteProperty -Name "PrimarySMTPaddress" -Value $Member.PrimarySmtpAddress
            $userObj | Add-Member NoteProperty -Name "DistributionGroup" -Value $DG.Name
            $userObj | Add-Member NoteProperty -Name "DistributionGroupPrimarySMTPaddress" -Value $DG.PrimarySmtpAddress
            $userObj | Add-Member NoteProperty -Name "DistributionGroupManagers" -Value $managers.DistributionGroupManagers
            $userObj | Add-Member NoteProperty -Name "DistributionGroupOU" -Value $DG.OrganizationalUnit
            $userObj | Add-Member NoteProperty -Name "DistributionGroupType" -Value $DG.GroupType
            $userObj | Add-Member NoteProperty -Name "DistributionGroupRecipient Type" -Value $DG.RecipientType
 
            $userList += $userObj
 
        }
    }
# update counters and write progress
$i++
Write-Progress -activity "Scanning Groups . . ." -status "Scanned: $i of $($allDg.Count)" -percentComplete (($i / $allDg.Count)  * 100)
$userList | Export-csv -Path $CSVfile -NoTypeInformation
}

Remove-PSSession $session1



<# Display groups and members - Mostly for troubleshooting the script
$exchange = Read-Host "Enter the FQDN for your On-Prem Exchange server: "
$session1 = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$exchange/powershell
Import-PSSession $session1 -AllowClobber -DisableNameChecking
$allDg = Get-DistributionGroup -ResultSize Unlimited

ForEach ($dG in $allDg) {
    $members = Get-DistributionGroupMember $Dg.Name -ResultSize Unlimited
    if($members.count -eq 0) {
        $userObj = New-Object PSObject
        $userObj | Add-Member NoteProperty -Name "DisplayName" -Value EmtpyGroup
        $userObj | Add-Member NoteProperty -Name "Alias" -Value EmtpyGroup
        $userObj | Add-Member NoteProperty -Name "Primary SMTP address" -Value EmtpyGroup
        $userObj | Add-Member NoteProperty -Name "Distribution Group" -Value $DG.Name
        Write-Output $Userobj
    }
    else {
        Foreach($Member in $members) {
            $userObj = New-Object PSObject
            $userObj | Add-Member NoteProperty -Name "DisplayName" -Value $member.Name
            $userObj | Add-Member NoteProperty -Name "Alias" -Value $member.Alias
            $userObj | Add-Member NoteProperty -Name "Primary SMTP address" -Value $member.PrimarySmtpAddress
            $userObj | Add-Member NoteProperty -Name "Distribution Group" -Value $DG.Name
            Write-Output $Userobj
        }
    }
}
#>
