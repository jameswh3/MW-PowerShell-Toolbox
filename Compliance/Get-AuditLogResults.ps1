#Requires -Modules ExchangeOnlineManagement

<#
.SYNOPSIS
    Retrieves audit log results from the Microsoft 365 Unified Audit Log.

.DESCRIPTION
    Searches the unified audit log for a specified date range and exports the results to a CSV file.
    Handles large result sets using session-based retrieval.

.PARAMETER StartDate
    The start date for the audit log search. Defaults to 5 days ago.

.PARAMETER EndDate
    The end date for the audit log search. Defaults to tomorrow.

.PARAMETER UserPrincipalName
    The UPN to use for connecting to Exchange Online. If not provided, you will be prompted.

.PARAMETER OutputPath
    The path where the CSV file will be saved. Defaults to c:\temp\audit.csv

.PARAMETER ExcludeBotIconUpdates
    Whether to exclude bot icon updates from the results. Defaults to $true.

.EXAMPLE
    Get-AuditLogResults -StartDate "2025-06-01" -EndDate "2025-06-24" -UserPrincipalName "admin@contoso.com"

.EXAMPLE
    Get-AuditLogResults -StartDate "2025-06-01" -EndDate "2025-06-24" -OutputPath "c:\reports\audit.csv"
#>
function Get-AuditLogResults {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$StartDate,

        [Parameter(Mandatory = $false)]
        [string]$EndDate,

        [Parameter(Mandatory = $false)]
        [string]$UserPrincipalName,

        [Parameter(Mandatory = $false)]
        [string]$OutputPath = "c:\temp\audit.csv",

        [Parameter(Mandatory = $false)]
        [bool]$ExcludeBotIconUpdates = $true
    )

    # Set default dates if not provided
    if (-not $StartDate) {
        $StartDate = (Get-Date).AddDays(-5).ToString("yyyy-MM-dd")
    }
    if (-not $EndDate) {
        $EndDate = (Get-Date).AddDays(1).ToString("yyyy-MM-dd")
    }

    # Exchange Online Management Session
    if (-not (Get-ConnectionInformation)) {
        if (-not $UserPrincipalName) {
            $UserPrincipalName = Read-Host "Enter your UPN"
        }
        Write-Host "Connecting to Exchange Online..." -ForegroundColor Yellow
        Connect-ExchangeOnline -UserPrincipalName $UserPrincipalName
    }

    # Get All Record Types for the Date Range
    $sessionId = "All RecordTypes from $StartDate to $EndDate & $(Get-Random -Minimum 1 -Maximum 100)"
    $allResults = @()
    
    Write-Host "Searching audit logs from $StartDate to $EndDate..." -ForegroundColor Cyan
    
    do {
        $currentResult = Search-UnifiedAuditLog `
            -StartDate $StartDate `
            -EndDate $EndDate `
            -SessionCommand ReturnLargeSet `
            -SessionId $sessionId
        
        if ($currentResult) {
            foreach ($result in $currentResult) {
                if ($result.Operations -eq "BotUpdateOperation-BotIconUpdate" -and $ExcludeBotIconUpdates) {
                    # Don't add the bot icon updates to the results
                    continue
                }
                $allResults += $result
            }
        }
        
        Write-Host "Current Result Count: $($currentResult.Count)" -ForegroundColor Gray
        Write-Host "All Result Count: $($allResults.Count)" -ForegroundColor Green
    } while ($currentResult.Count -ne 0)

    Write-Host "`nTotal results retrieved: $($allResults.Count)" -ForegroundColor Green
    
    # Export results
    if ($allResults.Count -gt 0) {
      if ($outputPath -ne "") {
        Write-Host "Exporting results to: $OutputPath" -ForegroundColor Cyan
        $allResults | Export-Csv -Path $OutputPath -NoTypeInformation
        Write-Host "Export complete!" -ForegroundColor Green
      } else {
            return $allResults
      }
    }
    else {
        Write-Host "No results found for the specified date range." -ForegroundColor Yellow
    }
}