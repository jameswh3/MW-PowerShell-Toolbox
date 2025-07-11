# PowerShell script to upload documents to specified SharePoint sites and libraries using an input array

# Prerequisites:
# - Install-Module -Name PnP.PowerShell
# - You must have permission to upload to the SharePoint sites

# Example input array
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

foreach ($doc in $documents) {
    $filePath = $doc.FilePath
    $siteUrl = $doc.SiteUrl
    $library = $doc.Library

    if (Test-Path $filePath) {
        Write-Host "Uploading $filePath to $siteUrl/$library..."

        # Connect to the SharePoint site
        Connect-PnPOnline -Url $siteUrl `
            -ClientId $ClientId `
            -Tenant $Tenant `
            -CertificatePath $CertificatePath

        # Upload the file to the specified library
        Add-PnPFile -Path $filePath -Folder $library

        # Disconnect after upload
        Disconnect-PnPOnline
    } else {
        Write-Host "Skipping $filePath--file does not exist."
    }
}