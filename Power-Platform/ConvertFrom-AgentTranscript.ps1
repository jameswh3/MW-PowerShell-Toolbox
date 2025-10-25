<#
.SYNOPSIS
Converts conversation transcript data from Power Platform to human-readable format.

.DESCRIPTION
Parses conversation transcript files and reconstructs them in a chronological, human-readable format
showing the flow of conversation between users and bots.

.PARAMETER InputFile
Path to the conversation transcript file to parse.

.PARAMETER OutputFile
Path where the human-readable transcript should be saved.

.EXAMPLE
ConvertFrom-AgentTranscripts -InputFile "C:\temp\conversationtranscripts.txt" -OutputFile "C:\temp\readable_transcripts.txt"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$InputFile,
    
    [Parameter(Mandatory = $true)]
    [string]$OutputFile
)

function Get-ActivityType {
    param($activity)
    
    if ($activity.type -eq "message") {
        if ($activity.from.role -eq 1) {
            return "User Message"
        } else {
            return "Bot Message"
        }
    }
    elseif ($activity.type -eq "event") {
        switch ($activity.name) {
            "startConversation" { return "Session Start" }
            "ResponseData" { return "Bot Response" }
            "DynamicPlanReceived" { return "Bot Planning" }
            "UniversalSearchToolTraceData" { return "Knowledge Search" }
            "pvaSetContext" { return "Context Set" }
            default { return "Event: $($activity.name)" }
        }
    }
    elseif ($activity.type -eq "trace") {
        switch ($activity.valueType) {
            "SessionInfo" { return "Session Info" }
            "KnowledgeTraceData" { return "Knowledge Search" }
            "VariableAssignment" { return "Variable Assignment" }
            "GPTAnswer" { return "AI Response" }
            default { return "Trace: $($activity.valueType)" }
        }
    }
    else {
        return "Unknown: $($activity.type)"
    }
}

function Parse-ConversationTranscript {
    param([string]$transcriptBlock)
    
    $lines = $transcriptBlock -split "`n"
    $transcript = @{}
    $currentKey = ""
    $currentValue = ""
    
    foreach ($line in $lines) {
        $line = $line.Trim()
        if ($line -match "^([^:]+)\s*:\s*(.*)$") {
            # Save previous key-value pair if exists
            if ($currentKey) {
                $transcript[$currentKey] = $currentValue.Trim()
            }
            
            $currentKey = $matches[1].Trim()
            $currentValue = $matches[2].Trim()
        } else {
            # Continue multi-line value
            if ($currentKey) {
                $currentValue += "`n" + $line
            }
        }
    }
    
    # Save last key-value pair
    if ($currentKey) {
        $transcript[$currentKey] = $currentValue.Trim()
    }
    
    return $transcript
}

function ConvertFrom-UnixTimestamp {
    param($UnixTimestamp)
    
    if (-not $UnixTimestamp -or $UnixTimestamp -eq 0) {
        return "N/A"
    }
    
    try {
        # Handle different timestamp formats
        $timestamp = $null
        
        if ($UnixTimestamp -is [string]) {
            # Try to parse as number
            if ([long]::TryParse($UnixTimestamp, [ref]$timestamp)) {
                # Success - use the parsed value
            } else {
                return "Invalid Timestamp (string: $UnixTimestamp)"
            }
        } elseif ($UnixTimestamp -is [long] -or $UnixTimestamp -is [int]) {
            $timestamp = [long]$UnixTimestamp
        } else {
            return "Invalid Timestamp (type: $($UnixTimestamp.GetType()))"
        }
        
        # Convert Unix timestamp to DateTime (without -Kind parameter for compatibility)
        $epoch = [DateTime]::new(1970, 1, 1, 0, 0, 0, [DateTimeKind]::Utc)
        $dateTime = $epoch.AddSeconds($timestamp)
        return $dateTime.ToLocalTime().ToString("MM-dd-yyyy HH:mm:ss")
    }
    catch {
        return "Invalid Timestamp (error: $($_.Exception.Message))"
    }
}

