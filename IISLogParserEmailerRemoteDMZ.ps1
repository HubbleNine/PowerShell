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
#>

#Credentials for PSSession - use securePassword to create password file with key on the target server
#Must have enabled PSRemoting for this on the target computer and host computer using the 'Enable-PSRemoting' commandlet
[Byte[]] $key = (24 digit array, seperated by commas or set a range)
$Pass = Get-Content "C:\Users\Administrator\Documents\THing\Stuff\Pass.txt" | ConvertTo-SecureString -Key $key
$Cred = New-Object -TypeName System.Management.Automation.PSCredential ("<servername>\Administrator", $Pass)

#Start PSSession with credentials above and run the commands in -ScriptBlock
Invoke-Command -ComputerName <servername> -Credential $Cred -ScriptBlock {

#Variables for sending email through O365 - use securePassword to create password file with key on the target server
[Byte[]] $key = (24 digit array, seperated by commas or set a range)
$smtpPass = Get-Content "C:\Users\Administrator\Documents\THing\Stuff\Pass.txt" | ConvertTo-SecureString -Key $key
$smtpCred = New-Object -TypeName System.Management.Automation.PSCredential ("email@email.com", $smtpPass)
$ToAddress = 'email@email.com'
$FromAddress = 'email@email.com'
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
    #$IISLog | select @{n="Time"; e={Get-Date -Format "HH:mm:ss"("$($_.time)")}} | ? { $_.time -ge $time }
    

    #Format Log data into string for sending
    $BodyString = ""
    foreach( $Row in $IISLog.Rows ){
        $BodyString = $BodyString + $Row.date + " " + $Row.time + " " + $Row.sip + " " + $Row.csmethod + " " + $Row.csuristem + " " + $Row.csuriquery + " " + $Row.cip + " " + $Row.csreferer + " " + $Row.scstatus + " " + $Row.scsubstatus + " " + $Row.scwin32status + " " + $Row.timetaken + " " + "`n"
    }

    #Send email with log entries found
    Send-MailMessage -To $ToAddress -From $FromAddress -Subject 'IIS Log Alert' -Body $BodyString -SmtpServer $SmtpServer -Port $SmtpPort -Credential $smtpCred -UseSsl
} else {
    exit
}
}
