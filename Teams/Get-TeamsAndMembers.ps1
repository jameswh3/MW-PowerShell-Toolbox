# Requires MicrosoftTeams PowerShell module
# Install-Module -Name PowerShellGet -Force
# Install-Module -Name MicrosoftTeams -Force

# Connect to Microsoft Teams
Connect-MicrosoftTeams

# Get all Teams
$teams = Get-Team

# Prepare output array
$results = @()

foreach ($team in $teams) {
    Write-Host "Processing Team: $($team.DisplayName)"

    # Get Owners
    $owners = Get-TeamUser -GroupId $team.GroupId -Role Owner | Select-Object -ExpandProperty User
    # Get Members
    $members = Get-TeamUser -GroupId $team.GroupId -Role Member | Select-Object -ExpandProperty User

    $results += [PSCustomObject]@{
        TeamName = $team.DisplayName
        TeamId   = $team.GroupId
        Visibility = $team.Visibility
        Owners   = $owners -join ', '
        Members  = $members -join ', '
    }
}

# Output results to console
$results | Format-Table -AutoSize

# Optionally export to CSV
# $results | Export-Csv -Path "./TeamsAndMembers.csv" -NoTypeInformation