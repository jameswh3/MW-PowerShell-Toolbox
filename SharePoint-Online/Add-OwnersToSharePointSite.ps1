function Add-OwnersToSharePointSite {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SiteUrl,

        [Parameter(Mandatory = $true)]
        [string[]]$OwnerEmails,

        [Parameter(Mandatory = $true)]
        [string]$ClientId,

        [Parameter(Mandatory = $true)]
        [string]$Tenant,

        [Parameter(Mandatory = $true)]
        [string]$CertificatePath
    )

    # Connect to SharePoint Online using PnP PowerShell
    Connect-PnPOnline -Url $SiteUrl `
        -ClientId $ClientId `
        -Tenant $Tenant `
        -CertificatePath $CertificatePath

    # Get the Owners group
    $ownersGroup = Get-PnPGroup -AssociatedOwnerGroup

    foreach ($email in $OwnerEmails) {
        # Add user to Owners group
        Add-PnPGroupMember -Identity $ownersGroup.Id -LoginName $email
        Write-Host "Added $email to $($ownersGroup.Title)"
    }
}