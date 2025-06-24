Connect-MgGraph -ClientId $clientId `
    -TenantId $tenantDomain `
    -Scopes "User.Read","ChannelSettings.ReadWrite.All","Team.ReadBasic.All","TeamSettings.ReadWrite.All"


$moderationSettings = @{
    "moderationSettings"= @{
        "userNewMessageRestriction"= "moderators"
        "replyRestriction" = "authorAndModerators"
        "allowNewMessageFromBots" = "false"
        "allowNewMessageFromConnectors"= "false"
    }
}

Invoke-MgGraphRequest -Method PATCH `
        -Uri "https://graph.microsoft.com/beta/teams/$($teamId)/channels/$($channelId)" `
        -ErrorAction Stop `
        -Body $moderationSettings

$channelResponse=Invoke-MgGraphRequest -Method GET `
        -Uri "https://graph.microsoft.com/beta/teams/$($teamId)/channels/$($channelId)" `
        -ErrorAction Stop

$channelResponse.moderationSettings | Format-List