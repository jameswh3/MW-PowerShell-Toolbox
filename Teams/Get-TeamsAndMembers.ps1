# Requires MicrosoftTeams PowerShell module

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