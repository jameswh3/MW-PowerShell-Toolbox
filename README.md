# MW-PowerShell-Toolbox

A collection of scripts that I use as part of my role as a Microsoft Modern Work Technical Specialist.

## Azure

### [Get-AzureAppRegistrations.ps1](Azure/Get-AzureAppRegistrations.ps1)

Retrieves all Azure App Registrations and displays their names and App IDs.

#### Get-AzureAppRegistrations.ps1 Example

```PowerShell
# Run the script directly - it handles authentication and retrieval
.\Azure\Get-AzureAppRegistrations.ps1
```

### [Start-AzureVMs.ps1](Azure/Start-AzureVMs.ps1)

Starts Azure Virtual Machines across resource groups.

#### Start-AzureVMs.ps1 Example

```PowerShell
# Run the script
.\Azure\Start-AzureVMs.ps1
```

## Compliance

### [Get-AuditLogResults.ps1](Compliance/Get-AuditLogResults.ps1)

Searches the unified audit log and retrieves results for specified date ranges.

#### Get-AuditLogResults.ps1 Example

```PowerShell
# Set your parameters
$startDate = "2025-06-01"
$endDate = "2025-06-24"

# Run the script
.\Compliance\Get-AuditLogResults.ps1
```

### [ContentSearch.ps1](Compliance/ContentSearch.ps1)

Performs a compliance content search and exports the results.

#### ContentSearch.ps1 Example

```PowerShell
# Set your search parameters
$upn="admin@domain.com"
$complianceSearchName = "MyContentSearch"
$mailbox = "<mailbox email address>"
$startDate="2025-02-20"
$endDate="2025-02-22"
$kql="Subject:`"`" AND sent>=$startDate AND sent<=$endDate"

# Run the script
.\Compliance\ContentSearch.ps1
```

## Copilot

### [Get-ConversationTranscriptsViaAPI.ps1](Power-Platform/Get-ConversationTranscriptsViaAPI.ps1)

Retrieves conversation transcripts from Power Platform bots via API within a specified date range.

#### Get-ConversationTranscriptsViaAPI.ps1 Example

```PowerShell
# Set your environment parameters
$clientId = "<your client id>"
$clientSecret = "<your client secret>"
$orgUrl = "<your org>.crm.dynamics.com"
$tenantDomain = "<your tenant domain>.onmicrosoft.com"
$startDate = "2025-06-01"
$endDate = "2025-06-30"

# Run the script
Get-ConversationTranscriptsViaAPI -ClientId $clientId `
    -ClientSecret $clientSecret `
    -OrgUrl $orgUrl `
    -TenantDomain $tenantDomain `
    -StartDate $startDate `
    -EndDate $endDate `
    -FieldList "content,createdon,conversationtranscriptid,_bot_conversationtranscriptid_value,metadata" `
    | Export-Csv -Path "C:\temp\conversation-transcripts.csv" -NoTypeInformation
```

### [Get-CopilotCreationAuditLogItems.ps1](Copilot/Get-CopilotCreationAuditLogItems.ps1)

Retrieves audit log entries for Copilot bot creation events.

#### Get-CopilotCreationAuditLogItems.ps1 Example

```PowerShell
# Set your parameters
$upn = "admin@yourdomain.com"
$startDate = "2025-06-01"
$endDate = "2025-06-24"

# Run the script
.\Copilot\Get-CopilotCreationAuditLogItems.ps1
```

### [Get-CopilotInteractionAuditLogItems.ps1](Copilot/Get-CopilotInteractionAuditLogItems.ps1)

Retrieves audit log entries for Copilot interaction events.

#### Get-CopilotInteractionAuditLogItems.ps1 Example

```PowerShell

# Run the script with parameters
.\Copilot\Get-CopilotInteractionAuditLogItems.ps1 -StartDate '2025-06-01' `
    -EndDate '2025-06-30' `
    -UserPrincipalName 'admin@yourdomain.com' `
    -OutputFile 'c:\temp\copilotinteractionauditlog.csv' `
    -Append
```

