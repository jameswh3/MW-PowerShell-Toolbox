<# Uncomment and modify the variables for your context
    $clientId="<your client id>"
    $clientSecret="<your client secret>"
    $orgUrl="<your org>.crm.dynamics.com"
    $tenantDomain="<your tenant domain>.onmicrosoft.com"
#>


$tokenUrl = "https://login.microsoftonline.com/$tenantDomain/oauth2/v2.0/token"
$token = Invoke-RestMethod -Uri $tokenUrl `
    -Method Post `
    -Body @{grant_type="client_credentials"; client_id="$clientId"; client_secret="$clientSecret"; scope="https://$orgUrl/.default"} `
    -ContentType 'application/x-www-form-urlencoded'
Write-Host $token.access_token

#get list of agents/copilots/bots
$fieldList="botid,componentidunique,name,configuration,createdon,publishedon,_ownerid_value,_createdby_value,solutionid,modifiedon,_owninguser_value,schemaname"
$response=Invoke-RestMethod -Uri "https://$orgUrl/api/data/v9.2/bots?`$select=$fieldList" `
    -Headers @{Authorization = "Bearer $($token.access_token)"}
$response.value