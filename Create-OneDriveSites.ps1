function Create-OneDriveSites {
    param (
        $usernames,
        $batchsize=200,
        $tenantname='yourtenantnamehere'

    )
    BEGIN {
        $SPOAdminUrl="https://$tenantname-admin.sharepoint.com"
        Connect-SPOService -Url $SPOAdminUrl -credential (get-credential)
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
            Request-SPOPersonalSite -UserEmails $batch -NoWait
            $batchnum++
        }
        
    }
    END {

    }
}


Create-OneDriveSites -usernames 'a','b','c','d','e','f','g'