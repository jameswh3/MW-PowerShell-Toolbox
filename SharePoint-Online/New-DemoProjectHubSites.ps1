# Requires: PnP.PowerShell module
# Install-Module -Name "PnP.PowerShell" -Scope CurrentUser


# Define site properties
$sites = @(
    @{
        Title = "Project Hub Site"
        Url = "https://contoso.sharepoint.com/sites/projecthub"
        Owner = "user1@contoso.com"
        Description = "Central hub for all projects"
        },
        @{
        Title = "NorthAm Regional Site"
        Url = "https://contoso.sharepoint.com/sites/northamprojects"
        Owner = "user2@contoso.com"
        Description = "North America regional site for projects"
        },
        @{
        Title = "LATAM Regional Site"
        Url = "https://contoso.sharepoint.com/sites/latamprojects"
        Owner = "user3@contoso.com"
        Description = "Latin America regional site for projects"
        },
        @{
        Title = "APAC Regional Site"
        Url = "https://contoso.sharepoint.com/sites/apacprojects"
        Owner = "user4@contoso.com"
        Description = "Asia-Pacific regional site for projects"
        },
        @{
        Title = "EMEA Regional Site"
        Url = "https://contoso.sharepoint.com/sites/emeaprojects"
        Owner = "user5@contoso.com"
        Description = "Europe, Middle East, and Africa regional site for projects"
        },
        @{
        Title = "Antarctica Regional Site"
        Url = "https://contoso.sharepoint.com/sites/antarcticaprojects"
        Owner = "user6@contoso.com"
        Description = "Antarctica regional site for projects"
    }
)

foreach ($site in $sites) {
    Write-Host "Provisioning site: $($site.Title)"
    New-PnPSite -Type CommunicationSite `
        -Title $site.Title `
        -Url $site.Url `
        -Owner $site.Owner `
        -Description $site.Description
}

foreach ($site in $sites) {
    $hubSite = Register-PnPHubSite -Site $site.Url -ErrorAction Stop
    Write-Host "Hub site registered: $($hubSite.Title) $($site.Url)" -ForegroundColor Green
}

# Associate each regional site with the Project Hub Site
$projectHubUrl = $sites[0].Url

foreach ($site in $sites[1..($sites.Count - 1)]) {
    Write-Host "Associating $($site.Title) with Hub Site"

    Add-PnPHubSiteAssociation -Site $site.Url -HubSite $projectHubUrl -ErrorAction Stop
}

# Create 100 project site collections and associate them with regional hubs

# Regional hub mapping
$regionalHubs = @{
    "NorthAm"     = $sites[1].Url
    "EMEA"        = $sites[4].Url
    "LATAM"       = $sites[2].Url
    "APAC"        = $sites[3].Url
    "Antarctica"  = $sites[5].Url
}

# Distribution: NorthAm=30, EMEA=25, LATAM=20, APAC=15, Antarctica=10
$distribution = @(
    @{ Region = "NorthAm";     Count = 30 },
    @{ Region = "EMEA";        Count = 25 },
    @{ Region = "LATAM";       Count = 20 },
    @{ Region = "APAC";        Count = 15 },
    @{ Region = "Antarctica";  Count = 10 }
)

$projectSites = @()
$projectNumber = 1

foreach ($dist in $distribution) {
    for ($i = 1; $i -le $dist.Count; $i++) {
        $region = $dist.Region
        $siteUrl = "https://contoso.sharepoint.com/sites/project$($projectNumber)"
        $title = "Project $($projectNumber) Site"
        $owner = "user1@contoso.com"
        $description = "Project $($projectNumber) for $region region"
        $projectSites += @{
            Title = $title
            Url = $siteUrl
            Alias = "project$($projectNumber)"
            Owner = $owner
            Description = $description
            Region = $region
        }
        $projectNumber++
    }
}

foreach ($proj in $projectSites) {
    Write-Host "Provisioning project site: $($proj.Title)"
    New-PnPSite -Type TeamSite `
        -Title $proj.Title `
        -Alias $proj.Alias `
        -Owner $proj.Owner `
        -Description $proj.Description
}

foreach ($proj in $projectSites) {
    $hubUrl = $regionalHubs[$proj.Region]
    Write-Host "Associating $($proj.Title) with $($proj.Region) hub"
    Add-PnPHubSiteAssociation -Site $proj.Url -HubSite $hubUrl -ErrorAction Stop
}

