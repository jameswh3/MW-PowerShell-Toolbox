function Start-AzureVMs {
    <#
    .SYNOPSIS
        Starts all virtual machines in a specified Azure resource group.
    
    .DESCRIPTION
        This function starts all virtual machines within a given Azure resource group.
        It requires the Az PowerShell module and an active Azure session.
    
    .PARAMETER ResourceGroupName
        The name of the Azure resource group containing the VMs to start.
    
    .PARAMETER SubscriptionId
        Optional. The Azure subscription ID. If not provided, uses the current context.
    
    .EXAMPLE
        Start-AzureVMs -ResourceGroupName "MyResourceGroup"
        
    .EXAMPLE
        Start-AzureVMs -ResourceGroupName "MyResourceGroup" -SubscriptionId "12345678-1234-1234-1234-123456789012"
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
        
        # Start each VM
        foreach ($vm in $vms) {
            Write-Output "Starting VM: $($vm.Name)"
            Start-AzVM -ResourceGroupName $ResourceGroupName -Name $vm.Name -NoWait
        }
        
        Write-Output "Start commands sent for all VMs in resource group: $ResourceGroupName"
        Write-Output "Use Get-AzVM to check the status of the VMs."
        
    }
    catch {
        Write-Error "Error starting VMs: $($_.Exception.Message)"
    }
}