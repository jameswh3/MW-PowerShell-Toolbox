<##connect to Azure AD
write-host "Connecting to Azure AD" -f green
Connect-AzureAD -credential (Get-Credential)
#>
function update-AADUserUPN {
    param (
        $originalUpn,
        $newUpn,
        $newUpnSuffix,
		[switch]$applyChanges,
        $logFolder="c:\temp"
    )

    $logfile=($logFolder + "\upnupdatelog.csv")

    if (-not (test-path $logfile)) {
        $row = '"ObjectId","OldUpn","NewUpn","NewUpnSuffix","Status","Timestamp"'
		$row | Out-File $logfile
    }

    if (!($newUpn) -and $newUpnSuffix) {
        #newUpn variable is empty and newUpnSuffix is populated, so assume that username will be the same with updated upn suffix
        $newUpn=($originalUpn.Split("@")[0])+'@'+$newUpnSuffix
    }

    #check for a potential conflict with the new UPN
    $upnCheck=Get-AzureADUser -objectId $newUpn -ErrorAction SilentlyContinue
	
	#retrieve objectId of original UPN
    $objectId=(Get-AzureADUser -objectId $originalUpn -ErrorAction SilentlyContinue).ObjectId

    if (!($upnCheck) -or ($objectId -eq $upnCheck.ObjectId)) {
        if ($objectId) {
            $status="Attempting to update user object $objectId upn from $originalupn to $newupn"
            write-host $status
            $row = '"'+$objectId+'","'+$originalUpn+'","'+$NewUpn+'","'+$newUpnSuffix+'","'+$status+'","'+$(get-date -format 'MM-dd-yyyy hh:mm')+'"'
		    $row | Out-File $logfile -append
            if($applyChanges) {
			    Set-AzureADUser -ObjectId $ObjectId  -UserPrincipalName $newupn
		    } #if applychanges
        } else {
            $status="$originalUPN does not exist"
            write-host $status -ForegroundColor Yellow
            $row = '"'+$objectId+'","'+$originalUpn+'","'+$NewUpn+'","'+$newUpnSuffix+'","'+$status+'","'+$(get-date -format 'MM-dd-yyyy hh:mm')+'"'
		    $row | Out-File $logfile -append
        } #if else objectid
    } else {
        $status="$newUpn already taken by user object $($upnCheck.objectid), so $originalUpn cannot be updated"
        write-host $status -ForegroundColor Yellow
        $row = '"'+$objectId+'","'+$originalUpn+'","'+$NewUpn+'","'+$newUpnSuffix+'","'+$status+'","'+$(get-date -format 'MM-dd-yyyy hh:mm')+'"'
		$row | Out-File $logfile -append
    } #if else upn check and same objectid
}