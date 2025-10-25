<#
.SYNOPSIS
    Gets metadata properties of a file in a SharePoint document library.

.DESCRIPTION
    This script connects to SharePoint Online and retrieves metadata properties 
    of a specified file in a document library using the file name and library URL.

.PARAMETER SiteUrl
    The URL of the SharePoint site (e.g., https://tenant.sharepoint.com/sites/sitename)

.PARAMETER LibraryUrl
    The relative URL of the document library (e.g., /sites/sitename/Shared Documents)

.PARAMETER FileName
    The name of the file to check metadata for

.PARAMETER Credential
    Optional PSCredential object for authentication

.EXAMPLE
    .\Get-SharePointFileProperties.ps1 -SiteUrl "https://contoso.sharepoint.com/sites/team" -LibraryUrl "/sites/team/Shared Documents" -FileName "Document.docx"

.NOTES
    Requires PnP.PowerShell module: Install-Module PnP.PowerShell
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$SiteUrl,
    
    [Parameter(Mandatory = $true)]
    [string]$LibraryUrl,
    
    [Parameter(Mandatory = $true)]
    [string]$FileName,
    
    [Parameter(Mandatory = $true)]
    [string]$ClientId,

    [Parameter(Mandatory = $true)]
    [string]$Tenant,

    [Parameter(Mandatory = $true)]
    [string]$CertificatePath
)

# Import required module
try {
    Import-Module PnP.PowerShell -ErrorAction Stop
    Write-Host "PnP.PowerShell module loaded successfully" -ForegroundColor Green
}
catch {
    Write-Error "PnP.PowerShell module is required. Install it using: Install-Module PnP.PowerShell"
    exit 1
}

