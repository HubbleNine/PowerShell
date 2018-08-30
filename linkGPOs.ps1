# Read the GPOs to be linked from CSV
$gpos = Import-Csv -Path $env:USERPROFILE\Desktop\link-gpos.csv

# Important: The CSV must contain the following columns with the indicated format
#    Target          Distinguished name of the OU to link the GPO to
#    Name            Name for the GPO to link

# Set GP links
foreach ($gpo in $gpos) {
     New-GPLink -Name $gpo.Name -Target $gpo.Target -Enforced No -LinkEnabled Yes | Out-Null 

}
