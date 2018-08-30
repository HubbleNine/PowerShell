Function Get-FileName($initialDirectory) {
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.InitialDirectory = $initialDirectory
    $OpenFileDialog.Filter = "CSV (*.csv)|*.csv"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.FileName
}

Function Set-SNMPTrustedHost {
    param (
        [Parameter(Mandatory=$true)]
        [string[]]$TrustedHost,

        [string]$ComputerName = $env:COMPUTERNAME
    )

    # Open remote registry hive
    $baseKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $ComputerName)

    # Open sub key
    $subKey = $baseKey.OpenSubKey("SYSTEM\CurrentControlSet\Services\SNMP\Parameters\PermittedManagers", $true)

    # Clear exist entries
    foreach ($valueName in $subKey.GetValueNames()) {
        $subKey.DeleteValue($valueName)
    }

    # Set new value
    for ($i = 0; $i -lt $TrustedHost.Count; $i++) {
        $subKey.SetValue(($i + 1), $TrustedHost[$i], [Microsoft.Win32.RegistryValueKind]::String)
    }

    # Close keys
    $subKey.Close()
    $baseKey.Close()
}  


$inputfile = Get-FileName "C:\temp"
$inputdata = Import-Csv $inputfile


foreach ($line in $inputdata) {
    #Modify SNMP Registry trusted hosts
    Set-SNMPTrustedHost -TrustedHost "Powershelliscool" -ComputerName $line.ComputerName

    #Get list of service to restart
    $services = $line.Service -split ';'

    #Process each service
    foreach ($service in $services) {
        Get-Service -ComputerName $line.ComputerName -Name $service | Restart-Service
    }
}
