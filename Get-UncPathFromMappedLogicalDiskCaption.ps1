[CmdletBinding()]
Param (
  [parameter(mandatory)]
  [string]$LetterString
)

(Get-WmiObject -Class Win32_MappedLogicalDisk | ? { $_.Caption -eq $LetterString }).ProviderName
