# MW-PowerShell-Toolbox

A collection of scripts that I use as part of my role as a Microsoft Modern Work Technical Specialist.

## Scripts Overview

### Compliance

| Script Name | Description |
|--------------------------------------------------|-----------------------------------------------------------------------------------------------|
| [AuditLogSearches.ps1](Compliance/AuditLogSearches.ps1) | Searches the unified audit log for specified date ranges. |
| [ContentSearch.ps1](Compliance/ContentSearch.ps1) | Performs a compliance content search and exports the results. |

### Copilot

| Script Name | Description |
|--------------------------------------------------|-----------------------------------------------------------------------------------------------|
| [Get-CopilotInteractionAuditLogItems.ps1](Copilot/Get-CopilotInteractionAuditLogItems.ps1) | Retrieves and processes Copilot interaction events from the unified audit log. |

### Entra

| Script Name | Description |
|--------------------------------------------------|-----------------------------------------------------------------------------------------------|
| [EntraUserInfo.ps1](Entra/EntraUserInfo.ps1) | Connects to Entra and retrieves user information based on UPN. |
| [Update-AzureADUserUPN.ps1](Entra/Update-AzureADUserUPN.ps1) | Updates the User Principal Name (UPN) for Azure AD users. |

### MsGraph

| Script Name | Description |
|--------------------------------------------------|-----------------------------------------------------------------------------------------------|
| [Get-MsGraphUserDetails.ps1](MsGraph/Get-MsGraphUserDetails.ps1) | Retrieves user details from Microsoft Graph. |

### Power-Platform

| Script Name | Description |
|--------------------------------------------------|-----------------------------------------------------------------------------------------------|
| [Get-AllDataPolicyConnectortInfo.ps1](Power-Platform/Get-AllDataPolicyConnectortInfo.ps1) | Retrieves all Data Loss Prevention (DLP) policy connector information from the Power Platform admin center. |
| [Get-EnvironmentInfo.ps1](Power-Platform/Get-EnvironmentInfo.ps1) | Retrieves information about Power Platform environments in your tenant. |
| [Get-EnvironmentInfoFromCLI.ps1](Power-Platform/Get-EnvironmentInfoFromCLI.ps1) | Parses Power Platform CLI environment output into PowerShell objects for further analysis. |
| [Get-PowerAppsAndConnections.ps1](Power-Platform/InventoryAppsAndConnections.ps1) | Gets details for Power Apps and their Connections. |
| [Get-PowerAppRoleAssignments.ps1](Power-Platform/Get-PowerAppRoleAssignments.ps1) | Retrieves role assignments for Power Apps. |
| [Get-PowerPlatformLicenseCounts.ps1](Power-Platform/Get-PowerPlatformLicenseCounts.ps1) | Retrieves license count information for Power Platform products. |


### SharePoint

| Script Name | Description |
|--------------------------------------------------|-----------------------------------------------------------------------------------------------|
| [Inventory-SPFarm.ps1](SharePoint/Inventory-SPFarm.ps1) | Inventories various components of a SharePoint farm and outputs the results to CSV files. |

### SharePoint-Online

| Script Name | Description |
|--------------------------------------------------|-----------------------------------------------------------------------------------------------|
| [Add-SharePointAgentDisclaimer.ps1](SharePoint-Online/Add-SharePointAgentDisclaimer.ps1) | Adds a disclaimer to the welcome message of a SharePoint agent. |
| [Create-OneDriveSites.ps1](SharePoint-Online/Create-OneDriveSites.ps1) | Creates OneDrive sites for a list of users in batches. |
