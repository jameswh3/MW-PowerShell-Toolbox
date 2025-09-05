#Requires -Modules ExchangeOnlineManagement


if (-not $startDate) {
      $startDate = (get-date).AddDays(-14).tostring("yyyy-MM-dd")
}
if (-not $endDate) {
      $endDate = (get-date).tostring("yyyy-MM-dd")
}

if (-not $upn) {
      $upn = Read-Host "Enter your UPN"
}
$excludeBotIconUpdates=$true #the bot icon updates include base64 representations of the icon, which are large and not useful for most purposes.  If you want to include them, set this to $false.

#Exchange Online Management Session; $set upn variable prior to running
if (-not (Get-ConnectionInformation)) {
      Connect-ExchangeOnline -UserPrincipalName $upn
}

#region - Get All Record Types for the Date Range
$sessionId = "All RecordTypes from $startDate to $endDate"
$allResults=@()
do {
      $currentResult=Search-UnifiedAuditLog `
            -StartDate $startDate `
            -EndDate $endDate `
            -SessionCommand ReturnLargeSet `
            -SessionId $sessionId
      if ($currentResult.Operations -eq "BotUpdateOperation-BotIconUpdate" -and $excludeBotIconUpdates) {
            #don't add the bot icon updates to the results
      } else {
            $allResults+=$currentResult
      }
      write-host "Current Result Count: $($currentResult.Count)"
      write-host "All Result Count: $($allResults.Count)"
} while ($currentResult.Count -ne 0)

$allResults.Count
#endregion

$allResults | export-csv c:\temp\audit.csv