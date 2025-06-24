
# Delegated Permissions


Connect-MgGraph -ClientId $ClientId `
    -TenantId $TenantDomain `
    -Scopes "User.Read","Group.Read.All","Team.ReadBasic.All","TeamMember.ReadWrite.All","ChannelMessage.ReadWrite","TeamSettings.ReadWrite.All","ChannelMessage.Read.All"

$teamsResponse=Invoke-MgGraphRequest -Method GET `
    -Uri "https://graph.microsoft.com/v1.0/teams" `
    -ErrorAction Stop

$teams=$teamsResponse.value

foreach ($t in $teams) {
    Write-Host "Processing Team: $($t.displayName) ($($t.id))"
    $channelResponse=Invoke-MgGraphRequest -Method GET `
    -Uri "https://graph.microsoft.com/v1.0/teams/$($t.id)/allChannels" `
    -ErrorAction Stop
    $channels=$channelResponse.value

    foreach ($c in $channels) {
        Write-Host "  Processing Channel: $($c.displayName) ($($c.id))"
        
        # Get channel messages
    $messagesResponse=Invoke-MgGraphRequest -Method GET `
        -Uri "https://graph.microsoft.com/v1.0/teams/$($t.id)/channels/$($c.id)/messages" `
        -ErrorAction Stop
    $messages=$messagesResponse.value
        foreach ($m in $messages) {
            write-host "    Message: [$($m.createdDateTime)] $($m.body.content) (ID: $($m.id))"
        } #foreach message
    } #foreach channel
} #foreach team


Disconnect-mgGraph