## Entra

### [Get-EntraUserInfo.ps1](Entra/Get-EntraUserInfo.ps1)

Retrieves detailed information about an Entra ID user.

#### Get-EntraUserInfo.ps1 Example

```PowerShell
# Set the user UPN
$upn = "user@yourdomain.com"

# Run the script
.\Entra\Get-EntraUserInfo.ps1
```

### [Get-EntraUserLicenseInfo.ps1](Entra/Get-EntraUserLicenseInfo.ps1)

Gets license information for Entra ID users.

#### Get-EntraUserLicenseInfo.ps1 Example

```PowerShell
# Set the user UPN
$upn = "user@yourdomain.com"

# Run the script
.\Entra\Get-EntraUserLicenseInfo.ps1
```

### [Update-AzureADUserUPN.ps1](Entra/Update-AzureADUserUPN.ps1)

Updates the User Principal Name (UPN) for Azure AD users.

#### Update-AzureADUserUPN.ps1 Example

```PowerShell
# Set the old and new UPN values
Update-AADUserUPN -originalUpn "user@olddomain.com" `
    -newUpn "user@newdomain.com" `
    -applyChanges `
    -logFolder 'c:\temp\upnupdatelog.csv'
```

## Misc

### [ConvertTo-SharePointDriveId.ps1](Misc/ConvertTo-SharePointDriveId.ps1)

Converts SharePoint site information to Drive IDs for Microsoft Graph API usage.

#### ConvertTo-SharePointDriveId.ps1 Example

```PowerShell
# Set the SharePoint site URL

ConvertTo-SharePointDriveId -siteId "<site GUID>" `
    -webId "<web GUID>" `
    -listId "<list GUID>"
```

## MsGraph

### [M365Reporting.ps1](MsGraph/M365Reporting.ps1)

Generates comprehensive Microsoft 365 usage and activity reports using Microsoft Graph.

#### M365Reporting.ps1 Example

```PowerShell
# Set your reporting parameters
$tenantId = "your-tenant-id"
$clientId = "your-app-registration-id"

# Run the script
.\MsGraph\M365Reporting.ps1
```

### [Get-OnlineMeetingRecordings.ps1](MsGraph/Get-OnlineMeetingRecordings.ps1)

Retrieves online meeting recordings for a specific user within a date range using Microsoft Graph.

#### Get-OnlineMeetingRecordings.ps1 Example

```PowerShell
# Set your parameters
$clientId = "your-app-registration-id"
$tenantId = "your-tenant-id"
$cert = Get-ChildItem -Path "Cert:\CurrentUser\My" | Where-Object {$_.Subject -like "*YourCertName*"}
$meetingOrganizerUserId = "user@yourdomain.com"

# Run the script
.\MsGraph\Get-OnlineMeetingRecordings.ps1
```

## Power-Platform

### [Add-AppUserviaCLI.ps1](Power-Platform/Add-AppUserviaCLI.ps1)

Adds users to Power Platform applications via CLI commands.

#### Add-AppUserviaCLI.ps1 Example

```PowerShell
# Set your parameters
$orgUrl = "https://yourorg.crm.dynamics.com/"
$role = "System Administrator"
$appId = "your-app-registration-id"

# Run the script
.\Power-Platform\Add-AppUserviaCLI.ps1
```

### [ConvertFrom-TranscriptData.ps1](Power-Platform/ConvertFrom-TranscriptData.ps1)

Converts and processes transcript data from Power Platform conversation transcripts.

#### ConvertFrom-TranscriptData.ps1 Example

```PowerShell
# Run the script to convert transcript data
.\Power-Platform\ConvertFrom-TranscriptData -TranscriptsData $transcriptsData -OutputPath "C:\temp\parsed-transcripts.txt"
```

### [Get-AllDataPolicyConnectorInfo.ps1](Power-Platform/Get-AllDataPolicyConnectorInfo.ps1)

Retrieves information about all data policy connectors in the Power Platform tenant.

#### Get-AllDataPolicyConnectorInfo.ps1 Example

```PowerShell
# Run the script directly - it handles authentication and data retrieval
Get-AllDataPolicyConnectorInfo | Export-Csv -Path "C:\temp\PowerPlatformDataPolicyConnectors.csv" -NoTypeInformation -Force
```

### [Get-BotComponentsViaAPI.ps1](Power-Platform/Get-BotComponentsViaAPI.ps1)

Gets bot components information using Power Platform APIs.

#### Get-BotComponentsViaAPI.ps1 Example

```PowerShell
# Set your environment parameters
$clientId="<your client id>"
$clientSecret="<your client secret>"
$orgUrl="<your org>.crm.dynamics.com"
$tenantDomain="<your tenant domain>.onmicrosoft.com"

