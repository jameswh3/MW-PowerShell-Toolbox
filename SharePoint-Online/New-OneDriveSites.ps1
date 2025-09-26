#Requires -Modules Microsoft.Online.SharePoint.PowerShell
Import-Module Microsoft.Online.SharePoint.PowerShell -UseWindowsPowerShell
function New-OneDriveSites {
    param (
        [string[]]$usernames,
        $batchsize=200,
        $tenantname='yourtenantnamehere'

    )
    BEGIN {
        $SPOAdminUrl="https://$tenantname-admin.sharepoint.com"
        Connect-SPOService -Url $SPOAdminUrl
        $batches = New-Object 'System.Collections.Generic.List[psobject]'
        for ($i=0; $i -lt $usernames.count; $i += $batchsize) {
            $batches += ,@($usernames[$i..($i+($batchsize-1))]);
        }
    }
    PROCESS {
        $usernames.count
        $batchnum=1
        foreach ($batch in $batches) {
            $emails=$batch -join ","
            $emails
            "Processing batch number $batchnum"
            #Request-SPOPersonalSite -UserEmails $batch -NoWait -
            $batchnum++
        }
        
    }
    END {

    }
}

New-OneDriveSites -usernames 'user1@example.com','user2@example.com','user3@example.com' -tenantname '<your tenant name>'