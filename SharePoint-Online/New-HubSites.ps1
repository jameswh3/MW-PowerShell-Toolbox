<#
.SYNOPSIS
    Creates SharePoint Online Hub Sites using PnP.PowerShell, with optional parent hub site association.

.DESCRIPTION
    This script creates one or more SharePoint Online Hub Sites using the PnP.PowerShell module.
    Optionally, it can associate the new hub site with a parent hub site if specified.

.PARAMETER SiteUrls
    Array of site URLs to register as hub sites.

.PARAMETER ParentHubSiteId
    (Optional) The Hub Site ID (GUID) of the parent hub site to associate with.

.EXAMPLE
    .\New-HubSites.ps1 -SiteUrls "https://contoso.sharepoint.com/sites/Hub1","https://contoso.sharepoint.com/sites/Hub2"
    .\New-HubSites.ps1 -SiteUrls "https://contoso.sharepoint.com/sites/Hub3" -ParentHubSiteId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
#>

param(
    [Parameter(Mandatory = $true)]
    [string[]]$SiteUrls,

    [Parameter(Mandatory = $false)]
    [string]$ParentHubSiteId
)

# Ensure PnP.PowerShell is installed and imported
if (-not (Get-Module -ListAvailable -Name "PnP.PowerShell")) {
    Install-Module -Name "PnP.PowerShell" -Scope CurrentUser -Force
}
Import-Module PnP.PowerShell -ErrorAction Stop

# Connect to SharePoint Online (interactive)
Write-Host "Connecting to SharePoint Online..." -ForegroundColor Cyan
Connect-PnPOnline -Interactive

foreach ($siteUrl in $SiteUrls) {
    Write-Host "Registering $siteUrl as a hub site..." -ForegroundColor Yellow
    try {
        $hubSite = Register-PnPHubSite -Site $siteUrl -ErrorAction Stop
        Write-Host "Hub site registered: $($hubSite.Title) ($siteUrl)" -ForegroundColor Green

        if ($ParentHubSiteId) {
            Write-Host "Associating $siteUrl with parent hub site ID $ParentHubSiteId..." -ForegroundColor Cyan
            Add-PnPHubSiteAssociation -Site $siteUrl -HubSiteId $ParentHubSiteId -ErrorAction Stop
            Write-Host "Associated $siteUrl with parent hub site." -ForegroundColor Green
        }
    }
    catch {
        Write-Host "Error processing $siteUrl $_" -ForegroundColor Red
    }
}

Write-Host "Script completed." -ForegroundColor Magenta