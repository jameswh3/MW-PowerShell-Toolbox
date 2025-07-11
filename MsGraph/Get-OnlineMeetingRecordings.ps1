Connect-MgGraph -ClientId $clientId `
        -TenantId $tenantId `
        -Certificate $cert `
        -NoWelcome
$startDateTime="2025-07-08T00:00:00Z" #note this is UTC
$endDateTime="2025-07-10T11:59:59Z" #note this is UTC

$uri="https://graph.microsoft.com/v1.0/users/$meetingOrganizerUserId/onlineMeetings/getAllRecordings(meetingOrganizerUserId='$meetingOrganizerUserId',startDateTime=$startDateTime,endDateTime=$endDateTime)"
$response = Invoke-MgGraphRequest -Method GET -Uri $uri