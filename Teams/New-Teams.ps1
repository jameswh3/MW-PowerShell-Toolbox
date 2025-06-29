param (
    [Parameter(Mandatory = $true)]
    [string[]]$TeamNames,
    [string]$Owner,
    [string[]]$Members
)

# Ensure MicrosoftTeams module is installed and imported
if (-not (Get-Module -ListAvailable -Name MicrosoftTeams)) {
    Install-Module -Name MicrosoftTeams -Force -Scope CurrentUser
}
Import-Module MicrosoftTeams

# Connect to Microsoft Teams
Write-Host "Connecting to Microsoft Teams..."
#Connect-MicrosoftTeams

foreach ($teamName in $TeamNames) {
    try {
        Write-Host "Creating Team: $teamName"
        $team = New-Team -DisplayName $teamName -Visibility Public -Owner $Owner -ErrorAction Stop
        Write-Host "Team '$teamName' created with GroupId: $($team.GroupId)"
        foreach ($member in $Members) {
            Add-TeamUser -GroupId $team.GroupId -User $member -Role Member
            Write-Host "Added member '$member' to team '$teamName'."
        }
    } catch {
        Write-Warning "Issue creating team '$teamName': $_"
    }
}

Write-Host "Team provisioning complete."