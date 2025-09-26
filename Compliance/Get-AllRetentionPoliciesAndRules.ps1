<#
.SYNOPSIS
    Lists all Microsoft 365 retention policies with their scopes and settings
.DESCRIPTION
    This script connects to Exchange Online and Security & Compliance Center to retrieve
    all retention policies and their detailed configuration including scopes and settings.
    Displays results in formatted tables for better readability.
.NOTES
    Requires ExchangeOnlineManagement PowerShell module
    Requires appropriate admin permissions (Security Admin, Compliance Admin, or Global Admin)
#>

# Import required modules
Import-Module ExchangeOnlineManagement -ErrorAction SilentlyContinue

# Connect to Exchange Online (this will prompt for authentication)
Write-Host "Connecting to Exchange Online..." -ForegroundColor Green
Connect-ExchangeOnline

# Connect to Security & Compliance Center
Write-Host "Connecting to Security & Compliance Center..." -ForegroundColor Green
Connect-IPPSSession

try {
    # Get all retention policies
    Write-Host "Retrieving retention policies..." -ForegroundColor Yellow
    $retentionPolicies = Get-RetentionCompliancePolicy
    
    if ($retentionPolicies) {
        Write-Host "`nFound $($retentionPolicies.Count) retention policies:" -ForegroundColor Green
        
        # Display policies overview in table format
        Write-Host "`nRetention Policies Overview:" -ForegroundColor Cyan
        $retentionPolicies | Format-Table -Property Name, Enabled, Mode, DistributionStatus, WhenCreated -AutoSize
        
        # Create detailed data for comprehensive table
        $detailedData = @()
        
        foreach ($policy in $retentionPolicies) {
            # Get retention rules for this policy
            $retentionRules = Get-RetentionComplianceRule -Policy $policy.Name
            
            if ($retentionRules) {
                foreach ($rule in $retentionRules) {
                    $detailedData += [PSCustomObject]@{
                        PolicyName = $policy.Name
                        RuleName = $rule.Name
                        Enabled = $policy.Enabled
                        Mode = $policy.Mode
                        RetentionDays = $rule.RetentionDuration
                        RetentionAction = $rule.RetentionComplianceAction
                        ExchangeLocations = if ($policy.ExchangeLocation) { ($policy.ExchangeLocation -join '; ') } else { "None" }
                        SharePointLocations = if ($policy.SharePointLocation) { ($policy.SharePointLocation -join '; ') } else { "None" }
                        OneDriveLocations = if ($policy.OneDriveLocation) { ($policy.OneDriveLocation -join '; ') } else { "None" }
                        TeamsChannels = if ($policy.TeamsChannelLocation) { ($policy.TeamsChannelLocation -join '; ') } else { "None" }
                        TeamsChats = if ($policy.TeamsChatLocation) { ($policy.TeamsChatLocation -join '; ') } else { "None" }
                        ContentQuery = if ($rule.ContentMatchQuery) { $rule.ContentMatchQuery } else { "All Content" }
                    }
                }
            } else {
                # Policy without rules
                $detailedData += [PSCustomObject]@{
                    PolicyName = $policy.Name
                    RuleName = "No Rules"
                    Enabled = $policy.Enabled
                    Mode = $policy.Mode
                    RetentionDays = "N/A"
                    RetentionAction = "N/A"
                    ExchangeLocations = if ($policy.ExchangeLocation) { ($policy.ExchangeLocation -join '; ') } else { "None" }
                    SharePointLocations = if ($policy.SharePointLocation) { ($policy.SharePointLocation -join '; ') } else { "None" }
                    OneDriveLocations = if ($policy.OneDriveLocation) { ($policy.OneDriveLocation -join '; ') } else { "None" }
                    TeamsChannels = if ($policy.TeamsChannelLocation) { ($policy.TeamsChannelLocation -join '; ') } else { "None" }
                    TeamsChats = if ($policy.TeamsChatLocation) { ($policy.TeamsChatLocation -join '; ') } else { "None" }
                    ContentQuery = "N/A"
                }
            }
        }
        
        # Display detailed information in table format
        Write-Host "`nDetailed Retention Policy Configuration:" -ForegroundColor Cyan
        $detailedData | Format-Table -Property PolicyName, RuleName, Enabled, RetentionDays, RetentionAction -AutoSize
        
        Write-Host "`nLocation Scopes:" -ForegroundColor Cyan
        $detailedData | Format-Table -Property PolicyName, ExchangeLocations, SharePointLocations, OneDriveLocations -Wrap
        
        Write-Host "`nTeams and Content Settings:" -ForegroundColor Cyan
        $detailedData | Format-Table -Property PolicyName, TeamsChannels, TeamsChats, ContentQuery -Wrap
        
        # Export to CSV for further analysis
        $csvPath = "M365_RetentionPolicies_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
        $detailedData | Export-Csv -Path $csvPath -NoTypeInformation
        Write-Host "`nData exported to: $csvPath" -ForegroundColor Green
        
    } else {
        Write-Host "No retention policies found." -ForegroundColor Red
    }
    
} catch {
    Write-Error "An error occurred: $($_.Exception.Message)"
} finally {
    # Disconnect sessions
    Write-Host "`nDisconnecting sessions..." -ForegroundColor Yellow
    Disconnect-ExchangeOnline -Confirm:$false
    
    # Check if Disconnect-IPPSSession cmdlet exists before trying to use it
    if (Get-Command Disconnect-IPPSSession -ErrorAction SilentlyContinue) {
        Disconnect-IPPSSession -Confirm:$false
    } else {
        Write-Host "Note: Security & Compliance Center session is managed by Exchange Online connection" -ForegroundColor Cyan
    }
    
    Write-Host "Script completed." -ForegroundColor Green
}