try {
    # Connect to SharePoint Online
    Write-Host "Connecting to SharePoint site: $SiteUrl" -ForegroundColor Yellow
    
    # Validate and clean LibraryUrl
    if ([string]::IsNullOrWhiteSpace($LibraryUrl)) {
        throw "LibraryUrl parameter cannot be null or empty"
    }
    
    # Ensure LibraryUrl starts with /
    if (-not $LibraryUrl.StartsWith('/')) {
        $LibraryUrl = '/' + $LibraryUrl
    }
    
    # Remove trailing slash if present
    $LibraryUrl = $LibraryUrl.TrimEnd('/')
    
    # Connect to the SharePoint site
    Connect-PnPOnline -Url $siteUrl `
        -ClientId $ClientId `
        -Tenant $Tenant `
        -CertificatePath $CertificatePath
    
    Write-Host "Connected successfully" -ForegroundColor Green
    
    # Construct the full file URL
    $fileUrl = "$LibraryUrl/$FileName"
    Write-Host "Searching for file at URL: $fileUrl" -ForegroundColor Yellow
    
    # Try to get the file with better error handling
    try {
        $file = Get-PnPFile -Url $fileUrl -ErrorAction Stop
    }
    catch {
        Write-Host "Direct file lookup failed. Attempting alternative methods..." -ForegroundColor Yellow
        
        # For OneDrive personal sites, try without the trailing folder structure
        if ($SiteUrl -like "*-my.sharepoint.com*") {
            # Get the personal site identifier from LibraryUrl
            $urlParts = $LibraryUrl.Split('/')
            $personalSiteId = $urlParts[2]  # Should be something like "adile_j3msft_com"
            
            # Try different path variations for OneDrive
            $alternativeFileUrl = "/personal/$personalSiteId/Documents/$FileName"
            Write-Host "Trying alternative URL for OneDrive: $alternativeFileUrl" -ForegroundColor Yellow
            
            try {
                $file = Get-PnPFile -Url $alternativeFileUrl -ErrorAction Stop
                $fileUrl = $alternativeFileUrl  # Update the working URL
            }
            catch {
                # Try with the subfolder if it exists in the original path
                if ($urlParts.Count -gt 4) {
                    $subFolder = ($urlParts[4..($urlParts.Count-1)] -join '/')
                    $subFolderUrl = "/personal/$personalSiteId/Documents/$subFolder/$FileName"
                    Write-Host "Trying with subfolder: $subFolderUrl" -ForegroundColor Yellow
                    
                    try {
                        $file = Get-PnPFile -Url $subFolderUrl -ErrorAction Stop
                        $fileUrl = $subFolderUrl
                    }
                    catch {
                        throw "File '$FileName' not found. Tried paths: '$fileUrl', '$alternativeFileUrl', '$subFolderUrl'"
                    }
                }
                else {
                    throw "File '$FileName' not found. Tried paths: '$fileUrl', '$alternativeFileUrl'"
                }
            }
        }
        else {
            throw "File '$FileName' not found at '$fileUrl'. Error: $($_.Exception.Message)"
        }
    }
    
    if ($file) {
        Write-Host "File found! Retrieving metadata..." -ForegroundColor Green
        Write-Host "File location: $($file.ServerRelativeUrl)" -ForegroundColor Green
        
        # Extract list name from the file's actual location
        $actualLibraryPath = Split-Path $file.ServerRelativeUrl -Parent
        $listName = Split-Path $actualLibraryPath -Leaf
        
        # For OneDrive, the list name is typically "Documents"
        if ($SiteUrl -like "*-my.sharepoint.com*" -and $listName -eq "Documents") {
            $listName = "Documents"
        }
        
        Write-Host "Using list name: '$listName'" -ForegroundColor Yellow
        
        # Get file properties and metadata with improved error handling
        try {
            $listItem = Get-PnPListItem -List $listName -Query "<View><Query><Where><Eq><FieldRef Name='FileLeafRef'/><Value Type='Text'>$FileName</Value></Eq></Where></Query></View>" -ErrorAction Stop
        }
        catch {
            Write-Host "Failed to get list item with list name '$listName'. Trying alternative method..." -ForegroundColor Yellow
            
            # Alternative: Get the list item directly from the file
            $list = Get-PnPList | Where-Object { $_.RootFolder.ServerRelativeUrl -eq $actualLibraryPath }
            if ($list) {
                $listItem = Get-PnPListItem -List $list.Title -Query "<View><Query><Where><Eq><FieldRef Name='FileLeafRef'/><Value Type='Text'>$FileName</Value></Eq></Where></Query></View>"
            }
            else {
                throw "Could not find the document library at '$actualLibraryPath'"
            }
        }
        
        if ($listItem) {
            # Create custom object with file properties
            $fileProperties = [PSCustomObject]@{
                FileName = $file.Name
                FilePath = $file.ServerRelativeUrl
                FileSize = [math]::Round($file.Length / 1KB, 2)
                Created = $listItem.FieldValues.Created
                Modified = $listItem.FieldValues.Modified
                CreatedBy = $listItem.FieldValues.Author.LookupValue
                ModifiedBy = $listItem.FieldValues.Editor.LookupValue
                CheckoutUser = $listItem.FieldValues.CheckoutUser.LookupValue
                Title = $listItem.FieldValues.Title
                ContentType = $listItem.FieldValues.ContentType.LookupValue
                Version = $listItem.FieldValues._UIVersionString
            }
            
            # Display basic properties
            Write-Host "`n=== FILE PROPERTIES ===" -ForegroundColor Cyan
            $fileProperties | Format-List
            
            # Display all metadata fields
            Write-Host "`n=== ALL METADATA FIELDS ===" -ForegroundColor Cyan
            $listItem.FieldValues.GetEnumerator() | 
                Where-Object { $_.Key -notlike "*." -and $_.Value -ne $null } |
                Sort-Object Key |
                ForEach-Object {
                    $value = if ($_.Value.GetType().Name -eq "FieldLookupValue") {
                        $_.Value.LookupValue
                    } elseif ($_.Value.GetType().Name -eq "FieldUserValue") {
                        $_.Value.LookupValue
                    } else {
                        $_.Value
                    }
                    Write-Host "$($_.Key): $value" -ForegroundColor White
                }
            
            # Return the properties object
            return $fileProperties
        }
        else {
            Write-Warning "Could not retrieve list item metadata for the file"
        }
    }
    else {
        Write-Error "File '$FileName' not found in library '$LibraryUrl'"
    }
}
catch {
    Write-Error "Error occurred: $($_.Exception.Message)"
    Write-Error "Stack trace: $($_.ScriptStackTrace)"
    
    # Add debugging information
    Write-Host "`nDebugging Information:" -ForegroundColor Red
    Write-Host "SiteUrl: '$SiteUrl'" -ForegroundColor Red
    Write-Host "LibraryUrl: '$LibraryUrl'" -ForegroundColor Red
    Write-Host "FileName: '$FileName'" -ForegroundColor Red
    if ($fileUrl) {
        Write-Host "Constructed FileUrl: '$fileUrl'" -ForegroundColor Red
    }
    
    # Add suggestions for OneDrive paths
    if ($SiteUrl -like "*-my.sharepoint.com*") {
        Write-Host "`nFor OneDrive personal sites, try these LibraryUrl formats:" -ForegroundColor Yellow
        Write-Host "  - /personal/username_domain_com/Documents" -ForegroundColor Yellow
        Write-Host "  - /personal/username_domain_com/Documents/FolderName" -ForegroundColor Yellow
    }
}
finally {
    # Disconnect from SharePoint
    try {
        # Disconnect-PnPOnline
        Write-Host "Disconnected from SharePoint" -ForegroundColor Green
    }
    catch {
        Write-Warning "Could not disconnect cleanly from SharePoint"
    }
}