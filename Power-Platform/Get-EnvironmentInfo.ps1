#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

function Get-PowerPlatformEnvironmentInfo {
    param (
        [string]$outputFilelocation = "C:\temp"
    )
    BEGIN {
        Add-PowerAppsAccount -Endpoint prod
        $environments=Get-AdminPowerAppEnvironment
        $environmentData=@()
    }
    PROCESS {
        foreach ($e in $environments) {
            #collect EnvironmentName, DisplayName, and EnvironmentType
            $environmentDatum = New-Object PSObject
            $environmentDatum | Add-Member NoteProperty EnvironmentName($e.EnvironmentName)
            $environmentDatum | Add-Member NoteProperty EnvironmentDisplayName($e.DisplayName)
            $environmentDatum | Add-Member NoteProperty EnvironmentType($e.EnvironmentType)
            $environmentData+=$environmentDatum
        }
    }
    END {
        return $environmentData
    }
}

Get-PowerPlatformEnvironmentInfo | Export-Csv -Path "$outputFilelocation\PowerPlatformEnvironmentInfo.csv" -NoTypeInformation -Force