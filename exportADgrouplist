Import-Module ActiveDirectory

# Show-SaveFileDialog Function
function Show-SaveFileDialog {
	param (
		[string]$InitialDirectory,
		
		[string]$Filter,
		
		[string]$Title,
		
		[string]$FileName,
		
		[System.Windows.Forms.IWin32Window]$Owner
	)
	
	# Create and configure dialog
	$saveFileDialog = New-Object 'System.Windows.Forms.SaveFileDialog'
	if ($InitialDirectory) { $saveFileDialog.InitialDirectory = $InitialDirectory }
	if ($Filter) { $saveFileDialog.Filter = $Filter }
	if ($Title) { $saveFileDialog.Title = $Title }
	if ($FileName) { $saveFileDialog.FileName = $FileName }
	
	# Show dialog
	$result = $saveFileDialog.ShowDialog($Owner)
	
	# Output results
	if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
		return $saveFileDialog.FileName
	}
	else {
		return $null
	}
} 


[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic")

$groupName = [Microsoft.VisualBasic.Interaction]::InputBox("Please type the desired group name", "Group Name")

$fileName = Show-SaveFileDialog - Title 'File Name' -Filter "CSV file (*.csv)| *.csv"   

#replace 'name of group' with the security group you want to export, replace 
#'username' with your username, replace 'groupmemebers.csv' with the group you're 
#exporting with the .csv extension.
Get-ADGroupMember -identity $groupName | select name | Export-csv -path $fileName -NoTypeInformation
