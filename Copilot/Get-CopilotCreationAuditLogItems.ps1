#Requires -Modules ExchangeOnlineManagement

$startDate = (get-date).AddDays(-7).tostring("yyyy-MM-dd")
$endDate = (get-date).tostring("yyyy-MM-dd")
$upn = Read-Host "Enter your UPN"

#Exchange Online Management Session; $set upn variable prior to running
Connect-ExchangeOnline -UserPrincipalName $upn


#region - Get CopilotInteraction Events for the Date Range
$recordType="BotCreate"
$sessionId = "$recordType from $startDate to $endDate 1"

$allResults=@()
do {
      $currentResult=Search-UnifiedAuditLog `
            -StartDate $startDate `
            -EndDate $endDate `
            -SessionCommand ReturnLargeSet `
            -SessionId $sessionId `
            -RecordType "$recordType"
      $allResults += $currentResult
      write-host "Current Result Count: $($currentResult.Count)"
      write-host "All Result Count: $($allResults.Count)"
} while ($currentResult.Count -ne 0)

$allResults.Count
#endregion

$copilotData=@()

foreach ($copilotResult in $allResults) {
      $auditData=ConvertFrom-JSON $copilotResult.AuditData
      $copilotDatum= New-Object PSObject
      $copilotDatum | Add-Member NoteProperty EventDate($copilotResult.CreationDate)
      $copilotDatum | Add-Member NoteProperty UserId($copilotResult.UserId)
      $copilotDatum | Add-Member NoteProperty EnvironmentId($auditData.EnvironmentId)

      $copilotData+=$copilotDatum
}

$copilotData | Export-CSV -path "c:\temp\copilotaudit.csv" -NoTypeInformation