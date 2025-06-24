# MW-PowerShell-Toolbox

A collection of scripts that I use as part of my role as a Microsoft Modern Work Technical Specialist.

## Scripts Overview

### Azure

| Script Name | Description |
|--------------------------------------------------|-----------------------------------------------------------------------------------------------|
| [Get-AzureAppRegistrations.ps1](Azure/Get-AzureAppRegistrations.ps1) | Retrieves all Azure App Registrations and displays their names and App IDs. |

### Compliance

| Script Name | Description |
|--------------------------------------------------|-----------------------------------------------------------------------------------------------|
| [AuditLogSearches.ps1](Compliance/AuditLogSearches.ps1) | Searches the unified audit log for specified date ranges. |
| [ContentSearch.ps1](Compliance/ContentSearch.ps1) | Performs a compliance content search and exports the results. |

### Copilot

| Script Name | Description |
|--------------------------------------------------|-----------------------------------------------------------------------------------------------|
| [Get-CopilotCreationAuditLogItems.ps1](Copilot/Get-CopilotCreationAuditLogItems.ps1) | Retrieves audit log entries for Copilot bot creation events. |
| [Get-CopilotInteractionAuditLogItems.ps1](Copilot/Get-CopilotInteractionAuditLogItems.ps1) | Retrieves audit log entries for Copilot interaction events. |

### Entra

| Script Name | Description |
|--------------------------------------------------|-----------------------------------------------------------------------------------------------|
| [Get-EntraUserInfo.ps1](Entra/Get-EntraUserInfo.ps1) | Retrieves detailed information about an Entra ID user. |
| [Get-EntraUserLicenseInfo.ps1](Entra/Get-EntraUserLicenseInfo.ps1) | Gets license information for Entra ID users. |
| [Update-AzureADUserUPN.ps1](Entra/Update-AzureADUserUPN.ps1) | Updates the User Principal Name (UPN) for Azure AD users. |

### Misc

| Script Name | Description |
|--------------------------------------------------|-----------------------------------------------------------------------------------------------|
| [ConvertTo-SharePointDriveId.ps1](Misc/ConvertTo-SharePointDriveId.ps1) | Converts SharePoint site information to Drive IDs for Microsoft Graph API usage. |

### MsGraph

| Script Name | Description |
|--------------------------------------------------|-----------------------------------------------------------------------------------------------|
| [M365Reporting.ps1](MsGraph/M365Reporting.ps1) | Generates comprehensive Microsoft 365 usage and activity reports using Microsoft Graph. |

### Power-Platform

| Script Name | Description |
|--------------------------------------------------|-----------------------------------------------------------------------------------------------|
| [Add-AppUserviaCLI.ps1](Power-Platform/Add-AppUserviaCLI.ps1) | Adds users to Power Platform applications via CLI commands. |
| [Get-AllDataPolicyConnectorInfo.ps1](Power-Platform/Get-AllDataPolicyConnectorInfo.ps1) | Retrieves information about all data policy connectors in the Power Platform tenant. |
| [Get-BotComponentsViaAPI.ps1](Power-Platform/Get-BotComponentsViaAPI.ps1) | Gets bot components information using Power Platform APIs. |
| [Get-CopilotAgentsViaAPI.ps1](Power-Platform/Get-CopilotAgentsViaAPI.ps1) | Retrieves Copilot agents information via Power Platform APIs. |
| [Get-CopilotsAndComponentsFromAllEnvironments.ps1](Power-Platform/Get-CopilotsAndComponentsFromAllEnvironments.ps1) | Gets Copilots and their components from all Power Platform environments. |
| [Get-EnvironmentInfo.ps1](Power-Platform/Get-EnvironmentInfo.ps1) | Retrieves detailed information about Power Platform environments. |
| [Get-PowerAppsAndConnections.ps1](Power-Platform/Get-PowerAppsAndConnections.ps1) | Gets Power Apps and their connections across all environments. |
| [Get-PowerPlatformUsageReports.ps1](Power-Platform/Get-PowerPlatformUsageReports.ps1) | Generates usage reports for Power Platform services and applications. |

### SharePoint

| Script Name | Description |
|--------------------------------------------------|-----------------------------------------------------------------------------------------------|
| [Inventory-SPFarm.ps1](SharePoint/Inventory-SPFarm.ps1) | Creates an inventory of SharePoint on-premises farm components and configuration. |

### SharePoint-Online

| Script Name | Description |
|--------------------------------------------------|-----------------------------------------------------------------------------------------------|
| [Check-SPOCopilotAgentTrialUsage.ps1](SharePoint-Online/Check-SPOCopilotAgentTrialUsage.ps1) | Checks SharePoint Online Copilot agent trial usage and licensing. |
| [CopilotAgentReporting.ps1](SharePoint-Online/CopilotAgentReporting.ps1) | Generates reports on Copilot agent usage and activities in SharePoint Online. |
| [Get-SharePointAgentCreationAuditLogItems.ps1](SharePoint-Online/Get-SharePointAgentCreationAuditLogItems.ps1) | Retrieves audit log entries for SharePoint agent creation events. |
| [Get-SharePointAgentInteractionAuditLogItems.ps1](SharePoint-Online/Get-SharePointAgentInteractionAuditLogItems.ps1) | Retrieves audit log entries for SharePoint agent interaction events. |
| [New-OneDriveSites.ps1](SharePoint-Online/New-OneDriveSites.ps1) | Creates new OneDrive sites for users in SharePoint Online. |

### Teams

| Script Name | Description |
|--------------------------------------------------|-----------------------------------------------------------------------------------------------|
| [Get-AllTeamsViaGraph.ps1](Teams/Get-AllTeamsViaGraph.ps1) | Retrieves all Microsoft Teams using Microsoft Graph API. |
| [Get-TeamsAndMembers.ps1](Teams/Get-TeamsAndMembers.ps1) | Gets Teams and their membership information. |
| [Get-UserTeams.ps1](Teams/Get-UserTeams.ps1) | Retrieves all Teams that a specific user is a member of. |
| [Set-ChannelModerationSettings.ps1](Teams/Set-ChannelModerationSettings.ps1) | Configures moderation settings for Teams channels. |
