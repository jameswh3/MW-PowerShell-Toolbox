#Requires -Modules ExchangeOnlineManagement

$startDate = (get-date).AddDays(-14).tostring("yyyy-MM-dd")
$endDate = (get-date).tostring("yyyy-MM-dd")
$upn = Read-Host "Enter your UPN"

#Exchange Online Management Session; $set upn variable prior to running
Connect-ExchangeOnline -UserPrincipalName $upn


#region - Get CopilotInteraction Events for the Date Range
$recordType="CopilotInteraction"
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
      $copilotDatum | Add-Member NoteProperty AgentName($auditData.AgentName)
      $copilotDatum | Add-Member NoteProperty AgentId($auditData.AgentId)
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
      #Get Accessed Resources; note that when resource is a website, the Type is not present
      $accessedResources=@()
      foreach ($accessedResource in $auditData.CopilotEventData.AccessedResources) {
            $accessedResources+=($accessedResource.Type) ? $accessedResource.Type : $accessedResource.SiteUrl
      }
      # Create a hashtable to store the counts of each string
      if ($accessedResources.Count -gt 0) {
            $accessedResourcesCounts = @{}
            # Iterate through the array and count occurrences of each string
            foreach ($item in $accessedResources) {
                  write-host "For $($copilotDatum.EventId), Item: $item"
                  $key=($item) ? $item : "No Type Defined"
                  if ($accessedResourcesCounts.ContainsKey($key)) {
                        $accessedResourcesCounts[$key]++
                  } else {
                        $accessedResourcesCounts[$key] = 1
                  }
            }
            $resourceCountStrings = @($accessedResourcesCounts.GetEnumerator() | ForEach-Object { "$($_.Key) ($($_.Value))" })
            $accessedResourcesCountsString = [string]::Join(", ", $resourceCountStrings)
            $copilotDatum | Add-Member NoteProperty AccessedResources($accessedResourcesCountsString)
      } else {
            $copilotDatum | Add-Member NoteProperty AccessedResources("")
      }
      $copilotData+=$copilotDatum
}

$copilotData | Export-CSV -path "c:\temp\copilotaudit.csv" -NoTypeInformation