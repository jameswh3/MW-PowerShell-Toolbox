Connect-MgGraph -ClientId $ClientId `
    -TenantId $TenantDomain `
    -Scopes "User.Read","ChannelSettings.ReadWrite.All","Group.Read.All","Team.ReadBasic.All","TeamMember.ReadWrite.All","ChannelMessage.ReadWrite","TeamSettings.ReadWrite.All","ChannelMessage.Read.All"


$body = @{
    "moderationSettings"= @{
        "userNewMessageRestriction"= "moderators"
        "replyRestriction" = "authorAndModerators"
        "allowNewMessageFromBots" = "false"
        "allowNewMessageFromConnectors"= "false"
        }
    }

$updateChannelResponse=Invoke-MgGraphRequest -Method PATCH `
        -Uri "https://graph.microsoft.com/beta/teams/$($teamId)/channels/$($channelId)" `
        -ErrorAction Stop `
        -Body $body


$channelResponse=Invoke-MgGraphRequest -Method GET `
        -Uri "https://graph.microsoft.com/beta/teams/$($teamId)/channels/$($channelId)" `
        -ErrorAction Stop