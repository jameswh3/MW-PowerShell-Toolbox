<#
.SYNOPSIS
    Retrieves raw licensing information for an Entra ID user.

.DESCRIPTION
    This script retrieves detailed licensing information for a specified Entra ID user,
    including assigned license SKUs, service plans, and their status without mapping SKU IDs to friendly names.

.PARAMETER UserPrincipalName
    The UserPrincipalName of the Entra ID user to query.

.PARAMETER OutputFormat
    The format to output results. Valid values are 'Host' (default) or 'Object'.
    Use 'Object' to return raw objects for pipeline processing.

.EXAMPLE
    .\Get-EntraUserLicenseInfo.ps1 -UserPrincipalName "user@contoso.com"
    
    Retrieves raw license information for the specified user and displays it.

.EXAMPLE
    .\Get-EntraUserLicenseInfo.ps1 -UserPrincipalName "user@contoso.com" -OutputFormat Object | Export-Csv -Path "UserLicenses.csv" -NoTypeInformation
    
    Retrieves raw license information and exports it to a CSV file.

.NOTES
    Requires Microsoft Graph PowerShell SDK modules:
    - Microsoft.Graph.Authentication
    - Microsoft.Graph.Users
    
    Required permissions:
    - User.Read.All or Directory.Read.All
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$UserPrincipalName,
    
    [Parameter(Mandatory = $false)]
    [ValidateSet('Host', 'Object')]
    [string]$OutputFormat = 'Host'
)

function Connect-MgGraphIfNeeded {
    try {
        $context = Get-MgContext -ErrorAction Stop
        if (-not $context) {
            throw "No existing connection found"
        }
        Write-Verbose "Using existing Microsoft Graph connection"
    }
    catch {
        Write-Verbose "Connecting to Microsoft Graph..."
        Connect-MgGraph -Scopes "User.Read.All", "Directory.Read.All" -ErrorAction Stop
    }
}

function Format-ServicePlanStatus {
    param (
        [string]$Status
    )

    switch ($Status) {
        "Success" { return "Enabled" }
        "Disabled" { return "Disabled" }
        "PendingInput" { return "Pending Input" }
        "PendingActivation" { return "Pending Activation" }
        "Error" { return "Error" }
        default { return $Status }
    }
}

# Main script execution
try {
    # Check for required modules
    $requiredModules = @("Microsoft.Graph.Authentication", "Microsoft.Graph.Users")
    foreach ($module in $requiredModules) {
        if (-not (Get-Module -ListAvailable -Name $module)) {
            Write-Error "Required module $module is not installed. Please install it using: Install-Module $module -Scope CurrentUser"
            return
        }
    }

    # Connect to Microsoft Graph if not already connected
    Connect-MgGraphIfNeeded

    # Get user information
    $user = Get-MgUser -UserId $UserPrincipalName -Property "displayName,userPrincipalName,assignedLicenses" -ErrorAction Stop
    
    if (-not $user) {
        Write-Error "User not found: $UserPrincipalName"
        return
    }

    # Get detailed license information
    $licenseDetails = Get-MgUserLicenseDetail -UserId $UserPrincipalName -ErrorAction Stop

    if ($OutputFormat -eq 'Object') {
        # Return license details as objects for pipeline processing
        $results = @()
        
        foreach ($license in $licenseDetails) {
            foreach ($servicePlan in $license.ServicePlans) {
                $results += [PSCustomObject]@{
                    UserPrincipalName = $user.UserPrincipalName
                    DisplayName = $user.DisplayName
                    SkuId = $license.SkuId
                    SkuPartNumber = $license.SkuPartNumber
                    ServicePlanId = $servicePlan.ServicePlanId
                    ServicePlanName = $servicePlan.ServicePlanName
                    ProvisioningStatus = $servicePlan.ProvisioningStatus
                }
            }
        }
        
        return $results
    }
    else {
        # Display license information in the console
        Write-Host "`n==== License Information for $($user.DisplayName) ($($user.UserPrincipalName)) ====`n" -ForegroundColor Cyan

        if (-not $licenseDetails -or $licenseDetails.Count -eq 0) {
            Write-Host "This user has no licenses assigned." -ForegroundColor Yellow
            return
        }

        Write-Host "Assigned Licenses: $($licenseDetails.Count)" -ForegroundColor Green

        foreach ($license in $licenseDetails) {
            Write-Host "`n- SKU: $($license.SkuPartNumber)" -ForegroundColor Yellow
            Write-Host "  SKU ID: $($license.SkuId)"
            
            Write-Host "`n  Service Plans:" -ForegroundColor Green
            
            foreach ($servicePlan in $license.ServicePlans) {
                $status = Format-ServicePlanStatus -Status $servicePlan.ProvisioningStatus
                $statusColor = if ($status -eq "Enabled") { "Green" } elseif ($status -eq "Disabled") { "Red" } else { "Yellow" }
                
                Write-Host "  - $($servicePlan.ServicePlanName) [$($servicePlan.ServicePlanId)]" -NoNewline
                Write-Host " [$status]" -ForegroundColor $statusColor
            }
        }
    }
} 
catch {
    Write-Error "An error occurred: $_"
    Write-Error $_.Exception.StackTrace
}