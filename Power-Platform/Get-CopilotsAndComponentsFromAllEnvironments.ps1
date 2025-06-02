#Requires -Modules Microsoft.PowerApps.Administration.PowerShell
#Requires -Modules Microsoft.PowerApps.PowerShell
#Requires -Modules Microsoft.PowerApps.Cds.Client
#Requires -Modules Microsoft.Xrm.Data.PowerShell

function Get-CopoilotsAndCompnonentsFromAllEnvironments.ps1 {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false, Position=0, HelpMessage="Enter the Azure AD application client ID")]
        [string]$ClientId,
        
        [Parameter(Mandatory=$false, Position=1, HelpMessage="Enter the client secret for authentication")]
        [string]$ClientSecret,

        [Parameter(Mandatory=$false, Position=3, HelpMessage="Enter your tenant domain (e.g., contoso.onmicrosoft.com)")]
        [string]$TenantDomain
    )
    BEGIN {
        $environmentData=Get-PowerPlatformEnvironmentInfo
    }
    PROCESS {
        foreach ($e in $environmentData) {
            $orgUrl=$e.EnvironmentUrl
            
            #get list of agents/copilots/bots
            $bots=Get-CopilotAgentsViaAPI -ClientId $clientId `
                -ClientSecret $clientSecret `
                -OrgUrl $orgUrl `
                -TenantDomain $tenantDomain `
                -FieldList "botid,componentidunique,name,configuration,createdon,publishedon,_ownerid_value,_createdby_value,solutionid,modifiedon,_owninguser_value,schemaname,_modifiedby_value,_publishedby_value,authenticationmode,synchronizationstatus,ismanaged"
            
            #get list of bot components
            $components=Get-BotComponentsViaAPI -ClientId $clientId `
                -ClientSecret $clientSecret `
                -OrgUrl $orgUrl `
                -TenantDomain $tenantDomain `
                -FieldList "botcomponentid,componenttype,data,description,filedata,filedata_name,name,schemaname,createdon,_createdby_value,modifiedon,_modifiedby_value,_parentbotid_value"
        }
    }
    END {
        return @($bots,$components)
    }
}