# Run the script
Get-BotComponentsViaAPI -ClientId $clientId `
    -ClientSecret $clientSecret `
    -OrgUrl $orgUrl `
    -TenantDomain $tenantDomain `
    -FieldList $fieldList
```

### [Get-CopilotAgentsViaAPI.ps1](Power-Platform/Get-CopilotAgentsViaAPI.ps1)

Retrieves Copilot agents information via Power Platform APIs.

#### Get-CopilotAgentsViaAPI.ps1 Example

```PowerShell
# Run the script

Get-CopilotAgentsViaAPI -ClientId "<your client id>" `
    -ClientSecret "<your client secret>" `
    -OrgUrl "<your org>.crm.dynamics.com" `
    -TenantDomain "<your domain>.onmicrosoft.com" `
    -FieldList "botid,componentidunique,applicationmanifestinformation,name,configuration,createdon,publishedon,_ownerid_value,_createdby_value,solutionid,modifiedon,_owninguser_value,schemaname,_modifiedby_value,_publishedby_value,authenticationmode,synchronizationstatus,ismanaged" `
    | Out-File "c:\temp\bots.txt"
```

### [Get-CopilotsAndComponentsFromAllEnvironments.ps1](Power-Platform/Get-CopilotsAndComponentsFromAllEnvironments.ps1)

Gets Copilots and their components from all Power Platform environments.

#### Get-CopilotsAndComponentsFromAllEnvironments.ps1 Example

```PowerShell
Get-CopoilotsAndCompnonentsFromAllEnvironments.ps1 -ClientId "<your client id>" `
    -ClientSecret "<your client secret>" `
    -TenantDomain "<your domain>.onmicrosoft.com" | 
    Out-File "C:\temp\copilotsAndComponents.txt"
```

### [Get-PowerAppsAndConnections.ps1](Power-Platform/Get-PowerAppsAndConnections.ps1)

Gets Power Apps and their connections across all environments.

#### Get-PowerAppsAndConnections.ps1 Example

```PowerShell
# Set output parameters
Get-PowerPlatformAppsAndConnections | Export-Csv -Path "c:\temp\PowerPlatformAppsAndConnections.csv"
```

### [Get-PowerPlatformEnvironmentInfo.ps1](Power-Platform/Get-PowerPlatformEnvironmentInfo.ps1)

Retrieves detailed information about Power Platform environments.

#### Get-PowerPlatformEnvironmentInfo.ps1 Example

```PowerShell
Get-PowerPlatformEnvironmentInfo | Export-Csv -Path "c:\temp\PowerPlatformEnvironmentInfo.csv" -NoTypeInformation -Force
```

### [Get-PowerPlatformUsageReports.ps1](Power-Platform/Get-PowerPlatformUsageReports.ps1)

Generates usage reports for Power Platform services and applications.

#### Get-PowerPlatformUsageReports.ps1 Example

```PowerShell
$tenantDomain=",yourdomain.onmicrosoft.com"
$startDate = "2025-06-01"
$endDate = "2025-06-23"
$tenantId="<your tenant id>"

$usageReports=Get-PowerPlatformUsageReports -StartDate $startDate `
    -EndDate $endDate `
    -TenantDomain $tenantDomain `
    -TenantId $tenantId `
    -SleepTime 600 `
    -OutputLocation "C:\temp"

