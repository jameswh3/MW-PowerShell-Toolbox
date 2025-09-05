#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

function Get-PowerPlatformEnvironmentInfo {
    BEGIN {
        Add-PowerAppsAccount -Endpoint prod
        $environments=Get-AdminPowerAppEnvironment
        $environmentData=@()
    }
    PROCESS {
        foreach ($e in $environments) {
            #collect EnvironmentName, DisplayName, and EnvironmentType
            #todo - add Teams env or not
            $environmentDatum = New-Object PSObject
            $environmentDatum | Add-Member NoteProperty EnvironmentName($e.EnvironmentName)
            $environmentDatum | Add-Member NoteProperty EnvironmentDisplayName($e.DisplayName)
            $environmentDatum | Add-Member NoteProperty EnvironmentType($e.EnvironmentType)
            $environmentDatum | Add-Member NoteProperty EnvironmentUrl($e.Internal.Properties.linkedEnvironmentMetadata.instanceApiUrl)
            $environmentDatum | Add-Member NoteProperty BingChatEnabled($e.Internal.Properties.bingChatEnabled)
            $environmentDatum | Add-Member NoteProperty M365Enabled($e.Internal.Properties.M365Enabled)
            $environmentDatum | Add-Member NoteProperty CreationType($e.Internal.Properties.creationType)
            $environmentDatum | Add-Member NoteProperty IsDefault($e.Internal.Properties.isDefault)
            $environmentData+=$environmentDatum
        }
    }
    END {
        return $environmentData
    }
}