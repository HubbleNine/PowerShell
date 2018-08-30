<# 
Title: CopyToMany.ps1
Author: Jordan Hubbard | Senior Infrastructure Engineer
Date: 08/23/2018
Version: 1.0

This script is designed to copy a file to multiple computers. The computers are put into a CSV file in the format:

Name,
somecomputername,
someothercomputername,

***Note***
If in an environment with separated rights accounts, i.e. a normal user account and a separate administrative account, you must run this script as a different user (admin)
#>

#Function to pull out a Windows Form Dialog box for browsing to the desired CSV
Function Get-FileNameCSV($initialDirectory) {
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.InitialDirectory = $initialDirectory
    $OpenFileDialog.Filter = "CSV (*.csv)|*.csv"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.FileName
}
#Function to pull out a Windows Form Dialog box for browsing to the desired file to copy over
Function Get-FileNameSource($initialDirectory) {
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.InitialDirectory = $initialDirectory
    $OpenFileDialog.Filter = "All (*.*)|*.*"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.FileName
}


#variable to call the CSV function and contain its object
$inputfilecsv = Get-FileNameCSV "C:\"
#variable to call the file function and contain its object
$inputfilesource = Get-FileNameSource "C:\"
#variable to import the csv contents for usability for the script
$inputdata = Import-Csv $inputfilecsv
#variable to prompt the user for the desired path on each remote computer to write to
$destination = Read-Host -Prompt "Input destination path i.e. C$\temp... ".ToString()

foreach ($name in $inputdata) {
    #local variable, takes the 'Name' value for each item
    $comppath = $name.Name
    #attempts to create the directory on the target computer
    New-Item -Path "\\$comppath\" -Name "$destination" -ItemType "directory"
    #tests if the directory exists on the target computer
    if ((Test-Path -Path "\\$comppath\$destination")) {
        #Copies the file to the target computer
        Copy-Item $inputfilesource -Destination "\\$comppath\$destination" -Force
    }
    else {
        #else, the directory doesn't exist or isn't reachable, writes this output to the console
        Write-Output "\\$comppath\$destination is not reachable or does not exist"
    }
}
