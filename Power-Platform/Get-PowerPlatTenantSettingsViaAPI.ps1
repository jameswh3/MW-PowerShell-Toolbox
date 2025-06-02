<#
    #Modify the following variables with your own values
    $clientId="<your client id>"
    $clientSecret="<your client secret>"
    $tenantDomain="<your tenant>.onmicrosoft.com>"
#>

#Authenticate to the API using client credentials
$tokenUrl = "https://login.microsoftonline.com/$tenantDomain/oauth2/v2.0/token"
$scope="https://service.powerapps.com/.default"
$token = Invoke-RestMethod -Uri $tokenUrl -Method Post -Body @{grant_type="client_credentials"; client_id="$clientId"; client_secret="$clientSecret"; scope="$scope"} -ContentType 'application/x-www-form-urlencoded'
Write-Host $token.access_token

#Get the list of environments and their settings
$api='https://api.bap.microsoft.com/providers/Microsoft.BusinessAppPlatform/scopes/admin/environments?api-version=2020-10-01&$expand=properties.capacity,properties.addons,properties.url'
$response=Invoke-RestMethod -Uri $api -Method Get -Headers @{Authorization = "Bearer $($token.access_token)"} -ContentType 'application/json'
$response.value.properties