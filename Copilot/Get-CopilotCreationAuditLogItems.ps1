#Requires -Modules ExchangeOnlineManagement

if ([string]::IsNullOrEmpty($startDate)) {
    $startDate = (get-date).AddDays(-14).tostring("yyyy-MM-dd")
}
if ([string]::IsNullOrEmpty($endDate)) {
    $endDate = (get-date).tostring("yyyy-MM-dd")
}
if ([string]::IsNullOrEmpty($upn)) {
    $upn = Read-Host "Enter your UPN"
}

# Check for existing Exchange Online connection
$existingConnection = Get-ConnectionInformation -ErrorAction SilentlyContinue
if ($existingConnection) {
    Write-Host "Using existing Exchange Online connection for $($existingConnection.UserPrincipalName)"
} else {
    Connect-ExchangeOnline -UserPrincipalName $upn
}

#region - Get CopilotInteraction Events for the Date Range
$recordType="BotCreate"
$sessionId = "$recordType from $startDate to $endDate"

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