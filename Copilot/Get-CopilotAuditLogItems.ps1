#Requires -Modules ExchangeOnlineManagement

$startDate = "2025-03-01"
$endDate = "2025-03-05"
$upn = Read-Host "Enter your UPN"

#Exchange Online Management Session; $set upn variable prior to running
Connect-ExchangeOnline -UserPrincipalName $upn


#region - Get CopilotInteraction Events for the Date Range
$recordType="CopilotInteraction"
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
      $copilotDatum | Add-Member NoteProperty AppIdentity($auditData.AppIdentity)
      $copilotDatum | Add-Member NoteProperty EventId($copilotResult.Identity)
      $copilotDatum | Add-Member NoteProperty Operation($auditData.Operation)
      $copilotDatum | Add-Member NoteProperty RecordType($copilotResult.RecordType)
      $copilotDatum | Add-Member NoteProperty UserKey($auditData.UserKey)
      $copilotDatum | Add-Member NoteProperty UserType($auditData.UserType)
      $copilotDatum | Add-Member NoteProperty ClientIP($auditData.ClientIP)
      $copilotDatum | Add-Member NoteProperty Workload($auditData.Workload)
      $copilotDatum | Add-Member NoteProperty UserId($auditData.UserId)
      $copilotDatum | Add-Member NoteProperty AppHost($auditData.CopilotEventData.AppHost)
      $aiSysPlugins=@()
      foreach ($aisysplugin in $auditData.CopilotEventData.AISystemPlugin) {
            $aiSysPlugins+=$aisysplugin.Id
      }
      $copilotDatum | Add-Member NoteProperty AIPlugins($aiSysPlugins -join ",")
      $messageCount=0
      foreach ($message in $auditData.CopilotEventData.Messages) {
            $messageCount++
      }
      $copilotDatum | Add-Member NoteProperty MessageCount ($messageCount)
      $copilotData+=$copilotDatum
}

$copilotData | Export-CSV -path "c:\temp\copilotaudit.csv" -NoTypeInformation