foreach ($report in $usageReports.Keys) {
    $reportType=$report
    write-host "exporting $reportType"
    $usageReports.$report | out-file "c:\temp\$reportType.csv"
}
```

### [Get-PowerPlatTenantSettingsViaAPI.ps1](Power-Platform/Get-PowerPlatTenantSettingsViaAPI.ps1)

Retrieves information about Power Platform Environments.

#### Get-PowerPlatTenantSettingsViaAPI.ps1 Example

```PowerShell
#Modify the following variables with your own values
    $clientId="<your client id>"
    $clientSecret="<your client secret>"
    $tenantDomain="<your tenant>.onmicrosoft.com>"

    .\Power-Platform\Get-PowerPlatTenantSettingsViaAPI.ps1
```

### [Get-UsersViaAPI.ps1](Power-Platform/Get-UsersViaAPI.ps1)

Retrieves user information via Power Platform APIs.

#### Get-UsersViaAPI.ps1 Example

```PowerShell
# Set your environment parameters
$clientId = "<your client id>"
$clientSecret = "<your client secret>"
$orgUrl = "<your org>.crm.dynamics.com"
$tenantDomain = "<your tenant domain>.onmicrosoft.com"

# Run the script
Get-UsersViaAPI -ClientId $clientId `
    -ClientSecret $clientSecret `
    -OrgUrl $orgUrl `
    -TenantDomain $tenantDomain `
    -FieldList "systemuserid,fullname,internalemailaddress,domainname,isdisabled,accessmode,createdon" `
    | Export-Csv -Path "C:\temp\users.csv" -NoTypeInformation
```

## SharePoint

### [Inventory-SPFarm.ps1](SharePoint/Inventory-SPFarm.ps1)

Creates an inventory of SharePoint on-premises farm components and configuration.

#### Inventory-SPFarm.ps1 Example

```PowerShell
# Set your SharePoint farm parameters
Inventory-SPFarm `
    -LogFilePrefix "Test_" `
    -DestinationFolder "d:\temp" `
    -InventoryFarmSolutions `
    -InventoryFarmFeatures `
    -InventoryWebTemplates `
    -InventoryTimerJobs `
    -InventoryWebApplications `
    -InventorySiteCollections `
    -InventorySiteCollectionAdmins `
    -InventorySiteCollectionFeatures `
    -InventoryWebPermissions `
    -InventoryWebs `
    -InventorySiteContentTypes `
    -InventoryWebFeatures `
    -InventoryLists `
    -InventoryWebWorkflowAssociations `
    -InventoryListContentTypes `
    -InventoryListWorkflowAssociations `
    -InventoryContentTypeWorkflowAssociations `
    -InventoryContentDatabases `
    -InventoryListFields `
    -InventoryListViews `
    -InventoryWebParts

```

## SharePoint-Online

### [Add-OwnersToSharePointSite.ps1](SharePoint-Online/Add-OwnersToSharePointSite.ps1)

Adds users as owners to a SharePoint site using certificate-based authentication.

#### Add-OwnersToSharePointSite.ps1 Example

```PowerShell
# Set your parameters
$siteUrl = "https://contoso.sharepoint.com/sites/yoursite"
$ownerEmails = @("user1@contoso.com", "user2@contoso.com")
$clientId = "your-app-registration-id"
$tenant = "contoso.onmicrosoft.com"
$certificatePath = "C:\path\to\certificate.pfx"

# Run the function
Add-OwnersToSharePointSite -SiteUrl $siteUrl `
    -OwnerEmails $ownerEmails `
    -ClientId $clientId `
    -Tenant $tenant `
    -CertificatePath $certificatePath
```

### [Get-CopilotAgentReport.ps1](SharePoint-Online/Get-CopilotAgentReport.ps1)

Generates reports on Copilot agent usage and activities in SharePoint Online.

#### Get-CopilotAgentReport.ps1 Example

```PowerShell
$spoAdminUrl="https://<your tenant>-admin.sharepoint.com"

