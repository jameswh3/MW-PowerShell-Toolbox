function Set-AzureSQLServerAccess {
    <#
    .SYNOPSIS
        Configures network access for an Azure SQL Server and adds the current client's public IP address.

    .DESCRIPTION
        This script configures selected network access for an Azure SQL Server by adding the current 
        client's public IP address to the list of allowed clients, if it's not already listed.

    .PARAMETER ResourceGroupName
        The name of the resource group containing the Azure SQL Server.

    .PARAMETER ServerName
        The name of the Azure SQL Server.

    .PARAMETER RuleName
        The name for the firewall rule (defaults to "ClientAccess-" + current date).

    .EXAMPLE
        Set-AzureSQLAccess -ResourceGroupName "MyRG" -ServerName "myserver"
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ResourceGroupName,
        
        [Parameter(Mandatory = $true)]
        [string]$ServerName,
        
        [Parameter(Mandatory = $false)]
        [string]$RuleName = "ClientAccess-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    )

    # Check if user is logged in to Azure
    $context = Get-AzContext
    if (-not $context) {
        Write-Host "Not logged in to Azure. Please run Connect-AzAccount first." -ForegroundColor Red
        Connect-AzAccount -UseDeviceAuthentication
    }

    # Get current public IP address
    Write-Host "Getting current public IP address..." -ForegroundColor Yellow
    $publicIP = (Invoke-RestMethod -Uri "https://api.ipify.org?format=json").ip
    Write-Host "Current public IP: $publicIP" -ForegroundColor Green

    # Get existing firewall rules
    Write-Host "Checking existing firewall rules..." -ForegroundColor Yellow
    $existingRules = Get-AzSqlServerFirewallRule -ResourceGroupName $ResourceGroupName -ServerName $ServerName

    # Check if current IP is already allowed
    $existingRule = $existingRules | Where-Object { 
        $_.StartIpAddress -eq $publicIP -and $_.EndIpAddress -eq $publicIP 
    }

    if ($existingRule) {
        Write-Host "Current IP address $publicIP is already allowed in rule: $($existingRule.FirewallRuleName)" -ForegroundColor Green
    }
    else {
        # Add firewall rule for current IP
        Write-Host "Adding firewall rule for current IP address..." -ForegroundColor Yellow
        $newRule = New-AzSqlServerFirewallRule -ResourceGroupName $ResourceGroupName -ServerName $ServerName -FirewallRuleName $RuleName -StartIpAddress $publicIP -EndIpAddress $publicIP
        Write-Host "Successfully added firewall rule: $($newRule.FirewallRuleName)" -ForegroundColor Green
        Write-Host "IP Address: $($newRule.StartIpAddress)" -ForegroundColor Green
    }

    # Enable public network access
    Write-Host "Enabling public network access..." -ForegroundColor Yellow
    Set-AzSqlServer -ResourceGroupName $ResourceGroupName -ServerName $ServerName -PublicNetworkAccess "Enabled"
    Write-Host "Public network access has been enabled." -ForegroundColor Green

    # Display current firewall rules
    Write-Host "`nCurrent firewall rules:" -ForegroundColor Cyan
    $currentRules = Get-AzSqlServerFirewallRule -ResourceGroupName $ResourceGroupName -ServerName $ServerName
    $currentRules | Format-Table FirewallRuleName, StartIpAddress, EndIpAddress -AutoSize
}
