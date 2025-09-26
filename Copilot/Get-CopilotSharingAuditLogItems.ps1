#Requires -Modules ExchangeOnlineManagement

function Get-CopilotSharingAuditLogItems {
      param(
            [Parameter(Mandatory = $false)]
            [string]$StartDate = (Get-Date).AddDays(-7).ToString("MM-dd-yyyy"),

            [Parameter(Mandatory = $false)]
            [string]$EndDate = (Get-Date).ToString("MM-dd-yyyy"),

            [Parameter(Mandatory = $false)]
            [string]$UserPrincipalName,

            [Parameter(Mandatory = $false)]
            [string]$OutputFile = "c:\temp\copilotshareaudit.csv",

            [Parameter(Mandatory = $false)]
            [switch]$Append
      )
      BEGIN {
            #check connection
            $connections=Get-ConnectionInformation
            if ($connections -eq $null -or $connections.Count -eq 0) {
                  Write-Host "No connections found. Please connect to Exchange Online first."
                  if (-not ($upn)) {
                        $upn = Read-Host "Enter your UPN"
                  }
                  #Exchange Online Management Session; $set upn variable prior to running
                  Connect-ExchangeOnline -UserPrincipalName $upn
            } else {
                  Write-Host "Using existing Exchange Online Connection."
            }
                        
            if ($StartDate -eq $null -or $EndDate -eq $null) {
                  $StartDate = (get-date).AddDays(-1).tostring("yyyy-MM-dd")
                  $EndDate = (get-date).tostring("yyyy-MM-dd")
            }

            $recordType="UpdateCopilotSettings"
            $sessionId = "$recordType from $EndDate to $EndDate"
      }
      PROCESS{
            $allResults=@()
            do {
                  $currentResult=Search-UnifiedAuditLog `
                        -StartDate $StartDate `
                        -EndDate $EndDate `
                        -SessionCommand ReturnLargeSet `
                        -SessionId $sessionId `
                        -RecordType "$recordType"
                  if ($currentResult.Operations -eq "BotUpdateOperation-BotShare") {
                        $allResults+=$currentResult
                  } else {
                        #don't add the updates to the results
                  }
                  write-host "Current Result Count: $($currentResult.Count)"
                  write-host "All Result Count: $($allResults.Count)"
            } while ($currentResult.Count -ne 0)

            $copilotData=@()

            foreach ($copilotResult in $allResults) {
                  $auditData=ConvertFrom-JSON $copilotResult.AuditData
                  $copilotDatum = New-Object PSObject
                  $copilotDatum | Add-Member NoteProperty CreationTime($auditData.CreationTime)
                  $copilotDatum | Add-Member NoteProperty UserId($auditData.UserId)
                  $copilotDatum | Add-Member NoteProperty Operation($auditData.Operation)
                  $copilotDatum | Add-Member NoteProperty Workload($auditData.Workload)
                  
                  # Extract bot update details from PropertyCollection
                  $botUpdateDetails = @()
                  if ($auditData.PropertyCollection) {
                        foreach ($property in $auditData.PropertyCollection) {
                              if ($property.Name -eq "powerplatform.analytics.resource.bot.update_details.change") {
                                    try {
                                          # Parse the JSON value if it's a string
                                          if ($property.Value -is [string]) {
                                                $changeDetails = ConvertFrom-Json $property.Value -ErrorAction SilentlyContinue
                                          } else {
                                                $changeDetails = $property.Value
                                          }
                                          
                                          # Create a structured object for the change details
                                          $changeInfo = [PSCustomObject]@{
                                                PropertyName = $property.Name
                                                ChangeDetails = $changeDetails
                                                RawValue = $property.Value
                                          }
                                          $botUpdateDetails += $changeInfo
                                    } catch {
                                          # If JSON parsing fails, capture the raw value
                                          $changeInfo = [PSCustomObject]@{
                                                PropertyName = $property.Name
                                                ChangeDetails = "Parse Error"
                                                RawValue = $property.Value
                                                Error = $_.Exception.Message
                                          }
                                          $botUpdateDetails += $changeInfo
                                    }
                              }
                        }
                  }
                  $copilotData+=$copilotDatum
            } 
      }
      END {
            if ($Append) {
                  $copilotData | Export-CSV -path $OutputFile -NoTypeInformation -Append
            }
            else {
                  $copilotData | Export-CSV -path $OutputFile -NoTypeInformation
            }
      }

}