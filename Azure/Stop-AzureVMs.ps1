function Stop-AzureVMs {
    <#
    .SYNOPSIS
        Stops all virtual machines in a specified Azure resource group.
    
    .DESCRIPTION
        This function stops all virtual machines within a given Azure resource group.
        It requires the Az PowerShell module and an active Azure session.
    
    .PARAMETER ResourceGroupName
        The name of the Azure resource group containing the VMs to stop.
    
    .PARAMETER SubscriptionId
        Optional. The Azure subscription ID. If not provided, uses the current context.
    
    .EXAMPLE
        Stop-AzureVMs -ResourceGroupName "MyResourceGroup"
        
    .EXAMPLE
        Stop-AzureVMs -ResourceGroupName "MyResourceGroup" -SubscriptionId "12345678-1234-1234-1234-123456789012"
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ResourceGroupName,
        
        [Parameter(Mandatory = $false)]
        [string]$SubscriptionId
    )
    
    try {
        # Set subscription context if provided
        if ($SubscriptionId) {
            Write-Output "Setting subscription context to: $SubscriptionId"
            Set-AzContext -SubscriptionId $SubscriptionId
        }
        
        # Get all VMs in the resource group
        Write-Output "Getting VMs in resource group: $ResourceGroupName"
        $vms = Get-AzVM -ResourceGroupName $ResourceGroupName
        
        if ($vms.Count -eq 0) {
            Write-Warning "No VMs found in resource group: $ResourceGroupName"
            return
        }
        
        Write-Output "Found $($vms.Count) VM(s) in resource group: $ResourceGroupName"
        
        # Stop each VM
        foreach ($vm in $vms) {
            Write-Output "Stopping VM: $($vm.Name)"
            Stop-AzVM -ResourceGroupName $ResourceGroupName -Name $vm.Name -Force -NoWait
        }
        
        Write-Output "Stop commands sent for all VMs in resource group: $ResourceGroupName"
        Write-Output "Use Get-AzVM to check the status of the VMs."
        
    }
    catch {
        Write-Error "Error stopping VMs: $($_.Exception.Message)"
    }
}