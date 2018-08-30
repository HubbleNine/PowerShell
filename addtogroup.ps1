<#
    Depends on consistent naming convention of computers in an ActiveDirectory environment
    Add computer objects to the designated group
    Author: Me | Desktop Engineer
#>

Import-Module ActiveDirectory

Get-ADComputer -Filter * | 
Where-Object {$_.Name -like '[partial naming convention]*' -or $_.Name -like '[partial naming convention]*'} | 
ForEach-Object {Add-ADPrincipalGroupMembership -Identity $_ -MemberOf '[group name]'}
