
$TenantId = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
$ClientId = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
$CertificatePath = 'c:\mycertificates\certificate.pfx'
$SiteId = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
$DriveId = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$FolderPath="https://yourtenant.sharepoint.com/sites/YourSite/YourFolder"

$searchPhrase = "southern"

$searchBody = @{
    requests = @(@{
        entityTypes = @("driveItem")
        query = @{ 
            queryString = "path:`"$FolderPath`" AND `"$searchPhrase`"" 
        }
        region = "NAM"  # North America - change to your region if different
        from = 0
        size = 25
    })
} | ConvertTo-Json -Depth 3

# Connect to Microsoft Graph

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Yellow
$Certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($CertificatePath)
Connect-MgGraph -TenantId $TenantId -ClientId $ClientId -Certificate $Certificate -NoWelcome
Write-Host "✓ Connected to Microsoft Graph" -ForegroundColor Green


# Execute Microsoft Graph Search
Write-Host "`n--- Initial Microsoft Graph Search ---" -ForegroundColor Magenta
Write-Host "Executing search query..." -ForegroundColor Yellow

# Define search parameters
# Search for files containing "cyber" in the specified folder
<#
Write-Host "Search body:" -ForegroundColor Gray
Write-Host $searchBody -ForegroundColor Gray
#>
$searchResponse = Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/v1.0/search/query" -Method POST -Body $searchBody -ContentType "application/json"

Write-Host "✓ Search API call completed" -ForegroundColor Green
# Check if we have valid response structure
if ($searchResponse -and $searchResponse.value -and $searchResponse.value.Count -gt 0) {
    $hitsContainer = $searchResponse.value[0].hitsContainers
    
    if ($hitsContainer -and $hitsContainer.Count -gt 0 -and $hitsContainer[0].hits) {
        $hits = $hitsContainer[0].hits
        Write-Host "Found $($hits.Count) search results:" -ForegroundColor Green
        
        $hits | Select-Object @{N='Name';E={$_.resource.name}}, 
                                @{N='Modified';E={$_.resource.lastModifiedDateTime}}, 
                                @{N='Path';E={$_.resource.parentReference.path}},
                                @{N='WebUrl';E={$_.resource.webUrl}} | Format-Table -AutoSize
    } else {
        Write-Host "No results found for search term '$searchPhrase' in path '$FolderPath'" -ForegroundColor Yellow
    }
} else {
    Write-Host "Search returned empty results" -ForegroundColor Yellow
}

# Get initial file listing
Write-Host "`nGetting current drive items..." -ForegroundColor Yellow
$fileMetadata = Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/v1.0/sites/$SiteId/drives/$DriveId/root/children" -Method GET
Write-Host "Current files:" -ForegroundColor Cyan
$fileMetadata.value | Select-Object name, lastModifiedDateTime, deleted | Format-Table -AutoSize

# Pause for file deletion
Write-Host "`n*** PAUSE FOR FILE OPERATIONS ***" -ForegroundColor Magenta
Write-Host "You can now delete a file from the SharePoint library." -ForegroundColor Yellow
Write-Host "Press any key to continue with the delta query..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Execute delta query
Write-Host "`nExecuting delta query..." -ForegroundColor Yellow
$deltaResponse = Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/v1.0/sites/$SiteId/drives/$DriveId/root/delta" -Method GET
Write-Host "✓ Delta Query Results:" -ForegroundColor Green
Write-Host "Number of items: $($deltaResponse.value.Count)" -ForegroundColor Cyan

if ($deltaResponse.value.Count -gt 0) {
    $deltaResponse.value | Select-Object name, lastModifiedDateTime, deleted | Format-Table -AutoSize
}

# Show delta link for future queries
if ($deltaResponse.'@odata.deltaLink') {
    Write-Host "`nDelta Link:" -ForegroundColor Yellow
    Write-Host $deltaResponse.'@odata.deltaLink' -ForegroundColor Cyan
}

# Execute Microsoft Graph Search
Write-Host "`n--- Post Deletion Microsoft Graph Search ---" -ForegroundColor Magenta
Write-Host "Executing search query..." -ForegroundColor Yellow

# Define search parameters
# Search for files containing "cyber" in the specified folder

$searchResponse = Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/v1.0/search/query" -Method POST -Body $searchBody -ContentType "application/json"

Write-Host "✓ Search API call completed" -ForegroundColor Green

# Check if we have valid response structure
if ($searchResponse -and $searchResponse.value -and $searchResponse.value.Count -gt 0) {
    $hitsContainer = $searchResponse.value[0].hitsContainers
    
    if ($hitsContainer -and $hitsContainer.Count -gt 0 -and $hitsContainer[0].hits) {
        $hits = $hitsContainer[0].hits
        Write-Host "Found $($hits.Count) search results:" -ForegroundColor Green
        
        $hits | Select-Object @{N='Name';E={$_.resource.name}}, 
                                @{N='Modified';E={$_.resource.lastModifiedDateTime}}, 
                                @{N='Path';E={$_.resource.parentReference.path}},
                                @{N='WebUrl';E={$_.resource.webUrl}} | Format-Table -AutoSize
    } else {
        Write-Host "No results found for search term '$searchPhrase' in path '$FolderPath'" -ForegroundColor Yellow
    }
} else {
    Write-Host "Search returned empty results" -ForegroundColor Yellow
}
