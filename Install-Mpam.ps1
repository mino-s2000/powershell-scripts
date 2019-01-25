$mpamProcessName = "mpam-fe"
$mpamFileName = "$($mpamProcessName).exe"

Write-Host "Download mpam."
wget "https://go.microsoft.com/fwlink/?LinkID=121721&arch=x64" -O "$mpamFileName"

Write-Host "Execute $($mpamFileName)"
$mpamProcess = Start-Process .\$mpamFileName -PassThru

Write-Host "Wait process: $($mpamProcessName)"
Wait-Process -InputObject $mpamProcess

Write-Host "Delete file: $($mpamFileName)"
Remove-Item -Force $mpamFileName

Write-Host "Complete."
