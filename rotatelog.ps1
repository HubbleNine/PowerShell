# Set up SMTP stuff
$SMTPServer = "ex2010b.gilsbar.int"
$MailFrom = "~IT Notification <it-notification@gilsbar.com>"
$MailTo = "acelestin@gilsbar.com"
$MailSubject= "EDDM Log Rotation Service on MLCSECURE3"
$MailBodySuccess = "Log rotation is complete on MLCSECURE3.  Below is a listing of the file(s) added to the zip archive.<br><br>"
#$MailBodyFailure = "Log rotation is complete, but there may be a problem with the zip file."


# Put today's date into a simple format for use in file naming
$currentdate = get-date -Format yyyyMMdd

# Move the log file to the working folder
move-item "C:\Program Files\Matrix Logic\Secure\SecureEngineLog.txt" ("C:\scripts\hblog\$currentdate.txt")

# First we add the .Net framework class needed for file compression.
Add-Type -As System.IO.Compression.FileSystem
 
# Then we need a variable of the type System.IO.Compression.CompressionLevel. 
# The options for compression level are "Fastest", "Optimal" and "NoCompression".
[System.IO.Compression.CompressionLevel]$compression = "Optimal"
 
# Which file do you want to compress?
$file = "C:\scripts\hblog\$currentdate.txt"
 
# Set the path to where you want the zip file to be created.
$zippath = 'C:\scripts\hblog\SecureEngineLog.zip'
 
# Open the zip file and set the mode. Options for mode are "Create", "Read" and "Update".
$ziparchive = [System.IO.Compression.ZipFile]::Open( $zippath, "Update" )
 
# The compression function likes relative file paths, so lets do that.
$relativefilepath = (Resolve-Path $file -Relative).TrimStart(".\")
 
# This is where the magic happens. 
# TODO: Add try/catch, then send success email if success, or failure email if failure.  Both emails should include zip contents.
# Compress the file with the variables you just created as parameters.
$null = [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($ziparchive, $file, $relativefilepath, $compression)

# Release the zip file. 
# Otherwise the file will still be in read only if you are using Powershell ISE.
$ziparchive.Dispose()

# Test by listing the .txt file in the archive that matches today's date, with size, timestamp, etc
# If we see zero length files or anything else weird, the archive may be corrupt
# Open the zip archive again, this time in "Read" mode
$ziparchive = [System.IO.Compression.ZipFile]::Open( $zippath, "Read" )

# find the log file (zip archive entry) that has today's date and put some of its properties in an array that we'll insert into the body of the success email
$array = @()

ForEach ($entry in $ziparchive.Entries) {

    if ($entry.Name.Contains($currentdate)) {

        #$entry | select Name,LastWriteTime,Length,CompressedLength
        #$array += $entry | select Name,LastWriteTime,Length,CompressedLength
        $array += New-Object psobject -Property @{

            Name = $entry.Name
            LastWriteTime = $entry.LastWriteTime
            Length = $entry.Length
            CompressedLength = $entry.CompressedLength
        }
           
    }
}

$htmlstr = $array | ConvertTo-Html 

# Send email notification

# Generate anonymous login
$s = New-Object System.Security.SecureString
$creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "NT AUTHORITY\ANONYMOUS LOGON", $S

# Send the email
Send-MailMessage -To $MailTo -From $MailFrom -Subject $MailSubject -SmtpServer $SMTPServer -Body ($MailBodySuccess + $htmlstr) -BodyAsHtml -Credential $creds

# Release the zip file (again)
$ziparchive.Dispose()

# Delete copied file
Remove-Item $file
