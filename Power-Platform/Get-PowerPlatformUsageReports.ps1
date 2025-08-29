#Requires -Modules Az.Accounts
#Note this uses an undocumented API endpoint, so it may change at any time.
function Get-PowerPlatformUsageReports {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
            [string]$TenantDomain,
        [Parameter(Mandatory = $true)]
            [string]$TenantId,
        [datetime]$StartDate = (Get-Date).AddDays(-8),
        [datetime]$EndDate = (Get-Date).AddDays(-1),
        [string]$OutputLocation = "C:\temp",
        [string[]]$ReportTypes = @("AIByUserAndEnvironment", "ApiByLicensedUser", "ApiByNonLicensedUser", "ApiByFlow", "PowerPagesAnonymous", "PowerPagesAuthenticated", "CopilotStudioDetailedUsage"),
        [int]$SleepTime = 600 #seconds to wait for report generation before downloading it
    )
    BEGIN {
        #connect and get access token
        Connect-AzAccount -Tenant $TenantDomain
        $token = (Get-AzAccessToken -ResourceUrl 'https://licensing.powerplatform.microsoft.com').token
        $startDateString = $StartDate.ToString("yyyy-MM-dd")
        $endDateString = $EndDate.ToString("yyyy-MM-dd")
        $OutputLocation = $OutputLocation.TrimEnd("\")
    }
    PROCESS {
        write-host "Starting Report Process for $TenantDomain ($TenantId) from $StartDate to $EndDate"
        #queue report generation for each report type
        $queueReportResponses = @{}
        foreach ($reportType in $ReportTypes) {
            write-host "  Generating report for $reportType"
            $licensingAPI = "https://licensing.powerplatform.microsoft.com/v0.1-alpha/tenants/$tenantId/TenantConsumptionReport/GenerateReportURL"
            $body = @{
                "consumptionReportDownload" = ""
                "endDate"                   = "$endDateString"
                "forceRegenerate"           = "true"
                "reportType"                = "$reportType"
                "startDate"                 = "$startDateString"
                "status"                    = "None"
                "tenantId"                  = "$tenantId"
            }
            $queueReportResponses[$reportType] = Invoke-RestMethod -Uri $licensingAPI -Method Post -Headers @{Authorization = "Bearer $($token)" } -ContentType 'application/json' -Body ($body | ConvertTo-Json -Depth 10)
        }
        #wait for the report to be generated before downloading it
        "Waiting for $SleepTime seconds for report generation to complete..."
        $startTime = Get-Date
        $endTime = $startTime.AddSeconds($SleepTime)
        while ((Get-Date) -lt $endTime) {
            $elapsedTime = (Get-Date) - $startTime
            $percentage = [math]::Round(($elapsedTime.TotalSeconds / $SleepTime) * 100)
            Write-Progress -Activity "Progress" -Status "$percentage% Complete" -PercentComplete $percentage
            Start-Sleep -Milliseconds 100
        }

        #download report for each report type
        $downloadReportResponses = @{}
        foreach ($reportType in $reportTypes) {
            write-host "  Downloading report for $reportType"
            $downloadAPI = "https://licensing.powerplatform.microsoft.com/v0.1-alpha/tenants/$tenantId/TenantConsumptionReport/DownloadReport"
            $body = @{
                "startDate"  = "$startDateString"
                "endDate"    = "$endDateString"
                "reportType" = "$ReportType"
                "status"     = "None"
                "tenantId"   = "$TenantId"
            }
            $downloadReportResponses[$reportType] = Invoke-RestMethod -Uri $downloadAPI -Method Post -Headers @{Authorization = "Bearer $($token)" } -ContentType 'application/json' -Body ($body | ConvertTo-Json -Depth 10)
        }
    }
    END {
        write-host "Report generation and download complete."
        If ($OutputLocation) {
            write-host "Saving reports to $OutputLocation"
            foreach ($report in $downloadReportResponses.Keys) {
                $reportType=$report
                write-host "exporting $reportType"
                $downloadReportResponses.$report | out-file "$OutputLocation\$reportType.csv"
            }
        } else {
            return $downloadReportResponses
        }
    }
}