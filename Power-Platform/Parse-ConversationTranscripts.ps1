<#
.SYNOPSIS
Parses conversation transcript data into structured conversations with timestamps.

.DESCRIPTION
This script parses a conversation transcripts file containing multiple bot conversation sessions,
extracting individual conversations with timestamps, messages, and response data.

.PARAMETER InputFile
Path to the conversation transcripts text file.

.PARAMETER OutputPath
Optional. Path to export parsed conversations to CSV/JSON format.

.PARAMETER Format
Output format: CSV, JSON, or Console. Defaults to Console.

.EXAMPLE
.\Parse-ConversationTranscripts.ps1 -InputFile "conversationtranscripts.txt" -Format Console

.EXAMPLE
.\Parse-ConversationTranscripts.ps1 -InputFile "conversationtranscripts.txt" -OutputPath "parsed_conversations.json" -Format JSON
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$InputFile,
    
    [Parameter(Mandatory = $false)]
    [string]$OutputPath,
    
    [Parameter(Mandatory = $false)]
    [ValidateSet("Console", "CSV", "JSON")]
    [string]$Format = "Console"
)

function Parse-ConversationTranscripts {
    param(
        [string]$FilePath
    )
    
    if (-not (Test-Path $FilePath)) {
        throw "Input file not found: $FilePath"
    }
    
    $content = Get-Content $FilePath -Raw
    $conversations = @()
    
    # Split content by conversation sessions (using @odata.etag as delimiter)
    $sessions = $content -split '@odata\.etag\s+:'
    
    foreach ($session in $sessions) {
        if ([string]::IsNullOrWhiteSpace($session)) { continue }
        
        try {
            # Extract conversation metadata
            $conversationId = ""
            $botName = ""
            $createdOn = ""
            $contentJson = ""
            
            # Parse session metadata
            if ($session -match 'conversationtranscriptid\s+:\s+([a-f0-9\-]+)') {
                $conversationId = $matches[1]
            }
            
            if ($session -match '"BotName"\s*:\s*"([^"]*)"') {
                $botName = $matches[1]
            }
            
            if ($session -match 'createdon\s+:\s+(.+)') {
                $createdOn = $matches[1].Trim()
            }
            
            # Extract content JSON
            if ($session -match 'content\s+:\s+(\{.*\})') {
                $contentJson = $matches[1]
            }
            
            if ([string]::IsNullOrWhiteSpace($contentJson)) { continue }
            
            # Parse JSON content
            $contentData = $contentJson | ConvertFrom-Json
            
            if (-not $contentData.activities) { continue }
            
            # Extract conversation activities
            $messages = @()
            $responses = @()
            
            foreach ($activity in $contentData.activities) {
                $timestamp = if ($activity.timestamp) { 
                    [DateTimeOffset]::FromUnixTimeSeconds($activity.timestamp).DateTime 
                } else { 
                    $null 
                }
                
                # Extract messages
                if ($activity.type -eq "message" -and $activity.text) {
                    $messages += [PSCustomObject]@{
                        Timestamp = $timestamp
                        From = if ($activity.from.role -eq 1) { "User" } else { "Bot" }
                        Text = $activity.text
                        ActivityId = $activity.id
                        ChannelId = $activity.channelId
                    }
                }
                
                # Extract response data
                if ($activity.name -eq "ResponseData" -and $activity.value) {
                    $responses += [PSCustomObject]@{
                        Timestamp = $timestamp
                        ResponseText = $activity.value
                        ActivityId = $activity.id
                        ReplyToId = $activity.replyToId
                    }
                }
                
                # Extract agent responses
                if ($activity.name -eq "AgentResponse" -and $activity.value) {
                    $responses += [PSCustomObject]@{
                        Timestamp = $timestamp
                        ResponseText = $activity.value
                        ActivityId = $activity.id
                        ReplyToId = $activity.replyToId
                    }
                }
            }
            
            # Extract session info
            $sessionInfo = $contentData.activities | Where-Object { $_.valueType -eq "SessionInfo" } | Select-Object -Last 1
            $sessionOutcome = if ($sessionInfo) { $sessionInfo.value.outcome } else { "Unknown" }
            $turnCount = if ($sessionInfo) { $sessionInfo.value.turnCount } else { 0 }
            
            $conversations += [PSCustomObject]@{
                ConversationId = $conversationId
                BotName = $botName
                CreatedOn = $createdOn
                SessionOutcome = $sessionOutcome
                TurnCount = $turnCount
                MessageCount = $messages.Count
                ResponseCount = $responses.Count
                Messages = $messages
                Responses = $responses
                StartTime = if ($messages) { ($messages | Sort-Object Timestamp)[0].Timestamp } else { $null }
                EndTime = if ($messages) { ($messages | Sort-Object Timestamp)[-1].Timestamp } else { $null }
            }
            
        } catch {
            Write-Warning "Failed to parse session: $($_.Exception.Message)"
            continue
        }
    }
    
    return $conversations
}

