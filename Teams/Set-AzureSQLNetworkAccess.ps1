# Azure SQL Server Network Access Configuration Script
param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory=$true)]
    [string]$ServerName,
    
    [Parameter(Mandatory=$false)]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory=$false)]
    [string]$RuleName = "LocalClientAccess"
)

try {
    # Set subscription if provided
    if ($SubscriptionId) {
        Set-AzContext -SubscriptionId $SubscriptionId
    }

    # Verify authentication
    $context = Get-AzContext
    if (-not $context) {
        Write-Host "Not authenticated to Azure. Connecting using device authentication..." -ForegroundColor Yellow
        Connect-AzAccount -UseDeviceAuthentication
        Write-Host "Authentication successful!" -ForegroundColor Green
    }

    # Get public IP
    Write-Host "Getting public IP..." -ForegroundColor Yellow
    $publicIP = (Invoke-RestMethod -Uri "https://ipinfo.io/ip").Trim()
    Write-Host "Public IP: $publicIP" -ForegroundColor Green

    # Verify SQL Server exists and configure network access
    Write-Host "Configuring SQL Server..." -ForegroundColor Yellow
    Set-AzSqlServer -ResourceGroupName $ResourceGroupName -ServerName $ServerName -PublicNetworkAccess "Enabled"

    # Create or update firewall rule (New-AzSqlServerFirewallRule updates if exists)
    Write-Host "Adding/updating firewall rule..." -ForegroundColor Yellow
    New-AzSqlServerFirewallRule -ResourceGroupName $ResourceGroupName -ServerName $ServerName -FirewallRuleName $RuleName -StartIpAddress $publicIP -EndIpAddress $publicIP -Force

    Write-Host "Complete! IP $publicIP can now access SQL Server '$ServerName'" -ForegroundColor Green
}
catch {
    Write-Error "Error: $_"
    exit 1
}
