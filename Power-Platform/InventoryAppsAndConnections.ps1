#Requires -Modules Microsoft.PowerApps.Administration.PowerShell, Microsoft.PowerApps.Checker.PowerShell, Microsoft.PowerApps.PowerShell

function Get-PowerPlatformAppsAndConnections {
    BEGIN {
        $environments=Get-AdminPowerAppEnvironment
        $powerAppsData=@()
    }
    PROCESS {
        foreach ($e in $environments) {
            $powerapps = Get-AdminPowerApp -EnvironmentName $e.EnvironmentName
            foreach ($pa in $powerapps) {
                $powerAppDatum = New-Object PSObject
                $powerAppDatum | Add-Member NoteProperty AppId($pa.AppName)
                $powerAppDatum | Add-Member NoteProperty AppName($pa.DisplayName)
                $powerAppDatum | Add-Member NoteProperty EnvironmentName($pa.EnvironmentName)
                $powerAppDatum | Add-Member NoteProperty LastModified($pa.LastModifiedTime)
                $powerAppDatum | Add-Member NoteProperty AppType($pa.Internal.appType)
                $powerAppDatum | Add-Member NoteProperty CreatedTime($pa.Internal.properties.createdTime)
                $powerAppDatum | Add-Member NoteProperty AppOwner($pa.Internal.properties.owner)
                $powerAppDatum | Add-Member NoteProperty AppVersion($pa.Internal.properties.appVersion)
                $powerAppDatum | Add-Member NoteProperty CanConsumeAppPass($pa.Internal.properties.canConsumeAppPass)
                $powerAppDatum | Add-Member NoteProperty AppPlanClassification($pa.Internal.properties.appPlanClassification)
                $powerAppDatum | Add-Member NoteProperty UsesPremiumApi($pa.Internal.properties.usesPremiumApi)
                $powerAppDatum | Add-Member NoteProperty UsesCustomApi($pa.Internal.properties.usesCustomApi)
                $powerAppDatum | Add-Member NoteProperty UsesOnPremiseGateway($pa.Internal.properties.usesOnPremiseGateway)
                $connectionReferenceNames=@()
                foreach ($cr in $pa.Internal.properties.connectionReferences) {
                    foreach ($conId in ($cr | Get-Member -MemberType NoteProperty).Name) {
                        $conDetails = $($cr.$conId)
                        $connectionReferenceNames+=$conDetails.displayName
                    } #foreach connection id in connection reference
                } #foreach connection reference
                $powerAppDatum | Add-Member NoteProperty connectionReferenceNames($connectionReferenceNames -join ",")
                $powerAppsData+=$powerAppDatum
            } #foreach powerapp
        } #foreach environment
    }
    END {
        return $powerAppsData
    }
}

<#

$outputFilelocation="C:\temp"
 
$environments = Get-AdminPowerAppEnvironment
$powerAppConnectionReferences=@()
$powerAppObjects=@()
$powerAppRoles=@()
 
foreach ($e in $environments) {
    write-host "Environment: " $e.displayname
    $powerapps = Get-AdminPowerApp -EnvironmentName $e.EnvironmentName
    foreach ($pa in $powerapps) {
        write-host "  App Name: " $pa.DisplayName " - " $pa.AppName
        $paObj=@{
            type="Power App"
            CanConsumeAppPasses=$app.Internal.properties.canConsumeAppPass
            UsesOnlyGrandfatheredPremiumAPIs=$app.Internal.properties.usesOnlyGrandfatheredPremiumApis
            UsesOnPremisesGateway=$app.Internal.properties.usesOnPremiseGateway
            UsesCustomAPI=$app.Internal.properties.usesCustomApi
            Environment=$e.displayname
            AppFlowName=$pa.AppName
            AppDisplayName=$pa.DisplayName
            createdDate=$pa.CreatedTime
            createdBy=$pa.Owner
            AppPlanClassification=$pa.Internal.properties.appPlanClassification
        }
        $powerAppObjects+=$(new-object psobject -Property $paObj)
        foreach ($role in (Get-AdminPowerAppRoleAssignment -AppName $pa.AppName -EnvironmentName $e.EnvironmentName)) {
            $paRoleObj=@{
                AppFlowName=$role.AppName
                RoleType=$role.RoleType
                PrincipalType=$role.PrincipalType
                PrincipalObjectId=$role.PrincipalObjectId
                PrincipalDisplayName=$role.PrincipalDisplayName
                PrincipalEmail=$role.PrincipalEmail
            }
            $powerAppRoles+=$(new-object psobject -Property $paRoleObj)
 
        } #foreach role
        foreach ($conRef in $pa.Internal.properties.connectionReferences) {
            foreach ($con in $conRef) {
                foreach ($conId in ($con | Get-Member -MemberType NoteProperty).Name) {
                    $conDetails = $($con.$conId)
                    $apiTier = $conDetails.apiTier
                    if ($conDetails.isCustomApiConnection) {$apiTier = "Premium (CustomAPI)"}
                    if ($conDetails.isOnPremiseConnection ) {$apiTier = "Premium (OnPrem)"}
                    Write-Host "    " $conDetails.displayName " (" $apiTier ")"
                    $paConnectionRefObj=@{
                        type="Power App"
                        ConnectionName=$conDetails.displayName
                        Tier=$apiTier
                        Environment=$e.displayname
                        AppFlowName=$pa.AppName
                    }
                    $powerAppConnectionReferences+=$(new-object psobject -Property $paConnectionRefObj)
                } #foreach $conId
            } #foreach $con
        } #foreach $conRef
    } #foreach power app
} #foreach environment
 
$powerAppConnectionReferences | Export-Csv "$outputFilelocation\powerAppConnectionReferences.csv" -NoTypeInformation
$powerAppObjects | Export-Csv "$outputFilelocation\powerAppObjects.csv" -NoTypeInformation
$powerAppRoles | Export-Csv "$outputFilelocation\powerAppRoles.csv" -NoTypeInformation 



$environments=Get-AdminPowerAppEnvironment

$powerapps = Get-AdminPowerApp -EnvironmentName $environments[0].EnvironmentName

$conRefs=Get-AdminPowerAppConnectionReferences -EnvironmentName $environments[0].EnvironmentName -AppName $powerapps[0].AppName
#>