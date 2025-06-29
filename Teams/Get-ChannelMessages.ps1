Connect-MgGraph -ClientId $clientId `
    -TenantId $tenantDomain `
    -Scopes "User.Read","Group.Read.All"

$channelMessages=Invoke-MgGraphRequest -Method GET `
        -Uri "https://graph.microsoft.com/beta/teams/$($teamId)/channels/$($channelId)/messages?`$top=3" `
        -ErrorAction Stop

$allMessages = @()
do {
    $allMessages += $channelMessages.value
    $nextLink = $channelMessages.'@odata.nextLink'
    if ($nextLink) {
        write-host "Next Link: $nextLink"
        $channelMessages = Invoke-MgGraphRequest -Method GET -Uri $nextLink -ErrorAction Stop
    }
} while ($nextLink)

Disconnect-MgGraph