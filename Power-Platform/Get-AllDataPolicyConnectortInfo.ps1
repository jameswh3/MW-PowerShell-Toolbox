#Requires -Modules Microsoft.PowerApps.Administration.PowerShell




function GetAllDataPolicyConnectorInfo {
    BEGIN {
        Add-PowerAppsAccount -Endpoint prod
        $environments=get-AdminPowerAppEnvironment
        $dataPolicies=Get-AdminDlpPolicy
        $dataPolicyData=@()
    }
    PROCESS {
        foreach ($dp in $dataPolicies) {
            #capture DisplayName, PolicyName, Constraints, and Environments
            $dataPolicyName = $dp.DisplayName
            $dataPolicyId = $dp.PolicyName

            #foreach environment in the policy, get the environment name and id
            $environments=$dp.Environments | Join-String -Property name -Separator ","

            #foreach connector in businessdatagroups, get the connector name and id and flag as business data group
            foreach ($bdp in $dp.BusinessDataGroup) {
                $dataPolicyDatum= New-Object PSObject
                $dataPolicyDatum | Add-Member NoteProperty PolicyName($dataPolicyName)
                $dataPolicyDatum | Add-Member NoteProperty PolicyId($dataPolicyId)
                $dataPolicyDatum | Add-Member NoteProperty Environments($environments)
                $dataPolicyDatum | Add-Member NoteProperty ConnectorName($bdp.Name)
                $dataPolicyDatum | Add-Member NoteProperty ConnectorId($bdp.Id)
                $dataPolicyDatum | Add-Member NoteProperty ConnectorType("Business Data Group")
                $dataPolicyData+=$dataPolicyDatum
            }
            #foreach connector in non-businessdatagroup, get the connector name and id and flag as business data group
            foreach ($bdp in $dp.NonBusinessDataGroup) {
                $dataPolicyDatum= New-Object PSObject
                $dataPolicyDatum | Add-Member NoteProperty PolicyName($dataPolicyName)
                $dataPolicyDatum | Add-Member NoteProperty PolicyId($dataPolicyId)
                $dataPolicyDatum | Add-Member NoteProperty Environments($environments)
                $dataPolicyDatum | Add-Member NoteProperty ConnectorName($bdp.Name)
                $dataPolicyDatum | Add-Member NoteProperty ConnectorId($bdp.Id)
                $dataPolicyDatum | Add-Member NoteProperty ConnectorType("Non Business Data Group")
                $dataPolicyData+=$dataPolicyDatum
            }
            #foreach connector in businessdatagroups, get the connector name and id and flag as business data group
            foreach ($bdp in $dp.BlockedGroup) {
                $dataPolicyDatum= New-Object PSObject
                $dataPolicyDatum | Add-Member NoteProperty PolicyName($dataPolicyName)
                $dataPolicyDatum | Add-Member NoteProperty PolicyId($dataPolicyId)
                $dataPolicyDatum | Add-Member NoteProperty Environments($environments)
                $dataPolicyDatum | Add-Member NoteProperty ConnectorName($bdp.Name)
                $dataPolicyDatum | Add-Member NoteProperty ConnectorId($bdp.Id)
                $dataPolicyDatum | Add-Member NoteProperty ConnectorType("Blocked")
                $dataPolicyData+=$dataPolicyDatum
            }
        }
    }
    END {
        return $dataPolicyData
    }
}

GetAllDataPolicyConnectorInfo | Export-Csv -Path "C:\temp\PowerPlatformDataPolicyConnectors.csv" -NoTypeInformation -Force