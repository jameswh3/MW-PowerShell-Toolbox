function Get-BotComponentsViaAPI {
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
        [string[]]$FieldList="botcomponentid,componenttype,data,description,filedata,filedata_name,name,schemaname,createdon,_createdby_value,modifiedon,_modifiedby_value,_parentbotid_value"
    )
    BEGIN {
        $tokenUrl = "https://login.microsoftonline.com/$TenantDomain/oauth2/v2.0/token"
        $token = Invoke-RestMethod -Uri $tokenUrl `
            -Method Post `
            -Body @{grant_type="client_credentials"; client_id="$ClientId"; client_secret="$ClientSecret"; scope="https://$OrgUrl/.default"} `
            -ContentType 'application/x-www-form-urlencoded'
    }
    PROCESS {
            #get list of agents/copilots/bots
        $response=Invoke-RestMethod -Uri "https://$OrgUrl/api/data/v9.2/botcomponents?`$select=$FieldList" `
            -Headers @{Authorization = "Bearer $($token.access_token)"}
    }
    END {
        return $response.value
    }
}