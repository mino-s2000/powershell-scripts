# Authority: https://kogelog.com/2016/10/18/20161018-01/
# Execute Run-As-Admin.

Set-WinUILanguageOverride -Language ja-JP
Set-WinCultureFromLanguageListOptOut -OptOut $False
Set-WinHomeLocation -GeoId 0x7A
Set-WinSystemLocale -SystemLocale ja-JP
Set-TimeZone -Id "Tokyo Standard Time"
Restart-Computer
