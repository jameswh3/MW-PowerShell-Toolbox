function ConvertFrom-TranscriptData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [object[]]$TranscriptsData,
        
        [Parameter(Mandatory=$false)]
        [string]$OutputPath,
        
        [Parameter(Mandatory=$false)]
        [switch]$ReturnAsString,
        
        [Parameter(Mandatory=$false)]
        [switch]$EnableDebug
    )
    
    BEGIN {
        $results = @()
        $sessionCounter = 1
        
        # Function to convert various timestamp formats to UTC datetime string
        function ConvertTo-UTCDateTime {
            param($timestamp)
            
            if (-not $timestamp) {
                return "Unknown Time"
            }
            
            try {
                # Check if it's a Unix timestamp (seconds since epoch)
                if ($timestamp -is [int] -or $timestamp -is [long] -or ($timestamp -match '^\d+$')) {
                    $timestampNum = [long]$timestamp
                    
                    # Check if it's milliseconds (13 digits) or seconds (10 digits)
                    if ($timestampNum.ToString().Length -eq 13) {
                        # Milliseconds since epoch
                        $dateTime = [DateTimeOffset]::FromUnixTimeMilliseconds($timestampNum).DateTime
                    } elseif ($timestampNum.ToString().Length -eq 10) {
                        # Seconds since epoch
                        $dateTime = [DateTimeOffset]::FromUnixTimeSeconds($timestampNum).DateTime
                    } else {
                        # Try as milliseconds first, then seconds
                        try {
                            $dateTime = [DateTimeOffset]::FromUnixTimeMilliseconds($timestampNum).DateTime
                        } catch {
                            $dateTime = [DateTimeOffset]::FromUnixTimeSeconds($timestampNum).DateTime
                        }
                    }
                    
                    # Convert to UTC and format
                    return $dateTime.ToUniversalTime().ToString("HH:mm:ss UTC")
                } else {
                    # Try to parse as regular datetime string
                    $dateTime = [datetime]::Parse($timestamp)
                    return $dateTime.ToUniversalTime().ToString("HH:mm:ss UTC")
                }
            } catch {
                # If all parsing fails, return the original timestamp
                return $timestamp.ToString()
            }
        }
    }
    
    PROCESS {
        foreach ($transcript in $TranscriptsData) {
            $output = @()
            
            # Session Start
            $sessionStartTime = if ($transcript.createdon) { 
                [datetime]::Parse($transcript.createdon).ToString("yyyy-MM-dd HH:mm:ss UTC") 
            } else { 
                "Unknown" 
            }
            
            $output += "=" * 80
            $output += "SESSION $sessionCounter START - $sessionStartTime"
            $output += "Conversation ID: $($transcript.conversationtranscriptid)"
            if ($transcript._bot_conversationtranscriptid_value) {
                $output += "Bot ID: $($transcript._bot_conversationtranscriptid_value)"
            }
            $output += "=" * 80
            $output += ""
            
            # Parse conversation content
            if ($transcript.content) {
                try {
                    $conversationData = $transcript.content | ConvertFrom-Json
                    
                    # Debug: Show the structure of conversation data
                    if ($EnableDebug) {
                        $output += "=== DEBUG: Conversation Data Structure ==="
                        $output += "Top-level properties: $($conversationData | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name -ErrorAction SilentlyContinue)"
                        $output += "Content type: $($conversationData.GetType().Name)"
                        if ($conversationData.activities) {
                            $output += "Activities count: $($conversationData.activities.Count)"
                        }
                        if ($conversationData.messages) {
                            $output += "Messages count: $($conversationData.messages.Count)"
                        }
                        $output += "=== END DEBUG ==="
                        $output += ""
                    }
                    
                    # Extract messages/activities
                    $activities = @()
                    if ($conversationData.activities) {
                        $activities = $conversationData.activities
                    } elseif ($conversationData.messages) {
                        $activities = $conversationData.messages
                    } elseif ($conversationData -is [array]) {
                        $activities = $conversationData
                    } else {
                        # Single message object
                        $activities = @($conversationData)
                    }
                    
                    # Debug: Show first activity structure if debug is enabled
                    if ($EnableDebug -and $activities.Count -gt 0) {
                        $output += "=== DEBUG: Sample Activity Structure ==="
                        $firstActivity = $activities[0]
                        $output += "Activity properties: $($firstActivity.PSObject.Properties.Name -join ', ')"
                        $output += "Activity type: $($firstActivity.type)"
                        
                        if ($firstActivity.from) {
                            $output += "From object: $($firstActivity.from | ConvertTo-Json -Depth 2 -Compress -ErrorAction SilentlyContinue)"
                        }
                        
                        if ($firstActivity.channelData) {
                            $output += "ChannelData properties: $($firstActivity.channelData.PSObject.Properties.Name -join ', ')"
                        }
                        
                        if ($firstActivity.attachments) {
                            $output += "Attachments count: $($firstActivity.attachments.Count)"
                            $output += "First attachment type: $($firstActivity.attachments[0].contentType)"
                        }
                        
                        $output += "=== END DEBUG ==="
                        $output += ""
                    }
                    
                    foreach ($activity in $activities) {
                        # Enhanced timestamp handling
                        $timestamp = $activity.timestamp ?? $activity.time ?? $activity.createdDateTime ?? $activity.localTimestamp
                        $formattedTime = ConvertTo-UTCDateTime -timestamp $timestamp
                        
                        # Determine if message is from user or agent/bot
                        $isFromUser = $false
                        $isFromBot = $false
                        
                        if ($activity.from) {
                            $fromRole = $activity.from.role ?? $activity.from.name ?? ""
                            $isFromUser = $fromRole -match "user|customer|human" -or $activity.from.id -match "user"
                            $isFromBot = $fromRole -match "bot|agent|assistant" -or $activity.from.id -match "bot"
                        } elseif ($activity.role) {
                            $isFromUser = $activity.role -match "user|customer|human"
                            $isFromBot = $activity.role -match "bot|agent|assistant"
                        } elseif ($activity.sender) {
                            $isFromUser = $activity.sender -match "user|customer|human"
                            $isFromBot = $activity.sender -match "bot|agent|assistant"
                        }
                        
                        # Extract message text
                        $messageText = ""
                        if ($activity.text) {
                            $messageText = $activity.text
                        } elseif ($activity.message) {
                            $messageText = $activity.message
                        } elseif ($activity.content) {
                            $messageText = $activity.content
                        }
                        
                        # Enhanced topic detection with more comprehensive checking
                        $topicTriggered = $false
                        $topicName = ""
                        $topicResponse = ""
                        $topicSource = ""
                        
                        # Check all possible locations for topic information
                        # 1. ChannelData topic
                        if ($activity.channelData) {
                            if ($activity.channelData.topic) {
                                $topicTriggered = $true
                                $topicName = $activity.channelData.topic.name ?? $activity.channelData.topic.displayName ?? $activity.channelData.topic
                                $topicResponse = $activity.channelData.topic.response ?? $messageText
                                $topicSource = "channelData.topic"
                            }
                            # Check for PVA postback (common in Power Virtual Agents)
                            elseif ($activity.channelData.postback -and $activity.channelData.postback.value) {
                                $topicTriggered = $true
                                $topicName = $activity.channelData.postback.value
                                $topicSource = "channelData.postback"
                            }
                            # Check for any topic-related properties in channelData
                            elseif ($activity.channelData.PSObject.Properties.Name -contains "topicName") {
                                $topicTriggered = $true
                                $topicName = $activity.channelData.topicName
                                $topicSource = "channelData.topicName"
                            }
                        }
                        
                        # 2. Entities
                        if (-not $topicTriggered -and $activity.entities) {
                            $topicEntity = $activity.entities | Where-Object { 
                                $_.type -eq "topic" -or 
                                $_.name -like "*topic*" -or 
                                $_.PSObject.Properties.Name -contains "topicName"
                            }
                            if ($topicEntity) {
                                $topicTriggered = $true
                                $topicName = $topicEntity.name ?? $topicEntity.displayName ?? $topicEntity.value ?? $topicEntity.topicName
                                $topicResponse = $topicEntity.response ?? $messageText
                                $topicSource = "entities"
                            }
                        }
                        
                        # 3. Value object
                        if (-not $topicTriggered -and $activity.value) {
                            if ($activity.value.topic) {
                                $topicTriggered = $true
                                $topicName = $activity.value.topic.name ?? $activity.value.topic.displayName ?? $activity.value.topic
                                $topicResponse = $activity.value.topic.response ?? $messageText
                                $topicSource = "value.topic"
                            } elseif ($activity.value.topicName) {
                                $topicTriggered = $true
                                $topicName = $activity.value.topicName
                                $topicSource = "value.topicName"
                            }
                        }
                        
                        # 4. Metadata
                        if (-not $topicTriggered -and $activity.metadata) {
                            if ($activity.metadata.topic -or $activity.metadata.topicName) {
                                $topicTriggered = $true
                                $topicName = $activity.metadata.topicName ?? $activity.metadata.topic
                                $topicResponse = $activity.metadata.response ?? $messageText
                                $topicSource = "metadata"
                            }
                        }
                        
                        # 5. Look for adaptive cards or rich responses
                        if ($activity.attachments) {
                            foreach ($attachment in $activity.attachments) {
                                if ($EnableDebug) {
                                    $output += "[DEBUG] Found attachment type: $($attachment.contentType)"
                                }
                                
                                if ($attachment.contentType -eq "application/vnd.microsoft.card.adaptive" -or 
                                    $attachment.contentType -eq "application/vnd.microsoft.card.hero" -or
                                    $attachment.contentType -eq "application/vnd.microsoft.card.thumbnail") {
                                    try {
                                        $cardContent = $attachment.content
                                        
                                        # Extract card text
                                        if ($cardContent.body) {
                                            $cardText = ($cardContent.body | ForEach-Object { 
                                                if ($_.text) { $_.text }
                                                elseif ($_.items) { ($_.items | ForEach-Object { $_.text }) -join " " }
                                                elseif ($_.columns) { 
                                                    ($_.columns | ForEach-Object { 
                                                        ($_.items | ForEach-Object { $_.text }) -join " "
                                                    }) -join " "
                                                }
                                            }) -join " "
                                            
                                            if ($cardText -and $cardText.Trim() -ne "") {
                                                $messageText += "`n[ADAPTIVE CARD] $cardText"
                                                if ($EnableDebug) {
                                                    $output += "[DEBUG] Added adaptive card content: $($cardText.Substring(0, [Math]::Min(100, $cardText.Length)))..."
                                                }
                                            }
                                        }
                                        
                                        # Check for topic information in card
                                        if ($cardContent.topic -or $cardContent.topicName) {
                                            $topicTriggered = $true
                                            $topicName = $cardContent.topicName ?? $cardContent.topic
                                            $topicSource = "adaptive card"
                                        }
                                        
                                        # Check card actions for topic triggers
                                        if ($cardContent.actions) {
                                            foreach ($action in $cardContent.actions) {
                                                if ($action.data -and $action.data.topic) {
                                                    $topicTriggered = $true
                                                    $topicName = $action.data.topic
                                                    $topicSource = "card action"
                                                }
                                            }
                                        }
                                        
                                    } catch {
                                        if ($EnableDebug) {
                                            $output += "[DEBUG] Error parsing card: $($_.Exception.Message)"
                                        }
                                    }
                                }
                            }
                        }
                        
                        # Debug topic detection
                        if ($EnableDebug -and $topicTriggered) {
                            $output += "[DEBUG] Topic detected from $topicSource`: '$topicName'"
                        } elseif ($EnableDebug -and $isFromBot) {
                            $output += "[DEBUG] No topic detected for bot message"
                        }
                        
                        # Format the message
                        if ($messageText -and $messageText.Trim() -ne "") {
                            if ($isFromUser) {
                                $output += "[$formattedTime] USER: $messageText"
                            } elseif ($isFromBot) {
                                if ($topicTriggered -and $topicName) {
                                    $output += "[$formattedTime] AGENT (Topic: $topicName): $messageText"
                                } else {
                                    $output += "[$formattedTime] AGENT: $messageText"
                                }
                            } else {
                                # Default handling when role is unclear
                                $sender = $activity.from.name ?? $activity.from.id ?? $activity.role ?? $activity.sender ?? "Unknown"
                                if ($topicTriggered -and $topicName) {
                                    $output += "[$formattedTime] $sender (Topic: $topicName): $messageText"
                                } else {
                                    $output += "[$formattedTime] $sender`: $messageText"
                                }
                            }
                            $output += ""
                        } elseif ($topicTriggered -and $topicName -and $topicResponse) {
                            # Handle case where topic was triggered but no direct message text
                            $output += "[$formattedTime] AGENT (Topic: $topicName): $topicResponse"
                            $output += ""
                        }
                        
                        # Check for suggested actions or quick replies
                        if ($activity.suggestedActions -and $activity.suggestedActions.actions) {
                            $suggestions = ($activity.suggestedActions.actions | ForEach-Object { $_.title ?? $_.text ?? $_.value }) -join ", "
                            if ($suggestions) {
                                $output += "[$formattedTime] SUGGESTED OPTIONS: $suggestions"
                                $output += ""
                            }
                        }
                    }
                    
                } catch {
                    $output += "ERROR: Could not parse conversation content - $($_.Exception.Message)"
                    if ($EnableDebug) {
                        $output += "Raw Content Preview: $($transcript.content.ToString().Substring(0, [Math]::Min(500, $transcript.content.ToString().Length)))..."
                    }
                    $output += ""
                }
            } else {
                $output += "No conversation content available"
                $output += ""
            }
            
            # Session End
            $output += "=" * 80
            $output += "SESSION $sessionCounter END"
            $output += "=" * 80
            $output += ""
            $output += ""
            
            $results += $output -join "`n"
            $sessionCounter++
        }
    }
    
    END {
        $finalOutput = $results -join "`n"
        
        if ($OutputPath) {
            $finalOutput | Out-File -FilePath $OutputPath -Encoding UTF8
            Write-Host "Transcript data saved to: $OutputPath" -ForegroundColor Green
        }
        
        if ($ReturnAsString -or -not $OutputPath) {
            return $finalOutput
        }
    }
}

# Example usage:
<#
# Parse transcript data and display to console with debug
$parsedTranscripts = ConvertFrom-TranscriptData -TranscriptsData $transcriptsData -EnableDebug

# Parse and save to file
ConvertFrom-TranscriptData -TranscriptsData $transcriptsData -OutputPath "C:\temp\parsed-transcripts.txt"

# Use with pipeline
$transcriptsData | ConvertFrom-TranscriptData -OutputPath "C:\temp\transcripts-output.txt"

# Return as string for further processing
$textOutput = $transcriptsData | ConvertFrom-TranscriptData -ReturnAsString
#>