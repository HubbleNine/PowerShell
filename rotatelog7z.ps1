<# 
Title: rotatelog7z.ps1
Author: Me | Senior Infrastructure Engineer
Date: 08/30/2018
Version: 1.0

This script is designed to go through a designated folder, find files with the .log extension and are older than 7 days, then uses 7-zip to compress these files into an
archive folder. Use/changes variables to modify script to suit the purposes of archiving the logs on your server. Remove and change between brackets [] to use.
#>

#Check if 7-Zip is installed
if (-not (Test-Path "$env:ProgramFiles\7-Zip\7z.exe")) {
    Write-Host "$env:ProgramFiles\7-Zip\7z.exe needed"
 }

#Set alias for 7-Zip
Set-Alias sz "$env:ProgramFiles\7-Zip\7z.exe"

#Set some variables
$LogPath = "[folder path to your log files]"
$LogNewPath = "[folder path to where to put your archives]"
$ArchiveDate = (Get-Date).AddDays(-7)
$LclServerName = $env:COMPUTERNAME
$s = New-Object System.Security.SecureString
$creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "NT AUTHORITY\ANONYMOUS LOGON", $S

#Set up SMTP stuff
$SMTPServer = "[your SMTP server]"
$MailFrom = "logrotate@[yourdomain].com"
$MailTo = "[email to this addy]"
$MailCc = "[CC this other addy]"
$MailSubject= "[your service/server] Log Rotation Service on $LclServerName"
$MailBodySuccess = "Log rotation is complete on $LclServerName."
$MailBodyFailure = "Log rotation has failed on $LclServerName."

#Magic time...
Get-ChildItem $LogPath -File | ForEach-Object {
    if ($_.LastWriteTime -lt $ArchiveDate -and $_.Extension -eq '.log') {
        ForEach-Object {
            $FilePath = $_.FullName.ToString();
            $FileName = $_.Name.ToString();
            $ZipPath = "$LogNewPath\$FileName.7z"
            sz a -mx=9 -t7z $ZipPath $FilePath
            if ($LastExitCode -eq 0) {
                Remove-Item $FilePath
                Send-MailMessage -To $MailTo -Cc $MailCc -From $MailFrom -Subject $MailSubject -SmtpServer $SMTPServer -Body ($MailBodySuccess + " $FilePath has been archived.") -BodyAsHtml -Credential $creds
            } else {
                Send-MailMessage -To $MailTo -Cc $MailCc -From $MailFrom -Subject $MailSubject -SmtpServer $SMTPServer -Body ($MailBodyFailure + " Failed to archive $FilePath with error code: $LastExitCode") -BodyAsHtml -Credential $creds
            }
        }
    }
}
