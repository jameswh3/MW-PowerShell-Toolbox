#Requires -Modules ExchangeOnlineManagement


$startDate = "2025-01-18"
$endDate = "2025-02-19"
$upn = read-host "Enter your UPN"

#Exchange Online Management Session; $set upn variable prior to running
Connect-ExchangeOnline -UserPrincipalName $upn

#region - Get All Record Types for the Date Range
$sessionId = "All RecordTypes from $startDate to $endDate 4"
$allResults=@()
do {
      $currentResult=Search-UnifiedAuditLog `
            -StartDate $startDate `
            -EndDate $endDate `
            -SessionCommand ReturnLargeSet `
            -SessionId $sessionId
      $allResults += $currentResult
      write-host "Current Result Count: $($currentResult.Count)"
      write-host "All Result Count: $($allResults.Count)"
} while ($currentResult.Count -ne 0)

$allResults.Count
#endregion


$allResults | export-csv c:\temp\audit.csv