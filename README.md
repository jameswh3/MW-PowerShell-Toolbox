# MW-PowerShell-Toolbox

A collection of scripts that I use as part of my role as a Technical Specialist. This repository contains various PowerShell scripts for managing and automating tasks.

## Scripts Overview

### Compliance

| Script Name | Description |
|--------------------------------------------------|-----------------------------------------------------------------------------------------------|
| [AuditLogSearches.ps1](Compliance/AuditLogSearches.ps1) | Searches the unified audit log for specified date ranges. |
| [ContentSearch.ps1](Compliance/ContentSearch.ps1) | Performs a compliance content search and exports the results. |

### Copilot

| Script Name | Description |
|--------------------------------------------------|-----------------------------------------------------------------------------------------------|
| [Get-CopilotAuditLogItems.ps1](Copilot/Get-CopilotAuditLogItems.ps1) | Retrieves and processes Copilot interaction events from the unified audit log.                 |

### Entra

| Script Name | Description |
|--------------------------------------------------|-----------------------------------------------------------------------------------------------|
| [EntraUserInfo.ps1](Entra/EntraUserInfo.ps1) | Connects to Entra and retrieves user information based on UPN. |
| [Update-AzureADUserUPN.ps1](Entra/Update-AzureADUserUPN.ps1) | Updates the User Principal Name (UPN) for Azure AD users. |

### SharePoint

| Script Name | Description |
|--------------------------------------------------|-----------------------------------------------------------------------------------------------|
| [Inventory-SPFarm.ps1](SharePoint/Inventory-SPFarm.ps1) | Inventories various components of a SharePoint farm and outputs the results to CSV files. |
| [Add-SharePointAgentDisclaimer.ps1](SharePoint-Online/Add-SharePointAgentDisclaimer.ps1) | Adds a disclaimer to the welcome message of a SharePoint agent. |
| [Create-OneDriveSites.ps1](SharePoint-Online/Create-OneDriveSites.ps1) | Creates OneDrive sites for a list of users in batches. |

### Power-Platform

| Script Name | Description |
|--------------------------------------------------|-----------------------------------------------------------------------------------------------|
| [InventoryAppsAndConnections.ps1](Power-Platform/InventoryAppsAndConnections.ps1) | Gets details for Power Apps and their Connections |