function Parse-ISO8601DateTime {
    param([string]$DateTimeString)
    
    if ([string]::IsNullOrWhiteSpace($DateTimeString)) {
        return "N/A"
    }
    
    try {
        $dateTime = [DateTime]::Parse($DateTimeString)
        return $dateTime.ToString("MM-dd-yyyy HH:mm:ss")
    }
    catch {
        return "Invalid DateTime: $DateTimeString"
    }
}

# Read the input file
if (-not (Test-Path $InputFile)) {
    Write-Error "Input file not found: $InputFile"
    return
}

$content = Get-Content $InputFile -Raw

# Split on @odata.etag but keep the delimiter
$transcriptBlocks = $content -split '(?=@odata\.etag)' | Where-Object { $_.Trim() -ne "" }

$output = @()

Write-Host "Found $($transcriptBlocks.Count) potential transcript blocks" -ForegroundColor Yellow

foreach ($block in $transcriptBlocks) {
    if ([string]::IsNullOrWhiteSpace($block)) { continue }
    
    # Clean up the block
    $block = $block.Trim()
    
    $transcript = Parse-ConversationTranscript $block
    
    if (-not $transcript.content) { 
        Write-Warning "No content found in transcript block"
        continue 
    }
    
    Write-Host "Processing conversation: $($transcript.conversationtranscriptid)" -ForegroundColor Green
    
    try {
        $contentJson = $transcript.content | ConvertFrom-Json -ErrorAction Stop
        
        # Parse metadata if available
        $metadata = $null
        if ($transcript.metadata) {
            try {
                $metadata = $transcript.metadata | ConvertFrom-Json -ErrorAction Stop
            }
            catch {
                Write-Warning "Could not parse metadata: $($_.Exception.Message)"
            }
        }
        
        # Extract session info
        $sessionInfo = $contentJson.activities | Where-Object { $_.valueType -eq "SessionInfo" } | Select-Object -First 1
        $conversationInfo = $contentJson.activities | Where-Object { $_.valueType -eq "ConversationInfo" } | Select-Object -First 1
        
        $output += "=" * 80
        $output += "Bot Name: $(if ($metadata -and $metadata.BotName) { $metadata.BotName } else { 'Unknown' })"
        $output += "Conversation ID: $($transcript.conversationtranscriptid)"
        $output += "Created On: $(Parse-ISO8601DateTime $transcript.createdon)"
        
        if ($sessionInfo) {
            $output += "Session Start: $(Parse-ISO8601DateTime $sessionInfo.value.startTimeUtc)"
            $output += "Session End: $(Parse-ISO8601DateTime $sessionInfo.value.endTimeUtc)"
            $output += "Session Type: $($sessionInfo.value.type)"
            $output += "Session Outcome: $($sessionInfo.value.outcome)"
            $output += "Session Outcome Reason: $($sessionInfo.value.outcomeReason)"
            $output += "Turn Count: $($sessionInfo.value.turnCount)"
        }
        
        if ($conversationInfo) {
            $output += "Last Session Outcome: $($conversationInfo.value.lastSessionOutcome)"
            $output += "Last Session Outcome Reason: $($conversationInfo.value.lastSessionOutcomeReason)"
            $output += "Design Mode: $($conversationInfo.value.isDesignMode)"
            $output += "Locale: $($conversationInfo.value.locale)"
        }
        
        $output += "-" * 40
        
        # Sort activities by timestamp and filter out activities without timestamps
        $activities = $contentJson.activities | Where-Object { $_.timestamp } | Sort-Object { 
            try { [long]$_.timestamp } catch { 0 }
        }
        
        if ($activities.Count -eq 0) {
            $output += "No timestamped activities found in this conversation."
        } else {
            Write-Host "Found $($activities.Count) activities in this conversation" -ForegroundColor Cyan
        }
        
        foreach ($activity in $activities) {
            $timestamp = ConvertFrom-UnixTimestamp $activity.timestamp
            
            # Debug: Show raw timestamp value
            Write-Debug "Raw timestamp: $($activity.timestamp) (type: $($activity.timestamp.GetType().Name))"
            
            switch ($activity.type) {
                "message" {
                    if ($activity.from.role -eq 1) {
                        $userInfo = if ($activity.from.aadObjectId) { " ($($activity.from.aadObjectId))" } else { " ($($activity.from.id))" }
                        $output += "[$timestamp] User$userInfo`: $($activity.text)"
                    } else {
                        $output += "[$timestamp] Bot: $($activity.text)"
                    }
                }
                "event" {
                    switch ($activity.name) {
                        "ResponseData" {
                            # Include full response text without truncation
                            $responseText = $activity.value
                            $output += "[$timestamp] Bot Response: $responseText"
                        }
                        "DynamicPlanReceived" {
                            if ($activity.value -and $activity.value.steps) {
                                $steps = $activity.value.steps -join ", "
                                $output += "[$timestamp] Bot Planning: Using tools [$steps]"
                            }
                        }
                        "DynamicPlanStepTriggered" {
                            if ($activity.value -and $activity.value.taskDialogId) {
                                $output += "[$timestamp] Bot Action: Starting $($activity.value.taskDialogId)"
                            }
                        }
                        "DynamicPlanStepFinished" {
                            if ($activity.value -and $activity.value.taskDialogId) {
                                $output += "[$timestamp] Bot Action: Completed $($activity.value.taskDialogId)"
                            }
                        }
                        "UniversalSearchToolTraceData" {
                            if ($activity.value -and $activity.value.knowledgeSources) {
                                $sources = ($activity.value.knowledgeSources | ForEach-Object { $_.Split('.')[-1] }) -join ", "
                                $output += "[$timestamp] Knowledge Search: Searched sources [$sources]"
                            }
                        }
                        "pvaSetContext" {
                            $output += "[$timestamp] Context Set (Channel: $($activity.channelId))"
                        }
                        default {
                            # Show other events that might be important
                            if ($activity.name -match "Plan|Search|Response|Step") {
                                $output += "[$timestamp] Event: $($activity.name)"
                            }
                        }
                    }
                }
                "trace" {
                    switch ($activity.valueType) {
                        "ConversationInfo" {
                            $output += "[$timestamp] Conversation Info: Outcome=$($activity.value.lastSessionOutcome), Locale=$($activity.value.locale)"
                        }
                        "KnowledgeTraceData" {
                            if ($activity.value -and $activity.value.citedKnowledgeSources) {
                                $sources = ($activity.value.citedKnowledgeSources | ForEach-Object { $_.Split('.')[-1] }) -join ", "
                                $output += "[$timestamp] Knowledge Search: Found sources [$sources], Status: $($activity.value.completionState)"
                            }
                        }
                        "VariableAssignment" {
                            if ($activity.value -and $activity.value.name -eq "Answer" -and $activity.value.newValue) {
                                # Include full answer without truncation
                                $output += "[$timestamp] Bot Generated Answer: $($activity.value.newValue)"
                            }
                        }
                        "GPTAnswer" {
                            if ($activity.value) {
                                $output += "[$timestamp] AI Processing: $($activity.value.gptAnswerState)"
                            }
                        }
                        "DynamicPlanReceived" {
                            if ($activity.value -and $activity.value.steps) {
                                $steps = $activity.value.steps -join ", "
                                $output += "[$timestamp] Bot Planning: Received plan with steps [$steps]"
                            }
                        }
                        "DynamicPlanFinished" {
                            $output += "[$timestamp] Bot Planning: Plan execution completed"
                        }
                    }
                }
            }
        }
        
        $output += ""
        
    }
    catch {
        Write-Warning "Failed to parse transcript block: $($_.Exception.Message)"
        Write-Warning "Block starts with: $($block.Substring(0, [Math]::Min(100, $block.Length)))"
        continue
    }
}

# Write output to file
$output | Out-File -FilePath $OutputFile -Encoding UTF8
Write-Host "Converted transcript saved to: $OutputFile" -ForegroundColor Green
Write-Host "Total conversations processed: $(($output | Where-Object { $_ -eq ('=' * 80) }).Count)" -ForegroundColor Cyan
