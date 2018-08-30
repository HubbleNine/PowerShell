<#
Author: me | desktop engineer
Find the chassis for the local computer running the script
#>

function check-chassis {  
BEGIN {}  
PROCESS {  
        Write-Output "Processing $_ which is a:-"  
        $computer = "$_"  
        $chassis = Get-WmiObject win32_systemenclosure -computer $computer | select chassistypes  
        if ($chassis.chassistypes -contains '3'){Write-Output "Desktop"}  
        elseif ($chassis.chassistypes -contains '4'){Write-Output "Low Profile Desktop"}  
        elseif ($chassis.chassistypes -contains '5'){Write-Output "Pizza Box"}  
        elseif ($chassis.chassistypes -contains '6'){Write-Output "Mini Tower"}  
        elseif ($chassis.chassistypes -contains '7'){Write-Output "Tower"}  
        elseif ($chassis.chassistypes -contains '8'){Write-Output "Portable"}  
        elseif ($chassis.chassistypes -contains '9'){Write-Output "Laptop"}  
        elseif ($chassis.chassistypes -contains '10'){Write-Output "Notebook"}  
        elseif ($chassis.chassistypes -contains '11'){Write-Output "Hand Held"}  
        elseif ($chassis.chassistypes -contains '12'){Write-Output "Docking Station"}  
        elseif ($chassis.chassistypes -contains '13'){Write-Output "All in One"}  
        elseif ($chassis.chassistypes -contains '14'){Write-Output "Sub Notebook"}  
        elseif ($chassis.chassistypes -contains '15'){Write-Output "Space-Saving"}   
        elseif ($chassis.chassistypes -contains '16'){Write-Output "Lunch Box"}  
        elseif ($chassis.chassistypes -contains '17'){Write-Output "Main System Chassis"}  
        elseif ($chassis.chassistypes -contains '18'){Write-Output "Expansion Chassis"}  
        elseif ($chassis.chassistypes -contains '19'){Write-Output "Sub Chassis"}  
        elseif ($chassis.chassistypes -contains '20'){Write-Output "Bus Expansion Chassis"}  
        elseif ($chassis.chassistypes -contains '21'){Write-Output "Peripheral Chassis"}  
        elseif ($chassis.chassistypes -contains '22'){Write-Output "Storage Chassis"}  
        elseif ($chassis.chassistypes -contains '23'){Write-Output "Rack Mount Chassis"}  
        elseif ($chassis.chassistypes -contains '24'){Write-Output "Sealed-Case PC"}  
        else {Write-output "Unknown"}  
          
                        }  
END{}  
        }  
      
"localhost" | check-chassis
