# Read the computer list from 'compslist.txt' file
$comps = Get-Content -Path $env:USERPROFILE\Desktop\compslist.txt


# Shutdown 
foreach ($line in $comps) {
    shutdown /s /m \\$line
}