.\SharePoint-Online\Get-CopilotAgentReport.ps1

```

### [Get-GraphDeltaQueryResults.ps1](SharePoint-Online/Get-GraphDeltaQueryResults.ps1)

Retrieves Microsoft Graph delta query results for tracking changes in SharePoint Online.

#### Get-GraphDeltaQueryResults.ps1 Example

```PowerShell
# Run the script to get delta query results
.\SharePoint-Online\Get-GraphDeltaQueryResults.ps1
```

### [Get-SharePointAgentCreationAuditLogItems.ps1](SharePoint-Online/Get-SharePointAgentCreationAuditLogItems.ps1)

Retrieves audit log entries for SharePoint agent creation events.

#### Get-SharePointAgentCreationAuditLogItems.ps1 Example

```PowerShell
# Set your parameters
$upn = "admin@yourdomain.com"
$startDate = "2025-06-01"
$endDate = "2025-06-24"

# Run the script
.\SharePoint-Online\Get-SharePointAgentCreationAuditLogItems.ps1
```

### [Get-SharePointAgentInteractionAuditLogItems.ps1](SharePoint-Online/Get-SharePointAgentInteractionAuditLogItems.ps1)

Retrieves audit log entries for SharePoint agent interaction events.

#### Get-SharePointAgentInteractionAuditLogItems.ps1 Example

```PowerShell
# Set your parameters
$upn = "admin@yourdomain.com"
$startDate = "2025-06-01"
$endDate = "2025-06-24"

# Run the script
.\SharePoint-Online\Get-SharePointAgentInteractionAuditLogItems.ps1
```

### [New-HubSites.ps1](SharePoint-Online/New-HubSites.ps1)

Creates SharePoint Online Hub Sites using PnP.PowerShell, with optional parent hub site association.

#### New-HubSites.ps1 Example

```PowerShell
# Create hub sites
$siteUrls = @("https://contoso.sharepoint.com/sites/Hub1", "https://contoso.sharepoint.com/sites/Hub2")
$parentHubSiteId = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# Run the script
.\SharePoint-Online\New-HubSites.ps1 -SiteUrls $siteUrls -ParentHubSiteId $parentHubSiteId
```

### [New-DemoProjectPlanDocs.ps1](SharePoint-Online/New-DemoProjectPlanDocs.ps1)

Creates demo project plan documents with random team assignments and tasks.

#### New-DemoProjectPlanDocs.ps1 Example

```PowerShell
# Requires ImportExcel and PSWriteWord modules
# Run the script to generate project plan documents
.\SharePoint-Online\New-DemoProjectPlanDocs.ps1
```

### [New-DemoProjectHubSites.ps1](SharePoint-Online/New-DemoProjectHubSites.ps1)

Creates a complete demo environment with hub sites, regional sites, and project sites with proper associations.

#### New-DemoProjectHubSites.ps1 Example

```PowerShell
# Run the script to create demo project hub structure
.\SharePoint-Online\New-DemoProjectHubSites.ps1
```

### [New-OneDriveSites.ps1](SharePoint-Online/New-OneDriveSites.ps1)

Creates new OneDrive sites for users in SharePoint Online.

#### New-OneDriveSites.ps1 Example

```PowerShell
# Set your parameters
$usernames = @("user1@domain.com", "user2@domain.com", "user3@domain.com")
$batchSize = 200
$tenantName = "yourtenant"

# Run the script function
New-OneDriveSites -usernames $usernames -batchsize $batchSize -tenantname $tenantName
```

### [Set-SPOOrgAssetLibrary.ps1](SharePoint-Online/Set-SPOOrgAssetLibrary.ps1)

Configures SharePoint Online organizational asset libraries for Office templates and images.

#### Set-SPOOrgAssetLibrary.ps1 Example

```PowerShell
# Update the tenant variable with your tenant name
$tenant = "contoso"

