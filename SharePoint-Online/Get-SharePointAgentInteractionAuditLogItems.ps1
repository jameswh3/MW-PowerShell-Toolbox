$startDate = "2025-02-25"
$endDate = "2025-02-28"
$upn = read-host "Enter your UPN"

#Exchange Online Management Session; $set upn variable prior to running
Connect-ExchangeOnline -UserPrincipalName $upn

#region - Get All Record Types for the Date Range
$sessionId = "FileUpload Operation SharePoint RecordTypes from $startDate to $endDate"
$allResults=@()
do {
      $currentResult=Search-UnifiedAuditLog `
            -StartDate $startDate `
            -EndDate $endDate `
            -SessionCommand ReturnLargeSet `
            -SessionId $sessionId `
            -RecordType "SharePointFileOperation" `
            -Operations "FileAccessed","FileAccessedExtended"
      $allResults += $currentResult
      write-host "Current Result Count: $($currentResult.Count)"
      write-host "All Result Count: $($allResults.Count)"
} while ($currentResult.Count -ne 0)

write-host "All items count: $($allResults.Count)"

$copilotAgentInteractionAuditLogItems = $allResults | Where-Object {$_.AuditData -like "*.agent*"}

write-host "SharePoint Agent items count: $($copilotAgentInteractionAuditLogItems.Count)"

$copilotAgentInteractionAuditLogItems | Export-CSV -path "c:\temp\copilotAgentCreation.csv" -NoTypeInformation