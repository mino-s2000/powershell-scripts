[CmdletBinding()]
param(
    [parameter(mandatory)]
    [string]$WsusServerFqdn,
    [parameter(mandatory)]
    [pscredential]$WsusCred,
    [parameter(mandatory)]
    [string]$TargetDate
)


$sdate = Get-Date $TargetDate -Format "yyyy-MM-dd HH:mm:ss.fff"
$edate = Get-Date ((Get-Date $TargetDate).AddDays(1).AddMilliseconds(-1)) -Format "yyyy-MM-dd HH:mm:ss.fff"

$queryBaseStr = @"
select MoreInfoURL from dbo.tbMoreInfoURLForRevision
where ShortLanguage = 'en'
and RevisionID in (
    select RevisionID from dbo.tbRevision
    where LocalUpdateID in (
        select LocalUpdateID from dbo.tbUpdate where ImportedTime between convert(datetime, '{0}', 121) and convert(datetime, '{1}', 121)
    )
)
group by MoreInfoURL
order by MoreInfoURL
"@
$queryStr = $queryBaseStr -f $sdate, $edate

if (Test-Connection -ComputerName $WsusServerFqdn -Quiet) {
    $urlList = Invoke-Command -ComputerName $WsusServerFqdn -Credential $WsusCred -HideComputerName -ArgumentList $queryStr -ScriptBlock {
        $connection = New-Object -TypeName System.Data.SqlClient.SqlConnection
        $connection.ConnectionString = "Data Source=\\.\pipe\MICROSOFT##WID\tsql\query;Initial Catalog=SUSDB;Integrated Security=true;"
        $command = $connection.CreateCommand()
        $command.CommandText = $args[0]
        $adapter = New-Object -TypeName System.Data.SqlClient.SqlDataAdapter $command
        $dataset = New-Object -TypeName System.Data.DataSet
        $tmp = $adapter.Fill($dataset)
        ($dataset.Tables[0]).MoreInfoURL
    }
    Write-Output $urlList
} else {
    Write-Error "Connection failed. Target: $($WsusServerFqdn)"
}
