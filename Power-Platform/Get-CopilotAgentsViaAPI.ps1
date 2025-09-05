
function Get-CopilotAgentsViaAPI {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0, HelpMessage="Enter the Azure AD application client ID")]
        [string]$ClientId,
        
        [Parameter(Mandatory=$true, Position=1, HelpMessage="Enter the client secret for authentication")]
        [string]$ClientSecret,
        
        [Parameter(Mandatory=$true, Position=2, HelpMessage="Enter your Dynamics 365 organization URL (e.g., contoso.crm.dynamics.com)")]
        [string]$OrgUrl,
        
        [Parameter(Mandatory=$true, Position=3, HelpMessage="Enter your tenant domain (e.g., contoso.onmicrosoft.com)")]
        [string]$TenantDomain,
        
        [Parameter(Mandatory=$false, HelpMessage="Specify additional fields to retrieve")]
        [string[]]$FieldList="botid,applicationmanifestinformation,componentidunique,name,configuration,createdon,publishedon,_ownerid_value,_createdby_value,solutionid,modifiedon,_owninguser_value,schemaname,_modifiedby_value,_publishedby_value,authenticationmode,synchronizationstatus,ismanaged"
    )
    BEGIN {
        $tokenUrl = "https://login.microsoftonline.com/$TenantDomain/oauth2/v2.0/token"
        $token = Invoke-RestMethod -Uri $tokenUrl `
            -Method Post `
            -Body @{grant_type="client_credentials"; client_id="$ClientId"; client_secret="$ClientSecret"; scope="$OrgUrl/.default"} `
            -ContentType 'application/x-www-form-urlencoded'
    }
    PROCESS {
            #get list of agents/copilots/bots
        $response=Invoke-RestMethod -Uri "$OrgUrl/api/data/v9.2/bots?`$select=$FieldList" `
            -Headers @{Authorization = "Bearer $($token.access_token)"}
    }
    END {
        return $response.value
    }
}