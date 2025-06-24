Connect-MgGraph -ClientId $clientId `
    -TenantId $tenantId `
    -Certificate $cert `
    -NoWelcome


$response=Invoke-MgGraphRequest -Method GET `
    -Uri "https://graph.microsoft.com/v1.0/teams" `
    -ErrorAction Stop `
    -Headers $header

    $response.value | Select-Object id, displayName

Disconnect-mgGraph



    