function Export-Conversations {
    param(
        [array]$Conversations,
        [string]$OutputPath,
        [string]$Format
    )
    
    switch ($Format.ToLower()) {
        "json" {
            $Conversations | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputPath -Encoding UTF8
            Write-Host "Exported to JSON: $OutputPath"
        }
        "csv" {
            # Flatten conversations for CSV export
            $flatData = foreach ($conv in $Conversations) {
                foreach ($msg in $conv.Messages) {
                    [PSCustomObject]@{
                        ConversationId = $conv.ConversationId
                        BotName = $conv.BotName
                        CreatedOn = $conv.CreatedOn
                        SessionOutcome = $conv.SessionOutcome
                        TurnCount = $conv.TurnCount
                        Timestamp = $msg.Timestamp
                        From = $msg.From
                        Text = $msg.Text
                        ActivityId = $msg.ActivityId
                        ChannelId = $msg.ChannelId
                    }
                }
            }
            $flatData | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8
            Write-Host "Exported to CSV: $OutputPath"
        }
    }
}

function Show-ConversationSummary {
    param([array]$Conversations)
    
    Write-Host "`n=== Conversation Transcript Analysis ===" -ForegroundColor Green
    Write-Host "Total Conversations: $($Conversations.Count)"
    Write-Host "Date Range: $(($Conversations.CreatedOn | Sort-Object)[0]) to $(($Conversations.CreatedOn | Sort-Object)[-1])"
    
    # Bot usage summary
    $botStats = $Conversations | Group-Object BotName | Sort-Object Count -Descending
    Write-Host "`nBot Usage:"
    foreach ($bot in $botStats) {
        Write-Host "  $($bot.Name): $($bot.Count) conversations"
    }
    
    # Session outcomes
    $outcomeStats = $Conversations | Group-Object SessionOutcome
    Write-Host "`nSession Outcomes:"
    foreach ($outcome in $outcomeStats) {
        Write-Host "  $($outcome.Name): $($outcome.Count)"
    }
    
    # Show sample conversations with messages
    Write-Host "`n=== Sample Conversations ===" -ForegroundColor Yellow
    $sampleConvs = $Conversations | Where-Object { $_.MessageCount -gt 1 } | Select-Object -First 3
    
    foreach ($conv in $sampleConvs) {
        Write-Host "`nConversation ID: $($conv.ConversationId)" -ForegroundColor Cyan
        Write-Host "Bot: $($conv.BotName) | Created: $($conv.CreatedOn) | Turns: $($conv.TurnCount)"
        Write-Host "Messages:"
        
        foreach ($msg in $conv.Messages | Sort-Object Timestamp) {
            $timeStr = if ($msg.Timestamp) { $msg.Timestamp.ToString("HH:mm:ss") } else { "N/A" }
            Write-Host "  [$timeStr] $($msg.From): $($msg.Text.Substring(0, [Math]::Min(100, $msg.Text.Length)))..."
        }
        
        if ($conv.Responses.Count -gt 0) {
            Write-Host "Response Data Available: $($conv.Responses.Count) responses"
        }
    }
}

# Main execution
try {
    Write-Host "Parsing conversation transcripts..." -ForegroundColor Yellow
    $conversations = Parse-ConversationTranscripts -FilePath $InputFile
    
    if ($conversations.Count -eq 0) {
        Write-Warning "No conversations found in the input file."
        return
    }
    
    # Display summary
    Show-ConversationSummary -Conversations $conversations
    
    # Export if requested
    if ($OutputPath -and $Format -ne "Console") {
        Export-Conversations -Conversations $conversations -OutputPath $OutputPath -Format $Format
    }
    
    Write-Host "`nParsing completed successfully!" -ForegroundColor Green
    
} catch {
    Write-Error "Script execution failed: $($_.Exception.Message)"
}
