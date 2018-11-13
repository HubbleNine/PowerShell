<#
Title: IISLogParserEmailerRemoteDMZ.ps1
Author: Me (and some internet people)
Job: Senior Network Engineer
Date: 11/08/2018
Use in junction with SecurePassword.ps1 script for credentials
Used to parse through IIS logs and find particular errors, compile them into an array and then send them via email to designated addresses
Can be reworked for most log files
Where <servername> exists, replace with target server/computer name
Where email@email.com, replace with desired auth email, from and to email addresses
Must enable WinRM and use these settings:
*Run Enable-PSRemoting on the server machine
**You can verify this by running winrm enumerate winrm/config/listener
*It will enable the Windows Remote Management firewall rules
*It will create and configure the LocalAccountTokenFilterPolicy registry key
*It will reset the permissions on the four sessions hosts
**You can verify this by running Get-PSSessionConfiguration
*Start the WinRM service on the client machine
*Run Set-Item WSMan:\localhost\Client\TrustedHosts -Value <hostname or FQDN or server>
**You can add -Concatenate to the end of Set-Item if you're trying to add a server to the list
#>

#Credentials for PSSession - use securePassword to create password file with key on the target server
#Must have enabled PSRemoting for this on the target computer and host computer using the 'Enable-PSRemoting' commandlet
#Example key: [Byte[]] $key = (23,6,9,14,91,354,29,5,93,128,64,37,23,6,9,14,91,354,29,5,93,128,64,37)
[Byte[]] $key = (<#24 digit array, seperated by commas#>)
$Pass = Get-Content "C:\Users\Administrator\Documents\THing\Stuff\Pass.txt" | ConvertTo-SecureString -Key $key
$Cred = New-Object -TypeName System.Management.Automation.PSCredential ("<servername>\Administrator", $Pass)

#Start PSSession with credentials above and run the commands in -ScriptBlock
Invoke-Command -ComputerName <#servername#> -Credential $Cred -ScriptBlock {

#Accounting for W3C being in GMT, check set time increment for the last half hour
$time = (Get-Date -Format "HH:mm:ss"(Get-Date).addminutes(330))

#Variables for sending email through O365 - use securePassword to create password file with key on the target server
[Byte[]] $key = (24 digit array, seperated by commas)
$smtpPass = Get-Content "C:\Users\Administrator\Documents\THing\Stuff\Pass.txt" | ConvertTo-SecureString -Key $key
$smtpCred = New-Object -TypeName System.Management.Automation.PSCredential ("email@email.com", $smtpPass)
$ToAddress = 'email@email.com'
$FromAddress = 'email@email.com'
$BodyString = "Please see attached for current HTTP 500 Errors"
$SmtpServer = 'smtp.office365.com'
$SmtpPort = '587'

# Directory of IIS log files
# This is currently set to look at the Default website, change to desired website log repository
$Path = "C:\inetpub\logs\LogFiles\W3SVC1"

#Get the most recent log file from the directory
$File = Get-ChildItem $Path | sort LastWriteTime | select -last 1

# Get-Content gets the file, pipe to Where-Object and skip the first 3 lines.
$Log = Get-Content $File.FullName | where {$_ -notLike "#[D,S-V]*"}

# Replace unwanted text in the line containing the columns.
$Columns = (($Log[0].TrimEnd()) -replace "#Fields: ", "" -replace "-","" -replace "\(","" -replace "\)","").Split(" ")

# Count available Columns, used later
$Count = $Columns.Length

# Get all Rows that I want to retrieve
# Replace contents of query string with desired error codes
# Good article for interpreting IIS logs: https://stackify.com/how-to-interpret-iis-logs/
$QueryString = "*502 3 64*"
$Rows = $Log | where {$_ -like $QueryString}

# Create an instance of a System.Data.DataTable
$IISLog = New-Object System.Data.DataTable "IISLog"

#Checks if the array is empty or not
if ($Rows.Count -gt 0) {

    # Loop through each Column, create a new column through Data.DataColumn and add it to the DataTable
    foreach ($Column in $Columns) {
      $NewColumn = New-Object System.Data.DataColumn $Column, ([string])
      $IISLog.Columns.Add($NewColumn)
      }


    # Loop Through each Row and add the Rows.
    foreach ($Row in $Rows) {
       $Row = $Row.Split(" ")
      $AddRow = $IISLog.newrow()
      for($i=0;$i -lt $Count; $i++) {
        $ColumnName = $Columns[$i]
        $AddRow.$ColumnName = $Row[$i]
      }
       $IISLog.Rows.Add($AddRow)
    }
    #Format Log data and increment over time so as to not repeat log alerts - Comment out if using the non-time-incremental method below
    $IISLog | select @{n="DateTime"; e={Get-Date ("$($_.date) $($_.time)")}},date,time,sip,csmethod,csuristem,csuriquery,cip,csreferer,scstatus,scsubstatus,scwin32status,timetaken | ? { $_.DateTime -ge $time } |Out-File C:\Users\Administrator\Documents\THing\Stuff\$_results.csv
    

    #Format Log data into string for sending - Uncomment if not wanting to increment over time
    #$BodyString = ""
    #foreach( $Row in $IISLog.Rows ){
    #    $BodyString = $BodyString + $Row.date + " " + $Row.time + " " + $Row.sip + " " + $Row.csmethod + " " + $Row.csuristem + " " + $Row.csuriquery + " " + $Row.cip + " " + $Row.csreferer + " " + $Row.scstatus + " " + $Row.scsubstatus + " " + $Row.scwin32status + " " + $Row.timetaken + " " + "`n"
    #}
    
    #Write CSV contents to a variable - Comment out if using the non-time-incremental method below
    $importResults = @(Import-Csv 'C:\Users\Administrator\Documents\THing\Stuff\.csv')
    
    #Checks if CSV is empty or not, sends email if there are contents -Comment out 'if' statement and attachement variable if using the non-time-incremental method below, keep 
    if ($importResults.Length -gt 0) {

        $Attachment = 'C:\Users\Administrator\Documents\THing\Stuff\.csv'

        #Send email with log entries found - Remove '-Attachments $Attachment' if using non-time-incremental method
        Send-MailMessage -To $ToAddress -From $FromAddress -Subject 'IIS Log Alert' -Body $BodyString -Attachments $Attachment -SmtpServer $SmtpServer -Port $SmtpPort -Credential $smtpCred -UseSsl
    } else {
        exit
        }
} else {
    exit
    }
}
