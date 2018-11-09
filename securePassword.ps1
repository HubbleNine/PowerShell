<#
Title: securePassword.ps1
Used to create an encrypted password file for use on remote computers for credentials to login or execute other remote functions
#>

[Byte[]] $key = (array of 24 numbers, use range or delimit with commas)
$file = "C:\Pass.txt"
$password = "Password" | ConvertTo-SecureString -AsPlainText -Force
$password | ConvertFrom-SecureString -Key $key | Out-File $file
