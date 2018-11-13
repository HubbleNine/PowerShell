function get-timezone 
{ 
[cmdletbinding()] 
param([string]$Name)
([system.timezoneinfo]::GetSystemTimeZones() | where { $_.ID}) 
}

get-timezone
