workflow StartStop-AzureVMs
{
    param (
        [parameter(mandatory)]
        [string]$ResourceGroupName,
        [parameter(mandatory)]
        [bool]$Stop
    )

    # Please changed your Connection Name.
    $connectionName = "AzureRunAsConnection"
    try {
        $servicePrincipalConnection = Get-AutomationConnection -Name $connectionName

        "Logging in to Azure..."
        Add-AzureRmAccount -ServicePrincipal -TenantId $servicePrincipalConnection.TenantId -ApplicationId $servicePrincipalConnection.ApplicationId -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint
    } catch {
        if (!$servicePrincipalConnection) {
            $ErrorMessage = "Connection $connectionName not found."
            throw $ErrorMessage
        } else {
            Write-Error -Message $_.Exception
            throw $_.Exception
        }
    }

    $vms = Get-AzureRmVM -ResourceGroupName $ResourceGroupName | Select-Object -ExpandProperty name

    # Start VMs
    if ($vms) {
        Foreach -parallel ($vm in $vms) {
            if ($Stop) {
                Write-Output "[$(Get-Date -Format "yyyy/MM/dd HH:mm:ss")] Stop VM. Target: $vm"
                $result = Stop-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $vm -Force -ErrorAction SilentlyContinue
            } else {
                Write-Output "[$(Get-Date -Format "yyyy/MM/dd HH:mm:ss")] Start VM. Target: $vm"
                $result = Start-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $vm -ErrorAction SilentlyContinue
            }
            Write-Output "[$(Get-Date -Format "yyyy/MM/dd HH:mm:ss")] $result"
            Write-Output "[$(Get-Date -Format "yyyy/MM/dd HH:mm:ss")] Completed. Target: $vm"
        }
    } else {
        Write-Output "[$(Get-Date -Format "yyyy/MM/dd HH:mm:ss")] No VMs were found in your resource group."
    }
    Write-Output "Runbook complete."
}