# Run the script to configure organizational asset libraries
.\SharePoint-Online\Set-SPOOrgAssetLibrary.ps1
```

### [Upload-Documents.ps1](SharePoint-Online/Upload-Documents.ps1)

Uploads documents to specified SharePoint sites and libraries using an input array.

#### Upload-Documents.ps1 Example

```PowerShell
# Define documents to upload
$documents = @(
    @{
        FilePath = "C:\temp\ProjectA Plan.docx"
        SiteUrl = "https://contoso.sharepoint.com/sites/ProjectA"
        Library = "Shared Documents"
    },
    @{
        FilePath = "C:\temp\ProjectB Plan.docx"
        SiteUrl = "https://contoso.sharepoint.com/sites/ProjectB"
        Library = "Shared Documents"
    }
)

# Run the script
.\SharePoint-Online\Upload-Documents.ps1
```

## Teams

### [Get-AllTeamsViaGraph.ps1](Teams/Get-AllTeamsViaGraph.ps1)

Retrieves all Microsoft Teams using Microsoft Graph API.

#### Get-AllTeamsViaGraph.ps1 Example

```PowerShell
# Set your Graph API parameters
$clientId = "your-app-registration-id"
$tenantId = "your-tenant-id"
$cert = Get-ChildItem -Path "Cert:\CurrentUser\My" | Where-Object {$_.Subject -like "*YourCertName*"}

# Run the script
.\Teams\Get-AllTeamsViaGraph.ps1
```

### [Get-ChannelMessages.ps1](Teams/Get-ChannelMessages.ps1)

Retrieves messages from specified Teams channels.

#### Get-ChannelMessages.ps1 Example

```PowerShell
# Run the script
.\Teams\Get-ChannelMessages.ps1
```

### [Get-TeamsAndMembers.ps1](Teams/Get-TeamsAndMembers.ps1)

Gets Teams and their membership information.

#### Get-TeamsAndMembers.ps1 Example

```PowerShell
# Run the script
.\Teams\Get-TeamsAndMembers.ps1
```

### [Get-UserTeams.ps1](Teams/Get-UserTeams.ps1)

Retrieves all Teams that a specific user is a member of.

#### Get-UserTeams.ps1 Example

```PowerShell
# Set the user parameters
$userId = "user@yourdomain.com"
$tenantId = "your-tenant-id"

# Run the script
.\Teams\Get-UserTeams.ps1
```

### [New-Channels.ps1](Teams/New-Channels.ps1)

Creates new channels in a specified Microsoft Team.

#### New-Channels.ps1 Example

```PowerShell
# Set your parameters
$teamId = "<your team id>"
$channelNames = @("General Discussion", "Project Updates", "Resources")

# Run the script
.\Teams\New-Channels.ps1 -TeamId $teamId -ChannelNames $channelNames
```

### [New-Teams.ps1](Teams/New-Teams.ps1)

Creates new Microsoft Teams with specified names and optional owners/members.

#### New-Teams.ps1 Example

```PowerShell
# Set your parameters
$teamNames = @("Project Alpha", "Project Beta", "Project Gamma")
$owner = "admin@yourdomain.com"
$members = @("user1@yourdomain.com", "user2@yourdomain.com")

# Run the script
.\Teams\New-Teams.ps1 -TeamNames $teamNames -Owner $owner -Members $members
```

### [Set-ChannelModerationSettings.ps1](Teams/Set-ChannelModerationSettings.ps1)

Configures moderation settings for Teams channels.

#### Set-ChannelModerationSettings.ps1 Example

```PowerShell
# Set your channel parameters
$clientId="<your client id>"
$teamId = "<your team id>"
$channelId = "<your-channel-id>"
$tenantDomain = "yourdomain.onmicrosoft.com"
$moderationSettings = @{
    "moderationSettings"= @{
        "userNewMessageRestriction"= "moderators"
        "replyRestriction" = "authorAndModerators"
        "allowNewMessageFromBots" = "false"
        "allowNewMessageFromConnectors"= "false"
    }
}

# Run the script
.\Teams\Set-ChannelModerationSettings.ps1
```