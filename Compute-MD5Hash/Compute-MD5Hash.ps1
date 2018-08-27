param(
    [Parameter(Mandatory)]
    [string]$FilePath
)

$data = (New-Object IO.StreamReader $FilePath).BaseStream
$md5 = [System.Security.Cryptography.MD5]::create()
Write-Output [System.BitConverter]::ToString($md5.ComputeHash($data)).ToLower().Replace("-", "")
