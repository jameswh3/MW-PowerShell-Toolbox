#Requires -Modules Microsoft.Online.SharePoint.PowerShell
Import-Module Microsoft.Online.SharePoint.PowerShell -UseWindowsPowerShell
#update with your tenant name
$tenant="contoso"
$officeTemplateLibraryUrl = "https://$tenant.sharepoint.com/sites/BrandGuide/OfficeTemplates"
$officeTemplateLibraryThumbnailUrl = "https://$tenant.sharepoint.com/sites/BrandGuide/SiteAssets/contoso_logo_dark.svg"
$imageDocumentLibraryUrl = "https://$tenant.sharepoint.com/sites/BrandGuide/Assets"
$imageDocumentLibraryThumbnailUrl = "https://$tenant.sharepoint.com/sites/BrandGuide/SiteAssets/contoso_logo_dark.svg"

Connect-SPOService -Url "https://$tenant-admin.sharepoint.com"

Add-SPOOrgAssetsLibrary -LibraryURL $officeTemplateLibraryUrl -ThumbnailURL $officeTemplateLibraryThumbnailUrl -OrgAssetType OfficeTemplateLibrary

Add-SPOOrgAssetsLibrary -LibraryURL $imageDocumentLibraryUrl -ThumbnailURL $imageDocumentLibraryThumbnailUrl -OrgAssetType ImageDocumentLibrary -CopilotSearchable $true