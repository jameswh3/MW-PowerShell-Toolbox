function Set-AzureBlobStorageAccess {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ResourceGroupName,
        
        [Parameter(Mandatory = $true)]
        [string]$StorageAccountName,
        
        [Parameter(Mandatory = $false)]
        [switch]$Enable
    )
    
    # Check if already connected to Azure
    $context = Get-AzContext
    if ($null -eq $context -or $null -eq $context.Account) {
        Write-Host "No active Azure connection found. Connecting to Azure..."
        Connect-AzAccount -UseDeviceAuthentication
    }

    if ($Enable) {
        Write-Host "Configuring Selected Networks access for Storage Account: $StorageAccountName"
        
        # Get current client's public IP
        
        $clientIP = (Invoke-RestMethod -Uri "https://api.ipify.org" -TimeoutSec 10).Trim()
        Write-Host "Current client IP: $clientIP"
       
        
        # Get current storage account configuration
        $storageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
        $currentRules = $storageAccount.NetworkRuleSet.IpRules
        
        # Check if client IP is already in the allowed list
        $ipExists = $currentRules | Where-Object { $_.IPAddressOrRange -eq $clientIP }
        
        if (-not $ipExists) {
            Write-Host "Adding client IP ($clientIP) to allowed IP addresses"
            # Create new IP rule for client IP
            $newIpRules = @($currentRules)
            $newIpRules += New-Object Microsoft.Azure.Commands.Management.Storage.Models.PSIpRule -Property @{
                IPAddressOrRange = $clientIP
                Action = "Allow"
            }
        }
        else {
            Write-Host "Client IP ($clientIP) is already in the allowed list"
            $newIpRules = $currentRules
        }
        
        # Configure storage account for selected networks
        Set-AzStorageAccount -ResourceGroupName $ResourceGroupName `
            -Name $StorageAccountName `
            -PublicNetworkAccess Enabled `
            -NetworkRuleSet (@{
            DefaultAction = "Deny"
            IpRules = $newIpRules
            VirtualNetworkRules = $storageAccount.NetworkRuleSet.VirtualNetworkRules
            Bypass = $storageAccount.NetworkRuleSet.Bypass
            })
        
        Write-Host "Storage account configured for selected networks access"
    } else {
        Write-Host "Disabling Public Network Access for Storage Account: $StorageAccountName"
        Set-AzStorageAccount -ResourceGroupName $ResourceGroupName `
            -Name $StorageAccountName `
            -PublicNetworkAccess Disabled
    }

    Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName | `
        Select-Object -Property Id, PublicNetworkAccess
}
