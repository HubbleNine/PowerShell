# Read the OUs to be created from CSV
$ous = Import-Csv -Path $env:USERPROFILE\Desktop\create-ous.csv

# Important: The CSV must contain the following columns with the indicated format
#    Path            Distinguished name of the path to create the OU under
#                    (should not include the name of the OU itself)
#    Name            Name of the OU to create
#    BlockInherit    Should be either 'Yes' or 'No' and indicate if Group
#                    Policy inhertiance should be blocked on the OU

# Create new OUs
foreach ($ou in $ous) {
    $identity = "OU=$($ou.Name),$($ou.Path)"

    $ouExists = try { Get-ADOrganizationalUnit -Identity $identity } catch { $null }
    
    if (-not $ouExists) {
        New-ADOrganizationalUnit -Name $ou.Name -Path $ou.Path
    }

    if ($ou.BlockInherit -eq 'Yes') {
        Set-GPInheritance -Target $identity -IsBlocked Yes | Out-Null
    }
}
